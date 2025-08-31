function Set-ShellRubyVersion {

    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '',
        Justification = 'Not an exported function'
    )]
    param(
        [ValidateNotNullOrWhiteSpace()]
        [string] $Version
    )

    $callerErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = [Management.Automation.ActionPreference]::Stop

    try {

        if ($Version -eq '-') {

            # Swaps between the 2 versions

            if (!$Env:RBENV_VERSION -and !$Env:RBENV_VERSION_OLD) {
                Write-Error 'No Shell version to swap ($Env:RBENV_VERSION or $Env:RBENV_VERSION_OLD).' `
                    -RecommendedAction 'Call `Set-RubyVersion -Shell` with an existing ruby version before using this command with `-` as the version.'
            }

            if ($Env:RBENV_VERSION_OLD) {
                Test-RubyVersion $Env:RBENV_VERSION_OLD
            }

            $Version = $Env:RBENV_VERSION_OLD
        }
        else {
            Test-RubyVersion $Version
        }

        Set-Item -Path Env:RBENV_VERSION_OLD -Value $Env:RBENV_VERSION
        Set-Item -Path Env:RBENV_VERSION -Value $Version

        Update-RubyShims
    }
    catch {
        $global:Error.RemoveAt(0)
        Write-Error $_ -ErrorAction $callerErrorActionPreference
    }
}
