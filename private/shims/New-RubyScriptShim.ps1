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
        $fullName = $Executable.FullName

        $body = {

            [CmdletBinding()]
            param()

            $ErrorActionPreference = $PSBoundParameters['ErrorAction'] ?? [Management.Automation.ActionPreference]::Continue

            Invoke-RbEnvShim--ruby -x $fullName @Args
        }

        $name = $Executable.BaseName -replace '\.','_'
        $functionName = "Invoke-RbEnvShim--${name}"

        New-Item -Path Function: -Name "global:$functionName" -Value $body.GetNewClosure() > $null

        $aliasName = (Get-Alias -Name $name -ErrorAction Ignore) ? "rb-${name}" : $name
        New-Alias -Name $aliasName -Value $functionName -Scope Global -Force
    }
    catch {
        $global:Error.RemoveAt(0)
        Write-Error $_ -ErrorAction $callerErrorActionPreference
    }
}
