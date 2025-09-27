if (!$IsWindows) {
    return
}

function Search-RubyVersions {

    [CmdletBinding()]
    [OutputType([RubyVersion[]])]
    param(
        [switch] $All
    )

    $callerErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = [Management.Automation.ActionPreference]::Stop

    try {
        if ($All) {
            $releases = Invoke-RestMethod `
                -Method Get `
                -Uri 'https://api.github.com/repos/oneclick/rubyinstaller2/releases' `
                -Headers @{ Accept = 'application/vnd.github+json' } `
                -ConnectionTimeoutSeconds 2 `
                -OperationTimeoutSeconds 5

            $versions = $releases.tag_name -replace '^RubyInstaller-' | ForEach-Object {
                $major, $minor, $build, $revision = $_ -split '[.-]'
                [RubyVersion]::new($major, $minor, $build, $revision)
            }

            return $versions | Sort-Object -Descending
        }

        $release = Invoke-RestMethod `
                -Method Get `
                -Uri 'https://api.github.com/repos/oneclick/rubyinstaller2/releases/latest' `
                -Headers @{ Accept = 'application/vnd.github+json' } `
                -ConnectionTimeoutSeconds 2 `
                -OperationTimeoutSeconds 5

        $release = $release.tag_name -replace '^RubyInstaller-'
        $major, $minor, $build, $revision = $release -split '[.-]'

        return [RubyVersion]::new($major, $minor, $build, $revision)
    }
    catch {
        $global:Error.RemoveAt(0)
        Write-Error $_ -ErrorAction $callerErrorActionPreference
    }
}
