function Set-GlobalRubyVersion {

    param(
        [ValidateNotNullOrWhiteSpace()]
        [string] $Version
    )

    Test-RubyVersion $Version

    $versionFile = Get-GlobalVersionFile
    $Version > $versionFile.FullName

    Update-RubyShims
}
