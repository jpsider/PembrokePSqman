function Get-CancelledTaskSet {
    <#
	.DESCRIPTION
		This function will gather the cancelled tasks for the specified TableName.
    .PARAMETER RestServer
        A Rest Server is required.
    .PARAMETER TableName
        A TableName is optional, default is tasks.
	.EXAMPLE
        Get-CancelledTaskSet -RestServer localhost -TableName tasks
	.NOTES
        This will return a hashtable of data from the PPS database.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory=$true)][string]$RestServer,
        [string]$TableName="tasks"
    )
    if (Test-Connection -Count 1 $RestServer -Quiet) {
        try
        {
            $TableName = $TableName.ToLower()
            Write-LogLevel -Message "Gathering cancelled tasks from table: $TableName" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel INFO
            $URL = "http://$RestServer/PembrokePS/public/api/api.php/$TableName" + "?filter=STATUS_ID,eq,10&transform=1"
            Write-LogLevel -Message "the URL is: $URL" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel TRACE
            $CancelledTasks = Invoke-RestMethod -Method Get -Uri "$URL" -UseBasicParsing
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            Throw "Get-CancelledTaskSet: $ErrorMessage $FailedItem"
        }
        $CancelledTasks
    } else {
        Throw "Get-CancelledTaskSet: Unable to reach Rest server: $RestServer."
    }
}