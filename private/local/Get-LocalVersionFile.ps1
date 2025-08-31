<#
Tries to find where `.ruby-version` is located.

Returns $null if the file wasn't found.
#>
function Get-LocalVersionFile {

    [CmdletBinding()]
    [OutputType([IO.FileInfo])] # Nullable
    param()

    $callerErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = [Management.Automation.ActionPreference]::Stop

    try {
        $versionPath = Get-VersionPath
        $filePath = Find-LocalVersionFile $versionPath
        if ($filePath) {
            return $filePath
        }

        if ($versionPath.FullName -eq $PWD.Path) {
            # If they're the same path, then it was already searched above,
            # and it wasn't found.
            return $null
        }

        $filePath = Find-LocalVersionFile $PWD.Path

        return $filePath
    }
    catch {
        $global:Error.RemoveAt(0)
        Write-Error $_ -ErrorAction $callerErrorActionPreference
    }
}

<#
Directory to start searching for `.ruby-version` files.

Uses $Env:RBENV_DIR, if set, otherwise defaults to $PWD
#>
function Get-VersionPath {

    [CmdletBinding()]
    [OutputType([IO.DirectoryInfo])]
    param()

    $callerErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = [Management.Automation.ActionPreference]::Stop

    try {
        if (!$Env:RBENV_DIR) {
            return Get-Item $PWD -Force
        }

        $dir = Resolve-Path $Env:RBENV_DIR -ErrorAction Ignore

        if (-not $dir -or -not (Test-Path $dir -PathType Container)) {
            Write-Error "Cannot change working directory to (`$Env:RBENV_DIR) $Env:RBENV_DIR" `
                -RecommendedAction 'Set $Env:RBENV_DIR to a valid directory containing the Ruby installations.'
        }

        return Get-Item $dir -Force
    }
    catch {
        $global:Error.RemoveAt(0)
        Write-Error $_ -ErrorAction $callerErrorActionPreference
    }
}
