function Get-AvailableWmanType {
    <#
	.DESCRIPTION
		This function will get the Workflow Manager Type based on the specified task type.
    .PARAMETER RestServer
        A Rest Server is required.
    .PARAMETER TaskTypeId
        A TaskTypeId is required.
	.EXAMPLE
        Get-AvailableWmanType -RestServer localhost -TaskTypeId 1
	.NOTES
        This will return a hashtable of data from the PPS database.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory=$true)][string]$RestServer,
        [Parameter(Mandatory=$true)][int]$TaskTypeId
    )
    if (Test-Connection -Count 1 $RestServer -Quiet) {
        try
        {
            Write-LogLevel -Message "Gathering Available Wman type based on task type: $TaskTypeId" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel DEBUG
            $URL = "http://$RestServer/PembrokePS/public/api/api.php/wman_task_types" + "?filter[]=TASK_TYPE_ID,eq,$TaskTypeId&filter[]=STATUS_ID,eq,11&transform=1"
            Write-LogLevel -Message "the URL is: $URL" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel TRACE
            $WmanTypeData = (Invoke-RestMethod -Method Get -Uri "$URL" -UseBasicParsing).wman_task_types
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName		
            Throw "Get-AvailableWmanType: $ErrorMessage $FailedItem"
        }
        $WmanTypeData
    } else {
        Throw "Get-AvailableWmanType: Unable to reach Rest server: $RestServer."
    }
    
}