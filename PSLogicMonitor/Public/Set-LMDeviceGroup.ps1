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
#>
Function Set-LMDeviceGroup{
	[CmdletBinding()]
	Param([string]
		  [Parameter(Mandatory=$true)]
          $Account,
          [string]
		  [Parameter(Mandatory=$true)]
          $DeviceName,
          [int]
		  [Parameter(Mandatory=$true)]
		  $GroupId,
		  [string]
		  [Parameter(Mandatory=$false)]
		  $AccessId = $env:LMAPIAccessId,
		  [string]
		  [Parameter(Mandatory=$false)]
		  $AccessKey = $env:LMAPIAccessKey)
	
	begin{
        <# request details #>
        try{
            Write-Verbose "Getting device details for $DeviceName"
            $DeviceDetails = Get-LMDeviceDetails -Account "$Account" -AccessId "$AccessId" -AccessKey "$AccessKey" -DeviceName "$DeviceName"
            $DeviceId = $DeviceDetails.id
        }
        catch{
            Write-Error $_.Exception.Message
        }

        if($DeviceDetails.hostGroupIds){
            $ids = "$($DeviceDetails.hostGroupIds),$GroupId"
            Write-Verbose "Setting hostGroupIds to $ids, original: $($DeviceDetails.hostGroupIds) for DeviceId: $DeviceId"
        }

		$httpVerb = "PATCH"
        $resourcePath = "/device/devices/$DeviceId"
        $Query = "?patchFields=hostGroupIds"
		$Data = '{"hostGroupIds":'+$ids+'}'
	}
	process{
		try{
			<# Make Request #>
			$output = Invoke-LMQuery -Account "$Account" -AccessId "$AccessId" -AccessKey "$AccessKey" -Verb "$httpVerb" -Path "$resourcePath" -Query "$Query" -Data $Data

			Write-Output $output
		}
		catch{
			Write-Error $_.Exception.Message
		}
		finally{}
	}
	end{}
}

