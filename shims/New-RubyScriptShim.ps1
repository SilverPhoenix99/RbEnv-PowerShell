function New-RubyScriptShim {

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '',
        Justification = 'Not an exported function'
    )]
    param(
        [ValidateNotNull()]
        [IO.FileInfo] $Executable
    )

    $fullName = $Executable.FullName

    $body = {
        Invoke-RbEnvShim--ruby -x $fullName @Args
    }

    $name = $Executable.BaseName -replace '\.','_'
    $functionName = "Invoke-RbEnvShim--${name}"

    New-Item -Path Function: -Name "global:$functionName" -Value $body.GetNewClosure() > $null

    $aliasName = (Get-Alias -Name $name -ErrorAction Ignore) ? "rb-${name}" : $name
    New-Alias -Name $aliasName -Value $functionName -Scope Global -Force
}
