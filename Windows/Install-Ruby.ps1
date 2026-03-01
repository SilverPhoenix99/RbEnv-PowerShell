function Install-Ruby {

    [CmdletBinding(DefaultParameterSetName = 'Version')]
    param(
        [ValidateNotNullOrWhiteSpace()]
        [Parameter(Mandatory, ParameterSetName = 'Version', Position = 0)]
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
            # TODO: [switch] $Force
            Write-Warning "Ruby version $Version is already installed."
            return
        }

        $versions = Get-RemoteRubyVersion -All

        $asset = switch -Exact ($PSCmdlet.ParameterSetName) {
            'Version' {
                $versions.Where({ $_.Version.ToString() -eq $Version }, 'First')
            }
            'Latest' {
                $Version = $versions[0].Version.ToString()
                $versions[0]
            }
        }

        if (!$asset) {
            Write-Error "Ruby version $Version not found." `
                -RecommendedAction 'Check available remote versions with Get-RubyVersion -Remote'
        }

        $versionsPath = Get-VersionsPath
        $installPackage = Join-Path $versionsPath $asset.AssetName

        Invoke-WebRequest `
            -Method Get `
            -Uri $asset.AssetUrl `
            -Headers @{ Accept = 'application/octet-stream' } `
            -OutFile $installPackage `
            -ProgressAction Continue

        $baseName = Split-Path $asset.AssetName -LeafBase
        $installPath = Join-Path $versionsPath $baseName
        7z x -y -bso0 -spe "-o$installPath" $installPackage

        $versionPath = Join-Path $versionsPath $Version
        Move-Item $installPath $versionPath
        Remove-Item $installPackage

        Get-RubyVersion -Installed | Where-Object { $_.Version.ToString() -eq $Version }
    }
    catch {
        $global:Error.RemoveAt(0)
        Write-Error $_ -ErrorAction $callerErrorActionPreference
    }
}
