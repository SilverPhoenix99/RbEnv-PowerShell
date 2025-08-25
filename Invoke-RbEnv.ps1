function Invoke-RbEnv {

    [CmdletBinding(DefaultParameterSetName = 'Command')]
    param(

        [ValidateSet(
            'Help',
            'Global',
            'Init',
            'Local',
            'Rehash',
            'Root',
            'Shell',
            'Shims',
            'Version',
            'Versions'
        )]
        [Parameter(ParameterSetName = 'Command', Position = 0)]
        [string] $Command,

        [Parameter(ParameterSetName = 'Help', Mandatory)]
        [switch] $Help,

        [Parameter(ParameterSetName = 'GlobalGet', Mandatory)]
        [Parameter(ParameterSetName = 'GlobalSet', Mandatory)]
        [switch] $Global,

        [Parameter(ParameterSetName = 'Init', Mandatory)]
        [switch] $Init,

        [Parameter(ParameterSetName = 'LocalGet', Mandatory)]
        [Parameter(ParameterSetName = 'LocalSet', Mandatory)]
        [Parameter(ParameterSetName = 'LocalUnset', Mandatory)]
        [switch] $Local,

        [Parameter(ParameterSetName = 'Rehash', Mandatory)]
        [switch] $Rehash,

        [Parameter(ParameterSetName = 'Root', Mandatory)]
        [switch] $Root,

        [Parameter(ParameterSetName = 'ShellGet', Mandatory)]
        [Parameter(ParameterSetName = 'ShellSet', Mandatory)]
        [Parameter(ParameterSetName = 'ShellUnset', Mandatory)]
        [switch] $Shell,

        [Parameter(ParameterSetName = 'Shims', Mandatory)]
        [switch] $Shims,

        [Parameter(ParameterSetName = 'Version', Mandatory)]
        [switch] $Version,

        [Parameter(ParameterSetName = 'Versions', Mandatory)]
        [switch] $Versions,

        [Parameter(ParameterSetName = 'Version')]
        [switch] $All,

        [ValidateNotNullOrWhiteSpace()]
        [Parameter(ParameterSetName = 'GlobalSet', Mandatory, Position = 1)]
        [Parameter(ParameterSetName = 'LocalSet', Mandatory, Position = 1)]
        [Parameter(ParameterSetName = 'ShellSet', Mandatory, Position = 1)]
        [string] $NewVersion,

        [Parameter(ParameterSetName = 'LocalUnset', Mandatory)]
        [Parameter(ParameterSetName = 'ShellUnset', Mandatory)]
        [switch] $Unset
    )

    $cmd = $PSCmdlet.ParameterSetName
    if ($cmd -eq 'Command') {
        $cmd = $Command
    }

    if (!$cmd) {
        $cmd = 'Help'
    }

    switch -Exact ($cmd) {
        'Help' {
            Get-Help Invoke-RbEnv
        }
        'Global' {
            Get-GlobalRubyVersion
        }
        'GlobalGet' {
            Get-GlobalRubyVersion
        }
        'GlobalSet' {
            Set-GlobalRubyVersion -Version $NewVersion
        }
        'Init' {
            Initialize-RbEnv
        }
        'Local' {
            Get-LocalRubyVersion
        }
        'LocalGet' {
            Get-LocalRubyVersion
        }
        'LocalSet' {
            Set-LocalRubyVersion -Version $NewVersion
        }
        'LocalUnset' {
            $versionFile = Join-Path $PWD .ruby-version
            Remove-Item $versionFile -Force
        }
        'Rehash' {
            Update-RubyShims
        }
        'Root' {
            Get-RbEnvRoot
        }
        'Shell' {
            Get-ShellRubyVersion
        }
        'ShellGet' {
            Get-ShellRubyVersion
        }
        'ShellSet' {
            Set-ShellRubyVersion -Version $NewVersion
        }
        'ShellUnset' {
            $Env:RBENV_VERSION_OLD = $Env:RBENV_VERSION
            $Env:RBENV_VERSION = $null
        }
        'Shims' {
            Get-RubyShims
        }
        'Version' {
            Get-RubyVersion -All:$All
        }
        'Versions' {
            Get-RubyVersions
        }
        default {
            throw "Unknown command or not implemented: $($cmd)"
        }
    }
}

New-Alias rbenv Invoke-RbEnv
