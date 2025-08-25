function New-RubyScriptShim {

    param(
        [ValidateNotNull()]
        [IO.FileInfo] $Executable
    )

    $name = $Executable.BaseName -replace '\.','_'
    $functionName = "Invoke-RbEnvShim--${name}"
    $fullName = $Executable.FullName

    Invoke-Expression @"
function global:${functionName} {
    Invoke-RbEnvShim--ruby -x '$fullName' @Args
}
"@

    $aliasName = (Get-Alias -Name $name -ErrorAction Ignore) ? "rb-${name}" : $name
    New-Alias -Name $aliasName -Value $functionName -Scope Global -Force
}
