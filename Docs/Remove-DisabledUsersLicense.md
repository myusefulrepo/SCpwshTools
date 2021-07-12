---
external help file: SCpwshTools-help.xml
Module Name: SCpwshTools
online version:
schema: 2.0.0
---

# Remove-DisabledUsersLicense

## SYNOPSIS

## SYNTAX

```
Remove-DisabledUsersLicense [-AccountSkuId] <String> [-LogFilePath] <String>
 [[-RemoveLicenseAADGroup] <String>] [<CommonParameters>]
```

## DESCRIPTION
Function for removing licenses from users who are disabled in Active Directory

## EXAMPLES

### EXAMPLE 1
```
Remove-DisabledUsersLicense -AccountSkuId Domain:SPE_E3 -LogFilePath C:\temp\license.log
This example will remove the E3 license from all disabled users in Active Directory
```

## PARAMETERS

### -AccountSkuId
The AccountSkuId for the license you want to remove for example: Domain:SPE_E3

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LogFilePath
Provide the exact path to where the log file should be stored

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RemoveLicenseAADGroup
If you have a group which automaticly deliveres licenses to users, you can
specify the group displayname in this parameter to remove the user from the group.

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

### [String] AccountSkuId the SKU for the license which you want to remove
### [String] LogFilePath the path to where a logfile should be placed
## OUTPUTS

### [File] Logfile with output of license removal
## NOTES
v.
1.0.0

## RELATED LINKS
