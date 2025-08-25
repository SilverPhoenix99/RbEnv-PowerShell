
$script:EXECUTABLE_FLAGS = [IO.UnixFileMode] 'UserExecute,GroupExecute,OtherExecute'

function Get-ExecutableType {

    [OutputType([string])] # Nullable
    param(
        [ValidateNotNull()]
        [IO.FileInfo] $Executable
    )

    if ($IsWindows -and $Executable.Extension -eq 'exe') {
        return 'Executable'
    }

    if ($Executable.Extension) {
        Write-Verbose "[Get-ExecutableType] $($Executable.Name) has unknown extension"
        return $null
    }

    # no extension

    if ($IsLinux -and (($Executable.UnixFileMode -band $script:EXECUTABLE_FLAGS) -eq [IO.UnixFileMode]::None)) {
        # in Linux, it's not a executable
        Write-Verbose "[Get-ExecutableType] $($Executable.Name) is not a Linux executable"
        return $null
    }

    # check if it's a binary executable, or a shell script

    [char[]] $buffer = [char[]]::new(2)
    $reader = $Executable.OpenText()
    try {
        $count = $reader.Read($buffer, 0, $buffer.Length)
    }
    finally {
        $reader.Close()
    }

    $buffer = $buffer[0..($count-1)]
    $string = [string]::new($buffer, 0, $buffer.Length)

    if ($string -eq '#!') {
        return 'Script'
    }

    if ($IsLinux) {
        return 'Executable'
    }

    Write-Verbose "[Get-ExecutableType] $($Executable.Name) is an unknown executable"

    return $null
}
