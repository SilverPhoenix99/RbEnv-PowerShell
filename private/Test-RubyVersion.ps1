function Test-RubyVersion {

    [CmdletBinding()]
    param(
        [ValidateNotNullOrWhiteSpace()]
        [string] $Version
    )

    $callerErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = [Management.Automation.ActionPreference]::Stop

    try {
        if ($Version -eq 'system') {
            # Errors out if it doesn't exist
            Get-SystemRubyVersion > $null
        }

        $versionsPath = Get-VersionsPath
        $rubyPath = Join-Path $versionsPath $Version
        if (Test-Path $rubyPath -PathType Container) {
            return
        }

        Write-Error "ruby version $Version is not installed" `
            -RecommendedAction 'Select a valid ruby version from `Get-RubyVersion -Installed`'
    }
    catch {
        $global:Error.RemoveAt(0)
        Write-Error $_ -ErrorAction $callerErrorActionPreference
    }
}
