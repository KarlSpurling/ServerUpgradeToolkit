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

    Get-ChildItem -Path $RootPath -Recurse -Force -File -ErrorAction SilentlyContinue |
        ForEach-Object {
            $owner = $null
            try { $owner = (Get-Acl $_.FullName).Owner } catch {}

            [PSCustomObject]@{
                FullPath      = $_.FullName
                SizeBytes     = $_.Length
                LastWriteTime = $_.LastWriteTimeUtc
                CreationTime  = $_.CreationTimeUtc
                Attributes    = $_.Attributes
                Owner         = $owner
                HashSHA256    = $(if ($IncludeHash) { Get-FileHashSafe -FilePath $_.FullName } else { $null })
            }
        }
}

function Compare-FileSnapshots {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$Before,
        [Parameter(Mandatory)] [string]$After
    )

    $a = Import-Csv $Before
    $b = Import-Csv $After

    $beforeIndex = $a | Group-Object FullPath -AsHashTable
    $afterIndex  = $b | Group-Object FullPath -AsHashTable

    $added = $afterIndex.Keys | Where-Object { -not $beforeIndex.ContainsKey($_) }
    $removed = $beforeIndex.Keys | Where-Object { -not $afterIndex.ContainsKey($_) }

    $modified = foreach ($path in $beforeIndex.Keys) {
        if ($afterIndex.ContainsKey($path)) {
            $x = $beforeIndex[$path]
            $y = $afterIndex[$path]

            if ($x.SizeBytes -ne $y.SizeBytes -or
                $x.LastWriteTime -ne $y.LastWriteTime -or
                $x.HashSHA256 -ne $y.HashSHA256) {

                [PSCustomObject]@{
                    FullPath = $path
                    Before   = $x
                    After    = $y
                }
            }
        }
    }

    [PSCustomObject]@{
        Added    = $added
        Removed  = $removed
        Modified = $modified
    }
}
