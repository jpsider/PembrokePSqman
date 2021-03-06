function Get-ActiveWmanTaskSet {
    <#
	.DESCRIPTION
		This function will gather the cancelled tasks for the specified TableName.
    .PARAMETER RestServer
        A Rest Server is required.
    .PARAMETER TableName
        A TableName is optional, default is tasks.
    .PARAMETER WmanId
        A WmanId is Required.
	.EXAMPLE
        Get-ActiveWmanTaskSet -RestServer localhost -TableName tasks -WmanId 1
	.NOTES
        This will return a hashtable of data from the PPS database.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory=$true)][string]$RestServer,
        [Parameter(Mandatory=$true)][int]$WmanId,
        [string]$TableName="tasks"
    )
    if (Test-Connection -Count 1 $RestServer -Quiet) {
        try
        {
            # Checking for tasks that are (Assigned(7),Running(8),Cancelled(10),Staged(14))
            Write-LogLevel -Message "Checking for tasks that are (Assigned(7),Running(8),Cancelled(10),Staged(14)) in table: $TableName" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel DEBUG
            $TableName = $TableName.ToLower()
            $URL = "http://$RestServer/PembrokePS/public/api/api.php/$TableName" + "?&filter[]=STATUS_ID,eq,7&filter[]=STATUS_ID,eq,8&filter[]=STATUS_ID,eq,10&filter[]=STATUS_ID,eq,14&transform=1&satisfy=any"
            Write-LogLevel -Message "The Url is $URL" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel TRACE
            $ActiveWmanTasks = Invoke-RestMethod -Method Get -Uri "$URL" -UseBasicParsing
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            Throw "Get-ActiveWmanTaskSet: $ErrorMessage $FailedItem"
        }
        $ActiveWmanTasks
    } else {
        Throw "Get-ActiveWmanTaskSet: Unable to reach Rest server $RestServer."
    }
}