
# This function returns the available versions found on the disk.
# Optionally, it constructs the objects used in the script to display
# the what's new document.
function Get-AvailableVersion {
    param ( [switch]$urihashtable )

    $versions = foreach($filename in Get-ChildItem "$PSScriptRoot/relnotes") {
        $fileVersion = $filename -replace ".*(\d)(\d).*",'$1.$2'
        # fix up version 5.0 to 5.1
        $fileVersion = $fileVersion -replace "5.0","5.1"
        $fileVersion
    }

    if ( $urihashtable ) {
        $filenameBase = "What-s-New-in-PowerShell"
        $urlBase = 'https://aka.ms/WhatsNew'
        foreach ( $version in $versions ) {
            $fileVersion = $version -replace "\."
            if ( $fileVersion -eq "51" ) {
                $fileBase = "What-s-New-in-Windows-PowerShell-50"
            } elseif ( $fileVersion -like "6*" ) {
                $fileBase = "${filenameBase}-Core-${fileVersion}"
            } else {
                $fileBase = "${filenameBase}-${fileVersion}"
            }
            @{
                # construct the hashtable
                version = $version
                path = Join-Path -Path $PSScriptRoot "relnotes/${fileBase}.md"
                url = "${urlBase}${fileVersion}"
            }
        }
    }
    else {
        $versions | Sort-Object
    }
}

function TestVersion {
    param ( [string[]]$versions )
    $allowedVersions = Get-AvailableVersion
    foreach ($version in $versions) {
        if ( $version -notmatch "\." ) {
            $version = "${version}.0"
        }
        if ( $allowedVersions -notcontains $version ) {
            throw ("'$version' not in: " + ( $allowedVersions -join ", "))
        }
    }
    return $true
}
<#
    .SYNOPSIS
    Displays release notes for a version of PowerShell.

    .DESCRIPTION
    This cmdlet allows you to see What's New information from the release notes for PowerShell. By
    default it shows the release notes for the current version of PowerShell you are running. You
    can also provide a specific version or a range of versions to be displayed.

    The cmdlet can display release notes for the following versions of PowerShell
    - Windows PowerShell 5.1
    - PowerShell 6.0
    - PowerShell 6.1
    - PowerShell 6.2
    - PowerShell 7.0
    - PowerShell 7.1
    - PowerShell 7.2
    - PowerShell 7.3 (preview)

    By default, the cmdlet shows all of the release notes for a version. You can also limit it to
    display a single random section of the release notes. This can be used as a "Message of the Day".

    .EXAMPLE
    Get-WhatsNew

    Displays the release notes for the version of PowerShell in which the cmdlet is running.

    .EXAMPLE
    Get-WhatsNew -Version 5.1

    Displays the release notes for PowerShell 5.1 regardless of which version the cmdlet is running.

    .EXAMPLE
    Get-WhatsNew -Daily -Version 7.0, 7.1, 7.2

    Displays one randomly selected section of the release notes per version of PowerShell selected.

    .EXAMPLE
    Get-WhatsNew -All

    Displays all of the releases for all versions supported by the cmdlet.

    .EXAMPLE
    Get-WhatsNew -Online -Version 7.3

    Opens your web browser and takes you to the webpage for the specified version of the release
    notes. If no version is specified, it uses the current version.

    .EXAMPLE
    Get-WhatsNew -Version 7.0, 7.1, 7.2

    Displays the release notes for PowerShell 7.0 through PowerShell 7.2.
#>
function Get-WhatsNew {
    [CmdletBinding(DefaultParameterSetName = 'ByVersion')]
    param (
        # The version number of PowerShell to be displayed. If not specified, the current version is used.
        [Parameter(Position=0,ParameterSetName='ByVersion')]
        [Parameter(Position=0,ParameterSetName='ByVersionDaily')]
        [Parameter(Position=0,ParameterSetName='ByVersionOnline')]
        [ValidateScript({TestVersion $_})]
        [string[]]$Version,

        # Dislays a single section of the releases for a version. Alias = `MOTD`.
        [Parameter(Mandatory,ParameterSetName='ByVersionDaily')]
        [Alias('MOTD')]
        [switch]$Daily,

        # Takes you to the release notes webpage for the specified version.
        [Parameter(Mandatory,ParameterSetName='ByVersionOnline')]
        [switch]$Online,

        # Displays release notes for all versions.
        [Parameter(Mandatory,ParameterSetName='AllVersions')]
        [switch]$All
    )

    if ($Version.Count -eq 0) {
        $Version = '{0}.{1}' -f $PSVersionTable.PSVersion.Major, $PSVersionTable.PSVersion.Minor
    }

    $Version = $Version | ForEach-Object {
        if ( $_ -notmatch "\." ) {
            "${_}.0"
        } else {
            $_
        }
    }
    if ($All) {
        $versions = Get-AvailableVersion -uriHashtable
    } else {
        $versions = Get-AvailableVersion -uriHashtable | Where-Object {$_.version -in $Version}
    }

    # Resolve parameter set
    $mdfiles = @()
    if ($PsCmdlet.ParameterSetName -eq 'AllVersions') {
        $mdfiles = ($versions).path
    } else {
        $mdfiles = ($versions | Where-Object {$_.version -in $Version}).path
    }

    if ($PsCmdlet.ParameterSetName -eq 'ByVersionOnline') {
        if ($Version.Count -gt 1) {
            Write-Warning 'This -Online parameter only supports one value for -Version. Using first value.'
        }
        Start-Process ($versions | Where-Object {$_.version -in $Version[0]}).url
        return
    }

    # Scan release notes for H2 blocks
    $endMarker = '<!-- end of content -->'
    foreach ($file in $mdfiles) {
        $mdtext = Get-Content $file -Encoding utf8
        $mdheaders = Select-String -Pattern '^##\s',$endMarker -Path $file

        ## Build a list of H2 blocks
        $blocklist = @()
        foreach ($hdr in $mdheaders) {
            if ($hdr.Line -ne $endMarker) {
                $block = @{
                    Name      = $hdr.Line.Trim()
                    StartLine = $hdr.LineNumber - 1
                    EndLine   = -1
                }
                $blocklist += $block
            } else {
                $blocklist[-1].EndLine = $hdr.LineNumber - 2
            }
        }
        if ($blocklist.Count -gt 0) {
            for ($x = 0; $x -lt $blocklist.Count; $x++) {
                if ($blocklist[$x].EndLine -eq -1) {
                    $blocklist[$x].EndLine = $blocklist[($x + 1)].StartLine - 1
                }
            }
        }

        if ( $file[-5] -eq '5') {
            $fileVersion = '5.1'
        } else {
            $fileVersion = '{0}.{1}' -f $file[-5], $file[-4]
        }
        '# Release notes for PowerShell {0}{1}' -f $fileVersion, [System.Environment]::NewLine
        if ($Daily) {
            $block = $blocklist | Get-Random -SetSeed (get-date -UFormat '%s')
            $mdtext[$block.StartLine..$block.EndLine]
        } else {
            foreach ($block in $blocklist) {
                $mdtext[$block.StartLine..$block.EndLine]
            }
        }
    }
}

$sbVersions = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    Get-AvailableVersion |
        Where-Object {$_ -like "$wordToComplete*"} |
        ForEach-Object { "'$_'"}
}
Register-ArgumentCompleter -CommandName Get-WhatsNew -ParameterName Version -ScriptBlock $sbVersions
