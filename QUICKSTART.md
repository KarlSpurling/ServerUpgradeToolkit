# Quick Start — Server Upgrade Toolkit

This quick-start guide provides the minimum steps required to safely upgrade a Windows Server 2022 machine to Windows Server 2025.

---

## 1. Create Toolkit Structure

Run:

```
C:\ServerUpgradeToolkit\CreateToolkit.ps1
```

This creates all folders and placeholder files.

---

## 2. Run Pre-Flight Backup

```
C:\ServerUpgradeToolkit\1_PreFlightBackup\PreFlightBackup.ps1
```

---

## 3. Run Compatibility Scans

```
C:\ServerUpgradeToolkit\1_PreFlightBackup\PreUpgradeScan.ps1
C:\ServerUpgradeToolkit\1_PreFlightBackup\DriverScan.ps1
```

---

## 4. Take a Hyper-V Snapshot

Mandatory before upgrading.

---

## 5. Perform OS Upgrade (Manual)

Run `setup.exe` from the Server 2025 ISO.

---

## 6. Run Post-Upgrade Restore

```
C:\ServerUpgradeToolkit\3_PostUpgradeRestore\PostUpgradeRestore.ps1 -BackupRoot <folder>
```

---

## 7. Install Defender

```
C:\ServerUpgradeToolkit\5_DefenderInstall\DefenderAutoInstall.ps1
```

---

## 8. Apply Hardening

```
C:\ServerUpgradeToolkit\6_Hardening\Hardening2025.ps1
```

---

## 9. Validate Defender Health

```
C:\ServerUpgradeToolkit\5_DefenderInstall\DefenderHealthScore.ps1
```

---

## 10. Validate SQL / RDS / DC

Use the provided CSV checklists.

---

## 11. Remove Snapshot (Optional)

After full validation.

---

## Optional: GUI Launcher

```
C:\ServerUpgradeToolkit\GuiLauncher.ps1
```

---

## Optional: Full Automated Flow

```
C:\ServerUpgradeToolkit\FullFlow.ps1
```

---

Quick start complete.
