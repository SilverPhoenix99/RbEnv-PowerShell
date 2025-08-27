function Update-RubyShims {

    [CmdletBinding(SupportsShouldProcess)]
    param()

    if ($PSCmdlet.ShouldProcess('Ruby Shims', 'Remove')) {
        Remove-RubyShims
    }

    $version = Get-RubyVersion
    if (!$version) {
        return
    }

    foreach ($exec in $version.GetExecutables()) {

        $type = Get-ExecutableType $exec
        if (!$type) {
            continue
        }

        if ($PSCmdlet.ShouldProcess($exec.FullName, 'Create Ruby Shim')) {
            switch -Exact ($type) {
                'Executable' {
                    New-RubyExecutableShim $exec
                    break
                }
                'Script' {
                    New-RubyScriptShim $exec
                    break
                }
            }
        }
    }
}
