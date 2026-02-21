Import-Module "$PSScriptRoot\..\FileSnapshot.psd1" -Force

Describe "Get-FileSnapshot" {
    It "Returns results for a known directory" {
        $tempPath = Join-Path $env:TEMP "fs-test-$(Get-Random)"
        $temp = New-Item -ItemType Directory -Path $tempPath
        $file = New-Item -ItemType File -Path (Join-Path $temp.FullName "test.txt")

        $result = Get-FileSnapshot -RootPath $temp.FullName

        $result.FullPath | Should -Contain $file.FullName

        Remove-Item -Path $temp.FullName -Recurse -Force
    }
}

Describe "Invoke-FileSnapshot with config" {
    It "Honours config and returns a CSV path" {
        $configDir = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
        $configPath = Join-Path $configDir 'Config\FileSnapshot.json'

        if (-not (Test-Path (Split-Path $configPath))) {
            New-Item -ItemType Directory -Path (Split-Path $configPath) | Out-Null
        }

        @{
            IncludeDrives = @("C:")
            ExcludeDrives = @()
            IncludeHash   = $false
            OutputPath    = "$env:TEMP\FileSnapshots"
        } | ConvertTo-Json | Set-Content $configPath

        $result = Invoke-FileSnapshot

        Test-Path $result | Should -BeTrue
    }
}
