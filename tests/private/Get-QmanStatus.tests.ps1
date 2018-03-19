$script:ModuleName = 'PembrokePSqman'

Describe "Get-QmanStatus function for $moduleName" {
    function Get-ComponentStatus {}
    It "Should not be null" {
        $RawReturn = @{
            value = @{
                ID            = '1'
                STATUS_ID     = '1'
                WAIT       = '300'
            }               
        }
        $ReturnJson = $RawReturn | ConvertTo-Json
        $ReturnData = $ReturnJson | convertfrom-json
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Get-ComponentStatus' -MockWith {
            $ReturnData
        }
        Get-QmanStatus -ComponentId 1 -RestServer dummyServer | Should not be $null
        Assert-MockCalled -CommandName 'Test-Connection' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Get-ComponentStatus' -Times 1 -Exactly
    }
    It "Should Throw if the Rest Server cannot be reached.." {
        Mock -CommandName 'Test-Connection' -MockWith {
            $false
        }
        {Get-QmanStatus -ComponentId 1 -RestServer dummyServer} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 2 -Exactly
    }
    It "Should Throw if the ID is not valid." {
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Get-ComponentStatus' -MockWith { 
            Throw "(404) Not Found"
        }
        {Get-QmanStatus -ComponentId 1 -RestServer dummyServer} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Get-ComponentStatus' -Times 2 -Exactly
    }
}