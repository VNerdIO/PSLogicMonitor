<#
    .SYNOPSIS

    .DESCRIPTION

    .EXAMPLE

    .PARAMETER
    
    .OUTPUTS

    .NOTES

    .LINK
#>
Function Remove-LMCollector{
	[CmdletBinding()]
	Param([string]
		  [Parameter(Mandatory=$true)]
		  $Account,
		  [int]
		  [Parameter(Mandatory=$true)]
		  $CollectorId,
		  [string]
		  [Parameter(Mandatory=$false)]
		  $AccessId = $env:LMAPIAccessId,
		  [string]
		  [Parameter(Mandatory=$false)]
		  $AccessKey = $env:LMAPIAccessKey)
	
		begin{
			<# request details #>
			$httpVerb = 'DELETE'
			$resourcePath = "/setting/collectors/$CollectorId"
		}
		process{
			try{
				<# Make Request #>
				Invoke-LMQuery -Account "$Account" -AccessId "$AccessId" -AccessKey "$AccessKey" -Verb "$httpVerb" -Path "$resourcePath"
			}
			catch{
				Write-Error $_.Exception.Message
			}
			finally{}
		}
		end{}
}

