$script:ModuleName = 'PembrokePSqman'

Describe "Invoke-AbortCancelledTaskSet function for $moduleName" {
    function Invoke-UpdateTaskTable{}
    It "Should not be null" {
        $RawReturn = @{
            tasks = @{
                ID            = '1'
                STATUS_ID     = '10'
                RESULT_ID       = '3'
            }               
        }
        $ReturnJson = $RawReturn | ConvertTo-Json
        $ReturnData = $ReturnJson | convertfrom-json
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Get-CancelledTaskSet' -MockWith {
            $ReturnData
        }
        Mock -CommandName 'Invoke-UpdateTaskTable' -MockWith {
            1
        }
        Invoke-AbortCancelledTaskSet -RestServer localhost -TableName tasks | Should not be $null
        Assert-MockCalled -CommandName 'Test-Connection' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Invoke-UpdateTaskTable' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Get-CancelledTaskSet' -Times 1 -Exactly
    }
    It "Should Throw if the Rest Server cannot be reached.." {
        Mock -CommandName 'Test-Connection' -MockWith {
            $false
        }
        {Invoke-AbortCancelledTaskSet -RestServer localhost -TableName tasks} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 2 -Exactly
    }
    It "Should Throw if the ID is not valid." {
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Get-CancelledTaskSet' -MockWith {
            Throw "(404) Not Found"
        }
        {Invoke-AbortCancelledTaskSet -RestServer localhost -TableName tasks} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Get-CancelledTaskSet' -Times 2 -Exactly
    }
}