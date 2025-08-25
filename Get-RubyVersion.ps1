<#
Show the current Ruby version and its origin.

Shows the currently selected Ruby version and how it was selected.

If -All is passed, it shows the configured versions
for shell, local, global, and system, that it can find.
#>
function Get-RubyVersion {

    # Never $null
    param(
        [switch] $All
    )

    $shell  = try { Get-ShellRubyVersion } catch { $null }
    $local  = try { Get-LocalRubyVersion } catch { $null }
    $global = try { Get-GlobalRubyVersion } catch { $null }
    $system = try { Get-SystemRubyVersion } catch { $null }

    $versions = $shell, $local, $global, $system `
        | Where-Object { $_ }

    if (!$versions) {
        throw 'No ruby installation found'
    }

    return $All ? $versions : ($versions | Select-Object -First 1)
}
