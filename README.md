# Server Upgrade Toolkit  
Windows Server 2022 → Windows Server 2025 Upgrade Automation

This toolkit provides a complete, production-safe workflow for upgrading Windows Server 2022 to Windows Server 2025.  
It includes:

- Pre-flight safety net (certs, RDS, IIS, logs, system info)
- Compatibility scanning
- Driver scanning
- Post-upgrade restore
- Rollback preparation
- Defender AV + EDR installation
- Defender health scoring
- Server 2025 hardening
- DC demotion readiness
- Full-flow orchestrator
- GUI launcher
- Excel checklists (CSV)
- Bootstrap script to auto-create the entire folder structure

All scripts are idempotent, non-destructive, and designed for real-world enterprise environments.

---

## 📁 Folder Structure

```
C:\ServerUpgradeToolkit\
│
├── Common\
│   ├── Logging.ps1
│   ├── MailHelper.ps1
│   ├── TeamsHelper.ps1
│   └── DefenderApi.ps1
│
├── 1_PreFlightBackup\
│   ├── PreFlightBackup.ps1
│   ├── DriverScan.ps1
│   └── PreUpgradeScan.ps1
│
├── 3_PostUpgradeRestore\
│   └── PostUpgradeRestore.ps1
│
├── 4_Rollback\
│   ├── RollbackPrep.ps1
│   └── RollbackHelper.ps1
│
├── 5_DefenderInstall\
│   ├── DefenderAutoInstall.ps1
│   └── DefenderHealthScore.ps1
│
├── 6_Hardening\
│   └── Hardening2025.ps1
│
├── DC\
│   └── DcDemotionReadiness.ps1
│
├── FullFlow.ps1
├── GuiLauncher.ps1
└── CreateToolkit.ps1
```

---

## 🚀 Bootstrap Script (CreateToolkit.ps1)

This script creates the entire folder structure and placeholder files on a new server.  
It is safe to run multiple times and will not overwrite existing files.

Save this file as:

```
C:\ServerUpgradeToolkit\CreateToolkit.ps1
```

Then run:

```
powershell.exe -ExecutionPolicy Bypass -File .\CreateToolkit.ps1
```

Bootstrap script:

```
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
```

---

## 🧩 Requirements

- Windows Server 2022 or 2025  
- PowerShell 5.1+  
- Local admin rights  
- Defender MSI installers (MpEng*.msi + Sense*.msi)  
- Optional: Defender onboarding script  
- Optional: Teams webhook URL  
- Optional: SMTP relay  

---

## 🛠 Usage

### Run the GUI
```
.\GuiLauncher.ps1
```

### Run the full upgrade flow
```
.\FullFlow.ps1
```

### Run individual phases
```
.\1_PreFlightBackup\PreFlightBackup.ps1
.\1_PreFlightBackup\PreUpgradeScan.ps1
.\1_PreFlightBackup\DriverScan.ps1
.\3_PostUpgradeRestore\PostUpgradeRestore.ps1 -BackupRoot <path>
.\5_DefenderInstall\DefenderAutoInstall.ps1 -SourcePath <path>
.\6_Hardening\Hardening2025.ps1
```

---

## 🛡 Notes

- Pre-flight backup MUST be run before upgrading.  
- OS upgrade (setup.exe) is manual and not scripted.  
- Post-upgrade restore MUST be run after the OS upgrade.  
- Defender install + hardening are safe to run multiple times.  
- Rollback scripts are advisory and non-destructive.  

---

## 📄 Documentation Included

- README.md (this file)  
- DEPLOYMENT_GUIDE.md  
- QUICKSTART.md  
- Excel checklists (CSV)  
- Bundle manifest  

---

## ✔ Status

Toolkit is complete and ready for deployment.
