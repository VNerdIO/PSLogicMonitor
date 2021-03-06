<#
    .SYNOPSIS

    .DESCRIPTION

    .EXAMPLE
		Get-LMDeviceSDT -Account "company" -GroupName "Customer/Servers/DC1"

	.PARAMETER GroupName
		The easiest place to get this is pick a device in that group and look at the devices Info tab

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
Function Get-LMDeviceSDT{
	[CmdletBinding()]
	Param([string]
		  [Parameter(Mandatory=$true)]
		  $Account,
          [string]
		  [Parameter(Mandatory=$true)]
		  $DeviceName,
		  [string]
		  [Parameter(Mandatory=$false)]
		  $AccessId = $env:LMAPIAccessId,
		  [string]
		  [Parameter(Mandatory=$false)]
		  $AccessKey = $env:LMAPIAccessKey)
	
	begin{
        $DeviceDetails = Get-LMDeviceDetails -Account "$Account" -AccessId "$AccessId" -AccessKey "$AccessKey" -DeviceName "$DeviceName"
        $httpVerb = 'GET'
        $resourcePath = "/device/devices/$($DeviceDetails.id)/sdts"
        #$Query = "?filter=displayName:$DeviceName"
	}
	process{
		try{
            <# Make Request #>
            Write-Verbose "Getting SDTs..."
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

