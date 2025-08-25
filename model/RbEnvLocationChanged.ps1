class RbEnvLocationChanged {
    static [void] OnLocationChanged([object] $source, [Management.Automation.LocationChangedEventArgs] $e) {

        if ($e.OldPath -ne $e.NewPath) {
            Update-RubyShims
        }
    }
}
