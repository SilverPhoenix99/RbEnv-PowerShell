function Test-RubyVersion {

    param(
        [ValidateNotNullOrWhiteSpace()]
        [string] $Version
    )

    if ($Version -eq 'system') {
        # Errors out if it doesn't exist
        Get-SystemRubyVersion > $null
        return
    }

    $rubyPath = Join-Path (Get-VersionsPath) $Version
    if (!(Test-Path $rubyPath -PathType Container)) {
        throw "ruby version $Version is not installed"
    }
}
