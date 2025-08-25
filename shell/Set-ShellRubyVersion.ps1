function Set-ShellRubyVersion {

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '',
        Justification = 'Not an exported function'
    )]
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

        Set-Item -Path Env:RBENV_VERSION -Value $Env:RBENV_VERSION_OLD
        Set-Item -Path Env:RBENV_VERSION_OLD -Value $currentVersion
    }
    else {
        Test-RubyVersion $Version

        Set-Item -Path Env:RBENV_VERSION_OLD -Value $Env:RBENV_VERSION
        Set-Item -Path Env:RBENV_VERSION -Value $Version
    }

    Update-RubyShims
}
