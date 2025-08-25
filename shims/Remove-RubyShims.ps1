function Remove-RubyShims {

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '',
        Justification = 'Not an exported function'
    )]
    param()

    # Remove all existing shims:
    # - aliases
    # - functions

    $shims = Get-RubyShims

    if ($shims.Aliases) {
        Remove-Alias -Name $shims.Aliases -Force
    }

    if ($shims.Functions) {
        Remove-Item -LiteralPath $shims.Functions.PSPath -Force
    }
}
