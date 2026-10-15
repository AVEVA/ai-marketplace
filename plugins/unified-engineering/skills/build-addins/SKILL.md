---
name: build-addins
description: 'Build all AVEVA Unified Engineering add-ins in a specified directory using dotnet build. Supports building all .csproj files recursively with specified configuration (Debug/Release). Reports build status for each project and fails if any build fails.'
license: MIT
argument-hint: 'Directory:Target directory containing csproj files (default: source), Configuration:Build configuration - Debug or Release (default: Debug)'
---

# Build UE Add-Ins

## Overview

Builds all C# add-in projects in a specified directory using `dotnet build`. Recursively finds all `.csproj` files and builds them with the specified configuration.

The [build script](./scripts/Build-AddIns.ps1) path is relative to this SKILL.md
file. Resolve it to an absolute path before invoking it, keeping the working
directory in the user's workspace. Use that resolved path as `$buildScript` in
the examples below.

---

## When to use

Use this skill when:

- Building UE add-ins after code changes
- Compiling all add-ins in the project
- Performing a clean build with a specific configuration
- Validating that all add-ins compile successfully

---

## Parameters

| Parameter     | Required | Default | Description                                                                    |
| ------------- | -------- | ------- | ------------------------------------------------------------------------------ |
| Directory     | No       | "source" | Directory containing add-in projects. Can be absolute or relative path.       |
| Configuration | No       | "Debug"  | Build configuration: "Debug" or "Release"                                     |

---

## Workflow

1. **Load environment**: Restores environment variables from `environment.json`
2. **Find projects**: Recursively searches for `.csproj` files in target directory
3. **Build each project**: Runs `dotnet build` on each project file
4. **Report results**: Shows success or failure for each project
5. **Exit with status**: Returns non-zero exit code if any build fails

---

## Output

- Builds all add-in DLLs to `bin/{Configuration}/` folders within each project
- Displays build summary for each project
- Reports overall build status

---

## Examples

### Build all add-ins in default directory (Debug)
```powershell
& $buildScript
```

### Build all add-ins in Release configuration
```powershell
& $buildScript -Configuration Release
```

### Build add-ins in specific directory
```powershell
& $buildScript -Directory "C:\MyCustomAddins"
```

### Build with both parameters
```powershell
& $buildScript -Directory "source\MyAddins" -Configuration Release
```

---

## Notes

- Requires `Setup-UECustomizationEnvironment.ps1` to have been run first
- Uses environment variables from `environment.json` for assembly references
- Requires .NET SDK to be installed
- Builds all `.csproj` files found recursively under the target directory
- If any project fails to build, the script exits with code 1

---

## Prerequisites

- .NET SDK installed (compatible with target framework)
- Environment set up via `setup-environment` skill
- Valid `.csproj` files in the target directory

---

## Error Handling

The script will:
- Stop on critical errors (missing directory, invalid path)
- Continue building remaining projects if one fails
- Report all failures at the end
- Exit with non-zero code if any builds failed
