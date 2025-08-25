function Set-RubyVersion {

    [CmdletBinding(DefaultParameterSetName = 'Shell', SupportsShouldProcess)]
    param(

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

    if ($PSCmdlet.ShouldProcess($PSCmdlet.ParameterSetName, "Set Ruby Version to $Version")) {
        switch ($PSCmdlet.ParameterSetName) {
            'Shell' {
                Set-ShellRubyVersion -Version $Version
            }
            'Local' {
                Set-LocalRubyVersion -Version $Version
            }
            'Global' {
                Set-GlobalRubyVersion -Version $Version
            }
        }
    }
}
