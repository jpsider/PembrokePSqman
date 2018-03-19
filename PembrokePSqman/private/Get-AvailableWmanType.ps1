function Get-AvailableWmanType {
    <#
	.DESCRIPTION
		This function will get the Workflow Manager Type based on the specified task type.
    .PARAMETER RestServer
        A Rest Server is required.
    .PARAMETER TaskTypeId
        A TaskTypeId is required.
	.EXAMPLE
        Get-AvailableWmanType -RestServer localhost -TaskTypeId 1
	.NOTES
        This will return a hashtable of data from the PPS database.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory=$true)][string]$RestServer,
        [Parameter(Mandatory=$true)][int]$TaskTypeId
    )
    if (Test-Connection -Count 1 $RestServer -Quiet) {
        try
        {
            $WmanTypeData = (Invoke-RestMethod -Method Get -Uri "http://$RestServer/PembrokePS/public/api/api.php/wman_task_types?filter[]=TASK_TYPE_ID,eq,$TaskTypeId&filter[]=STATUS_ID,eq,11&transform=1" -UseBasicParsing).wman_task_types
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName		
            Throw "Error: $ErrorMessage $FailedItem"
        }
        $WmanTypeData
    } else {
        Throw "Unable to reach web server."
    }
    
}