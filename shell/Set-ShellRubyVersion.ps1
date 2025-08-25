function Set-ShellRubyVersion {

    param(
        [ValidateNotNullOrWhiteSpace()]
        [string] $Version
    )

    if ($Version -eq '-') {

        # Swaps between the 2 versions

        if (!$Env:RBENV_VERSION_OLD) {
            throw 'RBENV_VERSION_OLD is not set'
        }

        $currentVersion = $Env:RBENV_VERSION
        $Env:RBENV_VERSION = $Env:RBENV_VERSION_OLD
        $Env:RBENV_VERSION_OLD = $currentVersion
    }
    else {
        Test-RubyVersion $Version

        $Env:RBENV_VERSION_OLD = $Env:RBENV_VERSION
        $Env:RBENV_VERSION = $Version
    }

    Update-RubyShims
}
