param ( [switch]$publish, [switch]$test, [switch]$package )
$moduleName = "Microsoft.PowerShell.WhatsNew"
$psd = Import-PowerShellDataFile "$PSScriptRoot/${moduleName}/${moduleName}.psd1"
$moduleVersion = $psd.ModuleVersion
$moduleDeploymentDir = "${PSScriptRoot}/out/${moduleName}/${moduleVersion}"

if ($publish) {
    # create directory with version
    # copy files to that location
    if (-not (Test-Path $moduleDeploymentDir)) {
        New-Item -Type Directory -Force -Path $moduleDeploymentDir
    }
    Copy-Item -Force -Recurse "$PSScriptRoot/${moduleName}/*" $moduleDeploymentDir
}

if ( $test ) {
    # run tests
}

if ( $package ) {
    if (-not (test-path $moduleDeploymentDir)) {
        throw "Could not find '$moduleDeploymentDir'"
    }
    $repoName = [Guid]::NewGuid().ToString("N")
    try {
        Register-PSRepository -Name $repoName -SourceLocation $PSScriptRoot
        Publish-Module -Path "$PsScriptRoot/${moduleName}" -Repository $repoName
    }
    finally {
        Unregister-PSRepository -Name $repoName
    }
    
}
