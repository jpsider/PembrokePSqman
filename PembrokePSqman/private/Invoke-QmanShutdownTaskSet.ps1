function Invoke-QmanShutdownTaskSet {
    <#
	.DESCRIPTION
		This function will perform shutdown tasks for a Queue_Manager
    .PARAMETER RestServer
        A RestServer is Required.
    .PARAMETER TableName
        A properties path is Required.
    .PARAMETER ID
        An ID is Required.
	.EXAMPLE
        Invoke-QmanShutdownTaskSet -RestServer localhost -TableName tasks -ID 1
	.NOTES
        This will return a hashtable of data from the PPS database.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    [OutputType([Boolean])]
    param(
        [Parameter(Mandatory=$true)][string]$RestServer,
        [Parameter(Mandatory=$true)][string]$TableName,
        [Parameter(Mandatory=$true)][int]$ID
    )
    if (Test-Connection -Count 1 $RestServer -Quiet) {
        try
        {
            $TableName = $TableName.ToLower()
            Write-LogLevel -Message "Aborting cancelled tasks for table: $TableName" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel INFO
            Invoke-AbortCancelledTaskSet -RestServer $RestServer -TableName $TableName
            Invoke-Wait -Seconds 5
            Write-LogLevel -Message "Shutting down QueueManager: $ID." -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel INFO
            Invoke-UpdateQmanData -ComponentId $ID -RestServer $RestServer -Column STATUS_ID -Value 1
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName		
            Throw "Invoke-QmanShutdownTaskSet: $ErrorMessage $FailedItem"
        }
        $ReturnMessage
    } else {
        Throw "Invoke-QmanShutdownTaskSet: Unable to reach Rest server: $RestServer."
    }

}
    