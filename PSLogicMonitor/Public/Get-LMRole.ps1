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
Function Get-LMRole{
	[CmdletBinding()]
	Param([string]
		  [Parameter(Mandatory=$true)]
		  $Account,
          [string]
		  [Parameter(Mandatory=$false)]
		  $RoleName,
		  [string]
		  [Parameter(Mandatory=$false)]
		  $AccessId = $env:LMAPIAccessId,
		  [string]
		  [Parameter(Mandatory=$false)]
		  $AccessKey = $env:LMAPIAccessKey)
	
	begin{
		<# request details #>
        $httpVerb = "GET"
        $resourcePath = "/setting/roles"
        if($RoleName){
            $Query = "?filter=name:$RoleName"
        } else {
            $Query = "?size=1000"
        }
	}
	process{
		try{
            <# Make Request #>
            Write-Verbose "Getting roles..."
			$bucket = @()
			$output = Invoke-LMQuery -Account "$Account" -AccessId "$AccessId" -AccessKey "$AccessKey" -Verb "$httpVerb" -Path "$resourcePath" -Query "$Query"
			$bucket += $output.items
            $i = 0
			
			if(!$RoleName){
				while($output.items.count -eq 1000){
					$i++
					$offset = $i * 1000
					Write-Verbose "Getting 1k more ($offset)"
					if($groupId){
						$Query = "?size=1000&offset=$offset&filter=hostGroupIds~*$groupId*"
					} else {
						$Query = "?size=1000&offset=$offset"
					}

					$output = Invoke-LMQuery -Account "$Account" -AccessId "$AccessId" -AccessKey "$AccessKey" -Verb "$httpVerb" -Path "$resourcePath" -Query "$Query"
					$bucket += $output.items
				}

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

