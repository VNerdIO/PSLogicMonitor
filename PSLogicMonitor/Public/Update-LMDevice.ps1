<#
    .SYNOPSIS

    .DESCRIPTION

	.EXAMPLE
		Only these fields can be updated: "name","displayName","preferredCollectorId","hostGroupIds","description","disableAlerting","link","enableNetflow","netflowCollectorId","customProperties"
		1. Create a hashtable with the fields you want to update:
		$Fields = @{}
		$Fields.add("name","MyServer1")
		Update-LMDevice -Account "COMPANY" -DeviceId $DeviceId -Fields $Fields
    .PARAMETER Account
		Your LogicMonitor account (e.g. company.logicmonitor.com. company is the account)

	.PARAMETER AccessId
		Generated in LogicMonitor Settings. Only available upon generation, store it securely.

	.PARAMETER AccessKey
		Generated in LogicMonitor Settings. Store is securely.
    
    .OUTPUTS

    .NOTES

    .LINK
    https://www.logicmonitor.com/support/rest-api-developers-guide/v1/devices/update-a-device/
#>
Function Update-LMDevice{
	[CmdletBinding()]
	Param([string]
		  [Parameter(Mandatory=$true)]
		  $Account,
          [int]
		  [Parameter(Mandatory=$true)]
		  $DeviceId,
		  [Parameter(Mandatory=$true)]
		  $Fields,
		  [string]
		  [Parameter(Mandatory=$false)]
		  $AccessId = $env:LMAPIAccessId,
		  [string]
		  [Parameter(Mandatory=$false)]
		  $AccessKey = $env:LMAPIAccessKey)
	
	begin{
		<# request details #>
		$httpVerb = "PATCH"
		$resourcePath = "/device/devices/$DeviceId"
		$QueryFields = $Fields.Keys -join ","
		$Query = "?patchFields=$QueryFields"
	}
	process{
		try{
			$Json = ((ConvertTo-Json -Compress -InputObject $Fields -Verbose) | Out-String).Trim()
			$DataJson = $Json.ToString()
			Write-Verbose "Json: $DataJson"
			<# Make Request #>
			$output = Invoke-LMQuery -Account "$Account" -AccessId "$AccessId" -AccessKey "$AccessKey" -Verb "$httpVerb" -Path "$resourcePath" -Data "$DataJson" -Query "$Query"

			if($output.errmsg){
				Write-Output $false
			} else {
				Write-Output $output
			}
		}
		catch{
			Write-Error $_.Exception.Message
		}
		finally{}
	}
	end{}
}

