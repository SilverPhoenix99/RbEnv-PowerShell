function Get-ExecutableType {

    [CmdletBinding()]
    [OutputType([string])] # Nullable
    param(
        [ValidateNotNull()]
        [IO.FileInfo] $Executable
    )

    $callerErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = [Management.Automation.ActionPreference]::Stop
    try {
        if ($Executable.Extension -eq '.exe') {
            return 'Executable'
        }

        if ($Executable.Extension) {
            Write-Debug "[$($MyInvocation.MyCommand)] $($Executable.Name) has unknown extension"
            return $null
        }

        # no extension

        # check if it's a binary executable, or a shell script

        # Test for shebang '#!'
        if (Test-ShellScript $Executable) {
            return 'Script'
        }

        Write-Debug "[$($MyInvocation.MyCommand)] $($Executable.Name) is an unknown executable"
        return $null
    }
    catch {
        $global:Error.RemoveAt(0)
        Write-Error $_ -ErrorAction $callerErrorActionPreference
    }
}
