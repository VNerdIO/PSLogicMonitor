# Delete the script
Remove-Item -Path $MyInvocation.MyCommand.Source

Start-Transcript "$PSScriptRoot\Install-LM.log"
<# 
	Some setup
#>
$WorkFolder = "PsLm"+(New-Guid).Guid.substring(31,5)
$ThisHost = hostname
$PSScriptRoot
$DownloadPSLM = "https://github.com/VNerdIO/PSLogicMonitor/archive/master.zip"
$Destination = "$PSScriptRoot\$WorkFolder\PSLogicMonitor.zip"
$ExtractTo = "$PSScriptRoot\$WorkFolder"
$CreateDir = New-Item -ItemType Directory -Path "$PSScriptRoot\$WorkFolder"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

<# 
	Get PSLogicMonitor module
#>
Write-Output "[$(Get-Date -Format s)] Starting download"
try{
	Invoke-WebRequest -Uri $DownloadPSLM -OutFile $Destination
}
catch{
	Write-Error -Message $_.Exception.Message
	break
}
Write-Output "[$(Get-Date -Format s)] Download complete."

$ExtShell = New-Object -ComObject Shell.Application
$File = $ExtShell.Namespace($Destination).Items()
Write-Output "[$(Get-Date -Format s)] Starting extraction"
try{
	$ExtShell.Namespace($ExtractTo).CopyHere($File)
}
catch{
	Write-Error -Message $_.Exception.Message
	break
}
Write-Output "[$(Get-Date -Format s)] Extraction complete"

<#
	Load PSLogicMonitor module and create new collector
#>
Import-Module "$ExtractTo\PSLogicMonitor-master\PSLogicMonitor\PSLogicMonitor.psm1"

Write-Output "[$(Get-Date -Format s)] Creating Collector"
try{
	$Collector = New-LMCollector -Account "cspire" -AccessId "$AccessId" -AccessKey "$AccessKey" -Description "$ThisHost" -CollectorGroupId 8
	Write-Output "[$(Get-Date -Format s)] Created Collector $($Collector.Id)"
}
catch{
	Write-Error -Message $_.Exception.Message
	break
}

<# 
	Download the collector installer, try twice.
#>
try{
$err = $false
$i = 0
$ts1 = Get-Date
while(!$err -AND $i -lt 3){
	$i++
	Write-Output "[$(Get-Date -Format s)] Downloading Collector installer (Attempt $i)."
	$err = Get-LMCollectorInstaller -Account "cspire" -AccessId "$AccessId" -AccessKey "$AccessKey" -CollectorId $Collector.Id -CollectorSize "small" -Platform "Win64" -File "$ExtractTo\LM-Install.exe" -Verbose

	if(!$err){
		Write-Output "[$(Get-Date -Format s)] Waiting for 60 seconds before attempting again."	
		Start-Sleep 60
	}
}
	$ts2 = Get-Date
	$TimeSpan = New-TimeSpan -Start $ts1 -End $ts2
	if($err){
		Write-Output "[$(Get-Date -Format s)] Installer downloaded ($($TimeSpan.Minutes) minutes, $($TimeSpan.Seconds) seconds)."
	} else {
		Write-Output "[$(Get-Date -Format s)] Installer NOT downloaded successfully."
	}
}
catch{
	Write-Error -Message $_.Exception.Message
	break
}

<#
	Install the collector
#>
Write-Output "Did the LM Installer make it?"
if(Test-Path "$ExtractTo\LM-Install.exe"){
	Write-Output "[$(Get-Date -Format s)] Yes, it did. Running LM installer."
	Start-Process -FilePath "$ExtractTo\LM-Install.exe" -ArgumentList "/q"
} else {
	Write-Output "[$(Get-Date -Format s)] Nope, the installer didn't make it."
}

Start-Sleep 180

<#
	The collector (as a device) will have a very useful name of 127.0.0.1. This will clean that up.
#>
Write-Output "[$(Get-Date -Format s)] Cleaning up the self monitored collector name."
$Fields = @{}
$Fields.Add("name",$ThisHost)
$Fields.Add("displayName",$ThisHost)
$CollectorDevice = Get-LMCollectorDevices -Account "cspire" -CollectorId $Collector.Id
Update-LMDevice -Account "cspire" -DeviceId $CollectorDevice.id -Fields $Fields -Verbose
<#
	Clean-up
#>
Remove-Item $ExtractTo -Recurse

Stop-Transcript