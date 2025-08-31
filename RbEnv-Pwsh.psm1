
$scriptName = (Get-Item $PSCommandPath).BaseName

$psd1File = Join-Path $PSScriptRoot "$scriptName.psd1"
$psd1 = Import-PowerShellDataFile -Path $psd1File

Get-ChildItem $PSScriptRoot -Recurse -Include *.ps1 `
    | ForEach-Object { . $_.FullName }

Export-ModuleMember `
    -Variable $psd1.VariablesToExport `
    -Function $psd1.FunctionsToExport `
    -Alias    $psd1.AliasesToExport
