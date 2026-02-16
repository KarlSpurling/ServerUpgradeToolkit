# Deployment Guide — Server Upgrade Toolkit  
Windows Server 2022 → Windows Server 2025 Upgrade Workflow

This guide explains how to deploy and use the Server Upgrade Toolkit safely and consistently across SQL, RDS, and general-purpose servers.

---

## 1. Create the Toolkit Folder Structure

Run the bootstrap script:

```
C:\ServerUpgradeToolkit\CreateToolkit.ps1
```

This creates:
- All required folders  
- All placeholder files  
- All documentation files  

No existing files are overwritten.

---

## 2. Populate Script Contents

Paste the full script contents into each placeholder file created by the bootstrap script.

---

## 3. Configure Common Modules

### MailHelper.ps1  
Set:
- `$SmtpServer`
- `$From`
- `$To`

### TeamsHelper.ps1 (optional)  
Set:
- `$WebhookUrl`

### DefenderApi.ps1 (optional)  
Set:
- `$TenantId`
- `$ClientId`
- `$ClientSecret`

---

## 4. Prepare Defender Installers

Place the following files into:

```
C:\ServerUpgradeToolkit\5_DefenderInstall\
```

Required:
- MpEng*.msi (Defender AV)
- Sense*.msi (Defender EDR)

Optional:
- Onboarding script (OnboardingScript*.cmd)

---

## 5. Run Pre-Flight Backup

```
C:\ServerUpgradeToolkit\1_PreFlightBackup\PreFlightBackup.ps1
```

This exports:
- Certificates  
- RDS deployment + licensing  
- IIS config  
- System info  
- Event logs  

---

## 6. Run Compatibility Scans

```
C:\ServerUpgradeToolkit\1_PreFlightBackup\PreUpgradeScan.ps1
C:\ServerUpgradeToolkit\1_PreFlightBackup\DriverScan.ps1
```

Resolve any warnings before continuing.

---

## 7. Take a Hyper-V Snapshot

This is mandatory before the OS upgrade.

---

## 8. Perform the OS Upgrade (Manual Step)

Run:

```
setup.exe
```

Choose:
- Keep personal files and apps  
- In-place upgrade  

Wait for the upgrade to complete.

---

## 9. Run Post-Upgrade Restore

```
C:\ServerUpgradeToolkit\3_PostUpgradeRestore\PostUpgradeRestore.ps1 -BackupRoot <folder>
```

Use the backup folder created in Step 5.

---

## 10. Install Defender (AV + EDR)

```
C:\ServerUpgradeToolkit\5_DefenderInstall\DefenderAutoInstall.ps1
```

---

## 11. Apply Server 2025 Hardening

```
C:\ServerUpgradeToolkit\6_Hardening\Hardening2025.ps1
```

---

## 12. Validate Defender Health

```
C:\ServerUpgradeToolkit\5_DefenderInstall\DefenderHealthScore.ps1
```

Score should be **4/5 or higher**.

---

## 13. Validate SQL / RDS / DC

Use the provided Excel checklists (CSV):
- SQL Upgrade Checklist  
- RDS Upgrade Checklist  
- Defender + Hardening Validation  
- DC Demotion Readiness  

---

## 14. Remove Hyper-V Snapshot (Optional)

Only after:
- All services validated  
- Defender healthy  
- No critical event log errors  
- User testing complete  

---

## 15. Optional: Use the GUI Launcher

```
C:\ServerUpgradeToolkit\GuiLauncher.ps1
```

---

## 16. Optional: Run the Full Automated Flow

```
C:\ServerUpgradeToolkit\FullFlow.ps1
```

---

## Deployment Complete

Your server is now fully upgraded, hardened, and validated.
