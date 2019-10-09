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
Function Get-LMAlerts{
	[CmdletBinding()]
	Param([string]
		  [Parameter(Mandatory=$true)]
		  $Account,
		  [string]
		  [Parameter(Mandatory=$false)]
		  $AccessId = $env:LMAPIAccessId,
		  [string]
		  [Parameter(Mandatory=$false)]
		  $AccessKey = $env:LMAPIAccessKey)
	
	begin{
		<# request details #>
		$httpVerb = 'GET'
		$resourcePath = '/alert/alerts'
		$Query = "?size=1000"
	}
	process{
		try{
			<# Make Request #>
			$bucket = @()
			$output = Invoke-LMQuery -Account "$Account" -AccessId "$AccessId" -AccessKey "$AccessKey" -Verb "$httpVerb" -Path "$resourcePath" -Query "$Query"
			$bucket += $output.items
			$i = 0
			while($output.items.count -eq 1000){
				$i++
				$offset = $i * 1000
				Write-Verbose $offset
				$Query = "?size=1000&offset=$offset"
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

