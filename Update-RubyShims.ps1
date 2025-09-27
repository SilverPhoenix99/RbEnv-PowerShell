function Update-RubyShims {

    [CmdletBinding(SupportsShouldProcess)]
    param()

    $callerErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = [Management.Automation.ActionPreference]::Stop

    try {
        if ($PSCmdlet.ShouldProcess('Ruby Shims', 'Remove')) {
            Remove-RubyShims
        }

        $version = Get-RubyVersion -ErrorAction Ignore
        if (-not $version) {
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
    catch {
        $global:Error.RemoveAt(0)
        Write-Error $_ -ErrorAction $callerErrorActionPreference
    }
}
