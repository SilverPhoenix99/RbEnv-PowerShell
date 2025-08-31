function Get-RubyShims {

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param()

    $callerErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = [Management.Automation.ActionPreference]::Stop

    try {
        return [PSCustomObject] @{
            Aliases   = Get-Alias -Definition Invoke-RbEnvShim--*
            Functions = Get-ChildItem Function:Invoke-RbEnvShim--*
        }
    }
    catch {
        $global:Error.RemoveAt(0)
        Write-Error $_ -ErrorAction $callerErrorActionPreference
    }
}
