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
        Write-Log -Message "Gathering Local Properties from: $PropertyFilePath" -OutputStyle ConsoleOnly
        $PpsProperties = Get-LocalPropertySet -PropertyFilePath $PropertyFilePath
        $RestServer = $PpsProperties.'system.RestServer'
        $ID = $PpsProperties.'component.Id'
     } else {
        Write-Log -Message "Unable to Locate Local properties file: $PropertyFilePath." -OutputStyle ConsoleOnly
        Throw "Unable to Locate Properties file."
    }
    try
    {
        $script:QmanRunning = "Running"
        do {
            # Test connection with the Database Server
            Write-Log -Message "Starting Invoke-Qman loop" -OutputStyle ConsoleOnly
            if (Test-Connection -Count 1 $RestServer -Quiet) {
                # No Action needed if the RestServer can be reached.
            } else {
                $script:QmanRunning = "Shutdown"
                Write-Log -Message "Unable to reach RestServer: $RestServer." -OutputStyle ConsoleOnly
                Throw "Unable to reach Rest server."
            }
			Write-Log -Message "Validated Connection to RestServer." -OutputStyle ConsoleOnly 
            # Get the Status and Queue Manager Specific Information from the Database
            $QmanStatusData = Get-QmanStatus -ComponentId $ID -RestServer $RestServer
            $QueueManagerStatus = $QmanStatusData.STATUS_ID
            $LOG_FILE = $QmanStatusData.LOG_FILE
            $ManagerWait = $QmanStatusData.WAIT
            $QUEUE_MANAGER_TYPE_ID = $QmanStatusData.QUEUE_MANAGER_TYPE_ID
			Write-Log -Message "Get-QmanStatus is complete" -Logfile $LOG_FILE -OutputStyle ConsoleOnly 
            $TableName = Get-QmanTableName -RestServer $RestServer -Type_ID $QUEUE_MANAGER_TYPE_ID
			Write-Log -Message "Get QmanTablename is complete, TableName: $TableName" -OutputStyle ConsoleOnly
            # Based on the Status Perform Specific actions
            Write-Log -Message "QueueManager ID:         $ID" -Logfile $LOG_FILE -OutputStyle ConsoleOnly 
            Write-Log -Message "QueueManager Status:     $QueueManagerStatus" -Logfile $LOG_FILE -OutputStyle ConsoleOnly 
            Write-Log -Message "QueueManager TableName : $TableName" -Logfile $LOG_FILE -OutputStyle ConsoleOnly 
            Write-Log -Message "QueueManager Wait:       $ManagerWait" -Logfile $LOG_FILE -OutputStyle ConsoleOnly 
            Write-Log -Message "QueueManager LogFile:    $LOG_FILE" -Logfile $LOG_FILE -OutputStyle ConsoleOnly 
            if ($QueueManagerStatus -eq 1) {
                # Down - Not doing Anything
                Write-Log -Message "Get-QmanStatus is Down, Not taking Action." -Logfile $LOG_FILE -OutputStyle ConsoleOnly 
            } elseif ($QueueManagerStatus -eq 2) {
                # Up - Perform normal Tasks
                Write-Log -Message "Get-QmanStatus is UP, performing Normal Operations" -Logfile $LOG_FILE -OutputStyle ConsoleOnly 
                Write-Log -Message "Aborting Cancelled Tasks" -Logfile $LOG_FILE -OutputStyle ConsoleOnly 
                Invoke-AbortCancelledTaskSet -RestServer $RestServer -TableName $TableName
                Invoke-Wait -Seconds 5
                Write-Log -Message "Queuing Submitted Tasks" -Logfile $LOG_FILE -OutputStyle ConsoleOnly 
                Invoke-QueueSubmittedTaskSet -RestServer $RestServer -TableName $TableName 
                Invoke-Wait -Seconds 5
                Write-Log -Message "Reviewing Queued Tasks" -Logfile $LOG_FILE -OutputStyle ConsoleOnly 
                Invoke-ReviewQueuedTaskSet -RestServer $RestServer -TableName $TableName
                Write-Log -Message "Normal Operations Completed." -Logfile $LOG_FILE -OutputStyle ConsoleOnly 
            } elseif ($QueueManagerStatus -eq 3) {
                # Starting Up - Perform startup Tasks
                Write-Log -Message "Performting Startup Tasks" -Logfile $LOG_FILE -OutputStyle ConsoleOnly 
                Invoke-QmanStartupTaskSet -TableName $TableName -RestServer $RestServer -ID $ID
                Write-Log -Message "Startup Tasks Completed." -Logfile $LOG_FILE -OutputStyle ConsoleOnly
            } elseif ($QueueManagerStatus -eq 4) {
                # Shutting Down - Perform Shutdown Tasks
                Write-Log -Message "Performing Shutdown tasks." -Logfile $LOG_FILE -OutputStyle ConsoleOnly 
                Invoke-QmanShutdownTaskSet -TableName $TableName -RestServer $RestServer -ID $ID
                $script:QmanRunning = "Shutdown"
                Write-Log -Message "Shutdown tasks completed." -Logfile $LOG_FILE -OutputStyle ConsoleOnly 
            }
            Write-Log -Message "Manager running String: $script:QmanRunning" -Logfile $LOG_FILE -OutputStyle ConsoleOnly 
            if($script:QmanRunning -ne "Shutdown"){
                Write-Log -Message "Waiting $ManagerWait Seconds" -Logfile $LOG_FILE -OutputStyle ConsoleOnly 
                Invoke-Wait -Seconds $ManagerWait
            }
        } while ($script:QmanRunning -ne "Shutdown")
        Write-Log -Message "Exiting QueueManager Function." -Logfile $LOG_FILE -OutputStyle ConsoleOnly 
    }
    catch
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName		
        Throw "Error: $ErrorMessage $FailedItem"
    }
    
}