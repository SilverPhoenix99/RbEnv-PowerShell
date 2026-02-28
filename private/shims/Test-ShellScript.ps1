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
