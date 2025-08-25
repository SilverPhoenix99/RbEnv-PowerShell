class RbEnvLocationChanged {
    static [void] OnLocationChanged([object] $source, [Management.Automation.LocationChangedEventArgs] $e) {

        if ($e.OldPath -eq $e.NewPath) {
            return
        }

        # TODO: rbenv rehash
    }

    static [void] Register() {

        $cmd = $global:ExecutionContext.SessionState.InvokeCommand

        $cmd.LocationChangedAction = [Delegate]::Combine(
            $cmd.LocationChangedAction,
            [EventHandler[Management.Automation.LocationChangedEventArgs]] ([RbEnvLocationChanged]::OnLocationChanged)
        )
    }

    static [void] Unregister() {

        $cmd = $global:ExecutionContext.SessionState.InvokeCommand

        $cmd.LocationChangedAction = [Delegate]::Remove(
            $cmd.LocationChangedAction,
            [EventHandler[Management.Automation.LocationChangedEventArgs]] ([RbEnvLocationChanged]::OnLocationChanged)
        )
    }
}
