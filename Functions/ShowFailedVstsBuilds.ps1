
Function Show-FailedVstsBuilds {
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
    )
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user, $token)))
    $uri = "https://$($vstsAccount).visualstudio.com/DefaultCollection/$($projectName)/_apis/build/builds?api-version=2.0" 

    while (1 -eq 1) {
        $e = $null
        $gte = Get-Date
        $result = Invoke-RestMethod -Uri $uri -Method Get -ContentType "application/json" -Headers @{Authorization = ("Basic {0}" -f $base64AuthInfo)}
        if ($watchOnlyMyBuilds) {
            $e = $result.value | Where-Object {$_.definition.name -eq $buildName -and $_.status -eq "completed" -and $_.requestedFor.displayName -eq $user}    
        }
        else {
            $e = $result.value | Where-Object {$_.definition.name -eq $buildName -and $_.status -eq "completed"} 
        }
        if ($null -ne $e) {
            $buildToCheck = $e | Select-Object -First 1
            $buildFinishTime = $buildToCheck.FinishTime.Substring(0, $buildToCheck.FinishTime.lastIndexOf('.'))
            $thisLoop = $gte.AddSeconds(-5).ToString("yyyy-MM-ddTHH:mm:ss") 
            if ($buildFinishTime -gt $thisLoop) {
                if ($buildToCheck.result -ne "completed") {
                    Write-Host "Oh dear! Build $($buildToCheck.definition.name) has failed!" -ForegroundColor Black -BackgroundColor Red
                    $FailedBuildDetails = New-Object psobject -Property @{
                        "Project Name"    = $buildToCheck.project.name
                        ; "Project url"   = $buildToCheck.project.url
                        ; "Requested for" = $buildToCheck.requestedFor.displayName
                        ; "Build logs"    = $buildToCheck.logs.url
                    }
                    $FailedBuildDetails | Format-List
                }
            }
        }
        Start-Sleep -Seconds 5
    }    
}
