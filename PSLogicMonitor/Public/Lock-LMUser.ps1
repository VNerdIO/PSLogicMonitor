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
    https://www.logicmonitor.com/support/rest-api-developers-guide/v1/users/update-users/
#>
Function Lock-LMUser{
	[CmdletBinding()]
	Param([string]
		  [Parameter(Mandatory=$true)]
		  $Account,
          [int]
		  [Parameter(Mandatory=$true)]
		  $UserId,
		  [string]
		  [Parameter(Mandatory=$false)]
		  $AccessId = $env:LMAPIAccessId,
		  [string]
		  [Parameter(Mandatory=$false)]
		  $AccessKey = $env:LMAPIAccessKey)
	
	begin{
		<# request details #>
		$httpVerb = "PUT"
		$resourcePath = "/setting/admins/$UserId"
	}
	process{
		try{
			$User = Get-LMUsers -Account "$Account" -AccessID "$AccessId" -AccessKey "$AccessKey" -UserId $UserId
			$Roles = $User.roles | Select-Object name
			$RolesJson = $Roles | ConvertTo-Json -Compress
			$Data = $User | Select-Object username,contactMethod,firstName,lastName,phone,smsEmail,note,smsEmailFormat,forcePasswordChange,viewPermission,acceptEULA,twoFAEnabled,email,@{n="roles";e={$RolesJson}},@{n="status";e={"suspended"}} | ConvertTo-Json -Compress
			# Dumb fix for the way LM API expects to see the roles
			$Data = ($Data -replace '"{','[{') -replace '}"','}]'
			$Data = $Data -replace "\\"

			<# Make Request #>
			$output = Invoke-LMQuery -Account "$Account" -AccessId "$AccessId" -AccessKey "$AccessKey" -Verb "$httpVerb" -Path "$resourcePath" -Data "$Data"

			Write-Output $output
		}
		catch{
			Write-Error $_.Exception.Message
		}
		finally{}
	}
	end{}
}

