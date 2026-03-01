$script:CPU_ARCH = uname -m

$script:ASSERT_MATCHER = "^ruby-(?<version>\d+\.\d+\.\d+)\.${script:CPU_ARCH}_linux\.tar\.gz$"

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
            [object] $Asset
        )

        process {

            if ($Asset.name -notmatch $script:ASSERT_MATCHER) {
                return
            }

            $version = $matches.version

            [PSCustomObject] @{
                Version = [RubyVersion]::Parse($version)
                AssetName = $Asset.name
                AssetUrl = [uri] $Asset.url
            }
        }
    }

    try {

        $versions = Get-GithubRelease | ConvertTo-RubyVersion | Sort-Object Version -Descending

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
