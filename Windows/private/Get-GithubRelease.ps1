function Get-GithubRelease {

    [CmdletBinding()]
    param(
        [uint] $Page = 1
    )

    $callerErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = [Management.Automation.ActionPreference]::Stop

    try {

        $response = Invoke-WebRequest `
            -Method Get `
            -Uri 'https://api.github.com/repos/oneclick/rubyinstaller2/releases' `
            -Headers @{ Accept = 'application/vnd.github+json' } `
            -Body @{
                per_page = 100
                page = $Page
            } `
            -ConnectionTimeoutSeconds 2 `
            -OperationTimeoutSeconds 5

        $nextPage = $response.RelationLink.next
        if ($nextPage) {
            $linkUrl = [uri] $nextPage
            $query = [Web.HttpUtility]::ParseQueryString($linkUrl.Query)
            $nextPage = [uint] $query['page']
        }
        else {
            $nextPage = $null
        }

        [PSCustomObject] @{
            NextPage = $nextPage
            Releases = $response.Content | ConvertFrom-Json
        }
    }
    catch {
        $global:Error.RemoveAt(0)
        Write-Error $_ -ErrorAction $callerErrorActionPreference
    }
}
