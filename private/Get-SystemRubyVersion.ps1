[char[]] $script:DIRECTORY_SEPARATORS = @([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar)

function Get-SystemRubyVersion {

    [CmdletBinding()]
    [OutputType([RubyVersionDescriptor])]
    param()

    $callerErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = [Management.Automation.ActionPreference]::Stop

    try {

        $rubyPath = (Get-Command ruby -CommandType Application -ErrorAction Ignore).Source
        if (!$rubyPath) {
            Write-Error 'ruby not found in $Env:PATH' `
                -RecommendedAction 'If ruby is installed, please add it to $Env:PATH.'
        }

        # Check if it's inside the versions directory.
        # If it is, then use the name of the directory as the version.
        $versionsPath = (Get-VersionsPath).FullName
        $versionsPath = $versionsPath.TrimEnd($script:DIRECTORY_SEPARATORS)
        $versionsPath += [IO.Path]::DirectorySeparatorChar

        $version = if ($rubyPath -like "$versionsPath*") {
            $rubyPath.Substring($versionsPath.Length).Split($script:DIRECTORY_SEPARATORS, 2)[0]
        }
        else {
            $versionString = & $rubyPath -v
            $versionString = $versionString | Select-String '\b\d+\.\d+\.\d+\S*'
            $versionString = $versionString.Matches.Value
        }

        $version = $version -split '[.-]'

        $version = [RubyVersion]::new(
            $version[0],
            $version[1],
            $version[2],
            $version[3] ?? 0
        )

        $rubyPath = Split-Path $rubyPath -Parent
        if ((Split-Path $rubyPath -Leaf) -eq 'bin') {
            $rubyPath = Split-Path $rubyPath -Parent
        }

        return [RubyVersionDescriptor]::new(
            $version,
            [RubyConfiguration]::System,
            (Get-Item -LiteralPath $rubyPath),
            'Env:PATH'
        )
    }
    catch {
        $global:Error.RemoveAt(0)
        Write-Error $_ -ErrorAction $callerErrorActionPreference
    }
}
