function Get-QmanStatus {
    <#
	.DESCRIPTION
		This function will gather Status information from PembrokePS web/rest for a Queue_Manager
    .PARAMETER ComponentId
        An ID is required.
    .PARAMETER RestServer
        A Rest Server is required.
	.EXAMPLE
        Get-QmanStatus -ComponentId 1 -RestServer localhost
	.NOTES
        This will return a hashtable of data from the PPS database.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory=$true)][int]$ComponentId,
        [Parameter(Mandatory=$true)][string]$RestServer
    )
    if (Test-Connection -Count 1 $RestServer -Quiet) {
        try
        {
            Write-LogLevel -Message "Getting the Queue_Manager via 'Get-ComponentStatus" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel DEBUG
            $ComponentStatusData = Get-ComponentStatus -ComponentType Queue_Manager -ComponentId $ComponentId -RestServer $RestServer
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName		
            Throw "Get-QmanStatus: $ErrorMessage $FailedItem"
        }
        $ComponentStatusData
    } else {
        Throw "Get-QmanStatus: Unable to reach Rest server: $RestServer."
    }
    
}