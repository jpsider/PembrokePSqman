function Invoke-ReviewQueuedTaskSet {
    <#
	.DESCRIPTION
		This function will Review Queued tasks for assignment to Workflow Managers.
    .PARAMETER RestServer
        A Rest Server is required.
    .PARAMETER TableName
        A TableName is optional, default is tasks.
	.EXAMPLE
        Invoke-ReviewQueuedTaskSet -RestServer localhost -TableName tasks
	.NOTES
        This will return a hashtable of data from the PPS database.
    #>
    [CmdletBinding()]
    [OutputType([Int])]
    [OutputType([Boolean])]
    param(
        [Parameter(Mandatory=$true)][string]$RestServer,
        [string]$TableName="tasks"
    )
    if (Test-Connection -Count 1 $RestServer -Quiet) {
        try
        {
            # Get a list of Submitted tasks
            $TableName = $TableName.ToLower()
            $QueuedTasks = Get-QueuedTaskSet -RestServer $RestServer -TableName $TableName
            $QueuedTasksCount = ($QueuedTasks | Measure-Object).Count
            Write-LogLevel -Message "Reviewing: $QueuedTasksCount tasks that are queued from table: $TableName." -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel INFO
            if($QueuedTasksCount -gt 0) {
                foreach($Task in $QueuedTasks){
                    # Foreach task, see if it can be assigned.
                    $TaskId = $Task.ID
                    $TASK_TYPE_ID = $Task.TASK_TYPE_ID
                    Write-LogLevel -Message "Reviewing TaskId: $TaskId TaskTypeID: $Task_Type_Id for Assignment." -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel INFO
                    # Based on the task type ID, we need to get the Workflow Manager Type that is enabled to perform that task.
                    Write-LogLevel -Message "Determining the Workflow Manager Type that can perform the task." -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel DEBUG
                    $Wman_Type_ID = (Get-AvailableWmanType -RestServer localhost -TaskTypeId $TASK_TYPE_ID).WORKFLOW_MANAGER_TYPE_ID
                    # then get the WMAN that is available
                    Write-LogLevel -Message "Getting list of Available Workflow Managers" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel DEBUG
                    $AvailableWmanSet = Get-AvailableWmanSet -RestServer localhost -Wman_Type $Wman_Type_ID
                    # Loop through each to see if the Wman is at it's max
                    :SingleTaskLoop
                    foreach($Workflow_Manager in $AvailableWmanSet) {
                        $WmanId = $Workflow_Manager.ID
                        $Wman_Max = $Workflow_Manager.MAX_CONCURRENT_TASKS
                        $Wman_Hostname = $Workflow_Manager.Hostname
                        # Get the current Number of 'active' tasks assigned to the Workflow Manager
                        $WmanActiveTaskCount = (Get-ActiveWmanTaskSet -RestServer localhost -TableName tasks -WmanId $WmanId | Measure-Object).count
                        # if its not, then we can assign it!
                        if ($WmanActiveTaskCount -lt $Wman_Max){
                        #Don't forget to break out if we can assign it!
                            Write-LogLevel -Message "Assigning task: $TaskId to Mgr: $Wman_Hostname." -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel INFO
                            $ReturnMessage = Invoke-AssignTask -RestServer localhost -TaskId $TaskId -WmanId $WmanId
                            break SingleTaskLoop
                        } else {
                            # Current Workflow MGR was at its Max.
                            Write-LogLevel -Message "Current Workflow Manager: $Wman_Hostname is running at it's max: $WmanActiveTaskCount." -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel DEBUG
                        }
                    }
                }
            } else {
                # No tasks to queue
                Write-LogLevel -Message "No Tasks to Queue" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel DEBUG
            }
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName		
            Throw "Invoke-ReviewQueuedTaskSet: $ErrorMessage $FailedItem"
        }
        $ReturnMessage
    } else {
        Throw "Invoke-ReviewQueuedTaskSet: Unable to reach Rest server: $RestServer."
    }
    
}