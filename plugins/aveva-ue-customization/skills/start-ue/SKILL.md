---
name: start-ue
description: 'Launch AVEVA Unified Engineering with the customization environment. Restores environment variables from environment.json and starts UE with optional parameters (Module, Project, Username, Mdb). Ensures add-ins are loaded with proper configuration.'
license: MIT
argument-hint: 'Module:UE module to launch (Engineering/Model/etc.), Project:Project name, Username:User name, Mdb:MDB name'
---

# Start UE with Customization Environment

## Overview

Launches AVEVA Unified Engineering with the customization environment restored. This ensures your add-ins are properly loaded with the correct environment variables and configuration.

**Script**: `./scripts/Start-UE.ps1`

---

## When to use

Use this skill when:

- Testing UE add-ins during development
- Launching UE with customization environment configured
- Starting UE with specific module, project, or database parameters
- Debugging add-in behavior in UE
- User wants to run UE with their custom add-ins loaded

---

## Parameters

| Parameter | Required | Alias      | Default | Description                                                    |
| --------- | -------- | ---------- | ------- | -------------------------------------------------------------- |
| Module    | No       | -md        | -       | UE module to launch (e.g., Engineering, Model, Draw)           |
| Project   | No       | -proj, -p  | -       | Project name to open                                           |
| Username  | No       | -user, -u  | -       | Username for project login                                     |
| Mdb       | No       | -m         | -       | MDB (Multi-Disciplinary Database) name                         |

---

## Workflow

1. **Load environment**: Restores environment variables from `environment.json`
2. **Build UE command**: Constructs the UE launch command with parameters
3. **Launch UE**: Starts the AVEVA Unified Engineering application
4. **Monitor process**: Optionally waits for UE to start

---

## Output

- Launches AVEVA Unified Engineering application
- Add-ins are loaded based on configuration in `addins/DesignAddins.xml`
- Environment variables are set for add-in assembly resolution

---

## Examples

### Launch UE with default settings
```powershell
.\Start-UE.ps1
```

### Launch Engineering module
```powershell
.\Start-UE.ps1 -Module Engineering
```

### Launch with project and username
```powershell
.\Start-UE.ps1 -Module Engineering -Project "MyProject" -Username "user1"
```

### Launch with MDB
```powershell
.\Start-UE.ps1 -Module Engineering -Project "MyProject" -Username "user1" -Mdb "MyMdb"
```

### Launch with verbose output
```powershell
.\Start-UE.ps1 -Module Engineering -Verbose
```

---

## Prerequisites

- `Setup-UECustomizationEnvironment.ps1` must have been run to create `environment.json`
- AVEVA Unified Engineering must be installed
- UE command must be accessible (typically added to PATH during UE installation)
- Add-ins should be built before launching (use `build-addins` skill)

---

## Environment Variables

The script restores these environment variables from `environment.json`:
- Assembly reference paths for UE assemblies
- Add-in configuration paths
- PML library paths
- Any custom variables set during environment setup

---

## Notes

- Password is prompted securely if Username is provided
- If UE is already running, this may launch a second instance (behavior depends on UE version)
- Add-ins must be registered in `DesignAddins.xml` to be loaded
- Use verbose mode (`-Verbose`) to see environment restoration details
- Close any previous UE instances to ensure clean add-in loading

---

## Troubleshooting

### Add-ins not loading
- Verify add-ins are built: `.\Build-AddIns.ps1`
- Check `addins/DesignAddins.xml` contains add-in entries
- Ensure environment was set up: `.\Setup-UECustomizationEnvironment.ps1`

### UE command not found
- Verify AVEVA Unified Engineering is installed
- Check that UE executable is in system PATH
- Try specifying full path to UE executable

### Environment variables not applied
- Ensure `environment.json` exists in customization root
- Re-run `Setup-UECustomizationEnvironment.ps1` if needed
- Check file permissions on `environment.json`

---

## Error Handling

The script will stop on errors. Common issues:
- Missing `environment.json`: Run setup-environment skill first
- UE not installed: Install AVEVA Unified Engineering
- Invalid module name: Check spelling of module parameter
- Permission issues: Run with appropriate permissions
