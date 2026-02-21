Import-Module "$PSScriptRoot\..\FileSnapshot.psd1" -Force

Describe "Compare-FileSnapshots" {
    It "Detects added files" {
        $beforePath = Join-Path $env:TEMP "before-$(Get-Random).csv"
        $afterPath  = Join-Path $env:TEMP "after-$(Get-Random).csv"

        @"
FullPath,SizeBytes,LastWriteTime,CreationTime,Attributes,Owner,HashSHA256
C:\Test\a.txt,10,2020-01-01,2020-01-01,Archive,,ABC
"@ | Set-Content $beforePath

        @"
FullPath,SizeBytes,LastWriteTime,CreationTime,Attributes,Owner,HashSHA256
C:\Test\a.txt,10,2020-01-01,2020-01-01,Archive,,ABC
C:\Test\b.txt,20,2020-01-01,2020-01-01,Archive,,DEF
"@ | Set-Content $afterPath

        $diff = Compare-FileSnapshots -Before $beforePath -After $afterPath

        $diff.Added | Should -Contain "C:\Test\b.txt"

        Remove-Item $beforePath, $afterPath -Force
    }
}
