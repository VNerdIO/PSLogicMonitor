<#
    .SYNOPSIS
		Get all LogicMonitor alerts.

    .DESCRIPTION
		Get all LogicMonitor alerts. If there are >= 1000 alerts, will do a while loop to get them all.

    .EXAMPLE
		$Alerts = Get-LMAlerts -Account "account"

	.PARAMETER Account
		Your LogicMonitor account (e.g. company.logicmonitor.com. company is the account)

	.PARAMETER AccessId
		Generated in LogicMonitor Settings. Only available upon generation, store it securely.

	.PARAMETER AccessKey
		Generated in LogicMonitor Settings. Store is securely.
		
    .OUTPUTS
		Output an array of alerts

    .NOTES

    .LINK
#>
Function Get-LMDatasourceInstances{
	[CmdletBinding()]
	Param([string]
		  [Parameter(Mandatory=$true)]
		  $Account,
          [string]
		  [Parameter(Mandatory=$true)]
		  $DeviceName,
          [string]
		  [Parameter(Mandatory=$true)]
		  $DatasourceId,
		  [string]
		  [Parameter(Mandatory=$false)]
		  $AccessId = $env:LMAPIAccessId,
		  [string]
		  [Parameter(Mandatory=$false)]
		  $AccessKey = $env:LMAPIAccessKey)
	
	begin{
		<# request details #>
		$DeviceDetails = Get-LMDeviceDetails -Account "$Account" -AccessId "$AccessId" -AccessKey "$AccessKey" -DeviceName "$DeviceName"
		$httpVerb = 'GET'
		$resourcePath = "/device/devices/$($DeviceDetails.id)/devicedatasources/$DatasourceId/instances"
		$Query = "?size=50"
	}
	process{
		try{
			<# Make Request #>
			$bucket = @()
			$output = Invoke-LMQuery -Account "$Account" -AccessId "$AccessId" -AccessKey "$AccessKey" -Verb "$httpVerb" -Path "$resourcePath" -Query "$Query"
			$bucket += $output.items
			$i = 0
			while($output.items.count -eq 50){
				$i++
				$offset = $i * 50
				Write-Verbose $offset
				$Query = "?size=50&offset=$offset"
				$output = Invoke-LMQuery -Account "$Account" -AccessId "$AccessId" -AccessKey "$AccessKey" -Verb "$httpVerb" -Path "$resourcePath" -Query "$Query"
				$bucket += $output.items
			}

			Write-Output $bucket
		}
		catch{
			Write-Error $_.Exception.Message
		}
		finally{}
	}
	end{}
}

