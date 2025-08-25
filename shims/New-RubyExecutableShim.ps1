function New-RubyExecutableShim {

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '',
        Justification = 'Not an exported function'
    )]
    param(
        [ValidateNotNull()]
        [IO.FileInfo] $Executable
    )

    $executableDirectory = $Executable.Directory.FullName
    $fullName = $Executable.FullName

    $body = {

        $ErrorActionPreference = 'Stop'

        $path = ($executableDirectory, $Env:PATH) -join [IO.Path]::PathSeparator

        $ExecutableArgs = $Args

        Invoke-WithEnv -EnvVars @{ PATH = $path } -Script { & $fullName @ExecutableArgs }
    }

    $name = $Executable.BaseName -replace '\.','_'
    $functionName = "Invoke-RbEnvShim--${name}"

    New-Item -Path Function: -Name "global:$functionName" -Value $body.GetNewClosure() > $null

    $aliasName = (Get-Alias -Name $name -ErrorAction Ignore) ? "rb-${name}" : $name
    New-Alias -Name $aliasName -Value $functionName -Scope Global -Force
}
