<#
Directory where ruby versions are installed.
#>
function Get-VersionsPath {

    [CmdletBinding()]
    [OutputType([IO.DirectoryInfo])]
    param()

    $callerErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = [Management.Automation.ActionPreference]::Stop

    try {
        $root = Get-RbEnvRoot
        $dir = Join-Path $root versions
        return Get-Item $dir -Force
    }
    catch {
        $global:Error.RemoveAt(0)
        Write-Error $_ -ErrorAction $callerErrorActionPreference
    }
}
