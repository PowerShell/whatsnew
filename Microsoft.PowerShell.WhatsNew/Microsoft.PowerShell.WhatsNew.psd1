# Module manifest for module 'Microsoft.PowerShell.WhatsNew'
@{
RootModule = 'Microsoft.PowerShell.WhatsNew.psm1'
ModuleVersion = '0.3.0'
GUID = 'e49f73fd-7419-4639-84d7-159ebc32645e'
Author = 'sewhee@microsoft.com'
CompanyName = 'Microsoft'
Copyright = '(c) Microsoft Corporation. All rights reserved.'
Description = @'
The Get-WhatsNew cmdlet allows you to see What's New information from the release notes for
PowerShell. By default it shows the release notes for the current version of PowerShell you are
running. You can also provide a specific version or a range of versions to be displayed.

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
'@
PowerShellVersion = '5.1'
FunctionsToExport = 'Get-WhatsNew'
CmdletsToExport = @()
VariablesToExport = '*'
AliasesToExport = @()

FileList = 'relnotes\What-s-New-in-PowerShell-70.md',
           'relnotes\What-s-New-in-PowerShell-71.md',
           'relnotes\What-s-New-in-PowerShell-72.md',
           'relnotes\What-s-New-in-PowerShell-73.md',
           'What-s-New-in-PowerShell-Core-60.md',
           'What-s-New-in-PowerShell-Core-61.md',
           'What-s-New-in-PowerShell-Core-62.md',
           'relnotes\What-s-New-in-Windows-PowerShell-50.md'

PrivateData = @{
    PSData = @{
        Tags = @('WhatsNew','ReleaseNotes','MOTD','MessageOfTheDay')
        LicenseUri = 'https://github.com/PowerShell/whatsnew'
        ProjectUri = 'https://github.com/PowerShell/whatsnew/blob/main/LICENSE'
        RequireLicenseAcceptance = $false
    }
}
}

