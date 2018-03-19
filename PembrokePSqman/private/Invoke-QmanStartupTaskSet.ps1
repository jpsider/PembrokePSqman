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
            Invoke-AbortCancelledTaskSet -RestServer $RestServer -TableName $TableName
            Invoke-Wait -Seconds 5
            Invoke-UpdateQmanData -ComponentId $ID -RestServer $RestServer -Column STATUS_ID -Value 2
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName		
            Throw "Error: $ErrorMessage $FailedItem"
        }
        $ReturnMessage = $true
        $ReturnMessage
    } else {
        Throw "Unable to reach web server."
    }
}
    