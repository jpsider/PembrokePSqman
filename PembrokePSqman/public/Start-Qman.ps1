function Start-Qman {
    <#
	.DESCRIPTION
		This function will gather Status information from PembrokePS web/rest for a Queue_Manager
    .PARAMETER RestServer
        A Rest Server is required.
	.EXAMPLE
        Start-Qman -RestServer localhost
	.NOTES
        This will return a hashtable of data from the PPS database.
    #>
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Low"
    )]
    [OutputType([hashtable])]
    [OutputType([Boolean])]
    param(
        [Parameter(Mandatory=$true)][string]$RestServer
    )
    begin {
        if (Test-Connection -Count 1 $RestServer -Quiet) {
            # Gather the local properties
        } else {
            Throw "Unable to reach web server."
        }
    }
    process
    {
        if ($pscmdlet.ShouldProcess("PembrokePSQman"))
        {
            try
            {
                #Going to be creating a new record here, need to figure out the 'joins' to ensure the data is good.
                Write-Output "This function is not complete!"
                # Validate properties file exists
                # Import all the data.
                # Validate system.RestServer
                # Start Kicker process
                # Start Rest Service (and kicker rest)
            }
            catch
            {
                $ErrorMessage = $_.Exception.Message
                $FailedItem = $_.Exception.ItemName
                Throw "Start-Qman: $ErrorMessage $FailedItem"
            }
        }
        else
        {
            # -WhatIf was used.
            return $false
        }
    }
}