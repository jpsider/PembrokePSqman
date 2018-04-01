function Invoke-QueueSubmittedTaskSet {
    <#
	.DESCRIPTION
		This function will queue Submitted tasks
    .PARAMETER RestServer
        A Rest Server is required.
    .PARAMETER TableName
        A TableName is optional, default is tasks.
	.EXAMPLE
        Invoke-QueueSubmittedTaskSet -RestServer localhost -TableName tasks
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
            $SubmittedTasks = (Get-SubmittedTaskSet -RestServer $RestServer -TableName $TableName).$TableName
            $SubmittedTasksCount = ($SubmittedTasks | Measure-Object).count
            Write-LogLevel -Message "Reviewing: $SubmittedTasksCount for queueing from table: $TableName." -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel INFO
            if($SubmittedTasksCount -gt 0) {
                foreach($Task in $SubmittedTasks){
                    # Foreach task, set it to Queued.
                    $TaskId = $Task.ID
                    $body = @{STATUS_ID = "6"} 
                    Write-LogLevel -Message "Queueing task: $TaskId." -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel INFO
                    $ReturnMessage = Invoke-UpdateTaskTable -RestServer $RestServer -TableName $TableName -TaskID $TaskId -Body $body
                }
            } else {
                # No tasks to queue
                Write-LogLevel -Message "No Tasks to Queue from table: $TableName." -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel DEBUG
            }
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName		
            Throw "Invoke-QueueSubmittedTaskSet: $ErrorMessage $FailedItem"
        }
        $ReturnMessage
    } else {
        Throw "Invoke-QueueSubmittedTaskSet: Unable to reach Rest server: $RestServer."
    }
    
}