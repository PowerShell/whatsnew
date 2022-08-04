param ( [switch]$publish, [switch]$test, [switch]$package, [switch]$clean )
$moduleName = "Microsoft.PowerShell.WhatsNew"
$psd = Import-PowerShellDataFile "$PSScriptRoot/${moduleName}/${moduleName}.psd1"
$moduleVersion = $psd.ModuleVersion
$moduleDeploymentDir = "${PSScriptRoot}/out/${moduleName}/${moduleVersion}"

if ( $clean ) {
    $null = if (Test-Path "${PSScriptRoot}/out") { Remove-Item "${PSScriptRoot}/out" -Recurse -Force }
    $null = if (Test-Path "$PsScriptRoot/*.nupkg") { Remove-Item "$PsScriptRoot/*.nupkg" -Force }
}

if ($publish) {
    # create directory with version
    # copy files to that location
    if (-not (Test-Path $moduleDeploymentDir)) {
        New-Item -Type Directory -Force -Path $moduleDeploymentDir
    }
    Copy-Item -Force -Recurse "$PSScriptRoot/${moduleName}/*" $moduleDeploymentDir
}

if ( $test ) {
    if ( ! $publish ) {
        ./build.ps1 -publish
    }
    # run tests
    $psExe = (get-process -id $PID).MainModule.filename
    $testCommand = "import-module $PSScriptRoot/out/${moduleName}; Set-Location $PSScriptRoot/test; Invoke-Pester -OutputFormat NUnitXml -OutputFile  $PSScriptRoot/testResults.xml"
    $psArgs = "-noprofile","-noninteractive","-command",$testCommand
    & $psExe $psArgs
}

if ( $package ) {
    if (-not (test-path $moduleDeploymentDir)) {
        throw "Could not find '$moduleDeploymentDir'"
    }
    $repoName = [Guid]::NewGuid().ToString("N")
    try {
        Register-PSRepository -Name $repoName -SourceLocation $PSScriptRoot
        Publish-Module -Path $moduleDeploymentDir -Repository $repoName
    }
    finally {
        Unregister-PSRepository -Name $repoName
    }

}
