function Get-SystemRubyVersion {

    [OutputType([RubyVersionDescriptor])] # Never $null
    param()

    $rubyPath = Get-Command ruby -CommandType Application -ErrorAction Ignore
    if (!$rubyPath) {
        throw 'ruby not found in Env:PATH'
    }

    $rubyPath = Split-Path $rubyPath.Source -Parent
    if ((Split-Path $rubyPath -Leaf) -eq 'bin') {
        $rubyPath = Split-Path $rubyPath -Parent
    }

    [RubyVersionDescriptor]::new(
        'System',
        'system',
        'Env:PATH',
        [IO.DirectoryInfo] $rubyPath
    )
}
