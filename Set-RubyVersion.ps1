function Set-RubyVersion {

    [CmdletBinding(DefaultParameterSetName = 'Shell', SupportsShouldProcess)]
    param(

        [ArgumentCompleter({
            param($cmd, $param, $wordToComplete)
            (Get-RubyVersion -Installed).
                ForEach({ $_.Version.ToString() }).
                Where({ $_ -like "${wordToComplete}*" })
        })]
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string] $Version,

        [Parameter(ParameterSetName = 'Shell')]
        [switch] $Shell,

        [Parameter(ParameterSetName = 'Local', Mandatory)]
        [switch] $Local,

        [Parameter(ParameterSetName = 'Global', Mandatory)]
        [switch] $Global
    )

    $callerErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = [Management.Automation.ActionPreference]::Stop

    try {
        if ($PSCmdlet.ShouldProcess($PSCmdlet.ParameterSetName, "Set Ruby Version to $Version")) {
            switch -Exact ($PSCmdlet.ParameterSetName) {
                'Shell' {
                    Set-ShellRubyVersion -Version $Version
                    break
                }
                'Local' {
                    Set-LocalRubyVersion -Version $Version
                    break
                }
                'Global' {
                    Set-GlobalRubyVersion -Version $Version
                    break
                }
            }
        }
    }
    catch {
        $global:Error.RemoveAt(0)
        Write-Error $_ -ErrorAction $callerErrorActionPreference
    }
}
