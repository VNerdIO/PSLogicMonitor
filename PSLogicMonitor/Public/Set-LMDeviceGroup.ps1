<#
    .SYNOPSIS
		Adds a device to a device group

    .DESCRIPTION
		Adds a device to a group. Retains the existing groups.

    .EXAMPLE
		Set-LMDeviceGroup -Account "company" -DeviceName "device123.domain.local" -GroupId 997

	.PARAMETER DeviceName
		The Name of the device you want to add to a certain group.

	.PARAMETER GroupId
		The GroupId you want the device added to. On the Info page for the Group, system.deviceGroupId
		
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
			Write-Verbose "hostGroupIds for $DeviceName ($DeviceId): $($DeviceDetails.hostGroupIds)"
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
		$Data = '{"hostGroupIds":"'+$ids+'"}'
	}
	process{
		try{
			<# Make Request #>
			$output = Invoke-LMQuery -Account "$Account" -AccessId "$AccessId" -AccessKey "$AccessKey" -Verb "$httpVerb" -Path "$resourcePath" -Query "$Query" -Data $Data

			if( !(Compare-Object -ReferenceObject @($output.hostGroupIds) -DifferenceObject @($ids)) ){
				Write-Output $true
			} else {
				Write-Error "hostGroupIds $($output.hostGroupIds) does not equal $ids"
				Write-Output $false
			}
		}
		catch{
			Write-Error $_.Exception.Message
		}
		finally{}
	}
	end{}
}

