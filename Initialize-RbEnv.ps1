function Initialize-RbEnv {

    [CmdletBinding(SupportsShouldProcess)]
    param()

    Update-RubyShims -WhatIf:$WhatIfPreference

    if ($PSCmdlet.ShouldProcess('$ExecutionContext.SessionState.InvokeCommand', 'Registering LocationChangedAction')) {

        $cmd = $global:ExecutionContext.SessionState.InvokeCommand

        $cmd.LocationChangedAction = [Delegate]::Combine(
            $cmd.LocationChangedAction,
            [EventHandler[Management.Automation.LocationChangedEventArgs]] ([RbEnvLocationChanged]::OnLocationChanged)
        )
    }
}
