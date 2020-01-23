<#
    .SYNOPSIS
		Executes the queries for the other Cmdlets

    .DESCRIPTION
		This script is used by all the other scripts to execute queries against the API
		
    .EXAMPLE
		Not called directly, only called by public Cmdlets

    .PARAMETER Account
		Your LogicMonitor account (e.g. company.logicmonitor.com. company is the account)

	.PARAMETER AccessId
		Generated in LogicMonitor Settings. Only available upon generation, store it securely.

	.PARAMETER AccessKey
		Generated in LogicMonitor Settings. Store is securely.
    
    .OUTPUTS
		Results of the query in a Powershell object
		
    .NOTES

    .LINK
#>
Function Invoke-LMQuery{
	[CmdletBinding()]
	Param([string]
		  [Parameter(Mandatory=$true)]
          $Account,
          [string]
		  [Parameter(Mandatory=$true)]
		  [ValidateSet("GET","PUT","PATCH","POST","DELETE")]
          $Verb,
          [string]
		  [Parameter(Mandatory=$true)]
          $Path,
          [string]
		  [Parameter(Mandatory=$false)]
		  $Query,
		  [string]
		  [Parameter(Mandatory=$false)]
		  $Data,
		  [string]
		  [Parameter(Mandatory=$false)]
		  $File,
		  [string]
		  [Parameter(Mandatory=$false)]
		  [ValidateSet("application/json","application/binary")]
		  $ContentType = "application/json",
		  [string]
		  [Parameter(Mandatory=$false)]
		  $AccessId = $env:LMAPIAccessId,
		  [string]
		  [Parameter(Mandatory=$false)]
		  $AccessKey = $env:LMAPIAccessKey)
	
	begin{
		<# Use TLS 1.2 #>
		[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

		<# request details #>
		$httpVerb = $Verb
		$resourcePath = $Path

        <# Construct URL #>
        $url = 'https://' + $Account + '.logicmonitor.com/santaba/rest' + $resourcePath + $Query

		<# Get current time in milliseconds #>
		$epoch = [Math]::Round((New-TimeSpan -start (Get-Date -Date "1/1/1970") -end (Get-Date).ToUniversalTime()).TotalMilliseconds)

		<# Concatenate Request Details #>
		Write-Verbose "Verb:$httpVerb Epoch:$epoch Data:$Data resourcePath:$resourcePath"
		$requestVars = $httpVerb + $epoch + $Data + $resourcePath

		<# Construct Signature #>
		$hmac = New-Object System.Security.Cryptography.HMACSHA256
		$hmac.Key = [Text.Encoding]::UTF8.GetBytes($AccessKey)
		$signatureBytes = $hmac.ComputeHash([Text.Encoding]::UTF8.GetBytes($requestVars))
		$signatureHex = [System.BitConverter]::ToString($signatureBytes) -replace '-'
		$signature = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($signatureHex.ToLower()))

		<# Construct Headers #>
		$auth = 'LMv1 ' + $AccessId + ':' + $signature + ':' + $epoch
		$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
		$headers.Add("Authorization",$auth)
		$headers.Add("Content-Type",'application/json')
	}
	process{
		try{
			<# Make Request #>
			if($Data){
				Write-Verbose "Url: $url, Method: $Verb, Header: $headers, Body: $Data"
				Write-Verbose "Running... Invoke-RestMethod -Uri $url -Method $Verb -Header $headers -Body $Data -ContentType $ContentType -Outfile $File"
				$response = Invoke-RestMethod -Uri "$url" -Method "$Verb" -Header $headers -Body "$Data" -ContentType "$ContentType" -Outfile "$File"
			} else {
				Write-Verbose "Url: $url, Method: $Verb, Header: $headers"
				Write-Verbose "Running... Invoke-RestMethod -Uri $url -Method $Verb -Header $headers -ContentType $ContentType -Outfile $File"
				$response = Invoke-RestMethod -Uri "$url" -Method "$Verb" -Header $headers -ContentType "$ContentType" -Outfile "$File"
			}

			<# Print status and body of response #>
			if($response.data){
				Write-Verbose "response.data results"
				$body = $response.data | ConvertTo-Json -Depth 10
				Write-Output (ConvertFrom-Json $body)
			} elseif($response) {
				Write-Verbose "response results"
				$body = $response | ConvertTo-Json -Depth 10
				Write-Output (ConvertFrom-Json $body)
			} else {
				Write-Verbose "no news is good news? results"
				Write-Output $true
			}
		}
		catch{
			Write-Error $_.Exception.Message
		}
		finally{}
	}
	end{}
}

