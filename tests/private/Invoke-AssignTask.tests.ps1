$script:ModuleName = 'PembrokePSqman'

$here = (Split-Path -Parent $MyInvocation.MyCommand.Path) -replace 'tests', "$script:ModuleName"
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Invoke-AssignTask function for $moduleName" {
    function Write-LogLevel{}
    It "Should not be null" {
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Invoke-RestMethod' -MockWith {
            1
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        Invoke-AssignTask -TableName tasks -TaskId 1 -WmanId 1 -RestServer dummyServer | Should -Be 1
        Assert-MockCalled -CommandName 'Test-Connection' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 2 -Exactly
    }
    It "Should Throw if the Rest Server cannot be reached.." {
        Mock -CommandName 'Test-Connection' -MockWith {
            $false
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        {Invoke-AssignTask -TableName tasks -TaskId 1 -WmanId 1 -RestServer dummyServer} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 2 -Exactly
    }
    It "Should Throw if the Return is not valid." {
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Invoke-RestMethod' -MockWith { 
            Throw "(404) Not Found"
        }
        Mock -CommandName 'Write-LogLevel' -MockWith {}
        {Invoke-AssignTask -TableName tasks -TaskId 1 -WmanId 1 -RestServer dummyServer} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Write-LogLevel' -Times 4 -Exactly
    }
}