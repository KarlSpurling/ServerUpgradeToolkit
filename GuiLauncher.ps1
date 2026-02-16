Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$root = "C:\ServerUpgradeToolkit"

$form               = New-Object System.Windows.Forms.Form
$form.Text          = "Server Upgrade Toolkit"
$form.Size          = New-Object System.Drawing.Size(420,380)
$form.StartPosition = "CenterScreen"

$buttons = @(
    @{Text="Pre-Flight Backup";      Script="$root\1_PreFlightBackup\PreFlightBackup.ps1";      Top=20},
    @{Text="Pre-Upgrade Scan";       Script="$root\1_PreFlightBackup\PreUpgradeScan.ps1";       Top=60},
    @{Text="Driver Scan";            Script="$root\1_PreFlightBackup\DriverScan.ps1";           Top=100},
    @{Text="Post-Upgrade Restore";   Script="$root\3_PostUpgradeRestore\PostUpgradeRestore.ps1";Top=140},
    @{Text="Defender Install";       Script="$root\5_DefenderInstall\DefenderAutoInstall.ps1";  Top=180},
    @{Text="Defender Health Score";  Script="$root\5_DefenderInstall\DefenderHealthScore.ps1";  Top=220},
    @{Text="Hardening 2025";         Script="$root\6_Hardening\Hardening2025.ps1";              Top=260},
    @{Text="Full Flow";              Script="$root\FullFlow.ps1";                               Top=300}
)

foreach ($b in $buttons) {
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text      = $b.Text
    $btn.Size      = New-Object System.Drawing.Size(180,30)
    $btn.Location  = New-Object System.Drawing.Point(20,$b.Top)
    $btn.Add_Click({
        param($path)
        if ($path -like "*PostUpgradeRestore*") {
            $folder = [System.Windows.Forms.FolderBrowserDialog]::new()
            if ($folder.ShowDialog() -eq "OK") {
                Start-Process powershell.exe "-ExecutionPolicy Bypass -File `"$path`" -BackupRoot `"$($folder.SelectedPath)`""
            }
        } elseif ($path -like "*DefenderAutoInstall*") {
            $folder = [System.Windows.Forms.FolderBrowserDialog]::new()
            if ($folder.ShowDialog() -eq "OK") {
                Start-Process powershell.exe "-ExecutionPolicy Bypass -File `"$path`" -SourcePath `"$($folder.SelectedPath)`""
            }
        } else {
            Start-Process powershell.exe "-ExecutionPolicy Bypass -File `"$path`""
        }
    }.GetNewClosure($b.Script))
    $form.Controls.Add($btn)
}

[System.Windows.Forms.Application]::Run($form)
