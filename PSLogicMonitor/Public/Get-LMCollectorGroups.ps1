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
Function Get-LMCollectorGroups{
	[CmdletBinding()]
	Param([string]
		  [Parameter(Mandatory=$true)]
          $Account,
          [int]
		  [Parameter(Mandatory=$false)]
		  $CollectorGroupId,
		  [string]
		  [Parameter(Mandatory=$false)]
		  $AccessId = $env:LMAPIAccessId,
		  [string]
		  [Parameter(Mandatory=$false)]
		  $AccessKey = $env:LMAPIAccessKey)
	
	begin{
		<# request details #>
		$httpVerb = "GET"
        if($CollectorGroupId){
            $resourcePath = "/setting/collectors/groups/$CollectorGroupId"
        } else {
            $resourcePath = "/setting/collectors/groups"
        }
	}
	process{
		try{
			<# Make Request #>
			$output = Invoke-LMQuery -Account "$Account" -AccessId "$AccessId" -AccessKey "$AccessKey" -Verb "$httpVerb" -Path "$resourcePath"

            if($CollectorGroupId){
                Write-Output $output
            } else {
                Write-Output $output.items
            }

		}
		catch{
			Write-Error $_.Exception.Message
		}
		finally{}
	}
	end{}
}

