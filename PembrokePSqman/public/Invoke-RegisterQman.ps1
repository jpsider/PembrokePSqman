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
    )
    if (Test-Connection -Count 1 $RestServer -Quiet) {
        try
        {
            #Going to be creating a new record here, need to figure out the 'joins' to ensure the data is good.
            Write-Output "This function is not complete!"
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName		
            Throw "Error: $ErrorMessage $FailedItem"
        }
        #$QmanStatusData
    } else {
        Throw "Unable to reach web server."
    }
    
}