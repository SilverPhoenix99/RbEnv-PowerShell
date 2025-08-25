<#
Display the root directory where versions and shims are kept.

E.g. `~/.rbenv`
#>
function Get-RbEnvRoot {

    # Alias: rbenv-root

    [OutputType([IO.DirectoryInfo])]
    param()

    if ($Env:RBENV_ROOT) {
        if (Test-Path $Env:RBENV_ROOT -PathType Container) {
            return Get-Item $Env:RBENV_ROOT -Force
        }
        throw "`$Env:RBENV_ROOT is not a valid directory: $Env:RBENV_ROOT"
    }

    $root = Join-Path $Env:HOME .rbenv
    if (Test-Path $root -PathType Container) {
        return Get-Item $root -Force
    }

    throw "not a directory: $root"
}
