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
            if($QueuedTasksCount -gt 0) {
                foreach($Task in $QueuedTasks){
                    # Foreach task, set it to Queued.
                    $TaskId = $Task.ID
                    $TASK_TYPE_ID = $Task.TASK_TYPE_ID
                    # Based on the task type ID, we need to get the Workflow Manager Type that is enabled to perform that task.
                    $Wman_Type_ID = (Get-AvailableWmanType -RestServer localhost -TaskTypeId $TASK_TYPE_ID).WORKFLOW_MANAGER_TYPE_ID
                    # then get the WMAN that is available
                    $AvailableWmanSet = Get-AvailableWmanSet -RestServer localhost -Wman_Type $Wman_Type_ID
                    # Loop through each to see if the Wman is at it's max
                    :SingleTaskLoop
                    foreach($Workflow_Manager in $AvailableWmanSet) {
                        $WmanId = $Workflow_Manager.ID
                        $Wman_Max = $Workflow_Manager.MAX_CONCURRENT_TASKS
                        # $ Remove the space Wman_Hostname = $Workflow_Manager.Hostname
                        # Get the current Number of 'active' tasks assigned to the Workflow Manager
                        $WmanActiveTaskCount = (Get-ActiveWmanTaskSet -RestServer localhost -TableName tasks -WmanId $WmanId | Measure-Object).count
                        # if its not, then we can assign it!
                        if ($WmanActiveTaskCount -lt $Wman_Max){
                        #Don't forget to break out if we can assign it!
                            $ReturnMessage = Invoke-AssignTask -RestServer localhost -TaskId $TaskId -WmanId $WmanId
                            break SingleTaskLoop
                        } else {
                            # Current Workflow MGR was at its Max.
                        }
                    }
                }
            } else {
                # No tasks to queue
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
        Throw "Unable to reach web server."
    }
    
}