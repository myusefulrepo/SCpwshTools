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
        $modules = Get-Module -ListAvailable MSOnline, AzureADPreivew
        If($modules){
            Write-Verbose -Message "Required modules are installed"
        }
        else {
            Write-Warning -Message "Make sure you have modules: AzureADPreview and MSOnline installed on your machine."
            Exit
        }
        Write-Verbose -Message "Make sure you are conneted to MSOnline and AzureAD"

        if($AllUsers.IsPresent){
            $Users = Get-MsolUser -All
        }
        elseif($UserName){
            $Users = [PSCustomObject]@{
                UserPrincipalName = $UserName
            }
        }
        elseif($ArrayOfUsers){
            $Users = $ArrayOfUsers
        }
    }
    
    process {
        Write-Verbose -Message "Looping throgh users and collecting data"
        $UserObject = New-Object -TypeName System.Collections.ArrayList
        $i = 0
        foreach ($user in $Users){
            Write-Verbose -Message "Searching user: $($user.UserPrincipalName)"
            $ZuleDateTime = $date = Get-AzureADAuditSignInLogs -Top 1 -Filter "userprincipalname eq '$($user.UserPrincipalName)'" | Select-Object -ExpandProperty CreatedDateTime
            if($ZuleDateTime){
                $Date = ($ZuleDateTime |Get-Date).ToString("yyyy-MM-dd")
                $Time = ($ZuleDateTime |Get-Date).ToString("hh:mm")
            }
            <#Todo - Configure the report to gather data on the users device
            $Device = Get-AzureADAuditSignInLogs -Top 1 -Filter "userprincipalname eq '$($user.UserPrincipalName)'"
            if($Device){
                $DeviceName = $Device.DeviceDetail.DisplayName
                $DeviceOS = $Device.DeviceDetail.OperatingSystem
                $DeviceEnabled = (Get-MsolDevice -DeviceId $Device.DeviceDetail.DeviceId).Enabled
                $DeviceLastLogon = ((Get-MsolDevice -DeviceId $Device.DeviceDetail.DeviceId).ApproximateLastLogonTimestamp |Get-Date).ToString("yyyy-MM-dd hh:mm")
            }
            #> 

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
                #"DeviceName" = $DeviceName
                #"DeviceOS" = $DeviceOS
                #"DeviceEnabled" = $DeviceEnabled
                #"DeviceLastLogon" = $DeviceLastLogon
            }
            $UserObject.Add($object)
            Write-Progress -Activity "Gathering Data" -Status "Progress:" -PercentComplete ($i/$Users.count*100)
            $i++
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
#Region - New-PSPassword.ps1
function New-PSPassword {
    <#
    .SYNOPSIS
        PowerShell function for generating a single password or a list of passwords
    .DESCRIPTION
        PowerShell function which can be used for generating a single password or a list of passwords.
        The password or passwords generated can be manipulated to define, length of password, and if 
        symbols and/or upper case letters should be used.
    .EXAMPLE
        PS C:\> New-PSPassword -UseUpperCase -UseSymbols -PasswordLength 8
        
        This example will generate an 8 character long random password including Symbols and Uppercase letters.
    .EXAMPLE
        PS C:\> New-PSPassword -UseUpperCase -PasswordLength 10 -GenerateList -NumberOfPasswords 50 -PasswordListFilePath "./PasswordList.txt"
        
        This example will generate a list of 50 passwords containing Uppercase letters, lowercase letters and numbers. It will store the list
        in ./PasswordList.txt
    .PARAMETER UseUpperCase
        Define if the password should contain Uppercase letters
    .PARAMETER UseSymbols
        Define if the password should contain Symbols
    .PARAMETER PasswordLength
        Define the length of the password in number of characters
    .PARAMETER GenerateList
        Define the the function should generate a list of passwords and store it in a file
    .PARAMETER NumberOfPasswords
        Define the total number of passwords which should be generated and added to the list
    .PARAMETER PasswordListFilePath
        The exact filepath to where the list of passwords should be store. See examples for how to use it.
    .NOTES
        N/A
    #>

    [CmdletBinding()]
    [Alias("npsp")]
    param (
        [Parameter(ParameterSetName="Password", Mandatory=$false)]
        [Switch]$UseUpperCase,
        [Parameter(ParameterSetName="Password", Mandatory=$false)]
        [Switch]$UseSymbols,
        [Parameter(ParameterSetName="Password", Mandatory=$true)]
        [Int]$PasswordLength,
        [Parameter(ParameterSetName="PasswordList", Mandatory=$false)]
        [Parameter(ParameterSetName="Password")]
        [Switch]$GenerateList,
        [Parameter(ParameterSetName="PasswordList", Mandatory=$true)]
        [Parameter(ParameterSetName="Password")]
        [Int]$NumberOfPasswords,
        [Parameter(ParameterSetName="PasswordList", Mandatory=$true)]
        [Parameter(ParameterSetName="Password")]
        [String]$PasswordListFilePath
    )

    begin{
        $LowerLetters = New-Object System.Collections.ArrayList; 97..122 | % {$LowerLetters.Add([Char]$_)} | Out-Null

        $UpperLetters = New-Object System.Collections.ArrayList; 65..90 | % {$UpperLetters.Add([Char]$_)} | Out-Null
    
        $NumberArray = New-Object System.Collections.ArrayList; 0..9 | % {$NumberArray.Add($_.ToString())} | Out-Null
    
        $SymbolsArray = New-Object System.Collections.ArrayList; 33..47 | % {$SymbolsArray.Add([Char]$_)} | Out-Null
    
        if(!$UseUpperCase -and !$UseSymbols){
            Write-Verbose -Message "Creating a password with: Lower Letters and Numbers"
            $varArray = @($LowerLetters, $NumberArray)
        }
        elseif($UseUpperCase.IsPresent -and !$UseSymbols){
            Write-Verbose -Message "Creating a password with: Lower Letters, Numbers and Uppercase letters"
            $varArray = @($LowerLetters, $NumberArray, $UpperLetters)
        }
        elseif($UseSymbols.IsPresent -and !$UseUpperCase){
            Write-Verbose -Message "Creating a password with: Lower letters, Numbers and Symbols"
            $varArray = @($LowerLetters, $NumberArray, $SymbolsArray)
        }
        elseif($UseUpperCase.IsPresent -and $UseSymbols.IsPresent){
            Write-Verbose -Message "Creating a password with: Lower Letters, Numbers, Uppercase and Symbols"
            $varArray = @($LowerLetters, $NumberArray, $UpperLetters, $SymbolsArray)
        }
    }

    process {
        if($GenerateList.IsPresent){
            Write-Verbose -Message "Generating a list of passwords"
            Write-Verbose -Message "Total number of passwords beeing generated: $($NumberOfPasswords)"
            if(!(Test-Path $PasswordListFilePath)){
                Write-Verbose -Message "Couldn't find password list file. Generating new"
                New-Item $PasswordListFilePath -ItemType File
            }
            
            $y = 0
            While($y -le $NumberOfPasswords){
                $Password = New-Object System.Collections.ArrayList
                $x = 0
                While($x -le $PasswordLength) {
                    $CharList = $varArray | Get-Random
                    $Character = $CharList | Get-Random
                    $Password.Add($Character) | Out-Null
                    $x++
                }
                $Password = $Password -join ""
                
                Write-Verbose -Message "Appending Password #$($y) to the password list file"
                Add-Content -Path $PasswordListFilePath -Value "$($Password)"
                $y++
            }
        }
        else{
            Write-Verbose -Message "Generating a single password"
            $Password = New-Object System.Collections.ArrayList
            $y = 0
            While($y -le $PasswordLength){
                $CharList = $varArray | Get-Random
                $Character = $CharList | Get-Random
                $Password.Add($Character) | Out-Null
                $y++
                Write-Verbose -Message "Generated Character $($Character)"
            }
            $Password = $Password -join ""
            Write-Verbose -Message "Outputting Password $($Password)"
            return $Password
        }
    }

    End {
        Write-Verbose -Message "Finishing Function"
    }
}
Export-Alias npsp
Export-ModuleMember -Function New-PSPassword
#EndRegion - New-PSPassword.ps1
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
