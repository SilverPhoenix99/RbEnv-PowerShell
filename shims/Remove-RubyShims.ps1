function Remove-RubyShims {

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
