function Get-AvailableWmanSet {
    <#
	.DESCRIPTION
		This function will gather available Workflow Managers that are of a specified type.
    .PARAMETER RestServer
        A Rest Server is required.
    .PARAMETER Wman_Type
        A Wman_Type is required.
	.EXAMPLE
        Get-AvailableWmanSet -RestServer localhost -Wman_Type 1
	.NOTES
        This will return a hashtable of data from the PPS database.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory=$true)][string]$RestServer,
        [Parameter(Mandatory=$true)][int]$Wman_Type
    )
    if (Test-Connection -Count 1 $RestServer -Quiet) {
        try
        {
            $WmanStatusData = (Invoke-RestMethod -Method Get -Uri "http://$RestServer/PembrokePS/public/api/api.php/workflow_manager?filter[]=status_id,eq,2&filter[]=WORKFLOW_MANAGER_TYPE_ID,eq,$Wman_Type&transform=1" -UseBasicParsing).workflow_manager
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName		
            Throw "Get-AvailableWmanSet: $ErrorMessage $FailedItem"
        }
        $WmanStatusData
    } else {
        Throw "Unable to reach web server."
    }
    
}