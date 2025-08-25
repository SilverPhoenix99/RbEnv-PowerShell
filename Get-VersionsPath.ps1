<#
Directory where ruby versions are installed.
#>
function Get-VersionsPath {

    [OutputType([IO.DirectoryInfo])] # Never $null
    param()

    $root = Get-RbEnvRoot
    $dir = Join-Path $root versions
    return Get-Item $dir -Force
}
