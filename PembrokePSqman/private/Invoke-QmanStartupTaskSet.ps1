function Invoke-QmanStartupTaskSet {
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
        Invoke-QmanStartupTaskSet -RestServer localhost -TableName tasks -ID 1
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
            Write-LogLevel -Message "Aborting Cancelled tasks for Table: $TableName" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel INFO
            Invoke-AbortCancelledTaskSet -RestServer $RestServer -TableName $TableName
            Invoke-Wait -Seconds 5
            Write-LogLevel -Message "Setting the QueueManager status to 2(Running)." -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel INFO
            Invoke-UpdateQmanData -ComponentId $ID -RestServer $RestServer -Column STATUS_ID -Value 2
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            Throw "Invoke-QmanStartupTaskSet: $ErrorMessage $FailedItem"
        }
        $ReturnMessage
    } else {
        Throw "Invoke-QmanStartupTaskSet: Unable to reach Rest server: $RestServer."
    }
}