function Invoke-Qman {
    <#
	.DESCRIPTION
		This function will gather Status information from PembrokePS web/rest for a Queue_Manager
    .PARAMETER PropertyFilePath
        A properties path is Required.
	.EXAMPLE
        Invoke-Qman -PropertyFilePath "c:\PembrokePS\qman\pembrokeps.properties"
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
        Write-LogLevel -Message "Gathering Local Properties from: $PropertyFilePath" -Logfile "$LOG_FILE" -RunLogLevel CONSOLEONLY -MsgLevel CONSOLEONLY
        $PpsProperties = Get-LocalPropertySet -PropertyFilePath $PropertyFilePath
        $RestServer = $PpsProperties.'system.RestServer'
        $ID = $PpsProperties.'component.Id'
        $RunLogLevel = $PpsProperties.'component.RunLogLevel'
     } else {
        Write-LogLevel -Message "Unable to Locate Local properties file: $PropertyFilePath." -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel ERROR
        Throw "Invoke-Qman: Unable to Locate Properties file."
    }
    try
    {
        $script:QmanRunning = "Running"
        do {
            # Test connection with the Database Server
            Write-LogLevel -Message "Starting Invoke-Qman loop" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel INFO
            if (Test-Connection -Count 1 $RestServer -Quiet) {
                # No Action needed if the RestServer can be reached.
            } else {
                $script:QmanRunning = "Shutdown"
                Write-LogLevel -Message "Unable to reach RestServer: $RestServer." -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel ERROR
                Throw "Unable to reach Rest server."
            }
			Write-LogLevel -Message "Validated Connection to RestServer." -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel INFO 
            # Get the Status and Queue Manager Specific Information from the Database
            $QmanStatusData = Get-QmanStatus -ComponentId $ID -RestServer $RestServer
            $QueueManagerStatus = $QmanStatusData.STATUS_ID
            $LOG_FILE = $QmanStatusData.LOG_FILE
            $ManagerWait = $QmanStatusData.WAIT
            $QUEUE_MANAGER_TYPE_ID = $QmanStatusData.QUEUE_MANAGER_TYPE_ID
			Write-LogLevel -Message "Get-QmanStatus is complete" -Logfile $LOG_FILE -RunLogLevel $RunLogLevel -MsgLevel INFO 
            $TableName = (Get-QmanTableName -RestServer $RestServer -Type_ID $QUEUE_MANAGER_TYPE_ID).TABLENAME
			Write-LogLevel -Message "Get QmanTablename is complete, TableName: $TableName" -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel INFO
            # Based on the Status Perform Specific actions
            Write-LogLevel -Message "QueueManager ID:         $ID" -Logfile $LOG_FILE -RunLogLevel $RunLogLevel -MsgLevel INFO 
            Write-LogLevel -Message "QueueManager Status:     $QueueManagerStatus" -Logfile $LOG_FILE -RunLogLevel $RunLogLevel -MsgLevel INFO 
            Write-LogLevel -Message "QueueManager TableName : $TableName" -Logfile $LOG_FILE -RunLogLevel $RunLogLevel -MsgLevel INFO 
            Write-LogLevel -Message "QueueManager Wait:       $ManagerWait" -Logfile $LOG_FILE -RunLogLevel $RunLogLevel -MsgLevel INFO 
            Write-LogLevel -Message "QueueManager LogFile:    $LOG_FILE" -Logfile $LOG_FILE -RunLogLevel $RunLogLevel -MsgLevel INFO 
            if ($QueueManagerStatus -eq 1) {
                # Down - Not doing Anything
                Write-LogLevel -Message "Get-QmanStatus is Down, Not taking Action." -Logfile $LOG_FILE -RunLogLevel $RunLogLevel -MsgLevel ERROR 
            } elseif ($QueueManagerStatus -eq 2) {
                # Up - Perform normal Tasks
                Write-LogLevel -Message "Get-QmanStatus is UP, performing Normal Operations" -Logfile $LOG_FILE -RunLogLevel $RunLogLevel -MsgLevel INFO 
                Write-LogLevel -Message "Aborting Cancelled Tasks" -Logfile $LOG_FILE -RunLogLevel $RunLogLevel -MsgLevel DEBUG 
                Invoke-AbortCancelledTaskSet -RestServer $RestServer -TableName $TableName
                Invoke-Wait -Seconds 5
                Write-LogLevel -Message "Queuing Submitted Tasks" -Logfile $LOG_FILE -RunLogLevel $RunLogLevel -MsgLevel DEBUG 
                Invoke-QueueSubmittedTaskSet -RestServer $RestServer -TableName $TableName 
                Invoke-Wait -Seconds 5
                Write-LogLevel -Message "Reviewing Queued Tasks" -Logfile $LOG_FILE -RunLogLevel $RunLogLevel -MsgLevel DEBUG 
                Invoke-ReviewQueuedTaskSet -RestServer $RestServer -TableName $TableName
                Write-LogLevel -Message "Normal Operations Completed." -Logfile $LOG_FILE -RunLogLevel $RunLogLevel -MsgLevel DEBUG 
            } elseif ($QueueManagerStatus -eq 3) {
                # Starting Up - Perform startup Tasks
                Write-LogLevel -Message "Performting Startup Tasks" -Logfile $LOG_FILE -RunLogLevel $RunLogLevel -MsgLevel INFO 
                Invoke-QmanStartupTaskSet -TableName $TableName -RestServer $RestServer -ID $ID
                Write-LogLevel -Message "Startup Tasks Completed." -Logfile $LOG_FILE -RunLogLevel $RunLogLevel -MsgLevel DEBUG
            } elseif ($QueueManagerStatus -eq 4) {
                # Shutting Down - Perform Shutdown Tasks
                Write-LogLevel -Message "Performing Shutdown tasks." -Logfile $LOG_FILE -RunLogLevel $RunLogLevel -MsgLevel INFO 
                Invoke-QmanShutdownTaskSet -TableName $TableName -RestServer $RestServer -ID $ID
                $script:QmanRunning = "Shutdown"
                Write-LogLevel -Message "Shutdown tasks completed." -Logfile $LOG_FILE -RunLogLevel $RunLogLevel -MsgLevel DEBUG 
            }
            Write-LogLevel -Message "Manager running String: $script:QmanRunning" -Logfile $LOG_FILE -RunLogLevel $RunLogLevel -MsgLevel TRACE 
            if($script:QmanRunning -ne "Shutdown"){
                Write-LogLevel -Message "Waiting $ManagerWait Seconds" -Logfile $LOG_FILE -RunLogLevel $RunLogLevel -MsgLevel DEBUG 
                Invoke-Wait -Seconds $ManagerWait
            }
        } while ($script:QmanRunning -ne "Shutdown")
        Write-LogLevel -Message "Exiting QueueManager Function." -Logfile $LOG_FILE -RunLogLevel $RunLogLevel -MsgLevel DEBUG 
    }
    catch
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName		
        Throw "Invoke-Qman: $ErrorMessage $FailedItem"
    }
    
}