<#
    .SYNOPSIS

    .DESCRIPTION

    .EXAMPLE
		Get-LMDevices -Account "company" -GroupName "Customer/Servers/DC1"

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
Function Get-LMDashboardWidgets{
	[CmdletBinding()]
	Param([string]
		  [Parameter(Mandatory=$true)]
		  $Account,
          [int]
		  [Parameter(Mandatory=$true)]
		  $DashboardId,
		  [string]
		  [Parameter(Mandatory=$false)]
		  $AccessId = $env:LMAPIAccessId,
		  [string]
		  [Parameter(Mandatory=$false)]
		  $AccessKey = $env:LMAPIAccessKey)
	
	begin{
		<# request details #>
        $httpVerb = "GET"
        $resourcePath = "/dashboard/dashboards/$DashboardId/widgets"
        $Query = "?size=1000"
	}
	process{
		try{
            <# Make Request #>
            Write-Verbose "Getting dashboards..."
			$bucket = @()
			$output = Invoke-LMQuery -Account "$Account" -AccessId "$AccessId" -AccessKey "$AccessKey" -Verb "$httpVerb" -Path "$resourcePath" -Query "$Query"
			$bucket += $output.items
            $i = 0
			
			while($output.items.count -eq 1000){
				$i++
				$offset = $i * 1000
				Write-Verbose "Getting 1k more ($offset)"
				$Query = "?size=1000&offset=$offset"

				$output = Invoke-LMQuery -Account "$Account" -AccessId "$AccessId" -AccessKey "$AccessKey" -Verb "$httpVerb" -Path "$resourcePath" -Query "$Query"
				$bucket += $output.items
			}
			
			Write-Output $bucket
		}
		catch{
			Write-Error $_.Exception.Message
		}
		finally{}
	}
	end{}
}

