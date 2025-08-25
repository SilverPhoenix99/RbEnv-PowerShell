function Set-LocalRubyVersion {

    param(
        [ValidateNotNullOrWhiteSpace()]
        [string] $Version
    )

    Test-RubyVersion $Version

    $versionFile = Join-Path $PWD .ruby-version
    $Version > $versionFile

    Update-RubyShims
}
