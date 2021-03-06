Add-Type -AssemblyName System.Web

$currentServerName = $env:computername
Write-Host $currentServerName

$csvPath = $PSScriptRoot + '\ServerConfig.csv';
$csvObjects = Import-CSV $csvPath;
$serverObject = $csvObjects | Where { $_.ServerName -eq $currentServerName}
If ($serverObject) {
    $serverName =  $serverObject.ServerName;
    $hospitalID =  $serverObject.HospitalId;
    $connectionString =  $serverObject.ConnectionString;
}
Else {
    Write-Host "variable is null" 
}

$webConfigPath = 'C:\inetpub\cosmosdb.webapi\Web.config'
$webConfig = (Get-Content $webConfigPath) -as [Xml]


$appSettingHospitalID = $webConfig.configuration.appSettings.add | where {$_.Key -eq 'HospitalID'}
if($appSettingHospitalID) {
    $appSettingHospitalID.value = $hospitalID;
}
else {
    $newAppSetting = $webConfig.CreateElement("add")
    $webConfig.configuration.appSettings.AppendChild($newAppSetting)
    $newAppSetting.SetAttribute("key","HospitalID");
    $newAppSetting.SetAttribute("value",$hospitalID);
}

$appSettingServerName = $webConfig.configuration.appSettings.add | where {$_.Key -eq 'ServerName'}
if($appSettingServerName) {
    $appSettingServerName.value = $serverName;
}
else {
    $newAppSetting = $webConfig.CreateElement("add")
    $webConfig.configuration.appSettings.AppendChild($newAppSetting)
    $newAppSetting.SetAttribute("key","ServerName");
    $newAppSetting.SetAttribute("value",$serverName);
}

$task1Msg = $env:OutputVar

if ($task1Msg)
{
	Write-Output "Value of the message is set and equals to $task1Msg"
}
else
{
	Write-Output "Value of the message is not set."
}

<#
$appSettingKVHospitalID = $webConfig.configuration.appSettings.add | where {$_.Key -eq 'KeyValutHospitalID'}
if($appSettingKVHospitalID) {
    $appSettingKVHospitalID.value = $(hospitalid);
}
else {
    $newAppSetting = $webConfig.CreateElement("add")
    $webConfig.configuration.appSettings.AppendChild($newAppSetting)
    $newAppSetting.SetAttribute("key","KeyValutHospitalID");
    $newAppSetting.SetAttribute("value",$(hospitalid));
}
#>
$webConfig.Save($webConfigPath)