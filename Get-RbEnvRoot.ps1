<#
Display the root directory where versions and shims are kept.

E.g. `~/.rbenv`
#>
function Get-RbEnvRoot {

    [CmdletBinding()]
    [OutputType([IO.DirectoryInfo])]
    param()

    $callerErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = [Management.Automation.ActionPreference]::Stop

    try {
    if ($Env:RBENV_ROOT) {

            $root = Get-Item $Env:RBENV_ROOT -Force -ErrorAction Ignore
            if ($root.PSIsContainer) {
                return $root
            }

            Write-Error "not a directory (`$Env:RBENV_ROOT): $Env:RBENV_ROOT" `
                -RecommendedAction 'Set $Env:RBENV_ROOT to a valid directory.'
    }

        $rootPath = Join-Path $HOME .rbenv
        $root = Get-Item $rootPath -Force -ErrorAction Ignore
        if ($root.PSIsContainer) {
            return $root
        }

        Write-Error "not a directory: $rootPath" `
            -RecommendedAction 'Create the directory `~/.rbenv`, or set $Env:RBENV_ROOT to a valid directory.'
    }
    catch {
        $global:Error.RemoveAt(0)
        Write-Error $_ -ErrorAction $callerErrorActionPreference
    }
}
