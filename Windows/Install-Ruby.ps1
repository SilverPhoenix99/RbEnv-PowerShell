function Install-Ruby {

    [CmdletBinding(DefaultParameterSetName = 'Version')]
    param(
        [ValidateNotNullOrWhiteSpace()]
        [Parameter(Mandatory, ParameterSetName = 'Version')]
        [string] $Version,

        [Parameter(Mandatory, ParameterSetName = 'Latest')]
        [switch] $Latest

        # TODO: [switch] $Force # To reinstall on top of an existing installation. Won't affect gems.
    )

    $callerErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = [Management.Automation.ActionPreference]::Stop

    try {
        # If already installed, quit
        $installedVersion = Get-RubyVersion -Installed | Where-Object { $_.Version.ToString() -eq $Version }
        if ($installedVersion) {
            Write-Warning "Ruby version $Version is already installed."
            return
        }

        $url = switch -Exact ($PSCmdlet.ParameterSetName) {
            'Version' {
                "https://api.github.com/repos/oneclick/rubyinstaller2/releases/tags/RubyInstaller-$Version"
            }
            'Latest' {
                'https://api.github.com/repos/oneclick/rubyinstaller2/releases/latest'
            }
        }

        $release = Invoke-RestMethod `
            -Method Get `
            -Uri $url `
            -Headers @{ Accept = 'application/vnd.github+json' } `
            -ConnectionTimeoutSeconds 2 `
            -OperationTimeoutSeconds 5 `
            -SkipHttpErrorCheck `
            -StatusCodeVariable statusCode

        if ($statusCode -ne 200) {
            Write-Error "Ruby version $Version not found"
        }

        if ($Latest) {
            $Version = $release.tag_name -replace '^RubyInstaller-'
        }

        $versionsPath = Get-VersionsPath
        $installPath = Join-Path $versionsPath $Version
        $installPackage = Join-Path $versionsPath "$Version.7z"

        $url = $release.assets.Where({ $_.name -ceq "rubyinstaller-$Version-x64.7z" }, 'First').url

        Invoke-WebRequest `
            -Method Get `
            -Uri $url `
            -Headers @{ Accept = 'application/octet-stream' } `
            -OutFile $installPackage `
            -ProgressAction Continue

        7z x -y -bso0 $installPackage "-o$installPath"

        $topLevel = Join-Path $installPath "rubyinstaller-$Version-x64"
        if (Test-Path $topLevel -PathType Container) {
            Move-Item (Join-Path $topLevel *) $installPath
            Remove-Item $topLevel
        }

        Get-RubyVersion -Installed | Where-Object { $_.Version.ToString() -eq $Version }
    }
    catch {
        $global:Error.RemoveAt(0)
        Write-Error $_ -ErrorAction $callerErrorActionPreference
    }
}
