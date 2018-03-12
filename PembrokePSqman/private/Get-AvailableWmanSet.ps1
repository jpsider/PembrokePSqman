function Get-AvailableWmanSet {
    <#
	.DESCRIPTION
		This function will gather Status information from PembrokePS web/rest for available Wman Servers.
    .PARAMETER RestServer
        A Rest Server is required.
	.EXAMPLE
        Get-AvailableWmanSet -ComponentId 1 -RestServer localhost
	.NOTES
        This will return a hashtable of data from the PPS database.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [string]$RestServer
    )
    if (Test-Connection -Count 1 $RestServer -Quiet) {
        try
        {
            $WmanStatusData = (Invoke-RestMethod -Method Get -Uri "http://$RestServer/PembrokePS/public/api/api.php/workflow_manager?filter=status_id,eq,2&transform=1" -UseBasicParsing).workflow_manager
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName		
            Throw "Error: $ErrorMessage $FailedItem"
        }
        $WmanStatusData
    } else {
        Throw "Unable to reach web server."
    }
    
}