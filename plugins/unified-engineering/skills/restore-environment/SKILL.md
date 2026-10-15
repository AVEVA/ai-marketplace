---
name: restore-environment
description: 'Restores AVEVA Unified Engineering environment variables from environment.json to the user profile and current PowerShell process. Use when reactivating an existing customization workspace without unpacking UE or recreating files, or before building or launching UE.'
license: MIT
argument-hint: 'ConfigPath:Optional path to environment.json; defaults to the current workspace'
---

# Restore UE Environment

Applies a saved customization environment without unpacking UE, changing add-in
files, building projects, or launching the application.

## Script

Run [Restore-UEEnvironment.ps1](scripts/Restore-UEEnvironment.ps1) from this skill's
installed directory. It owns environment restoration for setup, build, and start.

## Parameters

| Parameter | Required | Default | Purpose |
| --- | --- | --- | --- |
| ConfigPath | No | `environment.json` in the current directory | Saved environment configuration to apply |

## Workflow

1. Identify the user's customization workspace and configuration file.
2. Confirm permission to update the current user's persisted environment unless
   the user's request already authorizes restoration. Only use trusted
   configuration files.
3. Invoke the bundled script with `&` in the same PowerShell process as the
   subsequent build or launch. The caller MUST NOT start a separate `pwsh`
   process for restoration: child-process environment changes cannot update its
   parent process.
4. If restoration fails, stop the dependent build or launch and report the error.

```powershell
& "<installed-skill-path>/scripts/Restore-UEEnvironment.ps1"
```

To select another saved configuration:

```powershell
& "<installed-skill-path>/scripts/Restore-UEEnvironment.ps1" -ConfigPath "<workspace>/environment.json"
```

## Behavior

The script restores every saved variable, including `CAF_ADDINS_PATH`,
`CAF_UIC_PATH`, `CUSTOM_PMLLIB`, and `UNIFIED_ENGINEERING_REFERENCE_PATH`.
It updates both the user profile and the current process, skipping values that
are already correct. User-level changes also affect future processes.

PowerShell 7 or later on Windows and a saved environment configuration are
required. UE does not need to be running.

Missing files and malformed JSON cause a terminating error before variables are
applied. If no saved configuration exists, use `setup-environment` first.