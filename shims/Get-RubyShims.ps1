function Get-RubyShims {
    return [PSCustomObject] @{
        Aliases   = Get-Alias -Definition Invoke-RbEnvShim--*
        Functions = Get-ChildItem Function:Invoke-RbEnvShim--*
    }
}
