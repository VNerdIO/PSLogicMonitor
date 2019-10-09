<#
    .SYNOPSIS

    .DESCRIPTION

    .EXAMPLE

    .PARAMETER
    
    .OUTPUTS

    .NOTES

    .LINK
#>
Function Get-LMDeviceGroup{
	[CmdletBinding()]
	Param([string]
		  [Parameter(Mandatory=$true)]
          $Account,
          [string]
		  [Parameter(Mandatory=$true)]
		  $GroupName,
		  [string]
		  [Parameter(Mandatory=$false)]
		  $AccessId = $env:LMAPIAccessId,
		  [string]
		  [Parameter(Mandatory=$false)]
		  $AccessKey = $env:LMAPIAccessKey)
	
	begin{
        <# request details #>
        #$GroupName = [uri]::EscapeDataString($GroupName)
		$httpVerb = "GET"
		$resourcePath = "/device/groups"
		$Query = "?filter=fullPath:$GroupName"
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

