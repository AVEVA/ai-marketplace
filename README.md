# AVEVA Unified Engineering Customization Framework

This repository is a **plugin marketplace** for AVEVA Unified Engineering (UE) customization development. It provides skills, agents, templates, and tools to streamline UE add-in development.

## 🎯 What's New - Plugin Marketplace Structure

This repository has been restructured as a plugin marketplace, similar to the AVEVA Agent Plugins repository. The marketplace provides:

- **7 Skills** - Individual automation capabilities for UE development tasks
- **1 Agent** - Intelligent orchestration of the complete workflow
- **9 Templates** - Starting points for different add-in types
- **15+ Examples** - Reference implementations of UE API patterns
- **Web Catalog** - Browse available skills and agents via [the marketplace site](./site/index.html)

### Repository Structure

```
UnifiedEngineeringCustomizationFramework/
├── plugins/
│   └── aveva-ue-customization/     # Main UE customization plugin
│       ├── .github/                # Plugin metadata
│       │   └── plugin/
│       │       └── plugin.json
│       ├── agents/                 # Workflow orchestration agents
│       ├── helpers/                # Shared PowerShell modules
│       └── skills/                 # Individual automation skills
│           ├── setup-environment/
│           │   ├── scripts/
│           │   └── SKILL.md
│           ├── create-addin/
│           │   ├── scripts/
│           │   ├── templates/      # Add-in templates
│           │   └── SKILL.md
│           ├── build-addins/
│           ├── start-ue/
│           ├── remove-addin/
│           ├── clear-environment/
│           └── examples/
│               └── Examples/       # C# code examples
├── tests/                      # Pester tests
│   ├── Invoke-PesterTests.ps1  # Top-level test runner
│   └── aveva-ue-customization/ # Plugin-specific tests
│       └── skills/             # Tests for skills/helpers
```

## 🚀 Quick Start

All skills work in your **current workspace directory**. The pattern is simple:

1. **Create workspace**: `mkdir C:\MyUEProject; cd C:\MyUEProject`
2. **Invoke scripts**: Scripts automatically work in current directory

```powershell
# Navigate to your workspace
cd C:\MyUEProject

# Setup environment (creates addins/, pmllib/ in current directory)
& "{plugin-path}\plugins\aveva-ue-customization\skills\setup-environment\scripts\Setup-UECustomizationEnvironment.ps1"

# Create add-in (creates source/MyAddin/ in current directory)
& "{plugin-path}\plugins\aveva-ue-customization\skills\create-addin\scripts\New-UEAddin.ps1" -AddinName 'MyAddin' -Template 'DockedFormAddInTemplate' -Module 'Engineering'

# Build add-ins
& "{plugin-path}\plugins\aveva-ue-customization\skills\build-addins\scripts\Build-AddIns.ps1" -Configuration 'Release'

# Start UE
& "{plugin-path}\plugins\aveva-ue-customization\skills\start-ue\scripts\Start-UE.ps1" -Module 'Engineering'
```

Scripts read resources (templates, helpers) from plugin installation but write output to your current directory.

### Using the Unified Engineering Customization Manager Agent

The repository includes an intelligent agent that guides you through the complete workflow:

```
Ask the agent: "Set up my UE customization environment"
Ask the agent: "Create a new add-in called MyAddin"
Ask the agent: "Build my add-ins and start UE"
```

See the [plugin README](./plugins/aveva-ue-customization/README.md) for detailed agent capabilities.

## 📚 Documentation

- **[Plugin README](./plugins/aveva-ue-customization/README.md)** - Complete documentation of skills, agents, and templates
- **Individual Skill Documentation** - Each skill folder contains a detailed `SKILL.md` file
- **[Examples](./plugins/aveva-ue-customization/skills/examples/Examples/)** - C# code examples for UE APIs

## 🎨 Available Skills

| Skill                                                                                       | Purpose                                                      |
| ------------------------------------------------------------------------------------------- | ------------------------------------------------------------ |
| [setup-environment](./plugins/aveva-ue-customization/skills/setup-environment/SKILL.md)    | Initialize UE customization development environment          |
| [create-addin](./plugins/aveva-ue-customization/skills/create-addin/SKILL.md)              | Create new add-in from template                              |
| [build-addins](./plugins/aveva-ue-customization/skills/build-addins/SKILL.md)              | Build all add-ins in a directory                             |
| [start-ue](./plugins/aveva-ue-customization/skills/start-ue/SKILL.md)                      | Launch UE with customization environment                     |
| [remove-addin](./plugins/aveva-ue-customization/skills/remove-addin/SKILL.md)              | Remove add-in configuration                                  |
| [clear-environment](./plugins/aveva-ue-customization/skills/clear-environment/SKILL.md)    | Clean up and reset environment                               |
| [examples](./plugins/aveva-ue-customization/skills/examples/SKILL.md)                      | Reference C# code examples                                   |

## 🤖 Agent

**[Unified Engineering Customization Manager](./plugins/aveva-ue-customization/agents/ue-customization-manager.agent.md)** - Orchestrates the complete UE add-in development lifecycle with intelligent workflow guidance.

## � Quick Start

### Prerequisites

Before working with this repository, you'll need:

1. **Visual Studio Code**
   - Download and install from [code.visualstudio.com](https://code.visualstudio.com/)
   - A free, lightweight code editor with excellent PowerShell support

2. **GitHub Copilot** (recommended)
   - Install the GitHub Copilot extension in VS Code
   - Requires a GitHub Copilot subscription (free for students, educators, and open source maintainers)
   - Provides AI-powered assistance including the UE Customization Manager agent

3. **AVEVA Unified Engineering**
   - Must be installed with the `UE` command available in your PATH
   - Required for unpacking MSIX packages and running customizations

4. **PowerShell 7.0 or higher**
   - Install PowerShell 7 so `pwsh.exe` is available
   - Scripts are designed for PowerShell (`pwsh.exe`)

### Setting Up VS Code

1. Open Visual Studio Code
2. Install recommended extensions:
   - **GitHub Copilot** - AI-powered code assistance
   - **PowerShell** - PowerShell language support
3. Clone or open this repository in VS Code:
   ```powershell
   git clone <repository-url>
   cd UnifiedEngineeringCustomizationFramework
   code .
   ```

## Using the UE Customization Manager Agent

This repository includes a **GitHub Copilot agent** (`@ue-customization-manager`) that provides intelligent assistance for managing your UE customization environment. The agent understands the entire workflow and can guide you through setup, add-in creation, and cleanup operations.

### What the Agent Does

The UE Customization Manager agent:
- **Guides script selection** - Recommends the correct script based on your intent
- **Explains workflows** - Helps you understand the proper sequence of operations
- **Validates operations** - Warns about destructive operations and validates parameters
- **Troubleshoots issues** - Provides context-aware assistance based on README documentation
- **Launches UE** - Can start AVEVA Unified Engineering when requested
- **Manages the lifecycle** - From initial setup through add-in creation to final cleanup

### Sample Commands for the Agent

You can interact with the agent using natural language in the GitHub Copilot chat. Here are example commands:

#### Initial Setup
```
@ue-customization-manager I need to set up a new customization environment with an add-in called "DataExporter"

@ue-customization-manager What do I need to do before creating my first add-in?

@ue-customization-manager Set up the environment without creating an add-in yet
```

#### Creating Add-ins
```
@ue-customization-manager Create a new add-in named "ReportGenerator"

@ue-customization-manager I want to add multiple add-ins: "ToolOne", "ToolTwo", and "ToolThree"

@ue-customization-manager What are the naming rules for add-ins?
```

#### Managing Add-ins
```
@ue-customization-manager Remove the "OldAddin" add-in

@ue-customization-manager How do I delete an add-in I no longer need?

@ue-customization-manager List all the add-ins in my environment
```

#### Running UE
```
@ue-customization-manager Start UE

@ue-customization-manager Launch unified engineering

@ue-customization-manager Run ue

@ue-customization-manager Open the application
```
> Tip: The agent will ask if you want to supply optional UE launch values (module, project, username, password, mdb) and will forward them to `Start-UE.ps1` for you.

#### Cleanup Operations
```
@ue-customization-manager Clean up my environment

@ue-customization-manager I'm done with this project, how do I reset everything?

@ue-customization-manager Clear the environment but keep the template
```

#### Troubleshooting
```
@ue-customization-manager I'm getting an error about UE command not found

@ue-customization-manager The script says the environment doesn't exist

@ue-customization-manager What files will be deleted if I run Clear?
```

### Benefits of Using the Agent

- **Safer operations** - The agent warns before destructive operations
- **Faster workflow** - No need to remember exact script names or parameters
- **Better understanding** - Explains what each operation does and why
- **Context-aware** - Knows the state of your environment and suggests appropriate next steps
- **Error prevention** - Validates parameters before running scripts

## Overview

The scripts automate the process of:
- Creating a structured directory environment for UE customization
- Unpacking the UE MSIX installation package
- Configuring environment variables
- Managing add-in configurations
- Cleaning up the customization environment

## Repository Structure

```
.
├── scripts/                    # PowerShell scripts directory
│   ├── Setup-UECustomizationEnvironment.ps1
│   ├── New-UEAddin.ps1
│   ├── Remove-UEAddin.ps1
│   ├── Clear-UECustomizationEnvironment.ps1
│   ├── Build-AddIns.ps1
│   ├── Start-UE.ps1
│   ├── UECustomizationFunctions.psm1
│   └── Tests/
│       └── Run-Tests.ps1
├── templates/                  # Template directory for creating add-ins
│   ├── DockedFormAddInTemplate/  # Template for creating new add-ins
│   └── README.md
├── source/                     # Source directory for add-in projects
│   ├── [AddinName]/            # Auto-generated add-in source (created by New-UEAddin.ps1)
│   └── README.md
├── addins/                     # Add-in configuration and UIC files
├── samples/                    # Extracted samples from MSIX
├── README.md
└── environment.json            # Generated configuration (created by Setup)
```

## Customization Environment Structure

Once set up, the customization environment will have the following structure:

```
CustomizationRootDir/
├── templates/           # Template directory
│   ├── TemplateAddIn/   # Template for creating new add-ins
│   └── Template.uic     # Template for add-in UI configuration
├── source/              # Add-in source code directory
│   └── [AddinName]/     # Auto-generated copy of TemplateAddIn with substitutions
├── samples/             # Extracted samples from MSIX (generated by Setup)
├── addins/              # Add-in configuration and files
│   ├── DesignAddins.xml        # Module-specific Addins entries (Model → Design)
│   ├── TagsAddins.xml          # Engineering → Tags
│   ├── ConfigurationAddins.xml # EngineeringConfiguration → Configuration
│   ├── IsodraftAddins.xml      # Isodraft → Isodraft
│   ├── DrawAddins.xml          # Draw → Draw
│   ├── ParagonAddins.xml       # Paragon → Paragon
│   ├── SpoolerAddins.xml       # Spooler → Spooler
│   ├── MonitorAddins.xml       # Monitor → Monitor
│   ├── DesignCustomization.xml        # Module-specific customization entries (Model → Design)
│   ├── TagsCustomization.xml          # Engineering → Tags
│   ├── ConfigurationCustomization.xml # EngineeringConfiguration → Configuration
│   ├── IsodraftCustomization.xml      # Isodraft → Isodraft
│   ├── DrawCustomization.xml          # Draw → Draw
│   ├── ParagonCustomization.xml       # Paragon → Paragon
│   ├── SpoolerCustomization.xml       # Spooler → Spooler
│   ├── MonitorCustomization.xml       # Monitor → Monitor
│   ├── [AddinName].dll  # Compiled add-in binaries
│   └── [AddinName].uic  # Add-in UI configuration files
```

## Scripts

### 1. Setup-UECustomizationEnvironment.ps1

**Purpose:** Creates the initial customization environment and configures environment variables.

**Parameters:**
- `Force` (optional): Skips cleanup confirmation and automatically cleans existing folders if they exist.

**Usage:**

```powershell
# Setup with default directory (script's parent folder)
.\scripts\Setup-UECustomizationEnvironment.ps1

# Setup with Force flag to skip confirmations
.\scripts\Setup-UECustomizationEnvironment.ps1 -Force
```

**What it does:**
1. Creates directory structure (addins, samples)
2. Runs `UE -tool:unpack` to extract the MSIX
3. Extracts samples from samples.zip
4. Copies all XML configuration files matching `*Addins.xml` or `*Customization*.xml` patterns to addins folder
5. Creates `environment.json` containing environment variable configuration
6. Sets environment variables at User level and applies them to the current session:
   - `CAF_ADDINS_PATH`
   - `CAF_UIC_PATH`
   - `UNIFIED_ENGINEERING_REFERENCE_PATH`
7. If environment already exists, prompts user to either:
   - **Re-establish**: Restore environment variables from the existing configuration
   - **Full setup**: Clean samples and addins folders, then rebuild (source folder is preserved)

**Requirements:**
- PowerShell 7.0 or higher
- `UE` command available in PATH
- Access to `C:\Users\Public\Documents\AVEVA\Unpack\AVEVA.UnifiedEngineering`

---

### 2. New-UEAddin.ps1

**Purpose:** Creates a new add-in configuration and source code by copying and renaming the selected template folder.

**Parameters:**
- `AddinName` (required): Name of the add-in to create. Must contain only letters A-Z or a-z.
- `Template` (optional): Name of the template to use (e.g., "DockedFormAddInTemplate"). If not provided, the user will be prompted to select from available templates.
- `Module` (optional): UE module to target. Valid values: `Model`, `Engineering`, `EngineeringConfiguration`, `Isodraft`, `Draw`, `Paragon`, `Spooler`, `Monitor`. If omitted, the script prompts with a numbered list.

**Validation Rules:**
- `AddinName` must contain only letters A-Z or a-z. No spaces, numbers, or special characters allowed.

**Usage:**

```powershell
# Create an add-in and select template from prompt
.\scripts\New-UEAddin.ps1 -AddinName "MySecondAddin"

# Create an add-in with a specific template
.\scripts\New-UEAddin.ps1 -AddinName "MySecondAddin" -Template "DockedFormAddInTemplate"

# Create an add-in for a specific module (skips module prompt)
.\scripts\New-UEAddin.ps1 -AddinName "MyThirdAddin" -Module "Engineering"

# Create an add-in specifying both template and module
.\scripts\New-UEAddin.ps1 -AddinName "MyFourthAddin" -Template "DockedFormAddInTemplate" -Module "Model"
```

**What it does:**
1. Validates that `AddinName` contains only A-Z/a-z characters
2. If no module is specified, prompts with a numbered list and maps the choice to file prefixes:
   - Model
   - Engineering
   - EngineeringConfiguration
   - Isodraft
   - Draw
   - Paragon
   - Spooler
   - Monitor
3. If no template is specified, displays available templates from the `templates/` folder and prompts the user to select one
4. Validates the customization environment exists
5. Adds the add-in name to the module-specific `*Addins.xml` (e.g., `TagsAddins.xml` for Engineering)
6. If the chosen template contains a `.uic` file, adds a `CustomizationFile` entry to the module-specific `*Customization.xml` (e.g., `TagsCustomization.xml`); otherwise skips customization
7. **Copies the selected template folder** from `templates/[TemplateName]` to `source/[AddinName]`
   - Uses robocopy to avoid locked files
   - **Excludes directories**: bin, obj, .vs, logs, log
   - **Excludes files**: *.user, *.suo, *.rsuser, *.userprefs, *.pdb, *.ipdb, *.iobj, *.obj, *.pch, *.log, *.tlog, *.tmp, *.cache, *.ilk
8. Renames all files and folders containing the template name to the new add-in name
9. Replaces all text occurrences of the template name within the copied folder with the new add-in name

---

### 3. Remove-UEAddin.ps1

**Purpose:** Removes an existing add-in configuration and source code from the customization environment.

**Parameters:**
- `AddinName` (required): Name of the add-in to remove. Must contain only letters A-Z or a-z.
- `Force` (optional): Removes the add-in without prompting for confirmation.

**Validation Rules:**
- `AddinName` must contain only letters A-Z or a-z. No spaces, numbers, or special characters allowed.

**Usage:**

```powershell
# Remove an add-in with confirmation
.\scripts\Remove-UEAddin.ps1 -AddinName "MySecondAddin"

# Remove an add-in without confirmation
.\scripts\Remove-UEAddin.ps1 -AddinName "MySecondAddin" -Force
```

**What it does:**
1. Validates that `AddinName` contains only A-Z/a-z characters
2. Validates the customization environment exists
3. Prompts for confirmation (unless `-Force` is used)
4. Removes the add-in entry from all `*Addins.xml` files under `addins/` (e.g., `DesignAddins.xml`, `TagsAddins.xml`, etc.)
5. Removes the CustomizationFile entry from all `*Customization.xml` files under `addins/` (e.g., `DesignCustomization.xml`, `TagsCustomization.xml`, etc.)
6. Deletes the `.uic` file for the add-in (if present)
7. Deletes the add-in DLL `addins/[AddinName].dll` (if present)
8. **Deletes the add-in source folder** from `source/[AddinName]` and all its contents

---

### 4. Clear-UECustomizationEnvironment.ps1

**Purpose:** Cleans up the customization environment by removing the samples and addins folders and optionally the environment configuration file. The source folder with custom add-in projects is preserved for selective removal.

**Parameters:**
- `Force` (optional): Deletes folders and config without prompting for confirmation.

**Usage:**

```powershell
# Clear with confirmation (prompts for each item)
.\scripts\Clear-UECustomizationEnvironment.ps1

# Clear without confirmation
.\scripts\Clear-UECustomizationEnvironment.ps1 -Force
```

**What it does:**
1. Checks for existing `samples/`, `addins/`, and `environment.json`
2. If no `-Force` flag, prompts for confirmation to delete each item (folder name and path shown)
3. Removes selected items:
   - `samples/` (entire folder - extracted sample code)
   - `addins/` (entire folder - unpacked reference files)
   - `environment.json` (environment configuration)
4. **Preserves the `source/` folder** - Your custom add-in projects are kept intact
5. To remove individual add-ins from the `source/` folder, use **Remove-UEAddin.ps1**
6. Leaves repo structure intact (templates/, scripts/, etc.) for future use

---

### 5. Build-AddIns.ps1

**Purpose:** Builds all `.csproj` files under a specified directory (any folder, not limited to samples or source).

**Parameters:**
- `Directory` (required): Target directory to search recursively for `.csproj` files. Accepts relative paths (from repo root) or absolute paths.
- `Configuration` (optional): Build configuration; defaults to `Debug`.

**Usage:**

```powershell
# Build all sample projects
pwsh -NoProfile -File scripts/Build-AddIns.ps1 -Directory samples

# Build all source projects
pwsh -NoProfile -File scripts/Build-AddIns.ps1 -Directory source

# Build a custom folder with Release configuration
pwsh -NoProfile -File scripts/Build-AddIns.ps1 -Directory C:\Path\To\Projects -Configuration Release
```

**What it does:**
1. Resolves the provided directory (relative to repo root if not absolute).
2. Finds all `.csproj` files recursively beneath that directory.
3. Runs `dotnet build` for each project with the chosen configuration and summarizes any failures.

---

### 6. Start-UE.ps1

**Purpose:** Launches AVEVA Unified Engineering with the customization environment variables restored from the environment configuration file, optionally forwarding UE launch arguments.

**Parameters:**
- `Module` (optional, alias `md`): UE module to run (`--module:<value>`)
- `Project` (optional, aliases `proj`, `p`): Project name (`--project:<value>`)
- `Username` (optional, aliases `user`, `u`): Username (`--username:<value>`)
- `Password` (optional, aliases `pass`, `pw`): Password (`--password:<value>`)
- `Mdb` (optional, alias `m`): MDB name (`--mdb:<value>`)

**Usage:**

```powershell
# Launch UE with restored environment
.\scripts\Start-UE.ps1

# Launch UE with verbose output
.\scripts\Start-UE.ps1 -Verbose

# Launch UE with optional UE arguments forwarded
.\scripts\Start-UE.ps1 -Module Model -Project APS -Username SYSTEM -Password XXXXXX -Mdb ALL
```

**What it does:**
1. Reads the environment configuration from `environment.json`
2. Restores the customization environment variables (CAF_ADDINS_PATH, CAF_UIC_PATH, UNIFIED_ENGINEERING_REFERENCE_PATH, etc.) to both user and session scopes
3. Builds an optional UE argument list from provided parameters and forwards them to the `ue` executable
4. Launches the AVEVA Unified Engineering application
5. Displays warnings if `environment.json` is not found or environment restoration encounters issues

**Requirements:**
- `Setup-UECustomizationEnvironment.ps1` must have been run previously to create `environment.json`
- `UE` command must be available in PATH
- AVEVA Unified Engineering must be installed

---

## Environment Variables

The setup script creates and sets the following environment variables at the User level and applies them to the current session:

- **CAF_ADDINS_PATH**: Points to the addins folder (e.g., `C:\Git\UnifiedEngineeringCustomizationFramework\addins\`)
- **CAF_UIC_PATH**: Points to the addins folder (e.g., `C:\Git\UnifiedEngineeringCustomizationFramework\addins\`)
- **UNIFIED_ENGINEERING_REFERENCE_PATH**: Points to the unpacked UE binaries (e.g., `C:\Users\Public\Documents\AVEVA\Unpack\AVEVA.UnifiedEngineering\4000.2507.304.3703`)

These variables are persisted in the Windows Registry (User level) and restored automatically when `Start-UE.ps1` is run.

## Validation & Error Handling

### AddinName Validation

All scripts that accept an `AddinName` parameter enforce strict validation:
- **Allowed**: A-Z, a-z only (e.g., "MyAddin", "CustomAddIn", "TestAddin")
- **Not allowed**: Numbers, spaces, hyphens, underscores, or special characters
- **Error**: `AddinName must only contain letters A-Z or a-z, with no spaces or special characters.`

### Directory Handling

- `CustomizationRootDir` is always set to the parent directory of the scripts folder (automatic, non-configurable)
- All paths are handled safely; scripts create directories as needed
- Paths with spaces are handled correctly

### File Copy Handling

The `New-UEAddin.ps1` script uses **robocopy** to avoid locked files when copying TemplateAddIn:
- Retries up to 2 times on lock conflicts
- Automatically excludes `.gitignore`-listed artifacts (bin, obj, .vs, temp files)
- Fails gracefully with informative error messages if critical copy failures occur

## Quick Start Guide

### First-time Setup

```powershell
# 1. Navigate to the repository directory
cd C:\Git\UnifiedEngineeringCustomizationFramework

# 2. Run setup to create the environment
.\scripts\Setup-UECustomizationEnvironment.ps1

# 3. Create your first add-in
.\scripts\New-UEAddin.ps1 -AddinName "MyFirstAddin"
```

After setup completes:
- `source\MyFirstAddin\` contains your first add-in's source code
- `addins\MyFirstAddin.uic` contains the UI configuration
- `environment.json` contains your environment configuration
- Environment variables are set globally and will be restored when you run `Start-UE.ps1`

### Add Additional Add-ins

```powershell
# Create more add-ins from the template
.\scripts\New-UEAddin.ps1 -AddinName "MySecondAddin"
.\scripts\New-UEAddin.ps1 -AddinName "MyThirdAddin"

# Each creates:
# - source\[AddinName]\ (complete copy of the selected template with substitutions)
# - addins\[AddinName].uic (UI configuration file)
```

### Build and Test Your Add-in

```powershell
# Build your add-in
.\scripts\Build-AddIns.ps1 -Directory source\MyFirstAddin

# Launch UE with your add-in
.\scripts\Start-UE.ps1
```

### Customizing Your Add-in

Once created, edit your add-in source code:
- Navigate to `source\[AddinName]\`
- All references to the template name have been replaced with your add-in name
- All file/folder names containing the template name have been renamed
- Modify the C# code, projects, and configuration as needed

### Remove an Add-in

```powershell
# Remove a specific add-in (with confirmation)
.\scripts\Remove-UEAddin.ps1 -AddinName "MySecondAddin"

# Remove without confirmation
.\scripts\Remove-UEAddin.ps1 -AddinName "MySecondAddin" -Force
```

### Clean and Re-setup

```powershell
# Clean up all generated content
.\scripts\Clear-UECustomizationEnvironment.ps1 -Force

# Run setup again for a fresh environment
.\scripts\Setup-UECustomizationEnvironment.ps1
```

## Troubleshooting

### "UE command not found"
- Ensure the AVEVA Unified Engineering application is installed
- Add the UE installation directory to your PATH environment variable
- Run the setup script from a PowerShell session that has UE in its PATH

### "Expected unpack base folder not found"
- Run `UE -tool:unpack` manually first to create the unpack directory
- Default unpack location: `C:\Users\Public\Documents\AVEVA\Unpack\AVEVA.UnifiedEngineering`

### "Addins folder not found"
- Ensure `Setup-UECustomizationEnvironment.ps1` has been run successfully
- Check that the scripts are in the `scripts` folder under the customization root

### "AddinName must only contain letters A-Z or a-z"
- Ensure your add-in name contains only letters (no numbers, spaces, or special characters)
- Example: ✓ "MyAddin", ✗ "My-Addin", ✗ "MyAddin2"

### "Robocopy failed with exit code X"
- The source or templates folder may be locked by another process (IDE, file explorer, etc.)
- Close any open IDEs or file explorers accessing these directories
- Try running the script again

### "The process cannot access the file... because it is being used by another process"
- Close Visual Studio, GitHub Desktop, or other applications that may lock files
- Ensure no file explorers are open to the source directory
- Wait a moment and retry

### Permission Denied
- Run PowerShell as Administrator if you encounter permission issues
- Ensure you have write access to the customization directory
- Check that the environment variable `CAF_ADDINS_PATH` is correctly set

## Notes

- All scripts use `[CmdletBinding()]` for advanced function features
- Scripts follow PowerShell best practices from the [PowerShell Practice and Style Guide](https://github.com/PoshCode/PowerShellPracticeAndStyle)
- All function names use approved PowerShell verbs
- Scripts include comprehensive error handling and user feedback
- Changes to XML files are automatically saved

## License

[Add your license information here]

## Author

[Add author information here]

