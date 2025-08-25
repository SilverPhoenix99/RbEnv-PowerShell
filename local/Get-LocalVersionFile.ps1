<#
Tries to find where `.ruby-version` is located.

Returns $null if the file wasn't found.
#>
function Get-LocalVersionFile {

    [OutputType([IO.FileInfo])] # Nullable
    param()

    $versionPath = Get-VersionPath
    Write-Debug "[Get-LocalVersionFile] Starting search path: $($versionPath ?? '$null')"
    $filePath = Find-LocalVersionFile $versionPath
    Write-Debug "[Get-LocalVersionFile] Found version file = $($filePath ?? '$null')"
    if ($filePath) {
        return $filePath
    }

    if ($versionPath.FullName -eq $PWD.Path) {
        # If they're the same path, then it was already searched above,
        # and it wasn't found.
        return $null
    }

    Write-Debug "[Get-LocalVersionFile] Starting search path in `$PWD = $PWD"
    $filePath = Find-LocalVersionFile $PWD.Path
    Write-Debug "[Get-LocalVersionFile] Found version file = $($filePath ?? '$null')"

    return $filePath
}

<#
Directory to start searching for `.ruby-version` files.

Uses $Env:RBENV_DIR, if set, otherwise defaults to $PWD
#>
function Get-VersionPath {

    [OutputType([IO.DirectoryInfo])]
    param()

    if (!$Env:RBENV_DIR) {
        return Get-Item $PWD -Force
    }

    $dir = Resolve-Path $Env:RBENV_DIR -ErrorAction Ignore

    if (-not $dir -or -not (Test-Path $dir -PathType Container)) {
        throw "cannot change working directory to (Env:RBENV_DIR) $Env:RBENV_DIR"
    }

    return Get-Item $dir -Force
}
