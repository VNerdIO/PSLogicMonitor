<#
    .SYNOPSIS

    .DESCRIPTION

    .EXAMPLE

    .PARAMETER Account
		Your LogicMonitor account (e.g. company.logicmonitor.com. company is the account)

	.PARAMETER AccessId
		Generated in LogicMonitor Settings. Only available upon generation, store it securely.

	.PARAMETER AccessKey
		Generated in LogicMonitor Settings. Store is securely.
    
    .OUTPUTS

    .NOTES

    .LINK
#>
Function Get-LMEscalationChains{
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
		  [int]
		  [Parameter(Mandatory=$false)]
		  $EscalationChainId)
	
	begin{
		<# request details #>
		$httpVerb = 'GET'
		$resourcePath = '/setting/alert/chains'
		$Query = "?size=1000"
	}
	process{
		try{
			<# Make Request #>
			$output = Invoke-LMQuery -Account "$Account" -AccessId "$AccessId" -AccessKey "$AccessKey" -Verb "$httpVerb" -Path "$resourcePath" -Query "$Query"

			Write-Output $output.items
		}
		catch{
			Write-Error $_.Exception.Message
		}
		finally{}
	}
	end{}
}

