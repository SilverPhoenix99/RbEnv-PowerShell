function Initialize-RbEnv {

    Update-RubyShims

    [RbEnvLocationChanged]::Register()
}
