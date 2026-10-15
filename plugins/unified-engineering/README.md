---
title: AVEVA Unified Engineering Plugin
description: Skills and agents for AVEVA Unified Engineering customization and add-in development.
---

This plugin provides comprehensive support for AVEVA Unified Engineering (UE) add-in development, including skills for environment setup, add-in creation, building, and testing.

## Overview

The `unified-engineering` plugin contains:
- **8 Skills** for managing the complete UE add-in development lifecycle
- **1 Agent** (Unified Engineering Customization Manager) that orchestrates workflows
- PowerShell implementations owned by their individual skills
- **9 Templates** for creating different types of add-ins
- **15+ Code examples** demonstrating UE API patterns

## Quick Start

All skills operate in your **current workspace directory**. Navigate to where you want to create your project and invoke the scripts:

```powershell
# 1. Create and navigate to your workspace
mkdir C:\MyUEProject
cd C:\MyUEProject

# 2. Setup environment (creates addins/, pmllib/, environment.json here)
& "{plugin-path}\plugins\unified-engineering\skills\setup-environment\scripts\Setup-UECustomizationEnvironment.ps1"

# 3. Create an add-in (creates source/MyAddin/ here)
& "{plugin-path}\plugins\unified-engineering\skills\create-addin\scripts\New-UEAddin.ps1" -AddinName 'MyAddin' -Template 'DockedFormAddInTemplate' -Module 'Engineering'

# 4. Build add-ins (builds projects in source/)
& "{plugin-path}\plugins\unified-engineering\skills\build-addins\scripts\Build-AddIns.ps1" -Configuration 'Release'

# 5. Start UE with your add-ins loaded
& "{plugin-path}\plugins\unified-engineering\skills\start-ue\scripts\Start-UE.ps1" -Module 'Engineering'
```

**Important**: Scripts read templates from the plugin installation but write all output (addins/, source/, environment.json) to your current directory.

## Skills

### setup-environment
Initialize the UE customization development environment. Creates directory structure, unpacks UE MSIX files, and configures environment variables.

**Use when**: Starting a new project or resetting the environment

**Parameters**:
- `ReuseEnvironment` (optional): Skip unpacking if environment.json exists

### create-addin
Create a new UE add-in from a template. Supports all UE modules (Model, Engineering, EngineeringConfiguration, Isodraft, Draw, Paragon, Spooler, Monitor).

**Use when**: Creating a new add-in or adding a feature

**Parameters**:
- `AddinName` (required): Name of the add-in (letters only)
- `Template` (required): Template name (see available templates below)
- `Module` (required): UE module for the add-in

### restore-environment

Restore user and process environment variables from an existing `environment.json`
without unpacking UE or recreating customization files. Setup, build, and start
invoke this skill's script in the same PowerShell process.

See the [restore-environment skill](skills/restore-environment/SKILL.md).

Parameters:
- `ConfigPath` (optional): Saved configuration path; defaults to `environment.json` in the current directory

### build-addins
Build all add-ins in a directory using `dotnet build`. Supports Debug and Release configurations.

**Use when**: After creating or modifying add-in source code

**Parameters**:
- `Directory` (optional, default: "source"): Directory containing .csproj files
- `Configuration` (optional, default: "Debug"): Build configuration

### start-ue
Launch AVEVA Unified Engineering with the customization environment restored.

**Use when**: Testing add-ins or running UE with customizations

**Parameters**:
- `Module` (optional): UE module to launch
- `Project` (optional): Project name
- `Username` (optional): Username for login
- `Mdb` (optional): MDB name

### remove-addin
Remove an add-in configuration from XML files and delete the UIC file. Does NOT delete source code.

**Use when**: Cleaning up or removing an add-in

**Parameters**:
- `AddinName` (required): Name of the add-in to remove

### clear-environment
Clean up the customization environment by removing generated folders (addins, pmllib, samples).

**Use when**: Resetting to a clean state or troubleshooting

**Parameters**: None (prompts for confirmation)

### examples
Reference collection of C# code examples demonstrating UE API usage patterns.

**Use when**: Learning UE APIs or looking for implementation examples

**Contains**:
- Assembly info and basic structure
- Attribute operations
- Database and element operations
- Event handling
- Clash detection
- Spatial queries
- Tree navigation
- Undo operations
- And more...

## Agent

### Unified Engineering Customization Manager

An intelligent agent that orchestrates the complete UE add-in development workflow. It guides users through:
- Initial environment setup
- Add-in creation with template selection
- Building and testing
- Cleanup and troubleshooting

**Invoke with**: Ask natural language questions about UE customization, or request specific operations like "set up my environment" or "create a new add-in".

## Available Templates

Located in `skills/create-addin/templates/`:

| Template                        | Purpose                                   |
| ------------------------------- | ----------------------------------------- |
| AttributeBrowserAddInTemplate   | Browse and edit element attributes        |
| DockedFormAddInTemplate         | Dockable UI panel                         |
| FlexibleExplorerAddInTemplate   | Hierarchical explorer interface           |
| NetGridAddInTemplate            | Data grid display                         |
| PMLExtensionTemplate            | Extend PML functionality                  |
| PMLGridTemplate                 | PML-based grid control                    |
| PMLMLNetPredictTemplate         | Machine learning integration              |
| WebEndpointAddInTemplate        | REST API endpoints                        |
| WebpageAddInTemplate            | Embedded web interface                    |

## Quick Start Workflow

```powershell
# 1. Set up environment
# Use the setup-environment skill or run:
cd ai-marketplace
.\plugins\unified-engineering\skills\setup-environment\scripts\Setup-UECustomizationEnvironment.ps1

# 2. Create an add-in
# Use the create-addin skill or run:
.\plugins\unified-engineering\skills\create-addin\scripts\New-UEAddin.ps1 -AddinName "MyAddin" -Template "DockedFormAddInTemplate" -Module "Engineering"

# 3. Implement your feature
# The create-addin script generates source code in a 'source' folder in the repo root
# Edit the generated C# files for your add-in

# 4. Build the add-in
# Use the build-addins skill or run:
.\plugins\unified-engineering\skills\build-addins\scripts\Build-AddIns.ps1

# 5. Test in UE
# Use the start-ue skill or run:
.\plugins\unified-engineering\skills\start-ue\scripts\Start-UE.ps1 -Module Engineering
```

## Script Ownership

Each skill's script contains its own implementation. Creation and removal own
their XML and file operations; setup owns unpacking and directory initialization.
The restore-environment script owns environment restoration. Setup, build, and
start invoke it in the same PowerShell process so session changes remain visible
to the caller. Setup also delegates applying newly written configuration to it.

Cleanup is implemented once in the clear-environment script, which setup invokes
before creating a fresh environment. Script functions can be loaded for testing
by dot-sourcing with any required parameters; workflows run only when the scripts
are invoked normally.

## File Structure

```
plugins/unified-engineering/
├── .github/
│   └── plugin/
│       └── plugin.json              # Plugin metadata
├── agents/
│   └── ue-customization-manager.agent.md
└── skills/
    ├── restore-environment/
    │   ├── scripts/
    │   │   └── Restore-UEEnvironment.ps1
    │   └── SKILL.md
    ├── build-addins/
    │   ├── scripts/
    │   │   └── Build-AddIns.ps1
    │   └── SKILL.md
    ├── clear-environment/
    │   ├── scripts/
    │   │   └── Clear-UECustomizationEnvironment.ps1
    │   └── SKILL.md
    ├── create-addin/
    │   ├── scripts/
    │   │   └── New-UEAddin.ps1
    │   ├── templates/
    │   │   ├── AttributeBrowserAddInTemplate/
    │   │   ├── DockedFormAddInTemplate/
    │   │   └── ... (9 templates total)
    │   └── SKILL.md
    ├── examples/
    │   ├── Examples/
    │   │   ├── AssemblyInfo.cs
    │   │   ├── Example*.cs (15 example files)
    │   │   ├── Examples.csproj
    │   │   └── Examples.sln
    │   └── SKILL.md
    ├── remove-addin/
    │   ├── scripts/
    │   │   └── Remove-UEAddin.ps1
    │   └── SKILL.md
    ├── setup-environment/
    │   ├── scripts/
    │   │   └── Setup-UECustomizationEnvironment.ps1
    │   └── SKILL.md
    └── start-ue/
        ├── scripts/
        │   └── Start-UE.ps1
        └── SKILL.md
```

## Prerequisites

- **Windows** (PowerShell 7.0+)
- **AVEVA Unified Engineering** installed
- **.NET SDK** (compatible with UE target framework)
- **VS Code** with GitHub Copilot (recommended for agent support)

## Support and Documentation

- Each skill has detailed documentation in its `SKILL.md` file
- The agent provides context-aware guidance
- Example code is available in the `examples` skill
- Template README files provide template-specific guidance

## License

MIT - See LICENSE file for details
