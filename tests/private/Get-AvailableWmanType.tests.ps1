$script:ModuleName = 'PembrokePSqman'

Describe "Get-AvailableWmanType function for $moduleName" {
    It "Should not be null" {
        $RawReturn = @{
            wman_task_types = @{
                ID            = '1'
                WORKFLOW_MANAGER_TYPE_ID     = '1'
                TASK_TYPE_ID       = '1'
            }               
        }
        $ReturnJson = $RawReturn | ConvertTo-Json
        $ReturnData = $ReturnJson | convertfrom-json
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Invoke-RestMethod' -MockWith {
            $ReturnData
        }
        Get-AvailableWmanType -RestServer localhost -TaskTypeId 1 | Should not be $null
        Assert-MockCalled -CommandName 'Test-Connection' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1 -Exactly
    }
    It "Should Throw if the Rest Server cannot be reached.." {
        Mock -CommandName 'Test-Connection' -MockWith {
            $false
        }
        {Get-AvailableWmanType -RestServer localhost -TaskTypeId 1} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 2 -Exactly
    }
    It "Should Throw if the ID is not valid." {
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Invoke-RestMethod' -MockWith { 
            Throw "(404) Not Found"
        }
        {Get-AvailableWmanType -RestServer localhost -TaskTypeId 1} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 2 -Exactly
    }
}