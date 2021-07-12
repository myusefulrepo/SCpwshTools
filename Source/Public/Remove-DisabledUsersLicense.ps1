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

