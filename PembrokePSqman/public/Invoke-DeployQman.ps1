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
            Write-LogLevel -Message "The Qman Directory exists." -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel CONSOLEONLY
        } else {
            Write-LogLevel -Message "Creating '\qman\data' and '\qman\logs' Directories." -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel CONSOLEONLY
            New-Item -Path "$Destination\qman\data" -ItemType Directory
            New-Item -Path "$Destination\qman\logs" -ItemType Directory
        }
        Write-LogLevel -Message "Installing Required Modules." -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel CONSOLEONLY
        Install-Module -Name PembrokePSrest,PembrokePSutilities,PowerLumber,RestPS -Force
        Import-Module -Name PembrokePSrest,PembrokePSutilities,PowerLumber,RestPS -Force
        Write-LogLevel -Message "Creating Rest Directory Set." -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel CONSOLEONLY
        Invoke-CreateRouteDirectorySet -InstallDirectory "$Destination\Qman\rest"
        Write-LogLevel -Message "Copying Default Properties file to Qman\data Directory." -Logfile "$LOG_FILE" -RunLogLevel $RunLogLevel -MsgLevel CONSOLEONLY
        Copy-Item -Path "$Source\data\pembrokeps.properties" -Destination "$Destination\qman\data" -Confirm:$false
    }
    catch
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Throw "Invoke-DeployQman: $ErrorMessage $FailedItem"
    }
}