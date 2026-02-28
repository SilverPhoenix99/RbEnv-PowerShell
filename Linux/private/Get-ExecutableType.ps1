$script:EXECUTABLE_FLAGS = [IO.UnixFileMode] 'UserExecute,GroupExecute,OtherExecute'

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
        if (($Executable.UnixFileMode -band $script:EXECUTABLE_FLAGS) -eq [IO.UnixFileMode]::None) {
            Write-Debug "[$($MyInvocation.MyCommand)] $($Executable.Name) is not a Linux executable"
            return $null
        }

        # check if it's a binary executable, or a shell script

        return (Test-ShellScript $Executable) ? 'Script' : 'Executable'
    }
    catch {
        $global:Error.RemoveAt(0)
        Write-Error $_ -ErrorAction $callerErrorActionPreference
    }
}
