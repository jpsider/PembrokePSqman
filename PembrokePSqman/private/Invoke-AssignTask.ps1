function Invoke-AssignTask {
    <#
	.DESCRIPTION
		This function will Assign a task to a specific WorkFlow Manager.
    .PARAMETER TaskId
        A TaskId is required.
    .PARAMETER RestServer
        A Rest Server is required.
    .PARAMETER WmanId
        A WmanId is required.
    .PARAMETER TableName
        A TableName is optional, default is tasks.
	.EXAMPLE
        Invoke-AssignTask -RestServer localhost -TaskId 1 -WmanId 1
	.NOTES
        This will return a hashtable of data from the PPS database.
    #>
    [CmdletBinding()]
    [OutputType([Int])]
    param(
        [Parameter(Mandatory=$true)][int]$TaskId,
        [Parameter(Mandatory=$true)][int]$WmanId,
        [Parameter(Mandatory=$true)][string]$RestServer,
        [string]$TableName="tasks"
    )
    if (Test-Connection -Count 1 $RestServer -Quiet) {
        try
        {
            $TableName = $TableName.ToLower()
            $body = @{STATUS_ID = "7"
                        WORKFLOW_MANAGER_ID = "$WmanId"
                    }
            Write-LogLevel -Message "Assigning task: $TaskId, to Wman: $WmanId, table: $TableName" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel INFO
            $URL = "http://$RestServer/PembrokePS/public/api/api.php/$TableName/$TaskId"
            Write-LogLevel -Message "URL is: $URL" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel TRACE
            $RestReturn = Invoke-RestMethod -Method Put -Uri "$URL" -body $body
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName		
            Throw "Invoke-AssignTask: $ErrorMessage $FailedItem"
        }
        $RestReturn
    } else {
        Throw "Invoke-AssignTask: Unable to reach Rest server: $RestServer."
    }
    
}