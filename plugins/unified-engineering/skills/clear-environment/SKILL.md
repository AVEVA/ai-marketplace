---
name: clear-environment
description: 'Clean up the AVEVA Unified Engineering customization environment by removing generated folders (addins, pmllib, samples). Prompts for confirmation when deleting folders with more than 100 items. Useful for resetting the environment to a clean state.'
license: MIT
argument-hint: 'No parameters - interactively prompts for confirmation when needed'
---

# Clear UE Customization Environment

## Overview

Cleans up the UE customization environment by removing generated folders and files. This provides a clean slate for re-initializing the environment.

The [cleanup script](./scripts/Clear-UECustomizationEnvironment.ps1) path is
relative to this SKILL.md file. Resolve it to an absolute path before invoking
it, keeping the working directory in the user's workspace. Use that resolved path
as `$cleanupScript` in the examples below.

**Warning**: This operation removes generated files and folders. Source code in `source/` is NOT affected.

---

## When to use

Use this skill when:

- Resetting the development environment to a clean state
- Troubleshooting environment issues by starting fresh
- Preparing to re-run setup-environment with different settings
- Cleaning up before switching UE versions
- Removing all generated files after testing

---

## Parameters

This script takes no parameters. It prompts interactively for confirmation when deleting large folders.

---

## What Gets Removed

- ✓ `addins/` folder - All compiled add-ins and XML configurations
- ✓ `pmllib/` folder - All PML libraries
- ✓ `samples/` folder - Any generated sample files
- ✓ Unpacked UE assemblies (if present)
- ✗ `source/` folder - Source code is NOT removed
- ✗ `templates/` folder - Templates are NOT removed
- ✗ `environment.json` - May be removed (configurable)

---

## Safety Features

- **Confirmation prompt**: When deleting folders with more than 100 items, prompts for confirmation
- **Selective cleanup**: Only removes known generated folders
- **Source protection**: Never touches the `source/` folder containing your code
- **Verbose logging**: Shows what is being removed

---

## Workflow

1. **Locate customization root**: Finds the root directory
2. **Identify targets**: Determines which folders to remove
3. **Count items**: Checks size of folders to be deleted
4. **Prompt if needed**: Asks for confirmation for large deletions
5. **Remove folders**: Deletes confirmed folders
6. **Report status**: Shows what was removed

---

## Examples

### Clean environment (default)
```powershell
& $cleanupScript
```

### Clean with verbose output
```powershell
& $cleanupScript -Verbose
```

---

## Typical Workflow

Resolve `$setupScript`, `$createScript`, and `$buildScript` from the script links
in the [setup](../setup-environment/SKILL.md),
[create](../create-addin/SKILL.md), and [build](../build-addins/SKILL.md) skills.
Keep the working directory in the user's workspace throughout.

```powershell
# Clean existing environment
& $cleanupScript

# Set up fresh environment
& $setupScript

# Create and build add-ins
& $createScript -AddinName "MyAddin" -Template "DockedFormAddInTemplate" -Module "Engineering"
& $buildScript
```

---

## Notes

- This script is safe to run - it only removes generated files
- Your source code in `source/` is never touched
- After clearing, you'll need to run `setup-environment` again before building add-ins
- Useful for troubleshooting when environment state becomes inconsistent
- Consider backing up any custom configurations before running

---

## Recovery

After clearing the environment, restore it by:

1. Run `Setup-UECustomizationEnvironment.ps1` to recreate folder structure
2. Add-ins will need to be re-registered (re-run `New-UEAddin.ps1` or restore XML files)
3. Rebuild all add-ins with `Build-AddIns.ps1`

---

## Error Handling

The script will stop on critical errors. Common issues:
- Permission denied: Ensure you have write access to the folders
- Files in use: Close UE and any processes that may have files locked
- Missing script: Reinstall the plugin to restore `scripts/Clear-UECustomizationEnvironment.ps1`
