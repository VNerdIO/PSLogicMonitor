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
Function Get-LMDeviceData{
	[CmdletBinding()]
	Param([string]
		  [Parameter(Mandatory=$true)]
		  $Account,
		  [string]
		  [Parameter(Mandatory=$false)]
		  $AccessId = $env:LMAPIAccessId,
		  [string]
		  [Parameter(Mandatory=$false)]
		  $AccessKey = $env:LMAPIAccessKey,
          [string]
		  [Parameter(Mandatory=$true)]
		  $DeviceName,
          [string]
		  [Parameter(Mandatory=$true)]
		  $Datasource,
          [string]
		  [Parameter(Mandatory=$true)]
		  $Datapoint,
          [string]
		  [Parameter(Mandatory=$true)]
		  $Start,
          [string]
		  [Parameter(Mandatory=$true)]
		  $End,
          [string]
		  [Parameter(Mandatory=$true)]
		  $Datapoints)
	
	begin{
		<# request details #>
        try{
            $date1 = Get-Date -Date "01/01/1970"
            $date2 = Get-Date($Start)
            $StartUnixTime = (New-TimeSpan -Start $date1 -End $date2).TotalSeconds
        }
        catch{
            Write-Error $_.Exception.Message
        }

        try{
            $date1 = Get-Date -Date "01/01/1970"
            $date2 = Get-Date($End)
            $EndUnixTime = (New-TimeSpan -Start $date1 -End $date2).TotalSeconds
        }
        catch{
            Write-Error $_.Exception.Message
        }

        $Device = Get-LMDeviceDetails -Account $Account -AccessId $AccessId -AccessKey $AccessKey -DeviceName $DeviceName
        $DeviceId = $Device.AccessId

		$httpVerb = 'GET'
		$resourcePath = "/device/devices/$DeviceId/devicedatasources/{deviceDatasourceId}/data"
		$Query = "?start=$StartUnixTime&end=$EndUnixTime"
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

