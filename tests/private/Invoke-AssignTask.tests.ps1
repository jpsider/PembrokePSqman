$script:ModuleName = 'PembrokePSqman'

Describe "Invoke-AssignTask function for $moduleName" {
    It "Should not be null" {
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Invoke-RestMethod' -MockWith {
            1
        }
        Invoke-AssignTask -TableName tasks -TaskId 1 -WmanId 1 -RestServer dummyServer | Should -Be 1
        Assert-MockCalled -CommandName 'Test-Connection' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1 -Exactly
    }
    It "Should Throw if the Rest Server cannot be reached.." {
        Mock -CommandName 'Test-Connection' -MockWith {
            $false
        }
        {Invoke-AssignTask -TableName tasks -TaskId 1 -WmanId 1 -RestServer dummyServer} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 2 -Exactly
    }
    It "Should Throw if the Return is not valid." {
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Invoke-RestMethod' -MockWith { 
            Throw "(404) Not Found"
        }
        {Invoke-AssignTask -TableName tasks -TaskId 1 -WmanId 1 -RestServer dummyServer} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 2 -Exactly
    }
}