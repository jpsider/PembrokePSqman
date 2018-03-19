function Get-SubmittedTaskSet {
    <#
	.DESCRIPTION
		This function will gather The submitted tasks for the specified TableName.
    .PARAMETER RestServer
        A Rest Server is required.
    .PARAMETER TableName
        A TableName is optional, default is tasks.
	.EXAMPLE
        Get-SubmittedTaskSet -RestServer localhost -TableName tasks
	.NOTES
        This will return a hashtable of data from the PPS database.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory=$true)][string]$RestServer,
        [string]$TableName="tasks"
    )
    if (Test-Connection -Count 1 $RestServer -Quiet) {
        try
        {
            $TableName = $TableName.ToLower()
            $SubmittedTasks = (Invoke-RestMethod -Method Get -Uri "http://$RestServer/PembrokePS/public/api/api.php/$TableName?filter=STATUS_ID,eq,5&transform=1" -UseBasicParsing).$TableName
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName		
            Throw "Error: $ErrorMessage $FailedItem"
        }
        $SubmittedTasks
    } else {
        Throw "Unable to reach web server."
    }
    
}