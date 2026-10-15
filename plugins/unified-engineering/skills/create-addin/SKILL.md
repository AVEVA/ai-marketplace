---
name: create-addin
description: 'Create a new AVEVA Unified Engineering add-in from a template. Supports multiple UE modules (Model, Engineering, EngineeringConfiguration, Isodraft, Draw, Paragon, Spooler, Monitor). Creates add-in configuration, copies template source code, and sets up necessary XML entries.'
license: MIT
argument-hint: 'AddinName:Name of the add-in (letters only, no spaces), Template:Template name from templates folder, Module:UE module (Model/Engineering/EngineeringConfiguration/Isodraft/Draw/Paragon/Spooler/Monitor)'
---

# Create UE Add-In

## Overview

Creates a new AVEVA Unified Engineering add-in by:
1. Copying source code from a specified template
2. Creating add-in configuration entries in XML files
3. Setting up the add-in for the specified UE module

The [creation script](./scripts/New-UEAddin.ps1) path is relative to this SKILL.md
file. Resolve it to an absolute path before invoking it, keeping the working
directory in the user's workspace. Use that resolved path as `$createScript` in
the examples below.

---

## When to use

Use this skill when:

- Creating a new UE add-in from scratch
- Starting development on a new customization feature
- The user wants to scaffold a new add-in project
- Need to create an add-in for a specific UE module (Model, Engineering, etc.)

---

## Parameters

| Parameter  | Required | Default | Description                                                                                              |
| ---------- | -------- | ------- | -------------------------------------------------------------------------------------------------------- |
| AddinName  | Yes      | -       | Name of the add-in (letters only, no spaces or special characters)                                       |
| Template   | Yes      | -       | Name of the template to use (e.g., "AttributeBrowserAddInTemplate", "DockedFormAddInTemplate")          |
| Module     | Yes      | -       | UE module: Model, Engineering, EngineeringConfiguration, Isodraft, Draw, Paragon, Spooler, or Monitor |

---

## Available Templates

The framework includes several templates in the `templates/` folder:

- **AttributeBrowserAddInTemplate**: Add-in with attribute browsing capabilities
- **DockedFormAddInTemplate**: Add-in with dockable form UI
- **FlexibleExplorerAddInTemplate**: Add-in with explorer-style interface
- **NetGridAddInTemplate**: Add-in with .NET grid control
- **PMLExtensionTemplate**: PML extension add-in
- **PMLGridTemplate**: PML grid control add-in
- **PMLMLNetPredictTemplate**: PML machine learning prediction add-in
- **WebEndpointAddInTemplate**: Add-in with web endpoint capabilities
- **WebpageAddInTemplate**: Add-in with embedded web page

---

## Workflow

1. **Validate input**: Checks add-in name format and template existence
2. **Create source folder**: Copies template to `source/{AddinName}`
3. **Configure XML**: Updates `DesignAddins.xml` and `DesignCustomization.xml`
4. **Create UIC file**: Sets up User Interface Customization file for the module
5. **Token replacement**: Replaces template tokens with actual add-in name

---

## Output

- Creates `source/{AddinName}/` folder with template source code
- Updates `addins/DesignAddins.xml` with add-in entry
- Updates `addins/DesignCustomization.xml` with customization file entry
- Creates `addins/{AddinName}.uic` for the specified module

---

## Examples

### Create an Engineering add-in from docked form template
```powershell
& $createScript -AddinName "MyEngAddin" -Template "DockedFormAddInTemplate" -Module "Engineering"
```

### Create a Model add-in from attribute browser template
```powershell
& $createScript -AddinName "ModelBrowser" -Template "AttributeBrowserAddInTemplate" -Module "Model"
```

### Create a web-enabled add-in
```powershell
& $createScript -AddinName "WebDashboard" -Template "WebpageAddInTemplate" -Module "Engineering"
```

---

## Notes

- Run `Setup-UECustomizationEnvironment.ps1` first to initialize the environment
- Add-in name must contain only letters (no numbers, spaces, or special characters)
- The add-in source will be created in the `source/` folder
- After creation, build the add-in using the `build-addins` skill
- Templates are located in `templates/` folder under the create-addin skill

---

## Error Handling

The script will stop on errors. Common issues:
- Invalid add-in name format: Use only letters
- Template not found: Verify template exists in templates folder
- Environment not set up: Run setup-environment skill first
- XML parsing errors: Ensure XML files are not corrupted
