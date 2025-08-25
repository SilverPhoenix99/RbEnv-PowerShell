function Update-RubyShims {

    Remove-RubyShims

    $version = Get-RubyVersion
    if (!$version) {
        return
    }

    foreach ($exec in $version.GetExecutables()) {

        $type = Get-ExecutableType $exec

        # Write-Verbose "[Update-RubyShims] File $($exec.Name) is $($type ?? 'not executable')"

        switch -Exact ($type) {
            'Executable' {
                New-RubyExecutableShim $exec
            }
            'Script' {
                New-RubyScriptShim $exec
            }
        }
    }
}
