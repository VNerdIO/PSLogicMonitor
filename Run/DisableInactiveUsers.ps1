<#
	Find inactive users
	"inactive" - a status=active user that hasn't logged in 30 days
#>

[datetime]$origin = "1970-01-01 00:00:00"
$today = Get-Date
$Users = Get-LMUsers -Account "cspire"
$ExcludeUsernames = "apiuser"
[int]$DisableDays = 30
[int]$PurgeDays = 90
[int]$CustomerDisableDays = 180
[int]$CustomerPurgeDays = 365
$ReportSuspend = @()
$ReportPurge = @()
$CSpireDisable = 0
$CSpireDelete = 0
$CustomerDisable = 0
$CustomerDelete = 0

# C Spire users
$InactiveCSUsers = $Users | Where-Object {$_.email -like "*@cspire.com" -OR $_.email -like "*@kalleo.net"} | Where-Object {$ExcludeUsernames -notcontains $_.username} | Select-Object id,status,username,email,@{n="lastLogin";e={$origin.AddSeconds($_.lastLoginOn)}},lastActionOnLocal | Where-Object {$_.status -eq "active" -AND (New-TimeSpan -Start $_.lastLogin -End $today).Days -gt $DisableDays}
$PurgeCSUsers = $Users | Where-Object {$_.email -like "*@cspire.com" -OR $_.email -like "*@kalleo.net"} | Where-Object {$ExcludeUsernames -notcontains $_.username} | Select-Object id,status,username,email,@{n="lastLogin";e={$origin.AddSeconds($_.lastLoginOn)}},lastActionOnLocal | Where-Object {$_.status -eq "suspended" -AND (New-TimeSpan -Start $_.lastLogin -End $today).Days -gt $PurgeDays}

# Customers
$InactiveCustomers = $Users | Where-Object {$_.email -notlike "*@cspire.com" -AND $_.email -notlike "*@kalleo.net"} | Where-Object {$ExcludeUsernames -notcontains $_.username} | Select-Object id,status,username,email,@{n="lastLogin";e={$origin.AddSeconds($_.lastLoginOn)}},lastActionOnLocal | Where-Object {$_.status -eq "active" -AND (New-TimeSpan -Start $_.lastLogin -End $today).Days -gt $CustomerDisableDays}
$PurgeCustomers = $Users | Where-Object {$_.email -notlike "*@cspire.com" -AND $_.email -notlike "*@kalleo.net"} | Where-Object {$ExcludeUsernames -notcontains $_.username} | Select-Object id,status,username,email,@{n="lastLogin";e={$origin.AddSeconds($_.lastLoginOn)}},lastActionOnLocal | Where-Object {$_.status -eq "suspended" -AND (New-TimeSpan -Start $_.lastLogin -End $today).Days -gt $CustomerPurgeDays}

# Purge users first, so users are not disabled/purged immediately
foreach($PurgeCSUser IN $PurgeCSUsers){
	try{
		#$Lock = Remove-LMUser -Account "cspire" -UserId $PurgeCSUser.id
		$CSpireDelete++
		Write-Output "$($PurgeCSUser.username) was deleted."
		$ReportPurge += $Lock
	}
	catch{
		Write-Error "ERROR: $($PurgeCSUser.username) was NOT deleted ($($_.Exception.Message))."
	}
}

foreach($PurgeCustomer IN $PurgeCustomers){
	try{
		#$Lock = Remove-LMUser -Account "cspire" -UserId $PurgeCustomer.id
		$CustomerDelete++
		Write-Output "$($PurgeCustomer.username) was deleted."
		$ReportPurge += $Lock
	}
	catch{
		Write-Error "ERROR: $($PurgeCustomer.username) was NOT deleted ($($_.Exception.Message))."
	}
}

# Suspend users
foreach($InactiveCSUser IN $InactiveCSUsers){
	try{
		#$Lock = Lock-LMUser -Account "cspire" -UserId $InactiveCSUser.id
		$CSpireDisable++
		Write-Output "$($InactiveCSUser.username) was suspended."
		$ReportSuspend += $Lock
	}
	catch{
		Write-Error "ERROR: $($InactiveCSUser.username) was NOT suspended ($($_.Exception.Message))."
	}
}

foreach($InactiveCustomer IN $InactiveCustomers){
	try{
		#$Lock = Lock-LMUser -Account "cspire" -UserId $InactiveCustomer.id
		$CustomerDisable++
		Write-Output "$($InactiveCustomer.username) was suspended."
		$ReportSuspend += $Lock
	}
	catch{
		Write-Error "ERROR: $($InactiveCustomer.username) was NOT suspended ($($_.Exception.Message))."
	}
}

$Summary = "C Spire Users disabled: $CSpireDisable`r`nC Spire Users deleted: $CSpireDelete`r`nCustomer Accounts disabled: $CustomerDisable`r`nCustomer Accounts deleted: $CustomerDelete"

Write-Output $Summary