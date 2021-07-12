---
external help file: SCpwshTools-help.xml
Module Name: SCpwshTools
online version:
schema: 2.0.0
---

# Start-ADConnectSync

## SYNOPSIS

## SYNTAX

```
Start-ADConnectSync [-Credential] <PSCredential> [-SyncStyle] <String> [-ADSyncServer] <String>
 [<CommonParameters>]
```

## DESCRIPTION
Function for starting a New Azure Active Directory Sync

## EXAMPLES

### EXAMPLE 1
```
New-AADSync -Credential $creds -SyncStyle Initial -ADSyncServer "Server01.domain.local"
This example will create a new Inital Azure Active Directory Sync with the ADConnect server: Server01.domain.local
```

## PARAMETERS

### -Credential
Credentials needed for establishing a remote connection to the AD Connect Server

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -SyncStyle
If it should be a complete/full sync then Initial else provide Delta

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

### -ADSyncServer
The FQDN of the ADConnect Server

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
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
