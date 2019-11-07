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

