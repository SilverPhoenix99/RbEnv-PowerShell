<#
Shows Ruby version(s) currently in use, installed, or remote.
#>
function Get-RubyVersion {

    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [OutputType([RubyVersionDescriptor[]])]
    param(
        [Parameter(Mandatory, ParameterSetName = 'Current')]
        [switch] $Current,

        [Parameter(Mandatory, ParameterSetName = 'Configured')]
        [switch] $Configured,

        [Parameter(Mandatory, ParameterSetName = 'Installed')]
        [switch] $Installed,

        [Parameter(Mandatory, ParameterSetName = 'All')]
        [Parameter(Mandatory, ParameterSetName = 'RemoteAll')]
        [switch] $All,

        [Parameter(Mandatory, ParameterSetName = 'Remote')]
        [Parameter(Mandatory, ParameterSetName = 'RemoteAll')]
        [switch] $Remote
    )

    $callerErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = [Management.Automation.ActionPreference]::Stop

    try {

        $enabled = switch -Exact ($PSCmdlet.ParameterSetName) {
            'Default'    { $true }
            'Current'    { $Current }
            'Configured' { $Configured }
            'Installed'  { $Installed }
            'All'        { $All }
            'Remote'     { $Remote }
            'RemoteAll'  { $Remote }
        }

        if (-not $enabled) {
            # Weird flex, but ok
            Write-Error "All switches are disabled."
        }

        if ($PSCmdlet.ParameterSetName -eq 'Default') {
            $Current = $true
        }

        if ($Remote -and !$IsWindows) {
            Write-Error 'Remote version lookup is only supported on Windows.'
        }

        $shell = Get-ShellRubyVersion  -ErrorAction Ignore
        if ($shell -and $Current) {
            return $shell
        }

        $local = Get-LocalRubyVersion  -ErrorAction Ignore
        if ($local -and $Current) {
            return $local
        }

        $global = Get-GlobalRubyVersion -ErrorAction Ignore
        if ($global -and $Current) {
            return $global
        }

        $system = Get-SystemRubyVersion -ErrorAction Ignore
        if ($system -and $Current) {
            return $system
        }

        $configuredVersions = $shell, $local, $global, $system `
            | Where-Object { $_ } `
            | Group-Object Version `
            | ForEach-Object {
                $desc = $_.Group[0]
                foreach ($item in $_.Group) {
                    $desc.Configuration = $desc.Configuration -bor $item.Configuration
                }
                $desc.Source = $_.Group.Source
                $desc
            }

        if ($Configured) {

            if (!$configuredVersions) {
                Write-Error 'No ruby installation found' `
                    -RecommendedAction 'Ensure that Ruby installations are present and that RbEnv is configured to find them.'
            }

            return $configuredVersions
        }

        $configuredVersions = $configuredVersions | ForEach-Object {$h = @{}} { $h[$_.Version] = $_ } {$h}

        $versions = [Collections.Generic.List[RubyVersionDescriptor]]::new()

        $versionsPath = Get-VersionsPath
        foreach ($installPath in $versionsPath.EnumerateDirectories()) {

            $version = [RubyVersion]::Parse($installPath.Name)

            $descriptor = $configuredVersions[$version]
            if (!$descriptor) {
                $descriptor = [RubyVersionDescriptor]::new($version, $null, $installPath, $null)
            }

            $versions.Add($descriptor)
        }

        # NB: Can't check $All directly, because it's also used with $Remote.
        if ($Installed -or $PSCmdlet.ParameterSetName -eq 'All') {

            if($versions.Count -eq 0) {
                Write-Error 'No ruby installation found' `
                    -RecommendedAction 'Ensure that Ruby installations are present and that RbEnv is configured to find them.'
            }

            return $versions | Sort-Object Version -Descending
        }

        ## $Remote ####################

        $installedVersions = $versions | ForEach-Object {$h = @{}} { $h[$_.Version] = $_ } {$h}

        $remoteVersions = Get-RemoteRubyVersion -All:$All -ErrorAction Ignore

        $versions = [Collections.Generic.List[RubyVersionDescriptor]]::new()

        foreach ($remoteVersion in $remoteVersions.Version) {

            $descriptor = $installedVersions[$remoteVersion]

            if ($descriptor) {
                $descriptor.Configuration = $descriptor.Configuration -bor [RubyConfiguration]::Remote
            }
            else {
                $descriptor = [RubyVersionDescriptor]::new(
                    $remoteVersion,
                    [RubyConfiguration]::Remote,
                    $null,
                    $null
                )
            }

            $versions.Add($descriptor)
        }

        return $versions | Sort-Object Version -Descending
    }
    catch {
        $global:Error.RemoveAt(0)
        Write-Error $_ -ErrorAction $callerErrorActionPreference
    }
}
