
Function Show-VstsBuilds {
    [CmdletBinding()]
    param(
        [string]
        [ValidateNotNullOrEmpty()]
        $vstsAccount
        , [string]
        [ValidateNotNullOrEmpty()]
        $projectName
        , [string]
        [ValidateNotNullOrEmpty()]
        $buildName
        , [string]
        [ValidateNotNullOrEmpty()]
        $user
        , [string]
        [ValidateNotNullOrEmpty()]
        $token
        , [Switch]
        $watchOnlyMyBuilds
        , [Switch]
        $showFailedOnly
    )
    if ($showFailedOnly) {
        $allBuilds = $false
    }
    else {
        $allBuilds = $true
    }
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user, $token)))
    $uri = "https://$($vstsAccount).visualstudio.com/DefaultCollection/$($projectName)/_apis/build/builds?api-version=2.0" 

    while (1 -eq 1) {
        $e = $null
        try {
            $result = Invoke-RestMethod -Uri $uri -Method Get -ContentType "application/json" -Headers @{Authorization = ("Basic {0}" -f $base64AuthInfo)}
        }
        catch {
            Throw $_.Exception    
        }
        if ($watchOnlyMyBuilds) {
            $e = $result.value | Where-Object {$_.definition.name -eq $buildName -and $_.status -eq "completed" -and $_.requestedFor.displayName -eq $user }    
        }
        else {
            $e = $result.value | Where-Object {$_.definition.name -eq $buildName -and $_.status -eq "completed" } 
        }
        if ($null -ne $e) {
            $ShowBuild = $false
            $PreviousBuild = $buildToCheck
            $buildToCheck = $e | Select-Object -First 1
            if ($null -ne $previousBuild.buildNumber -and $buildToCheck.buildNumber -ne $PreviousBuild.buildNumber) {
                if (($buildToCheck.result -eq "succeeded") -and ($allBuilds -eq $true)) {
                    Write-Host "Hurray! Build $($buildToCheck.definition.name) has passed!" -ForegroundColor White -BackgroundColor DarkGreen
                    $ShowBuild = $true
                }
                if ($buildToCheck.result -eq "failed") {
                    Write-Host "Oh dear! Build $($buildToCheck.definition.name) has failed!" -ForegroundColor Black -BackgroundColor Red
                    $ShowBuild = $true
                }
                if ($ShowBuild -eq $true) {
                    $BuildDetails = New-Object psobject -Property @{
                        "Project Name"    = $buildToCheck.project.name
                        ; "Project url"   = $buildToCheck.project.url
                        ; "Requested for" = $buildToCheck.requestedFor.displayName
                        ; "Build logs"    = $buildToCheck.logs.url
                        ; "Build uid"     = $buildToCheck.buildNumber
                        ; "result"        = $buildToCheck.result
                    }
                    $BuildDetails | Format-List
                }
            }
        }
        Start-Sleep -Seconds 2
    }    
}
