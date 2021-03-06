$script:ModuleName = 'PembrokePSqman'

$here = (Split-Path -Parent $MyInvocation.MyCommand.Path) -replace 'tests', "$script:ModuleName"
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Invoke-DeployQman function for $moduleName" {
    function Write-LogLevel{}
    function Invoke-CreateRouteDirectorySet {}
    It "Should not Throw an exception if the source directory does exist." {
        Mock -CommandName 'Test-Path' -MockWith {
            $true
        }
        Mock -CommandName 'Install-Module' -MockWith {
            $true
        }
        Mock -CommandName 'Import-Module' -MockWith {
            $true
        }
        Mock -CommandName 'Invoke-CreateRouteDirectorySet' -MockWith {}
        Mock -CommandName 'Copy-Item' -MockWith {}
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        {Invoke-DeployQman -Source 'c:\testdir'} | Should -Not -Throw
        Assert-MockCalled -CommandName 'Test-Path' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Install-Module' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Import-Module' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Copy-Item' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Invoke-CreateRouteDirectorySet' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 4 -Exactly
        
    }
    It "Should Not throw, if the directories are created and files are moved.." {
        Mock -CommandName 'Install-Module' -MockWith {
            $true
        }
        Mock -CommandName 'Import-Module' -MockWith {
            $true
        }
        Mock -CommandName 'Test-Path' -MockWith {
            $false
        }
        Mock -CommandName 'New-Item' -MockWith {}
        Mock -CommandName 'Invoke-CreateRouteDirectorySet' -MockWith {}
        Mock -CommandName 'Copy-Item' -MockWith {}
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        {Invoke-DeployQman -Source 'c:\testdir'} | Should -Not -Throw
        Assert-MockCalled -CommandName 'New-Item' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Copy-Item' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Test-Path' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Invoke-CreateRouteDirectorySet' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Install-Module' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Import-Module' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 8 -Exactly

    }
    It "Should throw, if the directories are not created." {
        Mock -CommandName 'Install-Module' -MockWith {
            $true
        }
        Mock -CommandName 'Import-Module' -MockWith {
            $true
        }
        Mock -CommandName 'Test-Path' -MockWith {
            $false
        }
        Mock -CommandName 'Invoke-CreateRouteDirectorySet' -MockWith {}
        Mock -CommandName 'New-Item' -MockWith {
            Throw "Directory not created."
        }
        Mock -CommandName 'Copy-Item' -MockWith {}
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        {Invoke-DeployQman -Source 'c:\testdir'} | Should -Throw
        Assert-MockCalled -CommandName 'New-Item' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Copy-Item' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Test-Path' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Invoke-CreateRouteDirectorySet' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Install-Module' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Import-Module' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 9 -Exactly

    }
    It "Should throw, Rest Directories are not created." {
        Mock -CommandName 'Install-Module' -MockWith {
            $true
        }
        Mock -CommandName 'Import-Module' -MockWith {
            $true
        }
        Mock -CommandName 'Test-Path' -MockWith {
            $false
        }
        Mock -CommandName 'Invoke-CreateRouteDirectorySet' -MockWith {
            Throw "Unable to Create Rest Route Directories"
        }
        Mock -CommandName 'New-Item' -MockWith {}
        Mock -CommandName 'Copy-Item' -MockWith {}
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        {Invoke-DeployQman -Source 'c:\testdir'} | Should -Throw
        Assert-MockCalled -CommandName 'New-Item' -Times 5 -Exactly
        Assert-MockCalled -CommandName 'Copy-Item' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Test-Path' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Invoke-CreateRouteDirectorySet' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Install-Module' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Import-Module' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 12 -Exactly

    }
    It "Should throw, if the properties file is not copied." {
        Mock -CommandName 'Install-Module' -MockWith {
            $true
        }
        Mock -CommandName 'Import-Module' -MockWith {
            $true
        }
        Mock -CommandName 'Test-Path' -MockWith {
            $false
        }
        Mock -CommandName 'Invoke-CreateRouteDirectorySet' -MockWith {}
        Mock -CommandName 'New-Item' -MockWith {}
        Mock -CommandName 'Copy-Item' -MockWith {
            Throw "Unable to move Items"
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        {Invoke-DeployQman -Source 'c:\testdir'} | Should -Throw
        Assert-MockCalled -CommandName 'New-Item' -Times 7 -Exactly
        Assert-MockCalled -CommandName 'Copy-Item' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Test-Path' -Times 5 -Exactly
        Assert-MockCalled -CommandName 'Invoke-CreateRouteDirectorySet' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Install-Module' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Import-Module' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 16 -Exactly
    }
    It "Should throw, if modules could not be installed." {
        Mock -CommandName 'Install-Module' -MockWith {
            Throw "Could not install Modules"
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        Assert-MockCalled -CommandName 'Install-Module' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 16 -Exactly
    }
    It "Should throw, if modules could not be Imported." {
        Mock -CommandName 'Install-Module' -MockWith {
            $true
        }
        Mock -CommandName 'Import-Module' -MockWith {
            Throw "Could not Import Modules"
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        Assert-MockCalled -CommandName 'Install-Module' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Import-Module' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 16 -Exactly
    }
    function Split-Path {}
    function Get-Module {}
    It "Should not Throw an exception if the source directory does exist." {
        Mock -CommandName 'Test-Path' -MockWith {
            $true
        }
        Mock -CommandName 'Install-Module' -MockWith {
            $true
        }
        Mock -CommandName 'Import-Module' -MockWith {
            $true
        }
        Mock -CommandName 'Invoke-CreateRouteDirectorySet' -MockWith {}
        Mock -CommandName 'Copy-Item' -MockWith {}
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        {Invoke-DeployQman} | Should -Not -Throw
        Assert-MockCalled -CommandName 'Test-Path' -Times 6 -Exactly
        Assert-MockCalled -CommandName 'Install-Module' -Times 5 -Exactly
        Assert-MockCalled -CommandName 'Import-Module' -Times 5 -Exactly
        Assert-MockCalled -CommandName 'Copy-Item' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Invoke-CreateRouteDirectorySet' -Times 5 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 20 -Exactly
    }
}