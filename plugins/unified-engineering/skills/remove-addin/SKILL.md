---
name: remove-addin
description: 'Remove an AVEVA Unified Engineering add-in configuration. Removes entries from DesignAddins.xml and DesignCustomization.xml, and deletes the User Interface Customization (UIC) file for the add-in. Does not delete source code.'
license: MIT
argument-hint: 'AddinName:Name of the add-in to remove'
---

# Remove UE Add-In

## Overview

Removes an AVEVA Unified Engineering add-in configuration by:
1. Removing the entry from `DesignAddins.xml`
2. Removing the CustomizationFile entry from `DesignCustomization.xml`
3. Deleting the UIC (User Interface Customization) file

The [removal script](./scripts/Remove-UEAddin.ps1) path is relative to this
SKILL.md file. Resolve it to an absolute path before invoking it, keeping the
working directory in the user's workspace. Use that resolved path as
`$removeScript` in the examples below.

**Note**: This script removes the add-in configuration but does NOT delete the source code.

---

## When to use

Use this skill when:

- Removing an add-in that is no longer needed
- Cleaning up the add-in configuration
- The user wants to unregister an add-in from UE
- Troubleshooting add-in conflicts by temporarily removing an add-in

---

## Parameters

| Parameter | Required | Default | Description                                    |
| --------- | -------- | ------- | ---------------------------------------------- |
| AddinName | Yes      | -       | Name of the add-in to remove (exact match required) |

---

## Workflow

1. **Validate environment**: Checks for `environment.json`
2. **Remove from DesignAddins.xml**: Deletes the `<Addin>` entry for the specified add-in
3. **Remove from DesignCustomization.xml**: Deletes the `<CustomizationFile>` entry
4. **Delete UIC file**: Removes the `{AddinName}.uic` file from the addins folder
5. **Confirm removal**: Reports success or failure

---

## What Gets Removed

- ✓ Add-in entry in `addins/DesignAddins.xml`
- ✓ Customization file entry in `addins/DesignCustomization.xml`
- ✓ UIC file: `addins/{AddinName}.uic`
- ✗ Source code in `source/{AddinName}/` (NOT removed)
- ✗ Built assemblies in `source/{AddinName}/bin/` (NOT removed)

---

## Examples

### Remove an add-in
```powershell
& $removeScript -AddinName "MyEngAddin"
```

### Remove multiple add-ins
```powershell
@("Addin1", "Addin2", "Addin3") | ForEach-Object { & $removeScript -AddinName $_ }
```

---

## Notes

- The add-in name must match exactly (case-sensitive)
- Source code and built assemblies are NOT deleted - only configuration is removed
- To completely remove an add-in, manually delete the `source/{AddinName}/` folder after running this script
- Requires that `setup-environment` skill has been run first
- If the add-in doesn't exist in the configuration files, the script will report an error

---

## After Removal

If you want to completely remove the add-in including source code:

```powershell
# Remove configuration
& $removeScript -AddinName "MyAddin"

# Manually delete source (if desired)
Remove-Item -Path "source\MyAddin" -Recurse -Force
```

---

## Error Handling

The script will stop on errors. Common issues:
- Add-in not found: Verify the add-in name is correct
- Environment not set up: Run setup-environment skill first
- XML parsing errors: Ensure XML files are not corrupted
- Permission issues: Ensure you have write access to the addins folder
