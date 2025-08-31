function Get-SystemRubyVersion {

    [CmdletBinding()]
    [OutputType([RubyVersionDescriptor])]
    param()

    $callerErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = [Management.Automation.ActionPreference]::Stop

    try {

        $rubyPath = Get-Command ruby -CommandType Application -ErrorAction Ignore
        if (!$rubyPath) {
            Write-Error 'ruby not found in $Env:PATH' `
                -RecommendedAction 'If ruby is installed, add it to $Env:PATH.'
        }

        $rubyPath = Split-Path $rubyPath.Source -Parent
        if ((Split-Path $rubyPath -Leaf) -eq 'bin') {
            $rubyPath = Split-Path $rubyPath -Parent
        }

        return [RubyVersionDescriptor]::new(
            'System',
            'system',
            'Env:PATH',
            [IO.DirectoryInfo] $rubyPath
        )
    }
    catch {
        $global:Error.RemoveAt(0)
        Write-Error $_ -ErrorAction $callerErrorActionPreference
    }
}
