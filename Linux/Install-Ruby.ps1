function Install-Ruby {

    [CmdletBinding(DefaultParameterSetName = 'Version')]
    param(
        [ValidateNotNullOrWhiteSpace()]
        [Parameter(Mandatory, ParameterSetName = 'Version')]
        [string] $Version,

        [Parameter(Mandatory, ParameterSetName = 'Latest')]
        [switch] $Latest

        # TODO: [switch] $Force # To reinstall on top of an existing installation. Won't affect gems.
    )

    Write-Error 'Ruby installation is only supported on Windows.'
}
