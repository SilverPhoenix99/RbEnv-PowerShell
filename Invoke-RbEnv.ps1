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
            'Versions',
            'Remote',
            'Install'
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
        [Parameter(ParameterSetName = 'Remote')]
        [switch] $All,

        [ArgumentCompleter({
            param($cmd, $param, $wordToComplete)
            (Get-RubyVersion -Installed).
                ForEach({ $_.Version.ToString() }).
                Where({ $_ -like "${wordToComplete}*" })
        })]
        [ValidateNotNullOrWhiteSpace()]
        [Parameter(ParameterSetName = 'GlobalSet', Mandatory, Position = 1)]
        [Parameter(ParameterSetName = 'LocalSet', Mandatory, Position = 1)]
        [Parameter(ParameterSetName = 'ShellSet', Mandatory, Position = 1)]
        [Parameter(ParameterSetName = 'Install', Mandatory, Position = 1)]
        [string] $NewVersion,

        [Parameter(ParameterSetName = 'LocalUnset', Mandatory)]
        [Parameter(ParameterSetName = 'ShellUnset', Mandatory)]
        [switch] $Unset,

        [Parameter(ParameterSetName = 'Remote', Mandatory)]
        [switch] $Remote,

        [Parameter(ParameterSetName = 'Install', Mandatory)]
        [switch] $Install
    )

    $callerErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = [Management.Automation.ActionPreference]::Stop

    try {

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
                if ($All) {
                    return Get-RubyVersion -Installed
                }
                return Get-RubyVersion -Current
            }
            'Versions' {
                return Get-RubyVersion -Installed
            }
            'Remote' {
                return Get-RubyVersion -Remote -All:$All
            }
            'Install' {
                if ($NewVersion) {
                    Install-Ruby -Version $NewVersion
                }
                else {
                    Install-Ruby -Latest
                }
                break
            }
            default {
                Write-Error "Unknown command or not implemented: $($cmd)" `
                    -RecommendedAction 'Call `Invoke-RbEnv -Help` for a list of valid commands'
            }
        }
    }
    catch {
        $global:Error.RemoveAt(0)
        Write-Error $_ -ErrorAction $callerErrorActionPreference
    }
}

New-Alias rbenv Invoke-RbEnv
