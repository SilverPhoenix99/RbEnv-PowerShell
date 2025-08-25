function Set-GlobalRubyVersion {

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '',
        Justification = 'Not an exported function'
    )]
    param(
        [ValidateNotNullOrWhiteSpace()]
        [string] $Version
    )

    Test-RubyVersion $Version

    $versionFile = Get-GlobalVersionFile

    Set-Content -LiteralPath $versionFile.FullName -Value $Version

    Update-RubyShims
}
