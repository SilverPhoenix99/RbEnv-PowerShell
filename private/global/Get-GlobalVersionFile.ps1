<#
Returns the location of the global version file, even if that file does not exist.
#>
function Get-GlobalVersionFile {

    [CmdletBinding()]
    [OutputType([IO.FileInfo])]
    param()

    $callerErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = [Management.Automation.ActionPreference]::Stop

    try {
        $root = Get-RbEnvRoot
        return [IO.FileInfo] (Join-Path $root version)
    }
    catch {
        $global:Error.RemoveAt(0)
        Write-Error $_ -ErrorAction $callerErrorActionPreference
    }
}
