function Invoke-DeployQman
{
    <#
	.DESCRIPTION
		Deploys artifacts to prepare a machine to run a PembrokePS Queue Manager.
    .PARAMETER Destination
        A Destitnation path is optional.
    .PARAMETER Source
        A Source location for PembrokePS artifacts is optional.
	.EXAMPLE
        Invoke-DeployQman -Destination c:\PembrokePS -Source c:\OpenProjects\ProjectPembroke\PembrokePSqman
	.NOTES
        It will create the directory if it does not exist. Also install required Modules.
    #>
    [CmdletBinding()]
    [OutputType([boolean])]
    param(
        [String]$Destination="C:\PembrokePS\",
        [String]$Source=(Split-Path -Path (Get-Module -ListAvailable PembrokePSqman).path)
    )
    try
    {
        if(Test-Path -Path "$Destination\qman") {
            Write-Output "The Qman Directory exists."
        } else {
            New-Item -Path "$Destination\qman\data" -ItemType Directory
            New-Item -Path "$Destination\qman\logs" -ItemType Directory
        }
        Install-Module -Name PembrokePSrest,PembrokePSutilities,PowerLumber -Force
        Import-Module -Name PembrokePSrest,PembrokePSutilities,PowerLumber -Force
        Invoke-CreateRouteDirectorySet -InstallDirectory "$Destination\Qman\rest"
        Copy-Item -Path "$Source\data\pembrokeps.properties" -Destination "$Destination\qman\data" -Confirm:$false       
    }
    catch
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName		
        Write-Error "Error: $ErrorMessage $FailedItem"
        Throw $_
    }

}