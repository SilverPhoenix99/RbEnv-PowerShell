function New-RubyExecutableShim {

    param(
        [ValidateNotNull()]
        [IO.FileInfo] $Executable
    )

    $name = $Executable.BaseName -replace '\.','_'
    $functionName = "Invoke-RbEnvShim--${name}"
    $path = $Executable.Directory.FullName
    $fullName = $Executable.FullName

    Invoke-Expression @"
function global:${functionName} {

    `$ErrorActionPreference = 'Stop'

    `$execArgs = `$Args

    Invoke-WithEnv ``
        -EnvVars @{
            PATH = ('$path', `$Env:PATH) -join [IO.Path]::PathSeparator
        } ``
        -Script {
            & '${fullName}' @execArgs
        }
}
"@

    $aliasName = (Get-Alias -Name $name -ErrorAction Ignore) ? "rb-${name}" : $name
    New-Alias -Name $aliasName -Value $functionName -Scope Global -Force
}
