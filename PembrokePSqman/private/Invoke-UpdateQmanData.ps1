function Invoke-UpdateQmanData {
    <#
	.DESCRIPTION
		This function will update a column and field for a Queue_Manager
    .PARAMETER ComponentId
        An ID is required.
    .PARAMETER RestServer
        A Rest Server is required.
    .PARAMETER Column
        A Column/Field is required.
    .PARAMETER Value
        A Value is required.
	.EXAMPLE
        Invoke-UpdateQmanData -ComponentId 1 -RestServer localhost -Column STATUS_ID -Value 2
	.NOTES
        This will return a hashtable of data from the PPS database.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory=$true)][int]$ComponentId,
        [Parameter(Mandatory=$true)][string]$RestServer,
        [Parameter(Mandatory=$true)][string]$Column,
        [Parameter(Mandatory=$true)][string]$Value
    )
    if (Test-Connection -Count 1 $RestServer -Quiet) {
        try
        {
            Write-LogLevel -Message "Updating the Queue_Manager -Column $Column -Value $Value" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel TRACE
            if ((Invoke-UpdateComponent -ComponentId $ComponentId -RestServer $RestServer -Column $Column -Value $Value -ComponentType queue_manager) -eq 1) {
                # Good To go
            } else {
                Write-LogLevel -Message "Unable to update Queue Manager via restcall." -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel TRACE
                Throw "Unable to update Qman data."
            }
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            Throw "Invoke-UpdateQmanData: $ErrorMessage $FailedItem"
        }
    } else {
        Throw "Invoke-UpdateQmanData: Unable to reach Rest server: $RestServer."
    }
}