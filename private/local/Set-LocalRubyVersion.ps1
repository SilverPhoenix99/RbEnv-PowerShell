function Set-LocalRubyVersion {

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
        Test-RubyVersion $Version

        $versionFile = Join-Path $PWD .ruby-version

        Set-Content -LiteralPath $versionFile -Value $Version

        Update-RubyShims
    }
    catch {
        $global:Error.RemoveAt(0)
        Write-Error $_ -ErrorAction $callerErrorActionPreference
    }
}
