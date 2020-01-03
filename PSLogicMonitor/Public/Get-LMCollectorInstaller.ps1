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
Function Get-LMCollectorInstaller{
	[CmdletBinding()]
	Param([string]
		  [Parameter(Mandatory=$true)]
          $Account,
          [int]
		  [Parameter(Mandatory=$true)]
		  $CollectorId,
          [string]
		  [Parameter(Mandatory=$true)]
          [ValidateSet("nano","small","medium","large")]
		  $CollectorSize,
          [string]
		  [Parameter(Mandatory=$true)]
          [ValidateSet("Win32","Win64","Linux32","Linux64")]
		  $Platform,
		  [string]
		  [Parameter(Mandatory=$false)]
		  $AccessId = $env:LMAPIAccessId,
		  [string]
		  [Parameter(Mandatory=$false)]
		  $AccessKey = $env:LMAPIAccessKey)
	
	begin{
		<# request details #>
		$httpVerb = "GET"
        $resourcePath = "/setting/collectors/$CollectorId/installers/$Platform"
        $Query = "?collectorSize=$CollectorSize"
	}
	process{
		try{
			<# Make Request #>
			$output = Invoke-LMQuery -Account "$Account" -AccessId "$AccessId" -AccessKey "$AccessKey" -Verb "$httpVerb" -Path "$resourcePath" -Query "$Query" -Stream

            Write-Output $output
		}
		catch{
			Write-Error $_.Exception.Message
		}
		finally{}
	}
	end{}
}

