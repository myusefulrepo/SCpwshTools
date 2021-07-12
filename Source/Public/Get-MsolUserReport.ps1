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




