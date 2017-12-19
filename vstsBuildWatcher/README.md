# vstsBuildWatcher

A PowerShell Module that checks the status of a build every 2 seconds. Reports on build statuses "failed" and "succeeded". Option to filter to only failed builds.

```powershell
$_vstsAccount = "bzzzt_io"
$_projectName = "MyFirstProject"
$_buildName = "MyFirstBuild"
$_user = "bzzzt!"
$_token = "6eff7qdscjbzyfgrgzo3cuiwerta7nbvbnjhp7bgefionabt51q"
Import-Module vstsBuildwatcher -Force
Show-VstsBuilds -vstsAccount $_vstsAccount -projectName $_projectName -buildName $_buildName -user $_user -token $_token

Show-VstsBuilds -vstsAccount $_vstsAccount -projectName $_projectName -buildName $_buildName -user $_user -token $_token -ShowFailedOnly
```

The idea is to open up PowerShell, import the module and run the command above
