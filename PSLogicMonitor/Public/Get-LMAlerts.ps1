<#
    .SYNOPSIS

    .DESCRIPTION

    .EXAMPLE

    .PARAMETER
    
    .OUTPUTS

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

