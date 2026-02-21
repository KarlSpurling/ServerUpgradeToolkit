function Invoke-FileSnapshot {
    [CmdletBinding()]
    param(
        [string]$Path,
        [switch]$IncludeHash,
        [string]$OutputPath,
        [string]$ConfigPath = (Join-Path (Split-Path $PSScriptRoot -Parent) 'Config\FileSnapshot.json')
    )

    # --- Load config if present ---
    $config = $null
    if (Test-Path $ConfigPath) {
        try {
            $config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
        }
        catch {
            Write-Warning "Config file exists but could not be parsed: $ConfigPath"
        }
    }

    # --- Resolve settings (param > config > default) ---
    $resolvedIncludeHash = if ($IncludeHash.IsPresent) { $true }
                           elseif ($config -and $config.IncludeHash -ne $null) { [bool]$config.IncludeHash }
                           else { $false }

    $resolvedOutputPath = if ($OutputPath) { $OutputPath }
                          elseif ($config -and $config.OutputPath) { $config.OutputPath }
                          else { ".\Snapshots" }

    # --- Ensure output folder exists ---
    if (-not (Test-Path $resolvedOutputPath)) {
        New-Item -ItemType Directory -Path $resolvedOutputPath | Out-Null
    }

    # --- Determine target paths/drives ---
    if ($Path) {
        $targets = @($Path)
    }
    else {
        # Auto-detect fixed drives
        $auto = (Get-PSDrive -PSProvider FileSystem |
                 Where-Object { $_.Free -gt 0 -and $_.Root -match "^[A-Z]:" }).Root

        # Apply IncludeDrives (whitelist)
        if ($config -and $config.IncludeDrives) {
            $auto = $auto | Where-Object { $config.IncludeDrives -contains $_ }
        }

        # Apply ExcludeDrives (blacklist)
        if ($config -and $config.ExcludeDrives) {
            $auto = $auto | Where-Object { $config.ExcludeDrives -notcontains $_ }
        }

        $targets = $auto
    }

    if (-not $targets -or $targets.Count -eq 0) {
        Write-Warning "No target paths/drives resolved. Check IncludeDrives/ExcludeDrives configuration."
        return
    }

    # --- Snapshot output file ---
    $timestamp = (Get-Date).ToString("yyyyMMdd-HHmmss")
    $outFile = Join-Path $resolvedOutputPath "FileSnapshot-$timestamp.csv"

    # --- Run snapshot ---
    $results = foreach ($t in $targets) {
        Get-FileSnapshot -RootPath $t -IncludeHash:$resolvedIncludeHash
    }

    $results | Export-Csv -Path $outFile -NoTypeInformation -Encoding UTF8

    Write-Output $outFile
}
