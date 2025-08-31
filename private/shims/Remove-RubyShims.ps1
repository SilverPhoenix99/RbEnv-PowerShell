function Remove-RubyShims {

    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '',
        Justification = 'Not an exported function'
    )]
    param()

    # Remove all existing shims:
    # - aliases
    # - functions

    $callerErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = [Management.Automation.ActionPreference]::Stop

    try {
        $shims = Get-RubyShims

        if ($shims.Aliases) {
            Remove-Alias -Name $shims.Aliases -Force
        }

        if ($shims.Functions) {
            Remove-Item -LiteralPath $shims.Functions.PSPath -Force
        }
    }
    catch {
        $global:Error.RemoveAt(0)
        Write-Error $_ -ErrorAction $callerErrorActionPreference
    }
}
