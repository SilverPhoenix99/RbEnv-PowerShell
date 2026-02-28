
$ErrorActionPreference = [Management.Automation.ActionPreference]::Stop

(& {
    # Sorted by dependencies:
    Join-Path $PSScriptRoot 'model' 'RbEnvLocationChanged.ps1'
    Join-Path $PSScriptRoot 'model' 'RubyConfiguration.ps1'
    Join-Path $PSScriptRoot 'model' 'RubyVersion.ps1'
    Join-Path $PSScriptRoot 'model' 'RubyVersionDescriptor.ps1'

    Get-ChildItem (Join-Path $PSScriptRoot 'private') -File -Recurse -Include *.ps1 | ForEach-Object FullName
    Get-ChildItem (Join-Path $PSScriptRoot '*.ps1') -File | ForEach-Object FullName

}).ForEach{ . $_ }

& {
    $scriptName = Split-Path $PSCommandPath -LeafBase

    $psd1File = Join-Path $PSScriptRoot "$scriptName.psd1"
    $psd1 = Import-PowerShellDataFile -Path $psd1File

    Export-ModuleMember `
        -Variable $psd1.VariablesToExport `
        -Function $psd1.FunctionsToExport `
        -Alias    $psd1.AliasesToExport
}
