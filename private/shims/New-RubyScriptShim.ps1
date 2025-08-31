function New-RubyScriptShim {

    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '',
        Justification = 'Not an exported function'
    )]
    param(
        [ValidateNotNull()]
        [IO.FileInfo] $Executable
    )

    $callerErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = [Management.Automation.ActionPreference]::Stop

    try {
        $body = &{
            $fullName = $Executable.FullName

            # Shims are NOT advanced functions, so they can't control ErrorAction.
            # This prevents inheriting the caller's ErrorActionPreference here.
            $ErrorActionPreference = [Management.Automation.ActionPreference]::Continue

            { Invoke-RbEnvShim--ruby -x $fullName @Args }.GetNewClosure()
        }

        $name = $Executable.BaseName -replace '\.','_'
        $functionName = "Invoke-RbEnvShim--${name}"

        New-Item -Path Function: -Name "global:$functionName" -Value $body > $null

        $aliasName = (Get-Alias -Name $name -ErrorAction Ignore) ? "rb-${name}" : $name
        New-Alias -Name $aliasName -Value $functionName -Scope Global -Force
    }
    catch {
        $global:Error.RemoveAt(0)
        Write-Error $_ -ErrorAction $callerErrorActionPreference
    }
}
