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
		  $Start,
          [string]
		  [Parameter(Mandatory=$true)]
		  $End,
          [string]
		  [Parameter(Mandatory=$false)]
		  $Datapoints)
	
	begin{
		<# request details #>
		$date1 = Get-Date -Date "01/01/1970"

        try{
            $date2 = Get-Date($Start)
            $StartUnixTime = (New-TimeSpan -Start $date1 -End $date2).TotalSeconds
        }
        catch{
            Write-Error $_.Exception.Message
        }

        try{
            $date2 = Get-Date($End)
            $EndUnixTime = (New-TimeSpan -Start $date1 -End $date2).TotalSeconds
        }
        catch{
            Write-Error $_.Exception.Message
        }

		# 500 sample limit gets about 16 hours of data
		$Hours = 16
		$Iterations = [math]::round((New-TimeSpan -Start $Start -End $End).TotalHours/$Hours)

        $Device = Get-LMDeviceDetails -Account "$Account" -AccessId "$AccessId" -AccessKey "$AccessKey" -DeviceName "$DeviceName"
        $DeviceDatasource = Get-LMDatasources -Account "$Account" -AccessId "$AccessId" -AccessKey "$AccessKey" -DeviceName "$DeviceName" | Where-Object dataSourceDisplayName -eq "$Datasource"

		$httpVerb = 'GET'
		$resourcePath = "/device/devices/$($Device.Id)/devicedatasources/$($DeviceDatasource.Id)/data"
		$Query = "?start=$StartUnixTime&end=$EndUnixTime&datapoints=$Datapoints"
	}
	process{
		try{
			<# Make Request #>
			if($Iterations -lt 2){
            	Write-Verbose "$($MyInvocation.MyCommand) - $httpVerb $resourcePath$($Query)"
				$output = Invoke-LMQuery -Account "$Account" -AccessId "$AccessId" -AccessKey "$AccessKey" -Verb "$httpVerb" -Path "$resourcePath" -Query "$Query"
			} else {
				$output = @()
				for($i=0;$i -le $Iterations;$i++){
					Write-Verbose "$($MyInvocation.MyCommand) - $httpVerb $resourcePath$($Query) - #$i"
					if($i -eq 0){ 
						$NewStart = $Start 
					}
					$NewEnd = Get-Date(Get-Date($NewStart)).AddHours($Hours)

					$NewStartUnixTime = (New-TimeSpan -Start $date1 -End $NewStart).TotalSeconds
					$NewEndUnixTime = (New-TimeSpan -Start $date1 -End $NewEnd).TotalSeconds
					$Query = "?start=$NewStartUnixTime&end=$NewEndUnixTime&datapoints=$Datapoints"
					$output += Invoke-LMQuery -Account "$Account" -AccessId "$AccessId" -AccessKey "$AccessKey" -Verb "$httpVerb" -Path "$resourcePath" -Query "$Query"
				}
			}

			Write-Output $output
		}
		catch{
			Write-Error $_.Exception.Message
		}
		finally{}
	}
	end{}
}

