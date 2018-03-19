function Invoke-AbortCancelledTaskSet {
    <#
	.DESCRIPTION
		This function will Set any cancelled task to aborted.
    .PARAMETER RestServer
        A Rest Server is required.
    .PARAMETER TableName
        A TableName is optional, default is tasks.
	.EXAMPLE
        Invoke-AbortCancelledTaskSet -RestServer localhost -TableName tasks
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
            $CancelledTasks = Get-CancelledTaskSet -RestServer $RestServer -TableName $TableName
            $CancelledTasksCount = ($CancelledTasks | Measure-Object).count
            if($CancelledTasksCount -gt 0) {
                foreach($Task in $CancelledTasks){
                    # Foreach task, set it to Complete/Aborted.
                    $TaskId = $Task.ID
                    $body = @{STATUS_ID = "8"
                                RESULT_ID = "5"
                            }
                    $RestReturn = Invoke-UpdateTaskTable -RestServer $RestServer -TableName $TableName -TaskID $TaskId -Body $body
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
        $RestReturn = $true
        $RestReturn
    } else {
        Throw "Unable to reach web server."
    }
    
}