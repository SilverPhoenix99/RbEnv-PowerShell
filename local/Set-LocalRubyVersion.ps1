function Set-LocalRubyVersion {

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '',
        Justification = 'Not an exported function'
    )]
    param(
        [ValidateNotNullOrWhiteSpace()]
        [string] $Version
    )

    Test-RubyVersion $Version

    $versionFile = Join-Path $PWD .ruby-version

    Set-Content -LiteralPath $versionFile -Value $Version

    Update-RubyShims
}
