Describe "General tests for 'Get-WhatsNew'" {
    BeforeAll {
        $files = "What-s-New-in-PowerShell-70.md",
            "What-s-New-in-PowerShell-71.md",
            "What-s-New-in-PowerShell-72.md",
            "What-s-New-in-PowerShell-73.md",
            "What-s-New-in-PowerShell-Core-60.md",
            "What-s-New-in-PowerShell-Core-61.md",
            "What-s-New-in-PowerShell-Core-62.md",
            "What-s-New-in-Windows-PowerShell-50.md"
        $header2hash = @{}
        foreach ( $file in $files ) {
            $fileNumber = $file -replace ".*(\d\d).md",'$1'
            $key = "File${fileNumber}"
            $header2hash[$key] = select-string -raw "^## " "../Microsoft.PowerShell.WhatsNew/relnotes/$file"
        }
    }
    It "Handles Single Version" {
        $observed = Get-WhatsNew -version 7.2 | Select-String -Raw "^## "
        $observed | Should -Be $header2hash["File72"]
    }

    It "Handles Single Version ending in '0'" {
        $observed = Get-WhatsNew -version 7.0 | Select-String -Raw "^## "
        $observed | Should -Be $header2hash["File70"]
    }

    It "Handles multiple versions" {
        $observed = Get-WhatsNew -version 7.0,6.0,5.1 | Select-String -Raw "^## "
        $collection = @( $header2hash["File70"]; $header2hash["File60"]; $header2hash["File50"])
        $observed | Should -Be $collection
    }

    It "Converts a version missing the period to version.0" {
        $observed = Get-WhatsNew -version 7 | Select-String -Raw "^## "
        $observed | Should -Be $header2hash["File70"]
    }

    It "Returns all versions" {
        $observed = Get-WhatsNew -All | select-string '^# Release notes for'
        $observed.Count | Should -Be $files.Count
    }
}

