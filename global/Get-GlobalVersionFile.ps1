<#
Returns the location of the global version file, even if that file does not exist.
#>
function Get-GlobalVersionFile {

    [OutputType([IO.FileInfo])] # Never $null
    param()

    $root = Get-RbEnvRoot
    [IO.FileInfo] (Join-Path $root version)
}
