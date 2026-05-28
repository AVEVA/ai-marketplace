---
name: setup-environment
description: 'Set up the AVEVA Unified Engineering customization development environment. Creates directory structure, unpacks UE MSIX files, and configures environment variables for add-in development. Supports reusing existing environment to skip time-consuming unpacking.'
license: MIT
argument-hint: 'ReuseEnvironment:Optional switch to skip unpacking and reuse existing environment.json if it exists'
---

# Setup UE Customization Environment

## Overview

Sets up the necessary directory structure, unpacks UE MSIX files, and configures environment variables for AVEVA Unified Engineering add-in development.

**Script**: `./scripts/Setup-UECustomizationEnvironment.ps1`

This script is typically the first step in setting up a new development environment for UE customizations.

---

## When to use

Use this skill when:

- Starting a new UE customization project and need to set up the development environment
- The user wants to initialize the UE add-in development structure
- Environment variables need to be configured for UE add-in development
- UE MSIX files need to be unpacked for add-in references

---

## Parameters

| Parameter        | Required | Default | Description                                                                                          |
| ---------------- | -------- | ------- | ---------------------------------------------------------------------------------------------------- |
| ReuseEnvironment | No       | False   | If specified and environment.json exists, skips unpacking and reuses existing environment. Saves time. |

---

## Workflow

1. **Validate prerequisites**: Checks for required MSIX files and tools
2. **Create directory structure**: Sets up `addins/` and `pmllib/` folders
3. **Unpack MSIX files**: Extracts UE assemblies (or reuses existing if `-ReuseEnvironment` specified)
4. **Configure environment**: Creates `environment.json` with paths and environment variables
5. **Install UE files**: Copies necessary assemblies to the addins folder

---

## Output

- Creates `addins/` folder for compiled add-ins
- Creates `pmllib/` folder for PML libraries
- Creates `environment.json` with environment configuration
- Unpacks UE assemblies to a versioned directory

---

## Examples

### First-time setup
```powershell
.\Setup-UECustomizationEnvironment.ps1
```

### Quick setup (reuse existing environment)
```powershell
.\Setup-UECustomizationEnvironment.ps1 -ReuseEnvironment
```

### Setup with verbose output
```powershell
.\Setup-UECustomizationEnvironment.ps1 -Verbose
```

---

## Notes

- Requires AVEVA Unified Engineering MSIX packages to be accessible
- Creates `environment.json` that other scripts depend on
- Use `-ReuseEnvironment` for faster subsequent setups when MSIX hasn't changed
- This script must be run before creating or building add-ins

---

## Error Handling

The script will stop on errors (`$ErrorActionPreference = "Stop"`). Common issues:
- Missing MSIX files: Ensure UE is installed and MSIX packages are accessible
- Insufficient permissions: Run with appropriate permissions to create directories
- Missing dependencies: Ensure .NET SDK is installed for building add-ins
