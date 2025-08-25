
$ErrorActionPreference = 'Stop'

$scriptName = (Get-Item $PSCommandPath).BaseName

$psd1 = Get-Content (Join-Path $PSScriptRoot "$scriptName.psd1") -Raw `
    | Invoke-Expression

Get-ChildItem $PSScriptRoot -Recurse -Include *.ps1 `
    | ForEach-Object { . $_.FullName }

Export-ModuleMember `
    -Variable $psd1.VariablesToExport `
    -Function $psd1.FunctionsToExport `
    -Alias    $psd1.AliasesToExport
