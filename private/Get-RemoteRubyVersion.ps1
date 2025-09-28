if (!$IsWindows) {
    return
}

function Get-RemoteRubyVersion {

    [CmdletBinding()]
    [OutputType([RubyVersionDescriptor[]])]
    param(
        [switch] $All
    )

    $callerErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = [Management.Automation.ActionPreference]::Stop

    try {

        $url = 'https://api.github.com/repos/oneclick/rubyinstaller2/releases'

        if (!$All) {

            $url += '/latest'

            $releases = Invoke-RestMethod `
                -Method Get `
                -Uri $url `
                -Headers @{ Accept = 'application/vnd.github+json' } `
                -ConnectionTimeoutSeconds 2 `
                -OperationTimeoutSeconds 5 `
                -ResponseHeadersVariable headers
        }
        else {

            $response = Invoke-WebRequest `
                -Method Get `
                -Uri $url `
                -Headers @{ Accept = 'application/vnd.github+json' } `
                -Body @{ per_page = 100 } `
                -ConnectionTimeoutSeconds 2 `
                -OperationTimeoutSeconds 5

            $releases = $response.Content | ConvertFrom-Json

            if ($response.RelationLink.last) {

                $linkUrl = [uri] $response.RelationLink.last
                $query = [Web.HttpUtility]::ParseQueryString($linkUrl.Query)
                $lastPage = [uint] $query['page']

                for ($page = 2; $page -le $lastPage; $page++) {

                    $response = Invoke-WebRequest `
                        -Method Get `
                        -Uri $url `
                        -Headers @{ Accept = 'application/vnd.github+json' } `
                        -Body @{ per_page = 100 ; page = $page } `
                        -ConnectionTimeoutSeconds 2 `
                        -OperationTimeoutSeconds 5

                    $releases += $response.Content | ConvertFrom-Json
                }
            }
        }

        return $releases `
            | Where-Object { !$_.prerelease -and !$_.draft } `
            | ForEach-Object {

                $tag = $_.tag_name -replace '^RubyInstaller-'
                $version = [RubyVersion]::Parse($tag)

                [RubyVersionDescriptor]::new(
                    $version,
                    [RubyConfiguration]::Remote,
                    $null,
                    $null
                )
            } `
            | Sort-Object Version -Descending
    }
    catch {
        $global:Error.RemoveAt(0)
        Write-Error $_ -ErrorAction $callerErrorActionPreference
    }
}
