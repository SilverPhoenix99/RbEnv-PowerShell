$script:CPU_ARCH = switch -Exact ($Env:PROCESSOR_ARCHITECTURE) {
    'x86'   { 'x86' }
    'ARM64' { 'arm' }
    default { 'x64' }
}

$script:ASSET_SUFFIX = "-${script:CPU_ARCH}.7z"

function Get-RemoteRubyVersion {

    [CmdletBinding()] # Never empty
    param(
        [switch] $All
    )

    $callerErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = [Management.Automation.ActionPreference]::Stop

    function ConvertTo-RubyVersion {

        param(
            [ValidateNotNull()]
            [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
            [object] $Release
        )

        process {

            if ($Release.prerelease -or $Release.draft) {
                return
            }

            $tag = $Release.tag_name -replace '^RubyInstaller-'
            $name = "rubyinstaller-${tag}${script:ASSET_SUFFIX}"

            $asset = $Release.assets.Where({ $_.name -eq $name }, 'First')
            if (!$asset) {
                return
            }

            [PSCustomObject] @{
                Version = [RubyVersion]::Parse($tag)
                AssetName = $asset.name
                AssetUrl = [uri] $asset.url
            }
        }
    }

    function Get-GithubVersions {

        param(
            [Parameter(Mandatory, Position = 0)]
            [uint] $Page
        )

        $response = Get-GithubRelease -Owner 'oneclick' -Repository 'rubyinstaller2' -Page $Page

        [PSCustomObject] @{
            NextPage = $response.NextPage
            Versions = $response.Releases | ConvertTo-RubyVersion
        }
    }

    try {

        $response = Get-GithubVersions -Page 1
        $versions = @($response.Versions)

        while ($response.NextPage) {
            $response = Get-GithubVersions -Page $response.NextPage
            $versions += @($response.Versions)
        }

        $versions = $versions | Sort-Object Version -Descending

        if (!$versions) {
            $txt = $All ? 'versions' : 'version'
            Write-Error "No $txt found for CPU Architecture '${script:CPU_ARCH}'"
        }

        return $All ? $versions : $versions[0]
    }
    catch {
        $global:Error.RemoveAt(0)
        Write-Error $_ -ErrorAction $callerErrorActionPreference
    }
}
