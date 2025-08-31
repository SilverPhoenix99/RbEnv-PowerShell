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
        return Test-Path $rubyPath -PathType Container
    }
    catch {
        $global:Error.RemoveAt(0)
        Write-Error $_ -ErrorAction $callerErrorActionPreference
    }
}
