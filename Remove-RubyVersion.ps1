function Remove-RubyVersion {

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ParameterSetName = 'Shell')]
        [switch] $Shell,

        [Parameter(Mandatory, ParameterSetName = 'Local')]
        [switch] $Local
    )

    $callerErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = [Management.Automation.ActionPreference]::Stop

    try {
        switch -Exact ($PSCmdlet.ParameterSetName) {
            'Shell' {
                Set-Item -Path Env:RBENV_VERSION_OLD -Value $Env:RBENV_VERSION -WhatIf:$WhatIfPreference
                Remove-Item -Path Env:RBENV_VERSION -WhatIf:$WhatIfPreference
                break
            }
            'Local' {
                $versionFile = Join-Path $PWD .ruby-version
                Remove-Item $versionFile -Force -WhatIf:$WhatIfPreference
                break
            }
        }
    }
    catch {
        $global:Error.RemoveAt(0)
        Write-Error $_ -ErrorAction $callerErrorActionPreference
    }
}
