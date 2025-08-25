function Remove-RubyVersion {

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ParameterSetName = 'Shell')]
        [switch] $Shell,

        [Parameter(Mandatory, ParameterSetName = 'Local')]
        [switch] $Local
    )

    switch -Exact ($PSCmdlet.ParameterSetName) {
        'Shell' {
            Set-Item -Path Env:RBENV_VERSION_OLD -Value $Env:RBENV_VERSION -WhatIf:$WhatIfPreference
            Remove-Item -Path Env:RBENV_VERSION -WhatIf:$WhatIfPreference
        }
        'Local' {
            $versionFile = Join-Path $PWD .ruby-version
            Remove-Item $versionFile -Force -WhatIf:$WhatIfPreference
        }
    }
}
