function Invoke-RegisterQman {
    <#
	.DESCRIPTION
		This function will gather Status information from PembrokePS web/rest for a Queue_Manager
    .PARAMETER RestServer
        A Rest Server is required.
	.EXAMPLE
        Invoke-RegisterQman -RestServer -localhost
	.NOTES
        This will return a hashtable of data from the PPS database.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory=$true)][string]$RestServer
            # Update the Parameters
                # RestServer Required
                # ComponentType By Name (Required)
                # Description (Required)
                # Desired Port (Optional)
                # Hostname (Optional)
                # IP (Optional)
                # Wait
                # LogFile (Optional)
                # Kicker Port (Optional)
    )
    if (Test-Connection -Count 1 $RestServer -Quiet) {
        try
        {
            #Going to be creating a new record here, need to figure out the 'joins' to ensure the data is good.
            Write-Output "This function is not complete!"
            # if ports were specified
                # Check to see if the requested ports are available
                # if not, see if any are available
                    #if not, create the next ones

            # Build up the rest call to add the row

            # Write the local Properties file with all of the information used to create the row.

        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            Throw "Invoke-RegisterQman: $ErrorMessage $FailedItem"
        }
        #$QmanStatusData
    } else {
        Throw "Unable to reach Rest server: $RestServer."
    }
}