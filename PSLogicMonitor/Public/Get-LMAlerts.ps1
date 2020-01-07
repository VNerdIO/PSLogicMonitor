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
	https://www.logicmonitor.com/support/rest-api-developers-guide/v1/alerts/get-alerts/
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
		  $AccessKey = $env:LMAPIAccessKey,
		  [switch]
		  [Parameter(Mandatory=$false)]
		  $AlertDetails,
		  [string]
		  [Parameter(Mandatory=$false)]
		  [ValidateSet("Warning","Error","Critical")]
		  $Severity)
	
	begin{
		switch($Severity){
			"Warning"{ $Sev = "&filter=severity:2" }
			"Error"{ $Sev = "&filter=severity:3" }
			"Critical"{ $Sev = "&filter=severity:4" }
			Default{ $Sev = "" }
		}

		<# request details #>
		$httpVerb = 'GET'
		$resourcePath = '/alert/alerts'
		if($AlertDetails){
			$Query = "?size=1000$Sev&needMessage=true"
		} else {
			$Query = "?size=1000$Sev"
		}

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
				if($AlertDetails){
					$Query = "?size=1000$Sev&needMessage=true&offset=$offset"
				} else {
					$Query = "?size=1000$Sev&offset=$offset"
				}
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

