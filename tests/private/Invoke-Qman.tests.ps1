$script:ModuleName = 'PembrokePSqman'

Describe "Invoke-Qman function for $moduleName" {
    function Get-LocalPropertySet{}
    function Get-QmanStatus{}
    function Invoke-Wait{}
    It "Should Throw if the path fails" {
        Mock -CommandName 'Test-Path' -MockWith {
            $false
        }
        {Invoke-Qman -PropertyFilePath 'c:\pps\qman\pembrokeps.properties'} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Path' -Times 1 -Exactly
    }
    It "Should not Throw during Shutdown Tasks" {
        Mock -CommandName 'Test-Path' -MockWith {
            $true
        }
        Mock -CommandName 'Get-LocalPropertySet' -MockWith { 
            $PpsProperties = @{
                system = @{
                    RestServer = 'localhost'
                }
                component = @{
                    id = '1'
                }
            }
            return $PpsProperties
        }
        function Test-Connection {}
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Get-QmanStatus' -MockWith {
            $RawReturn = @(
                @{
                    ID            = '1'
                    STATUS_ID     = '4'
                    WAIT       = '300'
                }               
            )
            $ReturnJson = $RawReturn | ConvertTo-Json
            $QmanStatusData = $ReturnJson | convertfrom-json
            return $QmanStatusData
        }
        Mock -CommandName 'Get-QmanTableName' -MockWith {
            $true
        }
        Mock -CommandName 'Invoke-Wait' -MockWith {
            $true
        }
        function Invoke-QmanShutdownTaskSet{}
        Mock -CommandName 'Invoke-QmanShutdownTaskSet' -MockWith {
            $false
        }
        {Invoke-Qman -PropertyFilePath 'c:\pps\qman\pembrokeps.properties'} | Should -not -Throw
        Assert-MockCalled -CommandName 'Test-Path' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Test-Connection' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Get-LocalPropertySet' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Get-QmanStatus' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Invoke-Wait' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Invoke-QmanShutdownTaskSet' -Times 1 -Exactly
    }
    It "Should not Throw during StartUp Tasks" {
        Mock -CommandName 'Test-Path' -MockWith {
            $true
        }
        Mock -CommandName 'Get-LocalPropertySet' -MockWith { 
            $PpsProperties = @{
                system = @{
                    RestServer = 'localhost'
                }
                component = @{
                    id = '1'
                }
            }
            return $PpsProperties
        }
        function Test-Connection {}
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Get-QmanStatus' -MockWith {
            $RawReturn = @(
                @{
                    ID            = '1'
                    STATUS_ID     = '3'
                    WAIT       = '300'
                }               
            )
            $ReturnJson = $RawReturn | ConvertTo-Json
            $QmanStatusData = $ReturnJson | convertfrom-json
            return $QmanStatusData
        }
        Mock -CommandName 'Get-QmanTableName' -MockWith {
            $true
        }
        Mock -CommandName 'Invoke-Wait' -MockWith {
            $true
        }
        function Invoke-QmanStartupTaskSet{}
        Mock -CommandName 'Invoke-QmanStartupTaskSet' -MockWith {
            $false
        }
        {Invoke-Qman -PropertyFilePath 'c:\pps\qman\pembrokeps.properties'} | Should -not -Throw
        Assert-MockCalled -CommandName 'Test-Path' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Test-Connection' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Get-LocalPropertySet' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Get-QmanStatus' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Invoke-Wait' -Times 2 -Exactly
        Assert-MockCalled -CommandName 'Invoke-QmanStartupTaskSet' -Times 1 -Exactly
    }
    It "Should not Throw during Normal Operation" {
        Mock -CommandName 'Test-Path' -MockWith {
            $true
        }
        Mock -CommandName 'Get-LocalPropertySet' -MockWith { 
            $PpsProperties = @{
                system = @{
                    RestServer = 'localhost'
                }
                component = @{
                    id = '1'
                }
            }
            return $PpsProperties
        }
        function Test-Connection {}
        Mock -CommandName 'Test-Connection' -MockWith {
            $true
        }
        Mock -CommandName 'Get-QmanStatus' -MockWith {
            $RawReturn = @(
                @{
                    ID            = '1'
                    STATUS_ID     = '2'
                    WAIT       = $null
                }               
            )
            $ReturnJson = $RawReturn | ConvertTo-Json
            $QmanStatusData = $ReturnJson | convertfrom-json
            return $QmanStatusData
        }
        Mock -CommandName 'Get-QmanTableName' -MockWith {
            $true
        }
        Mock -CommandName 'Invoke-Wait' -MockWith {
            $true
        }
        function Invoke-AbortCancelledTaskSet{}
        Mock -CommandName 'Invoke-AbortCancelledTaskSet' -MockWith {
            $true
        }
        function Invoke-QueueSubmittedTaskSet{}
        Mock -CommandName 'Invoke-QueueSubmittedTaskSet' -MockWith {
            $true
        }
        function Invoke-ReviewQueuedTaskSet{}
        Mock -CommandName 'Invoke-ReviewQueuedTaskSet' -MockWith {
            $false
        }
        {Invoke-Qman -PropertyFilePath 'c:\pps\qman\pembrokeps.properties'} | Should -not -Throw
        Assert-MockCalled -CommandName 'Test-Path' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Test-Connection' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Get-LocalPropertySet' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Get-QmanStatus' -Times 3 -Exactly
        Assert-MockCalled -CommandName 'Invoke-Wait' -Times 5 -Exactly
        Assert-MockCalled -CommandName 'Invoke-AbortCancelledTaskSet' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Invoke-QueueSubmittedTaskSet' -Times 1 -Exactly
        Assert-MockCalled -CommandName 'Invoke-ReviewQueuedTaskSet' -Times 1 -Exactly
    }
    It "Should Throw if the Rest Server cannot be reached.." {
        Mock -CommandName 'Test-Path' -MockWith {
            $true
        }
        Mock -CommandName 'Get-LocalPropertySet' -MockWith {
            return $PpsProperties
        }
        Mock -CommandName 'Test-Connection' -MockWith {
            $false
        }
        {Invoke-Qman -PropertyFilePath "c:\pps\qman\pembrokeps.properties"} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Path' -Times 5 -Exactly
        Assert-MockCalled -CommandName 'Test-Connection' -Times 4 -Exactly
        Assert-MockCalled -CommandName 'Get-LocalPropertySet' -Times 4 -Exactly
    }
    It "Should Throw if the file does not exist." {
        Mock -CommandName 'Test-Path' -MockWith {}
        {Invoke-Qman -PropertyFilePath "c:\pps\qman\pembrokeps.properties"} | Should -Throw
        Assert-MockCalled -CommandName 'Test-Path' -Times 6 -Exactly
    }
}