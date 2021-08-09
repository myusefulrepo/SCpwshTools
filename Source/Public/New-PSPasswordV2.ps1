function New-PSPasswordV2 {
        <#
    .SYNOPSIS
        PowerShell function for generating a single password or a list of passwords
    .DESCRIPTION
        PowerShell function which can be used for generating a single password or a list of passwords.
        The password or passwords generated can be manipulated to define, length of password, and if 
        symbols and/or upper case letters should be used.
    .EXAMPLE
        PS C:\> New-PSPassword
        
        This example will generate a 12 character long password containing lower/uppercase letters, numbers and symbols
    .EXAMPLE
        PS C:\> New-PSPassword -SkipUpperCase -SkipSymbols
        
        This example will generate a password without uppercase letters and symbols
    .EXAMPLE
        PS C:\> New-PSPassword -SkipUpperCase -PasswordLength 16 -NumberOfPasswords 200 -PasswordFilePath ~/pass.txt
        
        This example will generate list of 200 passwords without uppercase letters and a password length of 16 characters
        it will store the passwords in the file ~/pass.txt
    .PARAMETER SkipUpperCase
        Define if the password should NOT contain uppercase letters
    .PARAMETER SkipLowerCase
        Define if the password should NOT contain lowercase letters
    .PARAMETER SkipNumbers
        Define if the password should NOT contain Numbers
    .PARAMETER SkipSymbols
        Define if the password should NOT contain Symbols
    .PARAMETER PasswordLength
        Define the length of the password in number of characters. The default password length will be 12
    .PARAMETER PasswordFilePath
        Define the exact path of where the list of passwords should be stored.

    .NOTES
        Created by Christian Hoejsager (ScriptingChris)
        https://scriptingchris.tech
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)][Switch]$SkipUpperCase,
        [Parameter(Mandatory=$false)][Switch]$SkipLowerCase,
        [Parameter(Mandatory=$false)][Switch]$SkipNumbers,
        [Parameter(Mandatory=$false)][Switch]$SkipSymbols,
        [Parameter(Mandatory=$false)][Int]$PasswordLength = 12,
        [Parameter(Mandatory=$false)][Int]$NumberOfPasswords = 1,
        [Parameter(Mandatory=$false)][String]$PasswordsFilePath
    )
    
    begin {

        if($SkipUpperCase.IsPresent -and $SkipLowerCase.IsPresent -and $SkipNumbers.IsPresent -and $SkipSymbols.IsPresent){
            Write-Error "You may not skip all four types of characters at the same time, try again..."
            Exit
        }

        $CharArray = New-Object System.Collections.ArrayList
        $ValidatePass = New-Object System.Collections.ArrayList

        $LowerLetters = New-Object System.Collections.ArrayList; 97..122 | % {$LowerLetters.Add([Char]$_)} | Out-Null
        $UpperLetters = New-Object System.Collections.ArrayList; 65..90 | % {$UpperLetters.Add([Char]$_)} | Out-Null
        $Numbers = New-Object System.Collections.ArrayList; 0..9 | % {$Numbers.Add($_.ToString())} | Out-Null
        $Symbols = New-Object System.Collections.ArrayList; 33..47 | % {$Symbols.Add([Char]$_)} | Out-Null

        if(!$SkipNumbers.IsPresent){$CharArray.Add($Numbers) | Out-Null; $ValidatePass.Add(1) | Out-Null}
        if(!$SkipLowerCase.IsPresent){$CharArray.Add($LowerLetters) | Out-Null; $ValidatePass.Add(2) | Out-Null}
        if(!$SkipUpperCase.IsPresent){$CharArray.Add($UpperLetters) | Out-Null; $ValidatePass.Add(3) | Out-Null}
        if(!$SkipSymbols.IsPresent){$CharArray.Add($Symbols) | Out-Null; $ValidatePass.Add(4) | Out-Null}

        $WorkingSet = $CharArray | % {$_}
    }
    
    process {

        if($PasswordsFilePath -and !(Test-Path $PasswordsFilePath)){
            New-Item $PasswordsFilePath -ItemType File
        }

        for($i = 0; $i -le $NumberOfPasswords; $i++){
            $Password = New-Object System.Collections.ArrayList
            for($y = 0; $y -le $PasswordLength; $y++){
                $Character = $WorkingSet | Get-Random
                $Password.Add($Character) | Out-Null
            }

            Switch ($ValidatePass){
                1 {if(!($Password -match '\d')){$PassNotValid = $true}}
                2 {if(!($Password -cmatch "[a-z]")){$PassNotValid = $true}}
                3 {if(!($Password -cmatch "[A-Z]")){$PassNotValid = $true}}
                4 {
                    $Password | % {if($Symbols -contains $_){$ContainSymbol = $true}}
                    if($ContainSymbol -eq $false){$PassNotValid = $true}
                    $ContainSymbol = $false
                }
            }
            if($PassNotValid -eq $true){$i = $i - 1; $PassNotValid = $false; continue}else {
                $Password = $Password -join ""
                if($PasswordsFilePath){Add-Content -Path $PasswordsFilePath -Value $Password}else{Return $Password}
            }
        }
    }
    
    end {
        Write-Verbose -Message "Finishing function"
    }
}