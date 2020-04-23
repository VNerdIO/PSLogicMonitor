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
        https://www.logicmonitor.com/support/rest-api-developers-guide/v1/devices/add-a-device
#>
Function New-LMDevice{
	[CmdletBinding()]
	Param([string]
		  [Parameter(Mandatory=$true)]
          $Account,
          [string]
		  [Parameter(Mandatory=$true)]
		  $Name,
          [string]
		  [Parameter(Mandatory=$true)]
		  $DisplayName,
          [int]
		  [Parameter(Mandatory=$true)]
		  $PreferredCollectorId,
          [string]
		  [Parameter(Mandatory=$false)]
		  $HostGroupIds,
          [string]
		  [Parameter(Mandatory=$false)]
		  $Description,
          [bool]
		  [Parameter(Mandatory=$false)]
		  $DisableAlerting,
		  [string]
		  [Parameter(Mandatory=$false)]
		  $AccessId = $env:LMAPIAccessId,
		  [string]
		  [Parameter(Mandatory=$false)]
		  $AccessKey = $env:LMAPIAccessKey)
	
	begin{
        <# request details #>
        $Hashtable = @{}
		$httpVerb = "POST"
		$resourcePath = "/device/devices"

        if($ParentGroupId){ $Hashtable.Add("parentId",$ParentGroupId) }
        $Hashtable.Add("name",$Name)
		$Hashtable.Add("displayName",$DisplayName)
		$Hashtable.Add("preferredCollectorId",$PreferredCollectorId)
		$Hashtable.Add("name",$GroupName)
		if($hostGroupIds){ $Hashtable.Add("hostGroupIds",$HostGroupIds) }
        if($Description){ $Hashtable.Add("description",$Description) }
        if($DisableAlerting){ $Hashtable.Add("disableAlerting",$DisableAlerting) }
        if($CustomProperties){ $Hashtable.Add("customProperties",$CustomProperties) }

        $Data = $Hashtable | ConvertTo-Json -Compress

        Write-Verbose $Data
	}
	process{
		try{
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

