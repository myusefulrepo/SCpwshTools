---
external help file: SCpwshTools-help.xml
Module Name: SCpwshTools
online version:
schema: 2.0.0
---

# Get-MsolUserReport

## SYNOPSIS

## SYNTAX

```
Get-MsolUserReport [[-UserName] <String>] [[-ArrayOfUsers] <Array>] [-AllUsers] [-CreateLogFile]
 [[-LogFilePath] <String>] [<CommonParameters>]
```

## DESCRIPTION
Function for creating a report on either a single user, multiple users or all users in a tenant.
The report will look at a user's license, login times, device information and other things

## EXAMPLES

### EXAMPLE 1
```
Get-MsolUserReport -UserName "user01@domain.com" -CreateLogFile -LogFilePath C:\Temp\userinfo.csv
This example will lookup a single user with username user01@domain.com, and create a csv logfile and place it in the path:
C:\Temp\userinfo.csv
```

### EXAMPLE 2
```
$ListOfUsers = Get-MsolUser -All | ? {$_.Licenses.AccountSkuId -contains "Domain:SPE_E3"}  
PS C:\> $result = $ListOfUsers | Get-MsolUserReport
This example will lookup all the users in the Array $ListOfUsers which has the E3 License assigned, and then lookup
all the data on those users.
```

## PARAMETERS

### -UserName
The user principalname of a single user you want to look up

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ArrayOfUsers
Takes an array of user objects

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -AllUsers
Switch parameter, if assigned then the function will query all the users in a domain

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

### -CreateLogFile
Switch parameter, if assigned then a csv file will be created containing all the data

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

### -LogFilePath
The exact path on where you want to place the csv log file containing the user data

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
v.
1.0.0

## RELATED LINKS
