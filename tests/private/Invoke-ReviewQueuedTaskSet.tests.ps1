$script:ModuleName = 'PembrokePSqman'

Describe "Invoke-ReviewQueuedTaskSet function for $moduleName" {
    $RawReturn1 = @(
        @{
            'ID'           = '1'
            'STATUS_ID'     = '6'
            'TASK_TYPE_ID'  = '1'
        }               
    )
    $ReturnJson1 = $RawReturn1 | ConvertTo-Json
    $ReturnData1 = $ReturnJson1 | convertfrom-json
    $RawReturn2 = @(
        @{
            ID                        = '1'
            WORKFLOW_MANAGER_TYPE_ID  = '1'
            TASK_TYPE_ID              = '1'
        }               
    )
    $ReturnJson2 = $RawReturn2 | ConvertTo-Json
    $ReturnData2 = $ReturnJson2 | convertfrom-json
    $RawReturn3 = @(
        @{
            ID                     = '1'
            STATUS_ID              = '1'
            MAX_CONCURRENT_TASKS   = '2'
            Hostname               = 'localhost'
        }               
    )
    $ReturnJson3 = $RawReturn3 | ConvertTo-Json
    $ReturnData3 = $ReturnJson3 | convertfrom-json
    $RawReturn4 = @(
        @{
            ID            = '1'
            STATUS_ID     = '9'
            RESULT_ID     = '2'
        }               
    )
    $ReturnJson4 = $RawReturn4 | ConvertTo-Json
    $ReturnData4 = $ReturnJson4 | convertfrom-json
    It "Should not be null" {
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Get-QueuedTaskSet' -MockWith {
            $ReturnData1
        }
        Mock -CommandName 'Get-AvailableWmanType' -MockWith {
            $ReturnData2
        }
        Mock -CommandName 'Get-AvailableWmanSet' -MockWith {
            $ReturnData3
        }
        Mock -CommandName 'Get-ActiveWmanTaskSet' -MockWith {
            $ReturnData4
        }
        Mock -CommandName 'Invoke-AssignTask' -MockWith {
            1
        }
        Invoke-ReviewQueuedTaskSet -RestServer localhost -TableName tasks | Should not be $null
        Assert-MockCalled -CommandName 'Test-Connection' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Get-QueuedTaskSet' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Get-AvailableWmanType' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Get-AvailableWmanSet' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Get-ActiveWmanTaskSet' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Invoke-AssignTask' -Times 1 -Exactly
    }
    It "Should Throw if the Rest Server cannot be reached.." {
        Mock -CommandName 'Test-Connection' -MockWith {
            $false
        }
        {Invoke-ReviewQueuedTaskSet -RestServer localhost -TableName tasks} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 2 -Exactly
    }
    It "Should Throw if the ID is not valid." {
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Get-QueuedTaskSet' -MockWith { 
            Throw "(404) Not Found"
        }
        {Invoke-ReviewQueuedTaskSet -RestServer localhost -TableName tasks} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Connection' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Get-QueuedTaskSet' -Times 2 -Exactly
    }
}