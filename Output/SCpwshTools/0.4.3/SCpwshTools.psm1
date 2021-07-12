### --- PUBLIC FUNCTIONS --- ###
#Region - Get-MailboxWithAlias.ps1
function Get-MailboxWithAlias {
    <#
    .DESCRIPTION
        Function for searching for a specific Alias in all mailboxes in a tenant
    .EXAMPLE
        PS C:\> Get-MailboxWithAlias -Alis test@domain.com
        This example will search all mailboxes in a tenant to see if any mailbox 
        has the Alias test@domain.com
    .PARAMETER Alias
        The Alias you want to search for, should be like: test@domain.com
    .INPUTS
        [String] The mail address of the alias you want to search for
    .OUTPUTS
        [Object] returns the object of the mailbox containing the Alias, if found
    .NOTES
        v. 1.0.0
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [String]$Alias
    )

    Begin {
        if(Get-Command -Name Get-Mailbox -ErrorAction SilentlyContinue) {
            Write-Verbose -Message "You are connected to Exchange Online"
        }
        else {
            Write-Error -Message "You are not connected to Exchange. Exiting function"
            Exit
        }
    }

    Process {
        Write-Verbose -Message "Searching all mailbox's in the tenant"
        $Mailboxes = Get-Mailbox -ResultSize Unlimited
        if($Mailboxes){
            Write-Verbose -Message "$($Mailboxes.Count) Was found in the tenant"
        }

        Write-Verbose -Message "Looping through all mailbox's searching for alias: $($Alias)"
        $total = [Int]$Mailboxes.count
        $i = 0
        $MailboxContainingAlias = New-Object -TypeName System.Collections.ArrayList
        $Mailboxes | ForEach-Object {
            Write-Verbose -Message "Searching Mailbox: $($_.Alias)"
            if($_.EmailAddresses -contains "smtp:$($Alias)"){
                $MailboxContainingAlias.Add($_) | Out-Null
            }
            Write-Progress -Activity "Searching Mailbox's" -Status "Progress:" -PercentComplete ($i/$total*100)
            $i++
        }

        return $MailboxContainingAlias
    }

    End {
        if($null -eq $MailboxContainingAlias) {
            Write-Warning "No Mailboxes containing Alias: $($Alias) was found.."
        }
    }
}
Export-ModuleMember -Function Get-MailboxWithAlias
#EndRegion - Get-MailboxWithAlias.ps1
#Region - Get-MsolUserReport.ps1
function Get-MsolUserReport {
    <#
    .DESCRIPTION
        Function for creating a report on either a single user, multiple users or all users in a tenant.
        The report will look at a user's license, login times, device information and other things
    .EXAMPLE
        PS C:\> Get-MsolUserReport -UserName "user01@domain.com" -CreateLogFile -LogFilePath C:\Temp\userinfo.csv
        This example will lookup a single user with username user01@domain.com, and create a csv logfile and place it in the path:
        C:\Temp\userinfo.csv
    .EXAMPLE
        PS C:\> $ListOfUsers = Get-MsolUser -All | ? {$_.Licenses.AccountSkuId -contains "Domain:SPE_E3"}  
        PS C:\> $result = $ListOfUsers | Get-MsolUserReport
        This example will lookup all the users in the Array $ListOfUsers which has the E3 License assigned, and then lookup
        all the data on those users.
    .PARAMETER UserName
        The user principalname of a single user you want to look up
    .PARAMETER ArrayOfUsers
        Takes an array of user objects
    .PARAMETER AllUsers
        Switch parameter, if assigned then the function will query all the users in a domain
    .PARAMETER CreateLogFile
        Switch parameter, if assigned then a csv file will be created containing all the data
    .PARAMETER LogFilePath
        The exact path on where you want to place the csv log file containing the user data
    .NOTES
        v. 1.0.0
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)][String]$UserName,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true)][Array]$ArrayOfUsers,
        [Parameter(Mandatory=$false)][Switch]$AllUsers,
        [Parameter(Mandatory=$false)][Switch]$CreateLogFile,
        [Parameter(Mandatory=$false)][String]$LogFilePath
    )
    
    begin {
        If(Get-Module -ListAvailable MSOnline, AzureADPreivew | Out-Null){
            Write-Verbose -Message "Required modules are installed"
        }
        else {
            Write-Warning -Message "Make sure you have modules: AzureADPreview and MSOnline installed on your machine."
            Exit
        }

        if(Get-MsolDomain -ErrorAction SilentlyContinue){
            Write-Verbose -Message "You are connected to MSOnline Services"
        }
        else {
            Write-Error "You are not connected to MSOnline Services. Run Connect-MsolService, to get connected..."
            Exit
        }

        if(Get-AzureADTenantDetail -ErrorAction SilentlyContinue | Out-Null){
            Write-Verbose -Message "You are successfully connected to AzureAD"
        }
        else {
            Write-Error "You are not connected to AzureAD. Run Connect-AzureAD, to get conncted..."
        }

        if($AllUsers.IsPresent){
            $AllUsers = Get-MsolUser -All
        }
        elseif($UserName){
            $AllUsers = [PSCustomObject]@{
                UserPrincipalName = $UserName
            }
        }
        elseif($ArrayOfUsers){
            $AllUsers = $ArrayOfUsers
        }
    }
    
    process {
        Write-Verbose -Message "Looping throgh users and collecting data"
        $UserObject = New-Object -TypeName System.Collections.ArrayList
        foreach ($user in $AllUsers){
            $ZuleDateTime = $date = Get-AzureADAuditSignInLogs -Top 1 -Filter "userprincipalname eq '$($user.UserPrincipalName)'" | Select-Object -ExpandProperty CreatedDateTime
            $Date = ($ZuleDateTime | Get-Date).ToString("yyyy-MM-dd")
            $Time = ($ZuleDateTime | Get-Date).ToString("hh:mm")
            $Device = Get-AzureADAuditSignInLogs -Top 1 -Filter "userprincipalname eq '$($user.UserPrincipalName)'"
            $DeviceName = $Device.DeviceDetail.DisplayName
            $DeviceOS = $Device.DeviceDetail.OperatingSystem
            $DeviceEnabled = (Get-MsolDevice -DeviceId $Device.DeviceDetail.DeviceId).Enabled
            $DeviceLastLogon = ((Get-MsolDevice -DeviceId $Device.DeviceDetail.DeviceId).ApproximateLastLogonTimestamp | Get-Date).ToString("yyyy-MM-dd hh:mm")
            $object = [PSCustomObject]@{
                "UserPrincipalName" = $user.UserPrincipalName
                "DisplayName" = $user.DisplayName
                "Department" = $user.Department
                "Title" = $user.Title
                "PasswordLastSet" = $user.LastPasswordChangeTimestamp
                "PasswordNeverExpires" = $user.PasswordNeverExpires
                "Licenses" = $user.Licenses.AccountSkuId
                "ObjectId" = $user.ObjectId
                "UserType" = $user.UserType
                "ValidationStatus" = $user.ValidationStatus
                "LastLogonDate" = $Date
                "LastLogonDateTime" = $Time
                "DeviceName" = $DeviceName
                "DeviceOS" = $DeviceOS
                "DeviceEnabled" = $DeviceEnabled
                "DeviceLastLogon" = $DeviceLastLogon
            }
            $UserObject.Add($object)
        }

        if($CreateLogFile.IsPresent){
            $UserObject | Export-Csv -Path $LogFilePath -NoTypeInformation
        }

        return $UserObject
    }
    
    end {
        if(!($UserObject)){
            Write-Warning "No users where found..."
        }
    }
}




Export-ModuleMember -Function Get-MsolUserReport
#EndRegion - Get-MsolUserReport.ps1
#Region - Remove-DisabledUsersLicense.ps1
function Remove-DisabledUsersLicense {
    <#
    .DESCRIPTION
        Function for removing licenses from users who are disabled in Active Directory
    .EXAMPLE
        PS C:\> Remove-DisabledUsersLicense -AccountSkuId Domain:SPE_E3 -LogFilePath C:\temp\license.log
        This example will remove the E3 license from all disabled users in Active Directory
    .PARAMETER AccountSkuId
        The AccountSkuId for the license you want to remove for example: Domain:SPE_E3
    .PARAMETER LogFilePath
        Provide the exact path to where the log file should be stored
    .PARAMETER RemoveLicenseAADGroup
        If you have a group which automaticly deliveres licenses to users, you can
        specify the group displayname in this parameter to remove the user from the group.
    .INPUTS
        [String] AccountSkuId the SKU for the license which you want to remove
        [String] LogFilePath the path to where a logfile should be placed
    .OUTPUTS
        [File] Logfile with output of license removal
    .NOTES
        v. 1.0.0
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][String]$AccountSkuId,
        [Parameter(Mandatory=$true)][String]$LogFilePath,
        [Parameter(Mandatory=$false)][String]$RemoveLicenseAADGroup
    )
    
    begin {
        if(Get-MsolDomain -ErrorAction SilentlyContinue) {
            Write-Verbose -Message "You are connected to MS Online Services"
        }
        else {
            Write-Error -Message "You are not connected to MS Online Services. User Connect-MsolService to get connected..."
            Exit
        }
        $users = Get-AdUser -Filter * | Where-Object Enabled -eq $false
    }
    
    process {
        $validUsers = New-Object -TypeName System.Collections.ArrayList
        foreach($user in $users){
            if((Get-MsolUser -SearchString $user.UserPrincipalName -MaxResults $true).Licenses.AccountSkuId -match $($AccountSkuId)) {
                Write-Verbose -Message "User: $($user.UserPrincipalName) is not enabled and license will be removed"
                if($RemoveLicenseAADGroup){
                    $UserObject = Get-MsolUser -SearchString $user.UserPrincipalName | Select-Object -ExpandProperty ObjectId
                    $GroupObject = Get-MsolGroup -SearchString $RemoveLicenseAADGroup | Select-Object -ExpandProperty ObjectId
    
                    try {
                        Write-Verbose -Message "Removing User: $($user.UserPrincipalName) from MSOL Group: $($RemoveLicenseAADGroup)"
                        Remove-MsolGroupMember -GroupObjectId $GroupObject -GroupMemberObjectId $UserObject
                        continue
                    }
                    catch {
                        Write-Error "$($_)"
                    }
                }
                $validUsers.Add($user.UserPrincipalName)
            }
        }
        try {
            Write-Verbose -Message "Removing Licenses"
            Remove-MsolUserLicense -SKU $AccountSkuId -LogFile $LogFilePath -Users $validUsers
        }
        catch {
            Write-Error "$($_)"
        }
    }   
    
    end {
        if(!$validUsers){
            Write-Warning "No users who are qualified for getting the license removed."
        }
    }
}

Export-ModuleMember -Function Remove-DisabledUsersLicense
#EndRegion - Remove-DisabledUsersLicense.ps1
#Region - Start-ADConnectSync.ps1
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
Export-ModuleMember -Function Start-ADConnectSync
#EndRegion - Start-ADConnectSync.ps1
### --- PRIVATE FUNCTIONS --- ###
