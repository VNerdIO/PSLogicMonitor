<#
    .SYNOPSIS

    .DESCRIPTION

    .EXAMPLE

    .PARAMETER
    
    .OUTPUTS

    .NOTES

    .LINK
#>
Function Get-LMCollectorDevices{
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
		$httpVerb = "GET"
		$resourcePath = "/device/devices"
		$Query = "?filter=currentCollectorId:$CollectorId"
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

