---
external help file: PembrokePSqman-help.xml
Module Name: PembrokePSqman
online version:
schema: 2.0.0
---

# Invoke-RegisterQman

## SYNOPSIS

## SYNTAX

```
Invoke-RegisterQman [-RestServer] <String> [<CommonParameters>]
```

## DESCRIPTION
This function will gather Status information from PembrokePS web/rest for a Queue_Manager

## EXAMPLES

### EXAMPLE 1
```
Invoke-RegisterQman -RestServer -localhost
```

## PARAMETERS

### -RestServer
A Rest Server is required.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Collections.Hashtable

## NOTES
This will return a hashtable of data from the PPS database.

## RELATED LINKS
