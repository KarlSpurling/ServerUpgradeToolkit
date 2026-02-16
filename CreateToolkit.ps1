<#
    Creates the full folder structure for the Server Upgrade Toolkit.
    Safe to run multiple times — existing folders/files are not overwritten.
#>

$root = "C:\ServerUpgradeToolkit"

$folders = @(
    "$root",
    "$root\Common",
    "$root\1_PreFlightBackup",
    "$root\3_PostUpgradeRestore",
    "$root\4_Rollback",
    "$root\5_DefenderInstall",
    "$root\6_Hardening",
    "$root\DC"
)

$files = @(
    "$root\Common\Logging.ps1",
    "$root\Common\MailHelper.ps1",
    "$root\Common\TeamsHelper.ps1",
    "$root\Common\DefenderApi.ps1",

    "$root\1_PreFlightBackup\PreFlightBackup.ps1",
    "$root\1_PreFlightBackup\DriverScan.ps1",
    "$root\1_PreFlightBackup\PreUpgradeScan.ps1",

    "$root\3_PostUpgradeRestore\PostUpgradeRestore.ps1",

    "$root\4_Rollback\RollbackPrep.ps1",
    "$root\4_Rollback\RollbackHelper.ps1",

    "$root\5_DefenderInstall\DefenderAutoInstall.ps1",
    "$root\5_DefenderInstall\DefenderHealthScore.ps1",

    "$root\6_Hardening\Hardening2025.ps1",

    "$root\DC\DcDemotionReadiness.ps1",

    "$root\FullFlow.ps1",
    "$root\GuiLauncher.ps1",

    "$root\README.md",
    "$root\DEPLOYMENT_GUIDE.md",
    "$root\QUICKSTART.md",
    "$root\BUNDLE_CONTENTS.txt"
)

Write-Host "=== Creating Server Upgrade Toolkit Structure ===" -ForegroundColor Cyan

foreach ($folder in $folders) {
    if (-not (Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder | Out-Null
        Write-Host "Created folder: $folder" -ForegroundColor Green
    } else {
        Write-Host "Folder exists: $folder" -ForegroundColor DarkYellow
    }
}

foreach ($file in $files) {
    if (-not (Test-Path $file)) {
        New-Item -ItemType File -Path $file | Out-Null
        Write-Host "Created placeholder: $file" -ForegroundColor Green
    } else {
        Write-Host "File exists: $file" -ForegroundColor DarkYellow
    }
}

Write-Host "`n=== Toolkit Structure Ready ===" -ForegroundColor Cyan
Write-Host "Root folder: $root" -ForegroundColor White
Write-Host "You can now paste the full script contents into each file." -ForegroundColor White
