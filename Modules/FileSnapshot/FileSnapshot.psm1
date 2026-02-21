function Get-FileHashSafe {
    param(
        [Parameter(Mandatory)]
        [string]$FilePath
    )
    try {
        return (Get-FileHash -Path $FilePath -Algorithm SHA256 -ErrorAction Stop).Hash
    }
    catch {
        return $null
    }
}

function Get-FileSnapshot {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$RootPath,

        [switch]$IncludeHash
    )

    Add-Type -Language CSharp -TypeDefinition @"
using System;
using System.IO;
using System.Collections.Generic;

public class FastSnapshot {
    private static readonly string[] SkipFolders = new string[] {
        @"C:\Windows\Servicing",
        @"C:\Windows\WinSxS\Temp",
        @"C:\Windows\WinSxS\ManifestCache",
        @"C:\Windows\System32\config\systemprofile",
        @"C:\Windows\System32\LogFiles\WMI\RtBackup",
        @"C:\Windows\SoftwareDistribution\Download",
        @"C:\Windows\Temp"
    };

    private static bool IsSkipped(string path) {
        foreach (var skip in SkipFolders) {
            if (path.StartsWith(skip, StringComparison.OrdinalIgnoreCase))
                return true;
        }
        return false;
    }

    public static IEnumerable<string> Walk(string root) {
        var dirs = new Stack<string>();
        dirs.Push(root);

        while (dirs.Count > 0) {
            string current = dirs.Pop();

            if (IsSkipped(current))
                continue;

            string[] subdirs = null;
            try {
                subdirs = Directory.GetDirectories(current);
            }
            catch { }

            if (subdirs != null) {
                foreach (var d in subdirs)
                    dirs.Push(d);
            }

            string[] files = null;
            try {
                files = Directory.GetFiles(current);
            }
            catch { }

            if (files != null) {
                foreach (var f in files)
                    yield return f;
            }
        }
    }
}
"@

    $RootPath = (Resolve-Path -Path $RootPath).ProviderPath

    foreach ($file in [FastSnapshot]::Walk($RootPath)) {

        $info = Get-Item -LiteralPath $file -ErrorAction SilentlyContinue
        if (-not $info) { continue }

        $hash = $null
        if ($IncludeHash) {
            try {
                $hash = (Get-FileHash -Path $file -Algorithm SHA256 -ErrorAction Stop).Hash
            }
            catch { }
        }

        [PSCustomObject]@{
            FullPath      = $info.FullName
            SizeBytes     = $info.Length
            LastWriteTime = $info.LastWriteTimeUtc
            CreationTime  = $info.CreationTimeUtc
            Attributes    = $info.Attributes
            Owner         = "UNREADABLE"   # ACL intentionally skipped for speed/safety
            HashSHA256    = $hash
        }
    }
}

function Compare-FileSnapshots {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$Before,
        [Parameter(Mandatory)] [string]$After
    )

    Add-Type -Language CSharp -TypeDefinition @"
using System;
using System.IO;
using System.Collections.Generic;

public class SnapshotRow {
    public string FullPath;
    public long SizeBytes;
    public string LastWriteTime;
    public string CreationTime;
    public string Attributes;
    public string Owner;
    public string HashSHA256;
}

public class SnapshotLoader {
    public static Dictionary<string, SnapshotRow> Load(string path) {
        var map = new Dictionary<string, SnapshotRow>(StringComparer.OrdinalIgnoreCase);

        using (var reader = new StreamReader(path)) {
            string header = reader.ReadLine(); // skip header
            string line;

            while ((line = reader.ReadLine()) != null) {
                var parts = SplitCsv(line);
                if (parts.Length < 7) continue;

                var row = new SnapshotRow {
                    FullPath      = parts[0],
                    SizeBytes     = long.TryParse(parts[1], out long s) ? s : 0,
                    LastWriteTime = parts[2],
                    CreationTime  = parts[3],
                    Attributes    = parts[4],
                    Owner         = parts[5],
                    HashSHA256    = parts[6]
                };

                if (!map.ContainsKey(row.FullPath))
                    map.Add(row.FullPath, row);
            }
        }

        return map;
    }

    // Very fast CSV splitter (no regex, no heavy parsing)
    private static string[] SplitCsv(string line) {
        return line.Split(',');
    }
}
"@

    # Load both snapshots using the native C# loader
    $beforeMap = [SnapshotLoader]::Load($Before)
    $afterMap  = [SnapshotLoader]::Load($After)

    # Added files
    $added = foreach ($key in $afterMap.Keys) {
        if (-not $beforeMap.ContainsKey($key)) {
            $afterMap[$key]
        }
    }

    # Removed files
    $removed = foreach ($key in $beforeMap.Keys) {
        if (-not $afterMap.ContainsKey($key)) {
            $beforeMap[$key]
        }
    }

    # Modified files
    $modified = foreach ($key in $beforeMap.Keys) {
        if ($afterMap.ContainsKey($key)) {
            $b = $beforeMap[$key]
            $a = $afterMap[$key]

            if ($a.SizeBytes -ne $b.SizeBytes -or
                $a.LastWriteTime -ne $b.LastWriteTime -or
                $a.HashSHA256 -ne $b.HashSHA256) {

                [PSCustomObject]@{
                    FullPath = $key
                    Before   = $b
                    After    = $a
                }
            }
        }
    }

    return [PSCustomObject]@{
        Added    = $added
        Removed  = $removed
        Modified = $modified
    }
}
