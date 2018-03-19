function Invoke-Qman {
    <#
	.DESCRIPTION
		This function will gather Status information from PembrokePS web/rest for a Queue_Manager
    .PARAMETER PropertyFilePath
        A properties path is Required.
	.EXAMPLE
        Invoke-Qman -PropertyFilePath "c:\pps\qman\pembrokeps.properties"
	.NOTES
        This will return a hashtable of data from the PPS database.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    [OutputType([Boolean])]
    param(
        [Parameter(Mandatory=$true)][string]$PropertyFilePath
    )
    if (Test-Path -Path $PropertyFilePath) {
        # Gather Local Properties for the Queue Manager
        $PpsProperties = Get-LocalPropertySet -PropertyFilePath $PropertyFilePath
        $RestServer = $PpsProperties.'system.RestServer'
        $ID = $PpsProperties.'component.Id'
        # $ComponentType = $PpsProperties.'component.Type'
     } else {
        Throw "Unable to Locate Properties file."
    }
    try
    {
        $QmanRunning = $true
        do {
            # Test connection with the Database Server
            if (Test-Connection -Count 1 $RestServer -Quiet) {
                # No Action needed if the RestServer can be reached.
            } else {
                $QmanRunning = $false
                Throw "Unable to reach Rest server."
            }
            # Get the Status and Queue Manager Specific Information from the Database
            $QmanStatusData = Get-QmanStatus -ComponentId $ID -RestServer $RestServer
            $QueueManagerStatus = $QmanStatusData.STATUS_ID
            # $LOG_FILE = $QmanStatusData.LOG_FILE
            $ManagerWait = $QmanStatusData.WAIT
            $QUEUE_MANAGER_TYPE_ID = $QmanStatusData.QUEUE_MANAGER_TYPE_ID
            $TableName = Get-QmanTableName -RestServer $RestServer -Type_ID $QUEUE_MANAGER_TYPE_ID
            # Based on the Status Perform Specific actions
            if ($QueueManagerStatus -eq 1) {
                # Down - Not doing Anything
            } elseif ($QueueManagerStatus -eq 2) {
                # Up - Perform normal Tasks
                $QmanRunning = Invoke-AbortCancelledTaskSet -RestServer $RestServer -TableName $TableName
                Invoke-Wait -Seconds 5
                $QmanRunning = Invoke-QueueSubmittedTaskSet -RestServer $RestServer -TableName $TableName 
                Invoke-Wait -Seconds 5
                $QmanRunning = Invoke-ReviewQueuedTaskSet -RestServer $RestServer $TableName
            } elseif ($QueueManagerStatus -eq 3) {
                # Starting Up - Perform startup Tasks
                $QmanRunning = Invoke-QmanStartupTaskSet -TableName $TableName -RestServer $RestServer
            } elseif ($QueueManagerStatus -eq 4) {
                # Shutting Down - Perform Shutdown Tasks
                $QmanRunning = Invoke-QmanShutdownTaskSet -TableName $TableName -RestServer $RestServer
            }
            if ($null -eq $ManagerWait) {
                Invoke-Wait -Seconds $ManagerWait
            } else {
                Invoke-Wait -Seconds 15
            }
        } while ($QmanRunning -eq $true)
    }
    catch
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName		
        Throw "Error: $ErrorMessage $FailedItem"
    }
    
}