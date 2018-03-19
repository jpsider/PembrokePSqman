function Get-QmanTableName {
    <#
	.DESCRIPTION
		This function will gather The tableName for the Queue Manager type.
    .PARAMETER RestServer
        A Rest Server is required.
    .PARAMETER Type_ID
        A Queue Manager Type_ID is required.
	.EXAMPLE
        Get-QmanTableName -RestServer localhost -Type_ID 1
	.NOTES
        This will return a hashtable of data from the PPS database.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory=$true)][string]$RestServer,
        [Parameter(Mandatory=$true)][int]$Type_ID
    )
    if (Test-Connection -Count 1 $RestServer -Quiet) {
        try
        {
            $TableName = (Invoke-RestMethod -Method Get -Uri "http://$RestServer/PembrokePS/public/api/api.php/queue_manager_type/$Type_ID" -UseBasicParsing).TABLENAME
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName		
            Throw "Error: $ErrorMessage $FailedItem"
        }
        $TableName
    } else {
        Throw "Unable to reach web server."
    }
    
}