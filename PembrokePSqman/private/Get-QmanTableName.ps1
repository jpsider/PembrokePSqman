function Get-QmanTableName {
    <#
	.DESCRIPTION
		This function will gather The tableName for the Queue Manager type.
    .PARAMETER RestServer
        A Rest Server is required.
    .PARAMETER Type_ID
        A Queue Manager Type_ID is required.
	.EXAMPLE
        Get-QmanTableName -RestServer localhost -Type_ID 1
	.NOTES
        This will return a hashtable of data from the PPS database.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory=$true)][string]$RestServer,
        [Parameter(Mandatory=$true)][int]$Type_ID
    )
    if (Test-Connection -Count 1 $RestServer -Quiet) {
        try
        {
            Write-LogLevel -Message "Getting the TableName from: queue_Manager_type table." -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel DEBUG
            $URL = "http://$RestServer/PembrokePS/public/api/api.php/queue_manager_type/$Type_ID"
            Write-LogLevel -Message "the URL is: $URL" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel TRACE
            $TableName = Invoke-RestMethod -Method Get -Uri "$URL" -UseBasicParsing
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            Throw "Get-QmanTableName: $ErrorMessage $FailedItem"
        }
        $TableName
    } else {
        Throw "Get-QmanTableName: Unable to reach Rest server: $RestServer."
    }
}