<#
Show the current Ruby version and its origin.

Shows the currently selected Ruby version and how it was selected.

If -All is passed, it shows the configured versions
for shell, local, global, and system, that it can find.
#>
function Get-RubyVersion {

    [CmdletBinding()]
    [OutputType([RubyVersionDescriptor[]])]
    param(
        [switch] $All
    )

    $callerErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = [Management.Automation.ActionPreference]::Stop

    try {
        $shell  = Get-ShellRubyVersion  -ErrorAction Ignore
        $local  = Get-LocalRubyVersion  -ErrorAction Ignore
        $global = Get-GlobalRubyVersion -ErrorAction Ignore
        $system = Get-SystemRubyVersion -ErrorAction Ignore

        $versions = $shell, $local, $global, $system `
            | Where-Object { $_ }

        if ($versions) {
            return $All ? $versions : $versions[0]
        }

        Write-Error 'No ruby installation found' `
            -RecommendedAction 'Ensure that Ruby installations are present and that RbEnv is configured to find them.'
    }
    catch {
        $global:Error.RemoveAt(0)
        Write-Error $_ -ErrorAction $callerErrorActionPreference
    }
}
