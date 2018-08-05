---
external help file: PembrokePSqman-help.xml
Module Name: PembrokePSqman
online version:
schema: 2.0.0
---

# Invoke-DeployQman

## SYNOPSIS

## SYNTAX

```
Invoke-DeployQman [[-Destination] <String>] [[-Source] <String>] [<CommonParameters>]
```

## DESCRIPTION
Deploys artifacts to prepare a machine to run a PembrokePS Queue Manager.

## EXAMPLES

### EXAMPLE 1
```
Invoke-DeployQman -Destination c:\PembrokePS -Source c:\OpenProjects\ProjectPembroke\PembrokePSqman
```

## PARAMETERS

### -Destination
A Destitnation path is optional.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: C:\PembrokePS\
Accept pipeline input: False
Accept wildcard characters: False
```

### -Source
A Source location for PembrokePS artifacts is optional.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: (Split-Path -Path (Get-Module -ListAvailable PembrokePSqman).path)
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Boolean

## NOTES
It will create the directory if it does not exist.
Also install required Modules.

## RELATED LINKS
