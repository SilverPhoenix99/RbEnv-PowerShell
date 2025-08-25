function Read-VersionFile {

    [OutputType([string])] # Nullable
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [IO.FileInfo] $File
    )

    if (!$File.Exists -or $File.Length -eq 0) {
        return $null
    }

    [char[]] $buffer = [char[]]::new(1024)
    $reader = $File.OpenText()
    try {
        $count = $reader.Read($buffer, 0, $buffer.Length)
    }
    finally {
        $reader.Close()
    }

    $buffer = $buffer[0..($count-1)]
    $buffer = $buffer.Where({ $_ -match "[`n`r]" }, 'Until')
    return [string]::new($buffer, 0, $buffer.Length)
}
