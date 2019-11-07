describe "Get-LMAlerts"{

    $param = @{
        "Account" = "mycompany"
        "AccessId" = "1111111111"
        "AccessKey" = "aaaaaaaaaaaaaaaaaaa"
    }

    Mock 'Invoke-LMQuery' -MockWith { $True }
}