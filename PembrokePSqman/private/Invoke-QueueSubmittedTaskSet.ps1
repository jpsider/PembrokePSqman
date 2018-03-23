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
            $SubmittedTasks = Get-SubmittedTaskSet -RestServer $RestServer -TableName $TableName
            $SubmittedTasksCount = ($SubmittedTasks | Measure-Object).count
            if($SubmittedTasksCount -gt 0) {
                foreach($Task in $SubmittedTasks){
                    # Foreach task, set it to Queued.
                    $TaskId = $Task.ID
                    $body = @{STATUS_ID = "6"} 
                    $ReturnMessage = Invoke-UpdateTaskTable -RestServer $RestServer -TableName $TableName -TaskID $TaskId -Body $body
                }
            } else {
                # No tasks to queue
            }
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName		
            Throw "Error: $ErrorMessage $FailedItem"
        }
        $ReturnMessage
    } else {
        Throw "Unable to reach web server."
    }
    
}