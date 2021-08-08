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