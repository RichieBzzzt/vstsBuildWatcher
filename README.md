# vstsBuildWatcher

A PowerShell Module that checks the status of a build every 5 seconds. If it is not "completed" then it is alerted as failed.

```powershell
$_vstsAccount = "bzzzt_io"
$_projectName = "MyFirstProject"
$_buildName = "MyFirstBuild"
$_user = "bzzzt!"
$_token = "6eff7qdscjbzyfgrgzo3cuiwerta7nbvbnjhp7bgefionabt51q"
Import-Module vstsBuildwatcher -Force
Show-FailedVstsBuilds -vstsAccount $_vstsAccount -projectName $_projectName -buildName $_buildName -user $_user -token $_token
```

The idea is to open up PowerShell, import the module and run the command above