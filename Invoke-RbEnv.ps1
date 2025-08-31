function Invoke-RbEnv {

    [CmdletBinding(DefaultParameterSetName = 'Command', SupportsShouldProcess)]
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

        [ArgumentCompleter({
            param($cmd, $param, $wordToComplete)
            (Get-RubyVersions).Version.Where({ $_ -like "${wordToComplete}*" })
        })]
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
            break
        }
        'Global' {
            return Get-GlobalRubyVersion
        }
        'GlobalGet' {
            return Get-GlobalRubyVersion
        }
        'GlobalSet' {
            Set-RubyVersion -Version $NewVersion -Global -WhatIf:$WhatIfPreference
            break
        }
        'Init' {
            Initialize-RbEnv -WhatIf:$WhatIfPreference
            break
        }
        'Local' {
            return Get-LocalRubyVersion
        }
        'LocalGet' {
            return Get-LocalRubyVersion
        }
        'LocalSet' {
            Set-RubyVersion -Version $NewVersion -Local -WhatIf:$WhatIfPreference
            break
        }
        'LocalUnset' {
            Remove-RubyVersion -Local -WhatIf:$WhatIfPreference
            break
        }
        'Rehash' {
            Update-RubyShims -WhatIf:$WhatIfPreference
            break
        }
        'Root' {
            return Get-RbEnvRoot
        }
        'Shell' {
            return Get-ShellRubyVersion
        }
        'ShellGet' {
            return Get-ShellRubyVersion
        }
        'ShellSet' {
            Set-RubyVersion -Version $NewVersion -Shell -WhatIf:$WhatIfPreference
            break
        }
        'ShellUnset' {
            Remove-RubyVersion -Shell -WhatIf:$WhatIfPreference
            break
        }
        'Shims' {
            return Get-RubyShims
        }
        'Version' {
            return Get-RubyVersion -All:$All
        }
        'Versions' {
            return Get-RubyVersions
        }
        default {
            Write-Error "Unknown command or not implemented: $($cmd)" `
                -RecommendedAction 'Call `Invoke-RbEnv -Help` for a list of valid commands'
        }
    }
}

New-Alias rbenv Invoke-RbEnv
