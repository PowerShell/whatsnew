---
title: What's New in PowerShell Core 6.0
description: New features and changes released in PowerShell Core 6.0
ms.date: 08/06/2018
---

# What's New in PowerShell Core 6.0

[PowerShell Core 6.0][github] is a new edition of PowerShell that is cross-platform (Windows, macOS,
and Linux), open-source, and built for heterogeneous environments and the hybrid cloud.

## Moved from .NET Framework to .NET Core

PowerShell Core uses [.NET Core 2.0][] as its runtime. .NET Core 2.0 enables PowerShell Core to work
on multiple platforms (Windows, macOS, and Linux). PowerShell Core also exposes the API set offered
by .NET Core 2.0 to be used in PowerShell cmdlets and scripts.

Windows PowerShell used the .NET Framework runtime to host the PowerShell engine. This means that
Windows PowerShell exposes the API set offered by .NET Framework.

The APIs shared between .NET Core and .NET Framework are defined as part of [.NET Standard][].

For more information on how this affects module/script compatibility between PowerShell Core and
Windows PowerShell, see
[Backwards compatibility with Windows PowerShell](#backwards-compatibility-with-windows-powershell).

## Support for macOS and Linux

PowerShell now officially supports macOS and Linux, including:

- Windows 7, 8.1, and 10
- Windows Server 2008 R2, 2012 R2, 2016
- [Windows Server Semi-Annual Channel][semi-annual]
- Ubuntu 14.04, 16.04, and 17.04
- Debian 8.7+, and 9
- CentOS 7
- Red Hat Enterprise Linux 7
- OpenSUSE 42.2
- Fedora 25, 26
- macOS 10.12+

Our community has also contributed packages for the following platforms,
but they are not officially supported:

- Arch Linux
- Kali Linux
- AppImage (works on multiple Linux platforms)

We also have experimental (unsupported) releases for the following platforms:

- Windows on ARM32/ARM64
- Raspbian (Stretch)

A number of changes were made to in PowerShell Core 6.0 to make it work better on non-Windows
systems. Some of these are breaking changes, which also affect Windows. Others are only present or
applicable in non-Windows installations of PowerShell Core.

- Added support for native command globbing on Unix platforms.
- The `more` functionality respects the Linux `$PAGER` and defaults to `less`. This means you can
  now use wildcards with native binaries/commands (for example, `ls *.txt`). (#3463)
- Trailing backslash is automatically escaped when dealing with native command arguments. (#4965)
- Ignore the `-ExecutionPolicy` switch when running PowerShell on non-Windows platforms because
  script signing is not currently supported. (#3481)
- Fixed ConsoleHost to honor `NoEcho` on Unix platforms. (#3801)
- Fixed `Get-Help` to support case insensitive pattern matching on Unix platforms. (#3852)
- `powershell` man-page added to package

### Logging

On macOS, PowerShell uses the native `os_log` APIs to log to Apple's
[unified logging system][os_log]. On Linux, PowerShell uses [Syslog][], a ubiquitous logging
solution.

### Filesystem

A number of changes have been made on macOS and Linux to support filename characters not
traditionally supported on Windows:

- Paths given to cmdlets are now slash-agnostic (both / and \ work as directory separator)
- XDG Base Directory Specification is now respected and used by default:
  - The Linux/macOS profile path is located at `~/.config/powershell/profile.ps1`
  - The history save path is located at
    `~/.local/share/powershell/PSReadline/ConsoleHost_history.txt`
  - The user module path is located at `~/.local/share/powershell/Modules`
- Support for file and folder names containing the colon character on Unix. (#4959)
- Support for script names or full paths that have commas. (#4136) (Thanks to
  [@TimCurwick](https://github.com/TimCurwick)!)
- Detect when `-LiteralPath` is used to suppress wildcard expansion for navigation cmdlets. (#5038)
- Updated `Get-ChildItem` to work more like the *nix `ls -R` and the Windows `DIR /S` native
  commands. `Get-ChildItem` now returns the symbolic links encountered during a recursive search and
  does not search the directories that those links target. (#3780)

### Case sensitivity

Linux and macOS tend to be case-sensitive while Windows is case-insensitive while preserving case.
In general, PowerShell is case insensitive.

For example, environment variables are case-sensitive on macOS and Linux, so the casing of the
`PSModulePath` environment variable has been standardized. (#3255) `Import-Module` is case
insensitive when it's using a file path to determine the module's name. (#5097)

## Support for side-by-side installations

PowerShell Core is installed, configured, and executed separately from Windows PowerShell.
PowerShell Core has a "portable" ZIP package. Using the ZIP package, you can install any number of
versions anywhere on disk, including local to an application that takes PowerShell as a dependency.
Side-by-side installation makes it easier to test new versions of PowerShell and migrating existing
scripts over time. Side-by-side also enables backwards compatibility as scripts can be pinned to
specific versions that they require.

> [!NOTE]
> By default, the MSI-based installer on Windows does an in-place update install.

## Renamed `powershell(.exe)` to `pwsh(.exe)`

The binary name for PowerShell Core has been changed from `powershell(.exe)` to `pwsh(.exe)`. This
change provides a deterministic way for users to run PowerShell Core on machines to support
side-by-side Windows PowerShell and PowerShell Core installations. `pwsh` is also much shorter and
easier to type.

Additional changes to `pwsh(.exe)` from `powershell.exe`:

- Changed the first positional parameter from `-Command` to `-File`. This change fixes the usage of
  `#!` (aka as a shebang) in PowerShell scripts that are being executed from non-PowerShell shells
  on non-Windows platforms. It also means that you can run commands like `pwsh foo.ps1` or
  `pwsh fooScript` without specifying `-File`. However, this change requires that you explicitly
  specify `-c` or `-Command` when trying to run commands like `pwsh.exe -Command Get-Command`.
  (#4019)
- PowerShell Core accepts the `-i` (or `-Interactive`) switch to indicate an interactive shell.
  (#3558) This allows PowerShell to be used as a default shell on Unix platforms.
- Removed parameters `-importsystemmodules` and `-psconsoleFile` from `pwsh.exe`. (#4995)
- Changed `pwsh -version` and built-in help for `pwsh.exe` to align with other native tools. (#4958
  & #4931) (Thanks [@iSazonov](https://github.com/iSazonov))
- Invalid argument error messages for `-File` and `-Command` and exit codes consistent with Unix
  standards (#4573)
- Added `-WindowStyle` parameter on Windows. (#4573) Similarly, package-based installations updates
  on non-Windows platforms are in-place updates.

## Backwards compatibility with Windows PowerShell

The goal of PowerShell Core is to remain as compatible as possible with Windows PowerShell.
PowerShell Core uses [.NET Standard][] 2.0 to provide binary compatibility with existing .NET
assemblies. Many PowerShell modules depend on these assemblies (often times DLLs), so .NET Standard
allows them to continue working with .NET Core. PowerShell Core also includes a heuristic to look in
well-known folders--like where the Global Assembly Cache typically resides on disk--to find .NET
Framework DLL dependencies.

You can learn more about .NET Standard on the [.NET Blog][], in this [YouTube][] video, and via this
[FAQ][] on GitHub.

Best efforts have been made to ensure that the PowerShell language and "built-in" modules (like
`Microsoft.PowerShell.Management`, `Microsoft.PowerShell.Utility`, etc.) work the same as they do in
Windows PowerShell. In many cases, with the help of the community, we've added new capabilities and
bug fixes to those cmdlets. In some cases, due to a missing dependency in underlying .NET layers,
functionality was removed or is unavailable.

Most of the modules that ship as part of Windows (for example, `DnsClient`, `Hyper-V`, `NetTCPIP`,
`Storage`, etc.) and other Microsoft products including Azure and Office have not been *explicitly*
ported to .NET Core yet. The PowerShell team is working with these product groups and teams to
validate and port their existing modules to PowerShell Core. With .NET Standard and [CDXML][], many
of these traditional Windows PowerShell modules do seem to work in PowerShell Core, but they have
not been formally validated, and they are not formally supported.

By installing the [`WindowsPSModulePath`][windowspsmodulepath] module, you can use Windows
PowerShell modules by appending the Windows PowerShell `PSModulePath` to your PowerShell Core
`PSModulePath`.

First, install the `WindowsPSModulePath` module from the PowerShell Gallery:

```powershell
# Add `-Scope CurrentUser` if you're installing as non-admin
Install-Module WindowsPSModulePath -Force
```

After installing this module, run the `Add-WindowsPSModulePath` cmdlet to add the Windows PowerShell
`PSModulePath` to PowerShell Core:

```powershell
# Add this line to your profile if you always want Windows PowerShell PSModulePath
Add-WindowsPSModulePath
```

## Docker support

PowerShell Core adds support for Docker containers for all the major platforms we support (including
multiple Linux distros, Windows Server Core, and Nano Server).

For a complete list, check out the tags on [`microsoft/powershell` on Docker Hub][docker-hub]. For
more information on Docker and PowerShell Core, see [Docker][] on GitHub.

## SSH-based PowerShell Remoting

The PowerShell Remoting Protocol (PSRP) now works with the Secure Shell (SSH) protocol in addition
to the traditional WinRM-based PSRP.

This means that you can use cmdlets like `Enter-PSSession` and `New-PSSession` and authenticate
using SSH. All you have to do is register PowerShell as a subsystem with an OpenSSH-based SSH
server, and you can use your existing SSH-based authenticate mechanisms (like passwords or private
keys) with the traditional `PSSession` semantics.

For more information on configuring and using SSH-based remoting,
see [PowerShell Remoting over SSH][ssh-remoting].

## Default encoding is UTF-8 without a BOM except for New-ModuleManifest

In the past, Windows PowerShell cmdlets like `Get-Content`, `Set-Content` used different encodings,
such as ASCII and UTF-16. The variance in encoding defaults created problems when mixing cmdlets
without specifying an encoding.

Non-Windows platforms traditionally use UTF-8 without a Byte Order Mark (BOM) as the default
encoding for text files. More Windows applications and tools are moving away from UTF-16 and towards
BOM-less UTF-8 encoding. PowerShell Core changes the default encoding to conform with the broader
ecosystems.

This means that all built-in cmdlets that use the `-Encoding` parameter use the `UTF8NoBOM` value by
default. The following cmdlets are affected by this change:

- Add-Content
- Export-Clixml
- Export-Csv
- Export-PSSession
- Format-Hex
- Get-Content
- Import-Csv
- Out-File
- Select-String
- Send-MailMessage
- Set-Content

These cmdlets have also been updated so that the `-Encoding` parameter universally accepts
`System.Text.Encoding`.

The default value of `$OutputEncoding` has also been changed to UTF-8.

As a best practice, you should explicitly set encodings in scripts using the `-Encoding` parameter
to produce deterministic behavior across platforms.

`New-ModuleManifest` cmdlet does not have **Encoding** parameter. The encoding of the module
manifest (.psd1) file created with `New-ModuleManifest` cmdlet depends on environment: if it is
PowerShell Core running on Linux then encoding is UTF-8 (no BOM); otherwise encoding is UTF-16 (with
BOM). (#3940)

## Support backgrounding of pipelines with ampersand (`&`) (#3360)

Putting `&` at the end of a pipeline causes the pipeline to be run as a PowerShell job. When a
pipeline is backgrounded, a job object is returned. Once the pipeline is running as a job, all of
the standard `*-Job` cmdlets can be used to manage the job. Variables (ignoring process-specific
variables) used in the pipeline are automatically copied to the job so `Copy-Item $foo $bar &` just
works. The job is also run in the current directory instead of the user's home directory. For more
information about PowerShell jobs, see
[about_Jobs](/powershell/module/microsoft.powershell.core/about/about_jobs).

## Semantic versioning

- Made `SemanticVersion` compatible with `SemVer 2.0`. (#5037) (Thanks
  [@iSazonov](https://github.com/iSazonov)!)
- Changed default `ModuleVersion` in `New-ModuleManifest` to `0.0.1` to align with SemVer. (#4842)
  (Thanks [@LDSpits](https://github.com/LDSpits))
- Added `semver` as a type accelerator for `System.Management.Automation.SemanticVersion`. (#4142)
  (Thanks to [@oising](https://github.com/oising)!)
- Enabled comparison between a `SemanticVersion` instance and a `Version` instance that is
  constructed only with `Major` and `Minor` version values.

## Language updates

- Implement Unicode escape parsing so that users can use Unicode characters as arguments, strings,
  or variable names. (#3958) (Thanks to [@rkeithhill](https://github.com/rkeithhill)!)
- Added new escape character for ESC: `` `e``
- Added support for converting enums to string (#4318) (Thanks
  [@KirkMunro](https://github.com/KirkMunro))
- Fixed casting single element array to a generic collection. (#3170)
- Added character range overload to the `..` operator, so `'a'..'z'` returns characters from 'a' to
  'z'. (#5026) (Thanks [@IISResetMe](https://github.com/IISResetMe)!)
- Fixed variable assignment to not overwrite read-only variables
- Push locals of automatic variables to 'DottedScopes' when dotting script cmdlets (#4709)
- Enable use of 'Singleline, Multiline' option in split operator (#4721) (Thanks
  [@iSazonov](https://github.com/iSazonov))

## Engine updates

- `$PSVersionTable` has four new properties:
  - `PSEdition`: This is set to `Core` on PowerShell Core and `Desktop` on Windows PowerShell
  - `GitCommitId`: This is the Git commit ID of the Git branch or tag where PowerShell was built.
    On released builds, it will likely be the same as `PSVersion`.
  - `OS`: This is an OS version string returned by
    `[System.Runtime.InteropServices.RuntimeInformation]::OSDescription`
  - `Platform`: This is returned by `[System.Environment]::OSVersion.Platform`
    It is set to `Win32NT` on Windows, `Unix` on macOS, and `Unix` on Linux.
- Removed the `BuildVersion` property from `$PSVersionTable`. This property was strongly tied to the
  Windows build version. Instead, we recommend that you use `GitCommitId` to retrieve the exact
  build version of PowerShell Core. (#3877) (Thanks to [@iSazonov](https://github.com/iSazonov)!)
- Remove `ClrVersion` property from `$PSVersionTable`. This property is irrelevant for .NET Core,
  and was only preserved in .NET Core for specific legacy purposes that are inapplicable to
  PowerShell.
- Added three new automatic variables to determine whether PowerShell is running in a given OS:
  `$IsWindows`, `$IsMacOs`, and `$IsLinux`.
- Add `GitCommitId` to PowerShell Core banner. Now you don't have to run `$PSVersionTable` as soon
  as you start PowerShell to get the version! (#3916) (Thanks to
  [@iSazonov](https://github.com/iSazonov)!)
- Add a JSON config file called `powershell.config.json` in `$PSHome` to store some settings
  required before startup time (e.g. `ExecutionPolicy`).
- Don't block pipeline when running Windows EXE's
- Enabled enumeration of COM collections. (#4553)

## Cmdlet updates

### New cmdlets

- Add `Get-Uptime` to `Microsoft.PowerShell.Utility`.
- Add `Remove-Alias` Command. (#5143) (Thanks [@PowershellNinja](https://github.com/PowershellNinja)!)
- Add `Remove-Service` to Management module. (#4858) (Thanks [@joandrsn](https://github.com/joandrsn)!)

### Web cmdlets

- Add certificate authentication support for web cmdlets. (#4646) (Thanks
  [@markekraus](https://github.com/markekraus))
- Add support for content headers to web cmdlets. (#4494 & #4640) (Thanks
  [@markekraus](https://github.com/markekraus))
- Add multiple link header support to Web Cmdlets. (#5265) (Thanks
  [@markekraus](https://github.com/markekraus)!)
- Support Link header pagination in web cmdlets (#3828)
  - For `Invoke-WebRequest`, when the response includes a Link header we create a RelationLink
    property as a Dictionary representing the URLs and `rel` attributes and ensure the URLs are
    absolute to make it easier for the developer to use.
  - For `Invoke-RestMethod`, when the response includes a Link header we expose a `-FollowRelLink`
    switch to automatically follow `next` `rel` links until they no longer exist or once we hit the
    optional `-MaximumFollowRelLink` parameter value.
- Add `-CustomMethod` parameter to web cmdlets to allow for non-standard method verbs. (#3142)
  (Thanks to @Lee303!)
- Add `SslProtocol` support to Web Cmdlets. (#5329) (Thanks
  [@markekraus](https://github.com/markekraus)!)
- Add Multipart support to web cmdlets. (#4782) (Thanks [@markekraus](https://github.com/markekraus))
- Add `-NoProxy` to web cmdlets so that they ignore the system-wide proxy setting. (#3447) (Thanks
  to [@TheFlyingCorpse](https://github.com/TheFlyingCorpse)!)
- User Agent of Web Cmdlets now reports the OS platform (#4937) (Thanks
  [@LDSpits](https://github.com/LDSpits))
- Add `-SkipHeaderValidation` switch to web cmdlets to support adding headers without validating the
  header value. (#4085)
- Enable web cmdlets to not validate the HTTPS certificate of the server if required.
- Add authentication parameters to web cmdlets. (#5052) (Thanks
  [@markekraus](https://github.com/markekraus))
  - Add `-Authentication` that provides three options: Basic, OAuth, and Bearer.
  - Add `-Token` to get the bearer token for OAuth and Bearer options.
  - Add `-AllowUnencryptedAuthentication` to bypass authentication that is provided for any
    transport scheme other than HTTPS.
- Add `-ResponseHeadersVariable` to `Invoke-RestMethod` to enable the capture of response headers.
  (#4888) (Thanks [@markekraus](https://github.com/markekraus))
- Fix web cmdlets to include the HTTP response in the exception when the response status code is not
  success. (#3201)
- Change web cmdlets `UserAgent` from `WindowsPowerShell` to `PowerShell`. (#4914) (Thanks
  [@markekraus](https://github.com/markekraus))
- Add explicit `ContentType` detection to `Invoke-RestMethod` (#4692)
- Fix web cmdlets `-SkipHeaderValidation` to work with non-standard User-Agent headers. (#4479 &
  #4512) (Thanks [@markekraus](https://github.com/markekraus))

### JSON cmdlets

- Add `-AsHashtable` to `ConvertFrom-Json` to return a `Hashtable` instead. (#5043) (Thanks
  [@bergmeister](https://github.com/bergmeister)!)
- Use prettier formatter with `ConvertTo-Json` output. (#2787) (Thanks to @kittholland!)
- Add `Jobject` serialization support to `ConvertTo-Json`. (#5141)
- Fix `ConvertFrom-Json` to deserialize an array of strings from the pipeline that together
  construct a complete JSON string. This fixes some cases where newlines would break JSON parsing.
  (#3823)
- Remove the `AliasProperty "Count"` defined for `System.Array`. This removes the extraneous `Count`
  property on some `ConvertFrom-Json` output. (#3231) (Thanks to
  [@PetSerAl](https://github.com/PetSerAl)!)

### CSV cmdlets

- `Import-Csv` now supports the W3C Extended Log File Format (#2482) (Thanks
  [@iSazonov](https://github.com/iSazonov)!)
- Add `PSTypeName` Support for `Import-Csv` and `ConvertFrom-Csv`. (#5389) (Thanks
  [@markekraus](https://github.com/markekraus)!)
- Make `Import-Csv` support `CR`, `LF`, and `CRLF` as line delimiters. (#5363) (Thanks
  [@iSazonov](https://github.com/iSazonov)!)
- Make `-NoTypeInformation` the default on `Export-Csv` and `ConvertTo-Csv`. (#5164) (Thanks
  [@markekraus](https://github.com/markekraus)!)

### Service cmdlets

- Add properties `UserName`, `Description`, `DelayedAutoStart`, `BinaryPathName`, and `StartupType`
  to the `ServiceController` objects returned by `Get-Service`. (#4907) (Thanks
  [@joandrsn](https://github.com/joandrsn))
- Add functionality to set credentials on `Set-Service` command. (#4844) (Thanks
  [@joandrsn](https://github.com/joandrsn))

### Other cmdlets

- Add a parameter to `Get-ChildItem` called `-FollowSymlink` that traverses symlinks on demand, with
  checks for link loops. (#4020)
- Update `Add-Type` to support `CSharpVersion7`. (#3933) (Thanks to
  [@iSazonov](https://github.com/iSazonov))
- Remove the `Microsoft.PowerShell.LocalAccounts` module due to the use of unsupported APIs until a
  better solution is found. (#4302)
- Remove the `*-Counter` cmdlets in `Microsoft.PowerShell.Diagnostics` due to the use of unsupported
  APIs until a better solution is found. (#4303)
- Add support for `Invoke-Item -Path <folder>`. (#4262)
- Add `-Extension` and `-LeafBase` switches to `Split-Path` so that you can split paths between the
  filename extension and the rest of the filename. (#2721) (Thanks to
  [@powercode](https://github.com/powercode)!)
- Add parameters `-Top` and `-Bottom` to `Sort-Object` for Top/Bottom N sort
- Expose a process' parent process by adding the `CodeProperty "Parent"` to
  `System.Diagnostics.Process`. (#2850) (Thanks to [@powercode](https://github.com/powercode)!)
- Use MB instead of KB for memory columns of `Get-Process`
- Add `-NoNewLine` switch for `Out-String`. (#5056) (Thanks
  [@raghav710](https://github.com/raghav710))
- `Move-Item` cmdlet honors `-Include`, `-Exclude`, and `-Filter` parameters. (#3878)
- Allow `*` to be used in registry path for `Remove-Item`. (#4866)
- Add `-Title` to `Get-Credential` and unify the prompt experience across platforms.
- Add the `-TimeOut` parameter to `Test-Connection`. (#2492)
- `Get-AuthenticodeSignature` cmdlets can now get file signature timestamp. (#4061)
- Remove unsupported `-ShowWindow` switch from `Get-Help`. (#4903)
- Fix `Get-Content -Delimiter` to not include the delimiter in the array elements returned (#3706)
  (Thanks [@mklement0](https://github.com/mklement0))
- Add `Meta`, `Charset`, and `Transitional` parameters to `ConvertTo-HTML` (#4184) (Thanks
  [@ergo3114](https://github.com/ergo3114))
- Add `WindowsUBR` and `WindowsVersion` properties to `Get-ComputerInfo` result
- Add `-Group` parameter to `Get-Verb`
- Add `ShouldProcess` support to `New-FileCatalog` and `Test-FileCatalog` (fixes `-WhatIf` and
  `-Confirm`). (#3074) (Thanks to [@iSazonov](https://github.com/iSazonov)!)
- Add `-WhatIf` switch to `Start-Process` cmdlet (#4735) (Thanks
  [@sarithsutha](https://github.com/sarithsutha))
- Add `ValidateNotNullOrEmpty` too many existing parameters.

## Tab completion

- Enhanced the type inference in tab completion based on runtime variable values. (#2744) (Thanks to
  [@powercode](https://github.com/powercode)!) This enables tab completion in situations like:

  ```powershell
  $p = Get-Process
  $p | Foreach-Object Prio<tab>
  ```

- Add Hashtable tab completion for `-Property` of `Select-Object`. (#3625) (Thanks to
  [@powercode](https://github.com/powercode))
- Enable argument auto-completion for `-ExcludeProperty` and `-ExpandProperty` of `Select-Object`.
  (#3443) (Thanks to [@iSazonov](https://github.com/iSazonov)!)
- Fix a bug in tab completion to make `native.exe --<tab>` call into native completer. (#3633)
  (Thanks to [@powercode](https://github.com/powercode)!)

We've introduced a number of breaking changes in PowerShell Core 6.0.
To read more about them in detail, see [Breaking Changes in PowerShell Core 6.0][breaking-changes].

## Debugging

- Support for remote step-in debugging for `Invoke-Command -ComputerName`. (#3015)
- Enable binder debug logging in PowerShell Core

## Filesystem updates

- Enable usage of the Filesystem provider from a UNC path. ($4998)
- `Split-Path` now works with UNC roots
- `cd` with no arguments now behaves as `cd ~`
- Fixed PowerShell Core to allow use of paths that are more than 260 characters long. (#3960)

## Bug fixes and performance improvements

We've made *many* improvements to performance across PowerShell, including in startup time, various
built-in cmdlets, and interaction with native binaries.

We've also fixed a number of bugs within PowerShell Core. For a complete list of fixes and changes,
check out our [changelog][] on GitHub.

## Telemetry

- PowerShell Core 6.0 added telemetry to the console host to report two values (#3620):
  - the OS platform (`$PSVersionTable.OSDescription`)
  - the exact version of PowerShell (`$PSVersionTable.GitCommitId`)

If you want to opt-out of this telemetry, simply create `POWERSHELL_TELEMETRY_OPTOUT` environment
variable with one of the following values: `true`, `1` or `yes`. Creating the variable bypasses all
telemetry even before the first run of PowerShell. We also plan on exposing this telemetry data and
the insights we glean from the telemetry in the [community dashboard][community-dashboard]. You can
find out more about how we use this data in this [blog post][telemetry-blog].

## Breaking Changes for PowerShell 6.0

### Modules not shipped for PowerShell 6.0

For various compatibility reasons, the following modules are not included in PowerShell 6.

- ISE
- Microsoft.PowerShell.LocalAccounts
- Microsoft.PowerShell.ODataUtils
- Microsoft.PowerShell.Operation.Validation
- PSScheduledJob
- PSWorkflow
- PSWorkflowUtility

### PowerShell Workflow

[PowerShell Workflow][workflow] is a feature in Windows PowerShell that builds on top of
[Windows Workflow Foundation (WF)][workflow-foundation] that enables the creation of robust runbooks
for long-running or parallelized tasks.

Due to the lack of support for Windows Workflow Foundation in .NET Core, we are not supporting
PowerShell Workflow in PowerShell Core.

In the future, we would like to enable native parallelism/concurrency in the PowerShell language
without the need for PowerShell Workflow.

If there is a need to use checkpoints to resume a script after the OS restarts, we recommend
using Task Scheduler to run a script on OS startup, but the script would need to maintain
its own state (like persisting it to a file).

[workflow]: /previous-versions/powershell/scripting/components/workflows-guide
[workflow-foundation]: /dotnet/framework/windows-workflow-foundation/

### Custom snap-ins

[PowerShell snap-ins][snapin] are a predecessor to PowerShell modules that do not have widespread
adoption in the PowerShell community.

Due to the complexity of supporting snap-ins and their lack of usage in the community, we no longer
support custom snap-ins in PowerShell Core.

Today, this breaks the `ActiveDirectory` and `DnsClient` modules in Windows and Windows Server.

[snapin]: /powershell/module/microsoft.powershell.core/about/about_pssnapins

### WMI v1 cmdlets

Due to the complexity of supporting two sets of WMI-based modules, we removed the WMI v1 cmdlets
from PowerShell Core:

- `Register-WmiEvent`
- `Set-WmiInstance`
- `Invoke-WmiMethod`
- `Get-WmiObject`
- `Remove-WmiObject`

Instead, we recommend that you the use the CIM (aka WMI v2) cmdlets which provide the same
functionality with new functionality and a redesigned syntax:

- `Get-CimAssociatedInstance`
- `Get-CimClass`
- `Get-CimInstance`
- `Get-CimSession`
- `Invoke-CimMethod`
- `New-CimInstance`
- `New-CimSession`
- `New-CimSessionOption`
- `Register-CimIndicationEvent`
- `Remove-CimInstance`
- `Remove-CimSession`
- `Set-CimInstance`

### Microsoft.PowerShell.LocalAccounts

Due to the use of unsupported APIs, `Microsoft.PowerShell.LocalAccounts` has been removed from
PowerShell Core until a better solution is found.

### `New-WebServiceProxy` cmdlet removed

.NET Core does not support the Windows Communication Framework, which provide services for using the
SOAP protocol. This cmdlet was removed because it requires SOAP.

### `*-Transaction` cmdlets removed

These cmdlets had very limited usage. The decision was made to discontinue support for them.

- `Complete-Transaction`
- `Get-Transaction`
- `Start-Transaction`
- `Undo-Transaction`
- `Use-Transaction`

### Security cmdlets not available on non-Windows platforms

- `Get-Acl`
- `Set-Acl`
- `Get-AuthenticodeSignature`
- `Set-AuthenticodeSignature`
- `Get-CmsMessage`
- `Protect-CmsMessage`
- `Unprotect-CmsMessage`
- `New-FileCatalog`
- `Test-FileCatalog`

### `*-Computer`and other Windows-specific cmdlets

Due to the use of unsupported APIs, the following cmdlets have been removed from PowerShell Core
until a better solution is found.

- `Get-Clipboard`
- `Set-Clipboard`
- `Add-Computer`
- `Checkpoint-Computer`
- `Remove-Computer`
- `Restore-Computer`
- `Reset-ComputerMachinePassword`
- `Disable-ComputerRestore`
- `Enable-ComputerRestore`
- `Get-ComputerRestorePoint`
- `Test-ComputerSecureChannel`
- `Get-ControlPanelItem`
- `Show-ControlPanelItem`
- `Get-HotFix`
- `Clear-RecycleBin`
- `Update-List`
- `Out-Printer`
- `ConvertFrom-String`
- `Convert-String`

### `*-Counter` cmdlets

Due to the use of unsupported APIs, the `*-Counter` has been removed from PowerShell Core until a
better solution is found.

### `*-EventLog` cmdlets

Due to the use of unsupported APIs, the `*-EventLog` has been removed from PowerShell Core. until a
better solution is found. `Get-WinEvent` and `New-WinEvent` are available to get and create
events on Windows.

### Cmdlets that use WPF removed

The Windows Presentation Framework is not supported on CoreCLR. The following cmdlets are affected:

- `Show-Command`
- `Out-GridView`
- The **showwindow** parameter of `Get-Help`

### Some DSC cmdlets removed

- `Get-DscConfiguration`
- `Publish-DscConfiguration`
- `Restore-DscConfiguration`
- `Start-DscConfiguration`
- `Stop-DscConfiguration`
- `Test-DscConfiguration`
- `Update-DscConfiguration`
- `Remove-DscConfigurationDocument`
- `Get-DscConfigurationStatus`
- `Disable-DscDebug`
- `Enable-DscDebug`
- `Get-DscLocalConfigurationManager`
- `Set-DscLocalConfigurationManager`
- `Invoke-DscResource`

## Engine/language changes

### Rename `powershell.exe` to `pwsh.exe` [#5101](https://github.com/PowerShell/PowerShell/issues/5101)

In order to give users a deterministic way to call PowerShell Core on Windows (as opposed to
Windows PowerShell), the PowerShell Core binary was changed to `pwsh.exe` on Windows and `pwsh` on
non-Windows platforms.

The shortened name is also consistent with naming of shells on non-Windows platforms.

### Don't insert line breaks to output (except for tables) [#5193](https://github.com/PowerShell/PowerShell/issues/5193)

Previously, output was aligned to the width of the console and line breaks were added at the end
width of the console, meaning the output didn't get reformatted as expected if the terminal was
resized. This change was not applied to tables, as the line breaks are necessary to keep the columns
aligned.

### Skip null-element check for collections with a value-type element type [#5432](https://github.com/PowerShell/PowerShell/issues/5432)

For the `Mandatory` parameter and `ValidateNotNull` and `ValidateNotNullOrEmpty` attributes, skip
the null-element check if the collection's element type is value type.

### Change `$OutputEncoding` to use `UTF-8 NoBOM` encoding rather than ASCII [#5369](https://github.com/PowerShell/PowerShell/issues/5369)

The previous encoding, ASCII (7-bit), would result in incorrect alteration of the output in some
cases. This change is to make `UTF-8 NoBOM` default, which preserves Unicode output with an encoding
supported by most tools and operating systems.

### Remove `AllScope` from most default aliases [#5268](https://github.com/PowerShell/PowerShell/issues/5268)

To speed up scope creation, `AllScope` was removed from most default aliases. `AllScope` was left
for a few frequently used aliases where the lookup was faster.

### `-Verbose` and `-Debug` no longer overrides `$ErrorActionPreference` [#5113](https://github.com/PowerShell/PowerShell/issues/5113)

Previously, if `-Verbose` or `-Debug` were specified, it overrode the behavior of
`$ErrorActionPreference`. With this change, `-Verbose` and `-Debug` no longer affect the behavior
of `$ErrorActionPreference`.

## Cmdlet changes

### Invoke-RestMethod doesn't return useful info when no data is returned. [#5320](https://github.com/PowerShell/PowerShell/issues/5320)

When an API returns just `null`, Invoke-RestMethod was serializing this as the string `"null"`
instead of `$null`. This change fixes the logic in `Invoke-RestMethod` to properly serialize a
valid single value JSON `null` literal as `$null`.

### Remove `-Protocol` from `*-Computer` cmdlets [#5277](https://github.com/PowerShell/PowerShell/issues/5277)

Due to issues with RPC remoting in CoreFX (particularly on non-Windows platforms) and ensuring a
consistent remoting experience in PowerShell, the `-Protocol` parameter was removed from the
`\*-Computer` cmdlets. DCOM is no longer supported for remoting. The following cmdlets only support
WSMAN remoting:

- Rename-Computer
- Restart-Computer
- Stop-Computer

### Remove `-ComputerName` from `*-Service` cmdlets [#5090](https://github.com/PowerShell/PowerShell/issues/5094)

In order to encourage the consistent use of PSRP, the `-ComputerName` parameter was removed from
`*-Service` cmdlets.

### Fix `Get-Item -LiteralPath a*b` if `a*b` doesn't actually exist to return error [#5197](https://github.com/PowerShell/PowerShell/issues/5197)

Previously, `-LiteralPath` given a wildcard would treat it the same as `-Path` and if the wildcard
found no files, it would silently exit. Correct behavior should be that `-LiteralPath` is literal
so if the file doesn't exist, it should error. Change is to treat wildcards used with `-Literal` as
literal.

### `Import-Csv` should apply `PSTypeNames` upon import when type information is present in the CSV [#5134](https://github.com/PowerShell/PowerShell/issues/5134)

Previously, objects exported using `Export-CSV` with `TypeInformation` imported with
`ConvertFrom-Csv` were not retaining the type information. This change adds the type information to
`PSTypeNames` member if available from the CSV file.

### `-NoTypeInformation` should be default on `Export-Csv` [#5131](https://github.com/PowerShell/PowerShell/issues/5131)

This change was made to address customer feedback on the default behavior of `Export-CSV` to
include type information.

Previously, the cmdlet would output a comment as the first line containing the type name of the
object. The change is to suppress this by default as it's not understood by most tools. Use
`-IncludeTypeInformation` to retain the previous behavior.

### Web Cmdlets should warn when `-Credential` is sent over unencrypted connections [#5112](https://github.com/PowerShell/PowerShell/issues/5112)

When using HTTP, content including passwords are sent as clear-text. This change is to not allow
this by default and return an error if credentials are being passed in an insecure manner. Users
can bypass this by using the `-AllowUnencryptedAuthentication` switch.

## API changes

### Remove `AddTypeCommandBase` class [#5407](https://github.com/PowerShell/PowerShell/issues/5407)

The `AddTypeCommandBase` class was removed from `Add-Type` to improve performance. This class is
only used by the Add-Type cmdlet and should not impact users.

### Unify cmdlets with parameter `-Encoding` to be of type `System.Text.Encoding` [#5080](https://github.com/PowerShell/PowerShell/issues/5080)

The `-Encoding` value `Byte` has been removed from the filesystem provider cmdlets. A new
parameter, `-AsByteStream`, is now used to specify that a byte stream is required as input or that
the output is a stream of bytes.

### Add better error message for empty and null `-UFormat` parameter [#5055](https://github.com/PowerShell/PowerShell/issues/5055)

Previously, when passing an empty format string to `-UFormat`, an unhelpful error message would
appear. A more descriptive error has been added.

### Clean up console code [#4995](https://github.com/PowerShell/PowerShell/issues/4995)

The following features were removed as they are not supported in PowerShell Core, and there are no
plans to add support as they exist for legacy reasons for Windows PowerShell: `-psconsolefile`
switch and code, `-importsystemmodules` switch and code, and font changing code.

### Removed `RunspaceConfiguration` support [#4942](https://github.com/PowerShell/PowerShell/issues/4942)

Previously, when creating a PowerShell runspace programmatically using the API you could use the
legacy [`RunspaceConfiguration`][runspaceconfig] or the newer [`InitialSessionState`][iss]. This
change removed support for `RunspaceConfiguration` and only supports `InitialSessionState`.

[runspaceconfig]: /dotnet/api/system.management.automation.runspaces.runspaceconfiguration
[iss]: /dotnet/api/system.management.automation.runspaces.initialsessionstate

### `CommandInvocationIntrinsics.InvokeScript` bind arguments to `$input` instead of `$args` [#4923](https://github.com/PowerShell/PowerShell/issues/4923)

An incorrect position of a parameter resulted in the args passed as input instead of as args.

### Remove unsupported `-showwindow` switch from `Get-Help` [#4903](https://github.com/PowerShell/PowerShell/issues/4903)

`-showwindow` relies on WPF, which is not supported on CoreCLR.

### Allow * to be used in registry path for `Remove-Item` [#4866](https://github.com/PowerShell/PowerShell/issues/4866)

Previously, `-LiteralPath` given a wildcard would treat it the same as `-Path` and if the wildcard
found no files, it would silently exit. Correct behavior should be that `-LiteralPath` is literal
so if the file doesn't exist, it should error. Change is to treat wildcards used with `-Literal` as
literal.

### Fix `Set-Service` failing test [#4802](https://github.com/PowerShell/PowerShell/issues/4802)

Previously, if `New-Service -StartupType foo` was used, `foo` was ignored and the service was
created with some default startup type. This change is to explicitly throw an error for an invalid
startup type.

### Rename `$IsOSX` to `$IsMacOS` [#4700](https://github.com/PowerShell/PowerShell/issues/4700)

The naming in PowerShell should be consistent with our naming and conform to Apple's use of macOS
instead of OSX. However, for readability and consistently we are staying with Pascal casing.

### Make error message consistent when invalid script is passed to -File, better error when passed ambiguous argument [#4573](https://github.com/PowerShell/PowerShell/issues/4573)

Change the exit codes of `pwsh.exe` to align with Unix conventions

### Removal of `LocalAccount` and cmdlets from  `Diagnostics` modules. [#4302](https://github.com/PowerShell/PowerShell/issues/4302) [#4303](https://github.com/PowerShell/PowerShell/issues/4303)

Due to unsupported APIs, the `LocalAccounts` module and the `Counter` cmdlets in the `Diagnostics`
module were removed until a better solution is found.

### Executing PowerShell script with bool parameter does not work [#4036](https://github.com/PowerShell/PowerShell/issues/4036)

Previously, using **powershell.exe** (now **pwsh.exe**) to execute a PowerShell script using `-File`
provided no way to pass `$true`/`$false` as parameter values. Support for `$true`/`$false` as parsed
values to parameters was added. Switch values are also supported as currently documented syntax
doesn't work.

### Remove `ClrVersion` property from `$PSVersionTable` [#4027](https://github.com/PowerShell/PowerShell/issues/4027)

The `ClrVersion` property of `$PSVersionTable` is not useful with CoreCLR, end users should not be
using that value to determine compatibility.

### Change positional parameter for `powershell.exe` from `-Command` to `-File` [#4019](https://github.com/PowerShell/PowerShell/issues/4019)

Enable shebang use of PowerShell on non-Windows platforms. This means on Unix based systems, you can
make a script executable that would invoke PowerShell automatically rather than explicitly invoking
`pwsh`. This also means that you can now do things like `powershell foo.ps1` or
`powershell fooScript` without specifying `-File`. However, this change now requires that you
explicitly specify `-c` or `-Command` when trying to do things like `powershell.exe Get-Command`.

### Implement Unicode escape parsing [#3958](https://github.com/PowerShell/PowerShell/issues/3958)

`` `u####`` or `` `u{####}`` is converted to the corresponding Unicode character. To output a
literal `` `u``, escape the backtick: ``` ``u```.

### Change `New-ModuleManifest` encoding to `UTF8NoBOM` on non-Windows platforms [#3940](https://github.com/PowerShell/PowerShell/issues/3940)

Previously, `New-ModuleManifest` creates psd1 manifests in UTF-16 with BOM, creating a problem for
Linux tools. This breaking change changes the encoding of `New-ModuleManifest` to be UTF (no BOM) in
non-Windows platforms.

### Prevent `Get-ChildItem` from recursing into symlinks (#1875). [#3780](https://github.com/PowerShell/PowerShell/issues/3780)

This change brings `Get-ChildItem` more in line with the Unix `ls -r` and the Windows `dir /s`
native commands. Like the mentioned commands, the cmdlet displays symbolic links to directories
found during recursion, but does not recurse into them.

### Fix `Get-Content -Delimiter` to not include the delimiter in the returned lines [#3706](https://github.com/PowerShell/PowerShell/issues/3706)

Previously, the output while using `Get-Content -Delimiter` was inconsistent and inconvenient as it
required further processing of the data to remove the delimiter. This change removes the delimiter
in returned lines.

### Implement Format-Hex in C# [#3320](https://github.com/PowerShell/PowerShell/issues/3320)

The `-Raw` parameter is now a "no-op" (in that it does nothing). Going forward all of the output
will be displayed with a true representation of numbers that includes all of the bytes for its type
(what the `-Raw` parameter was formally doing prior to this change).

### PowerShell as a default shell doesn't work with script command [#3319](https://github.com/PowerShell/PowerShell/issues/3319)

On Unix, it is a convention for shells to accept `-i` for an interactive shell and many tools
expect this behavior (`script` for example, and when setting PowerShell as the default shell) and
calls the shell with the `-i` switch. This change is breaking in that `-i` previously could be used
as short hand to match `-inputformat`, which now needs to be `-in`.

### Typo fix in Get-ComputerInfo property name [#3167](https://github.com/PowerShell/PowerShell/issues/3167)

`BiosSerialNumber` was misspelled as `BiosSeralNumber` and has been changed to the correct spelling.

### Add `Get-StringHash` and `Get-FileHash` cmdlets [#3024](https://github.com/PowerShell/PowerShell/issues/3024)

This change is that some hash algorithms are not supported by CoreFX, therefore they are no longer
available:

- `MACTripleDES`
- `RIPEMD160`

### Add validation on `Get-*` cmdlets where passing $null returns all objects instead of error [#2672](https://github.com/PowerShell/PowerShell/issues/2672)

Passing `$null` to any of the following now throws an error:

- `Get-Credential -UserName`
- `Get-Event -SourceIdentifier`
- `Get-EventSubscriber -SourceIdentifier`
- `Get-Help -Name`
- `Get-PSBreakpoint -Script`
- `Get-PSProvider -PSProvider`
- `Get-PSSessionConfiguration -Name`
- `Get-PSSnapin -Name`
- `Get-Runspace -Name`
- `Get-RunspaceDebug -RunspaceName`
- `Get-Service -Name`
- `Get-TraceSource -Name`
- `Get-Variable -Name`
- `Get-WmiObject -Class`
- `Get-WmiObject -Property`

### Add support W3C Extended Log File Format in `Import-Csv` [#2482](https://github.com/PowerShell/PowerShell/issues/2482)

Previously, the `Import-Csv` cmdlet cannot be used to directly import the log files in W3C extended
log format and additional action would be required. With this change, W3C extended log format is
supported.

### Parameter binding problem with `ValueFromRemainingArguments` in PS functions [#2035](https://github.com/PowerShell/PowerShell/issues/2035)

`ValueFromRemainingArguments` now returns the values as an array instead of a single value which
itself is an array.

### `BuildVersion` is removed from `$PSVersionTable` [#1415](https://github.com/PowerShell/PowerShell/issues/1415)

Remove the `BuildVersion` property from `$PSVersionTable`. This property was tied to the Windows
build version. Instead, we recommend that you use `GitCommitId` to retrieve the exact build version
of PowerShell Core.

### Changes to Web Cmdlets

The underlying .NET API of the Web Cmdlets has been changed to `System.Net.Http.HttpClient`. This
change provides many benefits. However, this change along with a lack of interoperability with
Internet Explorer have resulted in several breaking changes within `Invoke-WebRequest` and
`Invoke-RestMethod`.

- `Invoke-WebRequest` now supports basic HTML Parsing only. `Invoke-WebRequest` always returns a
  `BasicHtmlWebResponseObject` object. The `ParsedHtml` and `Forms` properties have been removed.
- `BasicHtmlWebResponseObject.Headers` values are now `String[]` instead of `String`.
- `BasicHtmlWebResponseObject.BaseResponse` is now a `System.Net.Http.HttpResponseMessage` object.
- The `Response` property on Web Cmdlet exceptions is now a `System.Net.Http.HttpResponseMessage`
  object.
- Strict RFC header parsing is now default for the `-Headers` and `-UserAgent` parameter. This can
  be bypassed with `-SkipHeaderValidation`.
- `file://` and `ftp://` URI schemes are no longer supported.
- `System.Net.ServicePointManager` settings are no longer honored.
- There is currently no certificate based authentication available on macOS.
- Use of `-Credential` over an `http://` URI will result in an error. Use an `https://` URI or
  supply the `-AllowUnencryptedAuthentication` parameter to suppress the error.
- `-MaximumRedirection` now produces a terminating error when redirection attempts exceed the
  provided limit instead of returning the results of the last redirection.
- In PowerShell 6.2, a change was made to default to UTF-8 encoding for JSON responses. When a
  charset is not supplied for a JSON response, the default encoding should be UTF-8 per RFC 8259.

<!-- end of content -->
<!-- reference links -->
[.NET Blog]: https://devblogs.microsoft.com/dotnet/introducing-net-standard/
[.NET Core 2.0]: /dotnet/core/
[.NET Standard]: /dotnet/standard/net-standard
[breaking-changes]: #breaking-changes-for-power-shell-60
[CDXML]: /previous-versions/windows/desktop/wmi_v2/getting-started-with-cdxml
[changelog]: https://github.com/PowerShell/PowerShell/tree/master/CHANGELOG.md
[community-dashboard]: https://aka.ms/PSGitHubBI
[docker-hub]: https://hub.docker.com/r/microsoft/powershell/
[docker]: https://github.com/PowerShell/PowerShell/tree/master/docker
[FAQ]: https://github.com/dotnet/standard/blob/master/docs/faq.md
[github]: https://github.com/PowerShell/PowerShell
[os_log]: https://developer.apple.com/documentation/os/logging
[semi-annual]: /windows-server/get-started/semi-annual-channel-overview
[ssh-remoting]: /powershell/scripting/learn/remoting/SSH-Remoting-in-PowerShell-Core
[Syslog]: https://en.wikipedia.org/wiki/Syslog
[telemetry-blog]: https://devblogs.microsoft.com/powershell/powershell-open-source-community-dashboard/
[windowspsmodulepath]: https://www.powershellgallery.com/packages/WindowsPSModulePath/
[YouTube]: https://www.youtube.com/watch?v=YI4MurjfMn8&list=PLRAdsfhKI4OWx321A_pr-7HhRNk7wOLLY
