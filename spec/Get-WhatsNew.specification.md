---
RFC: RFC00XX
Author: Jason Helmick
Status: Draft
SupercededBy: N/A
Version: 1.0
Area: Core
Comments Due: 4/30/2022
Plan to implement: Yes
---
# Get-WhatsNew

[Get-WhatsNew](https://github.com/PowerShell/WhatsNew) is a cmdlet that provides information about
changes and new features for a version of PowerShell, delivered to the local terminal experience.

## Motivation

Customers are unaware of benefits, new features and changes, that could impact their automation,
performance and security. Today, this useful information is provided through
[Microsoft Docs](https://docs.microsoft.com/powershell/scripting/whats-new/what-s-new-in-powershell-70)
and the PowerShell GitHub repository. PowerShell customers would benefit from being able to get this
information in the terminal as they expect.

- Customers expect to learn about available features that may enable new solutions
- Customers expect version specific information available from within PowerShell to make upgrade
  decisions.

> As an admin,
> I can list the new features released in my current version of PowerShell, similar
> to [webview](https://docs.microsoft.com/powershell/scripting/whats-new/what-s-new-in-powershell-72)
> so that I can discover and implement new features in managing my products.

> As a developer,
> I can list the new features released in my current version of PowerShell, similar
> to [webview](https://docs.microsoft.com/powershell/scripting/whats-new/what-s-new-in-powershell-72)
> so that I can discover and implement new features to develop automation solutions.

## Goals/Non-Goals

The WhatsNew module is not intended to be included with PowerShell. This will be published as a
separate module on the Gallery supporting PowerShell 7 and down-level to Windows PowerShell 5.1.

Goals

- Be distributed as a PowerShell module on the Gallery
- Support disconnected scenarios (data ships with module)
- Supports Windows PowerShell 5.1
- Supports a message-of-the-day (motd) option
- Provides easy access to the web version of the release notes
- Output is text-only

Non-goals/Alternatives

- Provide data model for filtering and pipelining of the output
- Ability to compare versions
- Data endpoint (Microservice) to synchronously deliver or update the data.
- Changelog information

Future feature considerations

- Render markdown output in the console with ANSI styling (enabled by switch parameter)
- Convert GitHub issue and PR IDs to hyperlinks
- Convert markdown hyperlinks to fully-qualified URLs
- Use ANSI strings to make hyperlinks clickable for terminals that support it
- Expand cmdlet to support What's New information from other data sources (eg. Az PowerShell, etc.)
- Add `Get-Changelog` cmdlet to display Changelog information

## Solution

Ship a **Microsoft.PowerShell.WhatsNew** module on the PowerShell Gallery that contains the cmdlet
and would:

- Be discoverable using normal PowerShell conventions
- Be available down-level to Windows PowerShell 5.1

## Specification

This specification is based on the cmdlet [Get-WhatsNew](https://github.com/PowerShell/WhatsNew)

- Module Name: Microsoft.PowerShell.WhatsNew
- Cmdlet name: Get-WhatsNew
- Alias: none

### Syntax and parameter sets

- ByVersion (Default)

```
Get-WhatsNew [[-Version] <string[]>] [<CommonParameters>]
```

- ByVersionOnline

```
Get-WhatsNew [[-Version] <string[]>] -Online [<CommonParameters>]
```

- ByVersionDaily

```
Get-WhatsNew [[-Version] <string[]>] -Daily [<CommonParameters>]
```

- AllVersions

```
Get-WhatsNew -All [<CommonParameters>]
```

The **Version** parameter has validation for all of the versions of the release notes included in
the module. The version list is built dynamically and validated using `[ValidateScript()]`. There is
also an argument completer for the parameter.

### Data model

To minimize content maintenance and allow for disconnected scenarios, the data presented is stored
with the module as version-specific markdown files.

- Uses the same markdown files as the
  [webview](https://docs.microsoft.com/powershell/scripting/whats-new/what-s-new-in-powershell-72)
- Version files are updated in the module at the time of a new release or a major change to the
  release notes
- This allows for disconnected scenarios
- Minimizes the maintenance of the content
- Update support
  - Updates to the data require publishing a new version of the module to the Gallery
  - To get the latest data, the user runs `Update-Module`
  - Eliminates the need for a Microservice to serve the data or updates

### Output

Output from the cmdlet is in the form of markdown strings that are displayed to the terminal.

### Demo.txt - Features

Example 1: Displays the release notes for the version of PowerShell in which the cmdlet is running.

```powershell
PS> Get-WhatsNew
```

Example 2: Displays the release notes for PowerShell 5.1 regardless of which version the cmdlet is
running.

```powershell
PS> Get-WhatsNew -Version '5.1'
```

Example 3: Displays one randomly selected section of the release notes per version of PowerShell
selected.

```powershell
PS> Get-WhatsNew -Daily -Version '7.0', '7.1', '7.2'
```

Example 4: Displays all of the releases for all versions supported by the cmdlet.

```powershell
PS> Get-WhatsNew -All
```

Example 5: Opens your web browser and takes you to the webpage for the specified version of the
release notes. If no version is specified, it uses the current version.

```powershell
PS> Get-WhatsNew -Online -Version '7.3', '7.2'
```

If you specify multiple versions with `-Online`, the cmdlet displays a warning but opens the webpage
for the first version listed.

Example 6: Displays the release notes for PowerShell 7.0 through PowerShell 7.2.

```powershell
PS> Get-WhatsNew -Version '7.0', '7.1', '7.2'
```
