# Delete the script
Remove-Item -Path $MyInvocation.MyCommand.Source

Start-Transcript "$PSScriptRoot\Install-LM.log"
# Some setup
$WorkFolder = "PsLm"+(New-Guid).Guid.substring(31,5)
$ThisHost = hostname
$PSScriptRoot
$DownloadPSLM = "https://github.com/VNerdIO/PSLogicMonitor/archive/master.zip"
$Destination = "$PSScriptRoot\$WorkFolder\PSLogicMonitor.zip"
$ExtractTo = "$PSScriptRoot\$WorkFolder"
$CreateDir = New-Item -ItemType Directory -Path "$PSScriptRoot\$WorkFolder"
$AccessId = "ET3cJkn5AJK6W3W26L28"
$AccessKey = "+kkQ68p8P~U8uu(Hu+U)5PIUy(yK3d5q2fKc8DD{"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Get PSLogicMonitor
Write-Output "Starting download"
try{
	$ts1 = Get-Date
	Invoke-WebRequest -Uri $DownloadPSLM -OutFile $Destination
	$ts2 = Get-Date
}
catch{
	Write-Error -Message $_.Exception.Message
	break
}
$TimeSpan = New-TimeSpan -Start $ts1 -End $ts2
Write-Output "Download complete ($($TimeSpan.Minutes) minutes, $($TimeSpan.Seconds) seconds)"

$ExtShell = New-Object -ComObject Shell.Application
$File = $ExtShell.Namespace($Destination).Items()
Write-Output "Starting extraction"
try{
	$ExtShell.Namespace($ExtractTo).CopyHere($File)
}
catch{
	Write-Error -Message $_.Exception.Message
	break
}
Write-Output "Extraction complete"

# Load PSLogicMonitor module
Import-Module "$ExtractTo\PSLogicMonitor-master\PSLogicMonitor\PSLogicMonitor.psm1"

Write-Output "Creating Collector"
try{
	$Collector = New-LMCollector -Account "cspire" -AccessId "$AccessId" -AccessKey "$AccessKey" -Description "$ThisHost" -CollectorGroupId 8
	Write-Output "Created Collector $($Collector.Id)"
}
catch{
	Write-Error -Message $_.Exception.Message
	break
}

# Download the collector installer, try twice.
try{
$err = $false
$i = 0

while(!$err -AND $i -lt 3){
	$i++
	Write-Output "Downloading Collector installer (Attempt $i)."
	$err = Get-LMCollectorInstaller -Account "cspire" -AccessId "$AccessId" -AccessKey "$AccessKey" -CollectorId $Collector.Id -CollectorSize "small" -Platform "Win64" -File "$ExtractTo\LM-Install.exe" -Verbose

	if(!$err){
		Write-Output "Waiting for 60 seconds before attempting again."	
		Start-Sleep 60
	}
}
	if($err){
		Write-Output "Installer downloaded."
	} else {
		Write-Output "Installer NOT downloaded successfully."
	}
}
catch{
	Write-Error -Message $_.Exception.Message
	break
}

Write-Output "Did the LM Installer make it?"
if(Test-Path "$ExtractTo\LM-Install.exe"){
	Write-Output "Running LM installer."
	Start-Process -FilePath "$ExtractTo\LM-Install.exe" -ArgumentList "/q"
} else {
	Write-Output "Looks like the installer didn't make it."
}

Start-Sleep 180

Remove-Item $ExtractTo -Recurse

Stop-Transcript