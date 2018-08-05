$script:ModuleName = 'PembrokePSqman'

$here = (Split-Path -Parent $MyInvocation.MyCommand.Path) -replace 'tests', "$script:ModuleName"
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Invoke-RegisterQman function for $moduleName" {
    It "Should not throw" {
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Write-Output' -MockWith {}
        {Invoke-RegisterQman -RestServer dummyServer} | Should -not -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Write-Output' -Times 1 -Exactly
    }
    It "Should Throw if the Rest Server cannot be reached.." {
        Mock -CommandName 'Test-Connection' -MockWith {
            $false
        }
        {Invoke-RegisterQman -RestServer dummyServer} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 2 -Exactly
    }
    It "Should Throw if the Return is not valid." {
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Write-Output' -MockWith { 
            Throw "Some failure to be udpated."
        }
        {Invoke-RegisterQman -RestServer dummyServer} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Write-Output' -Times 2 -Exactly
    }
}