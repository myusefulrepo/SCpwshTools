function Start-ADConnectSync {
    <#
    .DESCRIPTION
        Function for starting a New Azure Active Directory Sync
    .EXAMPLE
        PS C:\> New-AADSync -Credential $creds -SyncStyle Initial -ADSyncServer "Server01.domain.local"
        This example will create a new Inital Azure Active Directory Sync with the ADConnect server: Server01.domain.local
    .PARAMETER Credential
        Credentials needed for establishing a remote connection to the AD Connect Server
    .PARAMETER SyncStyle
        If it should be a complete/full sync then Initial else provide Delta
    .PARAMETER ADSyncServer
        The FQDN of the ADConnect Server
    .NOTES
        v. 1.0.0
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)][System.Management.Automation.PSCredential]$Credential,
        [Parameter(Mandatory=$true)][String]$SyncStyle,
        [Parameter(Mandatory=$true)][String]$ADSyncServer
    )
    
    begin {
        Write-Verbose "Starting the Azure Active Directory Sync"   
    }
    
    process {
        try {
            $result = Invoke-Command -ComputerName $ADSyncServer -Credential $Credential -ScriptBlock {Start-ADSyncSyncCycle -PolicyType $SyncStyle}
        }
        catch {
            Write-Error "$($_)"
        }
    }
    
    end {
        if($result){
            Write-Verbose -Message "Successfully initiated a $($SyncStyle) Sync with Azure Active Directory"
            Write-Output -InputObject $result
        }
    }
}