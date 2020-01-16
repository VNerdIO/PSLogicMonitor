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
    https://www.logicmonitor.com/support/rest-api-developers-guide/v1/users/get-users/
#>
Function Get-LMUsers{
	[CmdletBinding()]
	Param([string]
		  [Parameter(Mandatory=$true)]
		  $Account,
		  [int]
		  [Parameter(Mandatory=$false)]
		  $UserId,
		  [string]
		  [Parameter(Mandatory=$false)]
		  $AccessId = $env:LMAPIAccessId,
		  [string]
		  [Parameter(Mandatory=$false)]
		  $AccessKey = $env:LMAPIAccessKey)
	
	begin{
		<# request details #>
		$httpVerb = "GET"
        if($UserId){
            $resourcePath = "/setting/admins/$UserId"
        } else {
		    $resourcePath = "/setting/admins"
        }
        $Query = "?size=1000"

	}
	process{
		try{
			<# Make Request #>
			$output = Invoke-LMQuery -Account "$Account" -AccessId "$AccessId" -AccessKey "$AccessKey" -Verb "$httpVerb" -Path "$resourcePath" -Query "$Query"

            if($UserId){
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

