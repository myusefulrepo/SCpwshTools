---
external help file: SCpwshTools-help.xml
Module Name: SCpwshTools
online version:
schema: 2.0.0
---

# Get-MailboxWithAlias

## SYNOPSIS

## SYNTAX

```
Get-MailboxWithAlias [-Alias] <String> [<CommonParameters>]
```

## DESCRIPTION
Function for searching for a specific Alias in all mailboxes in a tenant

## EXAMPLES

### EXAMPLE 1
```
Get-MailboxWithAlias -Alis test@domain.com
This example will search all mailboxes in a tenant to see if any mailbox 
has the Alias test@domain.com
```

## PARAMETERS

### -Alias
The Alias you want to search for, should be like: test@domain.com

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### [String] The mail address of the alias you want to search for
## OUTPUTS

### [Object] returns the object of the mailbox containing the Alias, if found
## NOTES
v.
1.0.0

## RELATED LINKS
