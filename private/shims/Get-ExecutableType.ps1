
$script:EXECUTABLE_FLAGS = [IO.UnixFileMode] 'UserExecute,GroupExecute,OtherExecute'

if ($IsWindows) {
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
}
elseif ($IsLinux) {
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
}

function Test-ShellScript {

    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [ValidateNotNull()]
        [IO.FileInfo] $Executable
    )

    $callerErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = [Management.Automation.ActionPreference]::Stop

    try {
        [byte[]] $buffer = [byte[]]::new(2)
        $reader = $Executable.OpenRead()
        try {
            $count = $reader.Read($buffer, 0, $buffer.Length)
        }
        finally {
            $reader.Close()
        }

        # Test for shebang '#!'
        return $count -eq 2 -and $buffer[0] -eq 35 -and $buffer[1] -eq 33
    }
    catch {
        $global:Error.RemoveAt(0)
        Write-Error $_ -ErrorAction $callerErrorActionPreference
    }
}
