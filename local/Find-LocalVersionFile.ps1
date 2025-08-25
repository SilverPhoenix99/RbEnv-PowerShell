function Find-LocalVersionFile {

    [OutputType([IO.FileInfo])] # Nullable
    param(
        [ValidateNotNull()]
        [Parameter(Position = 0)]
        [IO.DirectoryInfo] $TargetDir
    )

    (Get-DirectoryAncestors $TargetDir). `
        ForEach({ Join-Path $_.FullName .ruby-version }). `
        Where({ Test-Path $_ -PathType Leaf }, 'First')
}
