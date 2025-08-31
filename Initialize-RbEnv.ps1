function Initialize-RbEnv {

    [CmdletBinding(SupportsShouldProcess)]
    param()

    $callerErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = [Management.Automation.ActionPreference]::Stop

    try {
        Update-RubyShims -WhatIf:$WhatIfPreference

        if ($PSCmdlet.ShouldProcess('$ExecutionContext.SessionState.InvokeCommand', 'Registering LocationChangedAction')) {

            $cmd = $global:ExecutionContext.SessionState.InvokeCommand

            $cmd.LocationChangedAction = [Delegate]::Combine(
                $cmd.LocationChangedAction,
                [EventHandler[Management.Automation.LocationChangedEventArgs]] ([RbEnvLocationChanged]::OnLocationChanged)
            )
        }
    }
    catch {
        $global:Error.RemoveAt(0)
        Write-Error $_ -ErrorAction $callerErrorActionPreference
    }
}
