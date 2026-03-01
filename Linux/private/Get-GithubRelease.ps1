function Get-GithubRelease {

    [CmdletBinding()]
    param()

    $callerErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = [Management.Automation.ActionPreference]::Stop

    try {

        $release = Invoke-RestMethod `
            -Method Get `
            -Uri 'https://api.github.com/repos/spinel-coop/rv-ruby/releases/latest' `
            -Headers @{ Accept = 'application/vnd.github+json' } `
            -ConnectionTimeoutSeconds 2 `
            -OperationTimeoutSeconds 5

        $release.assets
    }
    catch {
        $global:Error.RemoveAt(0)
        Write-Error $_ -ErrorAction $callerErrorActionPreference
    }
}
