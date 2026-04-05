# Travelers Auto-Push Script
# This script increments version numbers and pushes to GitHub every 5 seconds.

$major = 29
$minor = 0

Write-Host "Starting Travio Auto-Push Bot..." -ForegroundColor Cyan

try {
    while ($true) {
        $version = "$major.$minor"
        Write-Host "Current Version: $version" -ForegroundColor Green
        
        # 1. Update a version tracker file
        "Version: $version" | Out-File -FilePath "version.txt"
        
        # 2. Git operations
        git add version.txt
        $commitMessage = "Travio Update $version"
        git commit -m $commitMessage
        
        Write-Host "Syncing with remote..." -ForegroundColor Cyan
        git pull --rebase origin main
        
        Write-Host "Pushing $version to GitHub..." -ForegroundColor Yellow
        git push origin main
        
        # 3. Increment logic
        if ($minor -lt 9) {
            $minor++
        } else {
            $minor = 0
            $major++
        }
        
        Write-Host "Waiting 5 seconds..."
        Start-Sleep -Seconds 5
    }
}
catch {
    Write-Host "Stop requested. Terminating bot..." -ForegroundColor Red
}
finally {
    Write-Host "Script ended."
}
