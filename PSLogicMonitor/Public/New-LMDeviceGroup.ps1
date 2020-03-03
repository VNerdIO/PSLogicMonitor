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
        https://www.logicmonitor.com/support/rest-api-developers-guide/v1/device-groups/add-a-device-group/
#>
Function New-LMDeviceGroup{
	[CmdletBinding()]
	Param([string]
		  [Parameter(Mandatory=$true)]
          $Account,
          [string]
		  [Parameter(Mandatory=$true)]
		  $GroupName,
          [int]
		  [Parameter(Mandatory=$false)]
		  $ParentGroupId,
          [string]
		  [Parameter(Mandatory=$false)]
		  $Description,
          [bool]
		  [Parameter(Mandatory=$false)]
		  $DisableAlerting,
          [string]
		  [Parameter(Mandatory=$false)]
		  $AppliesTo,
          [string]
		  [Parameter(Mandatory=$false)]
		  $CustomProperties,
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
		$resourcePath = "/device/groups"

        if($ParentGroupId){ $Hashtable.Add("parentId",$ParentGroupId) }
        $Hashtable.Add("name",$GroupName)
        if($Description){ $Hashtable.Add("description",$Description) }
        if($DisableAlerting){ $Hashtable.Add("disableAlerting",$DisableAlerting) }
        if($AppliesTo){ $Hashtable.Add("appliesTo",$AppliesTo) }
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

