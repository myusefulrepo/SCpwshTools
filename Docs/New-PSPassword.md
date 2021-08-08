---
external help file: SCpwshTools-help.xml
Module Name: SCpwshTools
online version:
schema: 2.0.0
---

# New-PSPassword

## SYNOPSIS
PowerShell function for generating a single password or a list of passwords

## SYNTAX

### Password
```
New-PSPassword [-UseUpperCase] [-UseSymbols] -PasswordLength <Int32> [-GenerateList]
 [-NumberOfPasswords <Int32>] [-PasswordListFilePath <String>] [<CommonParameters>]
```

### PasswordList
```
New-PSPassword [-GenerateList] -NumberOfPasswords <Int32> -PasswordListFilePath <String> [<CommonParameters>]
```

## DESCRIPTION
PowerShell function which can be used for generating a single password or a list of passwords.
The password or passwords generated can be manipulated to define, length of password, and if 
symbols and/or upper case letters should be used.

## EXAMPLES

### EXAMPLE 1
```
New-PSPassword -UseUpperCase -UseSymbols -PasswordLength 8
```

This example will generate an 8 character long random password including Symbols and Uppercase letters.

### EXAMPLE 2
```
New-PSPassword -UseUpperCase -PasswordLength 10 -GenerateList -NumberOfPasswords 50 -PasswordListFilePath "./PasswordList.txt"
```

This example will generate a list of 50 passwords containing Uppercase letters, lowercase letters and numbers.
It will store the list
in ./PasswordList.txt

## PARAMETERS

### -UseUpperCase
Define if the password should contain Uppercase letters

```yaml
Type: SwitchParameter
Parameter Sets: Password
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseSymbols
Define if the password should contain Symbols

```yaml
Type: SwitchParameter
Parameter Sets: Password
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -PasswordLength
Define the length of the password in number of characters

```yaml
Type: Int32
Parameter Sets: Password
Aliases:

Required: True
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -GenerateList
Define the the function should generate a list of passwords and store it in a file

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -NumberOfPasswords
Define the total number of passwords which should be generated and added to the list

```yaml
Type: Int32
Parameter Sets: Password
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: Int32
Parameter Sets: PasswordList
Aliases:

Required: True
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -PasswordListFilePath
The exact filepath to where the list of passwords should be store.
See examples for how to use it.

```yaml
Type: String
Parameter Sets: Password
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: PasswordList
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
N/A

## RELATED LINKS
