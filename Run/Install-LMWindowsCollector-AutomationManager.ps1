<# 
	Some setup
#>
$WorkFolder = "PsLm"+(New-Guid).Guid.substring(31,5)
$ThisHost = hostname
$Root = (Get-Location).Path
$DownloadPSLM = "https://github.com/VNerdIO/PSLogicMonitor/archive/master.zip"
$Destination = "$Root\$WorkFolder\PSLogicMonitor.zip"
$ExtractTo = "$Root\$WorkFolder"
$CreateDir = New-Item -ItemType Directory -Path "$Root\$WorkFolder"
$AccessId = "ET3cJkn5AJK6W3W26L28"
$AccessKey = "+kkQ68p8P~U8uu(Hu+U)5PIUy(yK3d5q2fKc8DD{"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Start-Transcript "$Root\Install-LM.log"
<# 
	Get PSLogicMonitor module
#>
Write-Output "[$(Get-Date -Format s)] Starting PSLogicMonitor download"
try{
	Invoke-WebRequest -Uri $DownloadPSLM -OutFile $Destination
}
catch{
	Write-Error -Message $_.Exception.Message
	break
}
Write-Output "[$(Get-Date -Format s)] PSLogicMonitor Download complete."

$ExtShell = New-Object -ComObject Shell.Application
$File = $ExtShell.Namespace($Destination).Items()
Write-Output "[$(Get-Date -Format s)] Starting extraction of PSLogicMonitor"
try{
	$ExtShell.Namespace($ExtractTo).CopyHere($File)
}
catch{
	Write-Error -Message $_.Exception.Message
	break
}
Write-Output "[$(Get-Date -Format s)] PSLogicMonitor Extraction complete"

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
		exit 1
	}
}
catch{
	Write-Error -Message $_.Exception.Message
	exit 1
}

<#
	Install the collector
#>
Write-Output "[$(Get-Date -Format s)] Did the LM Installer make it?"
if(Test-Path "$ExtractTo\LM-Install.exe"){
	Write-Output "[$(Get-Date -Format s)] Yes, it did. Running LM installer."
	Start-Process -FilePath "$ExtractTo\LM-Install.exe" -ArgumentList "/q"
} else {
	Write-Output "[$(Get-Date -Format s)] Nope, the installer didn't make it."
	exit 1
}

$done = $false
$i = 0
while(!$done -AND $i -lt 3){
	$i++
	Write-Output "[$(Get-Date -Format s)] Waiting 3 minutes for the install to complete."
	Start-Sleep 180
	
	if(Get-LMCollectorDevices -Account "cspire" -CollectorId $Collector.Id){
		$done = $true
		Write-Output "[$(Get-Date -Format s)] Install is wrapped up."
	} elseif($i -gt 2){
		Write-Output "[$(Get-Date -Format s)] Install is not done, quitting."
		exit 1
	}
}

<#
	The collector (as a device) will have a very useful name of 127.0.0.1. This will clean that up.
#>
Write-Output "[$(Get-Date -Format s)] Cleaning up the self monitored collector name."
$Fields = @{}
$Fields.Add("name",$ThisHost)
$Fields.Add("displayName",$ThisHost)
$CollectorDevice = Get-LMCollectorDevices -Account "cspire" -CollectorId $Collector.Id
if($Update = Update-LMDevice -Account "cspire" -DeviceId $CollectorDevice.id -Fields $Fields -Verbose){
	Write-Output "[$(Get-Date -Format s)] Name/displayName updated."
} else {
	Write-Output "[$(Get-Date -Format s)] Name/displayName was NOT updated."
	exit 1
}
<#
	Clean-up
#>
Remove-Item $ExtractTo -Recurse

Stop-Transcript