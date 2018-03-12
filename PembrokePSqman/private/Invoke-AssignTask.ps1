function Invoke-AssignTask {
    <#
	.DESCRIPTION
		This function will gather Status information from PembrokePS web/rest for a Queue_Manager
    .PARAMETER TaskId
        A TaskId is required.
    .PARAMETER RestServer
        A Rest Server is required.
    .PARAMETER WmanId
        A WmanId is required.
    .PARAMETER TableName
        A TableName is optional, default is tasks.
	.EXAMPLE
        Invoke-AssignTask -RestServer localhost -TaskId 1 -WmanId 1
	.NOTES
        This will return a hashtable of data from the PPS database.
    #>
    [CmdletBinding()]
    [OutputType([Int])]
    param(
        [Parameter(Mandatory=$true)][int]$TaskId,
        [Parameter(Mandatory=$true)][int]$WmanId,
        [Parameter(Mandatory=$true)][string]$RestServer,
        [string]$TableName="tasks"
    )
    if (Test-Connection -Count 1 $RestServer -Quiet) {
        try
        {
            $body = @{STATUS_ID = "7"} | convertto-json
            $RestReturn = Invoke-RestMethod -Method Put -Uri "http://$RestServer/PembrokePS/public/api/api.php/$TableName/$TaskId" -body $body
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName		
            Throw "Error: $ErrorMessage $FailedItem"
        }
        $RestReturn
    } else {
        Throw "Unable to reach web server."
    }
    
}