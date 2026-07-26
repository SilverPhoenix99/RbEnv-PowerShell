
$ErrorActionPreference = [Management.Automation.ActionPreference]::Stop

$sources = (& {
    # Sorted by dependencies:
    Join-Path $PSScriptRoot 'model' 'RbEnvLocationChanged.ps1' | Get-Item
    Join-Path $PSScriptRoot 'model' 'RubyConfiguration.ps1' | Get-Item
    Join-Path $PSScriptRoot 'model' 'RubyVersion.ps1' | Get-Item
    Join-Path $PSScriptRoot 'model' 'RubyVersionDescriptor.ps1' | Get-Item

    $osDir = $IsLinux ? 'Linux' `
        : $IsWindows ? 'Windows' `
        : $null

    if ($osDir) {
        Join-Path $PSScriptRoot $osDir | Get-ChildItem -File -Recurse -Include *.ps1
    }

    Join-Path $PSScriptRoot 'private' | Get-ChildItem -File -Recurse -Include *.ps1
    Join-Path $PSScriptRoot '*.ps1' | Get-ChildItem -File -Exclude *.Cache.ps1
})

$cacheFile = Join-Path $PSScriptRoot "$(Split-Path $PSCommandPath -LeafBase).Cache.ps1"

if (Test-Path $cacheFile) {

    $cacheTime = (Get-Item $cacheFile).LastWriteTimeUtc

    $skipBuild = $sources.Where({ $_.LastWriteTimeUtc -gt $cacheTime }, 'First').Count -eq 0

    if ($skipBuild) {
        $sources = $null
    }
}

if ($sources) {
    $sources | Get-Content -Raw | Set-Content -Path $cacheFile -Encoding utf8
}

. $cacheFile

& {
    $scriptName = Split-Path $PSCommandPath -LeafBase

    $psd1File = Join-Path $PSScriptRoot "$scriptName.psd1"
    $psd1 = Import-PowerShellDataFile -Path $psd1File

    Export-ModuleMember `
        -Variable $psd1.VariablesToExport `
        -Function $psd1.FunctionsToExport `
        -Alias    $psd1.AliasesToExport
}
