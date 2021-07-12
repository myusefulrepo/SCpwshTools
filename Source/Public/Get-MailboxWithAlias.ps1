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
