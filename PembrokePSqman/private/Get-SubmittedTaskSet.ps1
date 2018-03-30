function Get-SubmittedTaskSet {
    <#
	.DESCRIPTION
		This function will gather The submitted tasks for the specified TableName.
    .PARAMETER RestServer
        A Rest Server is required.
    .PARAMETER TableName
        A TableName is optional, default is tasks.
	.EXAMPLE
        Get-SubmittedTaskSet -RestServer localhost -TableName tasks
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
            Write-LogLevel -Message "Gathering Submitted tasks for table: $TableName" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel INFO
            $URL = "http://$RestServer/PembrokePS/public/api/api.php/$TableName" + "?filter=STATUS_ID,eq,5&transform=1"
            Write-LogLevel -Message "the URL is: $URL" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel TRACE
            $SubmittedTasks = (Invoke-RestMethod -Method Get -Uri "$URL" -UseBasicParsing).$TableName
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName		
            Throw "Get-SubmittedTaskSet: $ErrorMessage $FailedItem"
        }
        $SubmittedTasks
    } else {
        Throw "Get-SubmittedTaskSet: Unable to reach Rest server: $RestServer."
    }
    
}