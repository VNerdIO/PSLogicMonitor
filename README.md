# PSLogicMonitor

## Requirements

- An active LogicMonitor account
- An AccessID
- An AccessKey

The AccessID and AccessKey can be environment variables

## Usage

Get all alerts for COMPANY (e.g. https://COMPANY.logicmonitor.com/santaba). The AccessID/AccessKey are environment variables and pulled in.
```
Import-Module PSLogicMonitor
$Alerts = Get-LMAlerts -Account "COMPANY"
```

Get all the devices under the Company/Servers folder from the root. AccessID and AccessKey are specified.
```
$Devices = Get-LMDevices -Account "COMPANY" -GroupName "Company/Servers" -AccessId "1234567nope" -AccessKey "nopenope"
$Devices.Count
60
```