
# This will return the available versions found on the disk.
# Optionally, it will construct the objects used in the script
# to display the what's new document.
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
            }
            else {
                $fileBase = "${filenameBase}-${fileVersion}"
            }
            @{
                # construct the hashtable
                version = $version
                path = Join-Path -Path $PSScriptRoot -ChildPath relnotes -Additional "${fileBase}.md"
                url = "${urlBase}${fileVersion}"
            }
        }
    }
    else {
        $versions | Sort-Object
    }
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
    Get-WhatsNew -Daily -Version 7.2

    Displays one randomly selected section of the release notes for PowerShell 7.2.

    .EXAMPLE
    Get-WhatsNew -All

    Displays all of the releases for all versions supported by the cmdlet.

    .EXAMPLE
    Get-WhatsNew -Online -Version 7.3

    Opens your web browser and takes you to the webpage for the specified version of the release
    notes. If no version is specified, it uses the current version.

    .EXAMPLE
    Get-WhatsNew -Version 7.2 -EndVersion 5.1

    Displays the release notes for PowerShell 5.1 through PowerShell 7.2. The order of the values
    for parameters does not matter. Use this when you want to see what has change over a range of
    versions.
#>
function Get-WhatsNew {
    [CmdletBinding(DefaultParameterSetName = 'ByVersion')]
    param (
        # The version number of PowerShell to be displayed. If not specified, the current version is used.
        [Parameter(Position=0,ParameterSetName='ByVersion')]
        [Parameter(Position=0,ParameterSetName='ByVersionRange')]
        [ValidateScript({TestVersion $_})]
        [string]$Version,

        # The version number of PowerShell used to defined the range of versions to be displayed.
        [Parameter(Mandatory,ParameterSetName='ByVersionRange')]
        [ValidateScript({TestVersion $_})]
        [string]$EndVersion,

        # Displays release notes for all versions.
        [Parameter(Mandatory,ParameterSetName='AllVersions')]
        [switch]$All,

        # Dislays a single section of the releases for a version. Alias = `MOTD`.
        [Parameter(Position=0,ParameterSetName='ByVersion')]
        [Alias('MOTD')]
        [switch]$Daily,

        # Takes you to the release notes webpage for the specified version.
        [Parameter(ParameterSetName='ByVersion')]
        [switch]$Online
    )

    $versions = Get-AvailableVersion -uriHashtable

    if (0 -eq $Version) {
        $Version = [double]('{0}.{1}' -f $PSVersionTable.PSVersion.Major,$PSVersionTable.PSVersion.Minor)
    }

    # Resolve parameter set
    $mdfiles = @()
    if ($PsCmdlet.ParameterSetName -eq 'EndVersion') {
        if ($Version -gt $EndVersion) {
            $tempver = $EndVersion
            $EndVersion = $Version
            $Version = $tempver
        }
        foreach ($ver in $versions) {
            if (($ver.version -ge $Version) -and ($ver.version -le $EndVersion)) {
                $mdfiles += $ver.path
            }
        }
    } elseif ($PsCmdlet.ParameterSetName -eq 'AllVersions') {
        $mdfiles = ($versions).path
    } else {
        $mdfiles = ($versions | Where-Object version -eq $Version).path
    }

    # Scan release notes for H2 blocks
    $endMarker = '<!-- end of content -->'
    foreach ($file in $mdfiles) {
        $mdtext = Get-Content $file -Encoding utf8
        $mdheaders = Select-String -Pattern '^##\s',$endMarker -Path $file

        $blocklist = @()

        ## Build a list of H2 blocks
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

        if ($Daily) {
            $block = $blocklist | Get-Random -SetSeed (get-date -UFormat '%s')
            $mdtext[$block.StartLine..$block.EndLine]
        } elseif ($Online) {
            Start-Process ($versions | Where-Object version -eq $Version).url
        } else {
            foreach ($block in $blocklist) {
                $mdtext[$block.StartLine..$block.EndLine]
            }
        }
    }
}
