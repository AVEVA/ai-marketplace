# UE Customization Templates

This directory contains template projects for creating AVEVA Unified Engineering (UE) add-ins. Each template provides a starting point for a specific type of customization or add-in functionality.

## Available Templates

Current template folders in this repository:

- DockedFormAddInTemplate
- AttributeBrowserAddInTemplate
- WebEndpointAddInTemplate
- WebpageAddInTemplate
- FlexibleExplorerAddInTemplate
- NetGridAddInTemplate
- PMLExtensionTemplate
- PMLGridTemplate
- PMLMLNetPredictTemplate

### DockedFormAddInTemplate

**Purpose:** Base template for creating a docked form AVEVA Unified Engineering add-in with UI customization.

**Description:**  
The DockedFormAddInTemplate is a fully functional add-in template that demonstrates best practices for developing custom add-ins with docked windows. It includes:

- **DockedFormAddInTemplate.cs** - Main add-in class implementing the add-in interface
- **ShowDockedFormAddInTemplateCommand.cs** - Command handler for the add-in button
- **DockedFormAddInTemplateControl.cs** - Windows Forms UserControl for the add-in UI
- **DockedFormAddInTemplateControl.resx** - UI resource file for the control
- **DockedFormAddInTemplate.uic** - User Interface Customization file defining the ribbon and toolbar items
- **DockedFormAddInTemplate.csproj** - C# project file with proper build configuration
- **DockedFormAddInTemplate.sln** - Visual Studio solution file

**Use When:**  
You want to create a standard add-in with a docked window, custom user interface, command handlers, and ribbon/toolbar integration.

**How to Use:**  
Use the `New-UEAddin.ps1` script with your desired add-in name. The script will:
1. Copy this entire template folder to `source/[YourAddinName]/`
2. Rename all files and folders containing "DockedFormAddInTemplate" to your add-in name
3. Replace all text occurrences of "DockedFormAddInTemplate" with your add-in name throughout the project

```powershell
.\scripts\New-UEAddin.ps1 -AddinName "MyCustomAddin" -Template "DockedFormAddInTemplate"
```

### AttributeBrowserAddInTemplate

**Purpose:** Template for creating an attribute browser add-in that displays and manages element attributes in a docked window.

**Description:**  
The AttributeBrowserAddInTemplate provides a complete implementation for browsing element attributes in AVEVA Unified Engineering. It includes:

- **AttributeBrowserAddInTemplate.cs** - Main add-in class with current element tracking
- **ShowAttributeBrowserAddInTemplateCommand.cs** - Command handler for showing/hiding the attribute browser
- **AttributeListControl.cs** - Custom control for displaying attribute lists
- **AttributeListControl.Designer.cs** - Designer-generated code for the control
- **AttributeListControl.resx** - UI resource file for the attribute list control
- **AttributeBrowserAddInTemplate.uic** - User Interface Customization file defining the ribbon button
- **AttributeBrowserAddInTemplate.csproj** - C# project file with proper build configuration
- **AttributeBrowserAddInTemplate.sln** - Visual Studio solution file

**Use When:**  
You need to create an add-in that displays element attributes, responds to current element changes, or provides attribute browsing capabilities.

**How to Use:**  
Use the `New-UEAddin.ps1` script with your desired add-in name. The script will:
1. Copy this entire template folder to `source/[YourAddinName]/`
2. Rename all files and folders containing "AttributeBrowserAddInTemplate" to your add-in name
3. Replace all text occurrences of "AttributeBrowserAddInTemplate" with your add-in name throughout the project

```powershell
.\scripts\New-UEAddin.ps1 -AddinName "MyAttributeBrowser" -Template "AttributeBrowserAddInTemplate"
```

### WebEndpointAddInTemplate

**Purpose:** Template for creating web/API endpoint integration add-ins with JSON data handling and visualization in a docked window.

**Description:**  
The WebEndpointAddInTemplate provides a foundation for building add-ins that integrate with web services, REST APIs, or handle JSON data. It uses AVEVA Connect as the default authentication mechanism for endpoint communication. It includes:

- **WebEndpointAddInTemplate.cs** - Main add-in class implementing the add-in interface
- **ShowWebEndpointAddInTemplateCommand.cs** - Command handler for showing/hiding the docked window
- **WebEndpointAddInTemplateControl.cs** - Windows Forms UserControl with DataGridView for JSON visualization
- **WebEndpointAddInTemplateControl.resx** - UI resource file for the control
- **WebEndpointAddInTemplate.uic** - User Interface Customization file defining the ribbon tab and button
- **WebEndpointAddInTemplate.csproj** - C# project file configured with Newtonsoft.Json reference
- **WebEndpointAddInTemplate.sln** - Visual Studio solution file

**Features:**
- Pre-configured JSON parsing and handling using Newtonsoft.Json
- DataGridView control for displaying hierarchical JSON data
- Example implementation of JSON generation and visualization
- Button-based interaction pattern for triggering data operations

**Use When:**  
You need to create an add-in that:
- Communicates with external web services or REST APIs
- Processes and displays JSON data
- Integrates external data sources into AVEVA Unified Engineering
- Requires structured data visualization in a grid format

**How to Use:**  
Use the `New-UEAddin.ps1` script with your desired add-in name. The script will:
1. Copy this entire template folder to `source/[YourAddinName]/`
2. Rename all files and folders containing "WebEndpointAddInTemplate" to your add-in name
3. Replace all text occurrences of "WebEndpointAddInTemplate" with your add-in name throughout the project

```powershell
.\scripts\New-UEAddin.ps1 -AddinName "MyApiConnector" -Template "WebEndpointAddInTemplate"
```

### WebpageAddInTemplate

**Purpose:** Template for creating web page viewer add-ins with embedded Microsoft Edge WebView2 control for displaying web content in a docked window.

**Description:**  
The WebpageAddInTemplate provides a modern web browser experience within AVEVA Unified Engineering using the Microsoft Edge WebView2 control. It includes:

- **WebpageAddInTemplate.cs** - Main add-in class implementing the add-in interface
- **ShowWebpageAddInTemplateCommand.cs** - Command handler for showing/hiding the web viewer window
- **WebpageAddInTemplateControl.cs** - Windows Forms UserControl with WebView2 browser control
- **WebpageAddInTemplateControl.resx** - UI resource file for the control
- **WebpageAddInTemplate.uic** - User Interface Customization file defining the ribbon button
- **WebpageAddInTemplate.csproj** - C# project file with WebView2 references
- **WebpageAddInTemplate.sln** - Visual Studio solution file

**Features:**
- Pre-configured to load https://www.aveva.com/en/about/news/press-releases/ by default
- URL text box for entering custom web addresses
- "Load" button to navigate to user-specified URLs
- Enter key support in URL box for quick navigation
- Automatic HTTPS protocol addition if not specified
- Modern Microsoft Edge rendering engine (Chromium-based)
- Full modern web standards support (HTML5, CSS3, JavaScript ES6+)
- Loading indicators during page navigation
- Thread-safe UI updates for navigation events

**Use When:**  
You need to create an add-in that:
- Displays web content or documentation within UE
- Integrates web-based tools or dashboards
- Provides access to online resources without leaving the application
- Embeds modern web applications with full browser capabilities
- Requires proper rendering of contemporary websites (unlike the old WebBrowser control)

**How to Use:**  
Use the `New-UEAddin.ps1` script with your desired add-in name. The script will:
1. Copy this entire template folder to `source/[YourAddinName]/`
2. Rename all files and folders containing "WebpageAddInTemplate" to your add-in name
3. Replace all text occurrences of "WebpageAddInTemplate" with your add-in name throughout the project

```powershell
.\scripts\New-UEAddin.ps1 -AddinName "MyWebViewer" -Template "WebpageAddInTemplate"
```

**Requirements:**
- Microsoft Edge WebView2 Runtime (included with AVEVA Unified Engineering installation)
- WebView2 assemblies referenced from UNIFIED_ENGINEERING_REFERENCE_PATH

### FlexibleExplorerAddInTemplate

**Purpose:** Template for building a flexible explorer-style add-in with custom refresh behavior and tree/grid-style navigation UI.

**Description:**  
The FlexibleExplorerAddInTemplate provides a structured starting point for explorer-like add-ins with custom refresh management. It includes:

- **FlexibleExplorerAddInTemplate.cs** - Main add-in class implementing the add-in entry points
- **ShowFlexibleExplorerAddInTemplateCommand.cs** - Command handler for displaying the explorer UI
- **MyFlexibleExplorerControl.cs** - User control that hosts the explorer interface
- **MyFlexibleExplorerControl.resx** - UI resource file for the explorer control
- **MyCustomRefreshManager.cs** - Example refresh manager for controlling explorer updates
- **FlexibleExplorerAddInTemplate.uic** - User Interface Customization file for ribbon/command integration
- **FlexibleExplorerAddInTemplate.xml** - Template XML/configuration metadata used by the explorer pattern
- **FlexibleExplorerAddInTemplate.csproj** - C# project file
- **FlexibleExplorerAddInTemplate.sln** - Visual Studio solution file

**Use When:**  
You need an add-in with an explorer-style UX, custom refresh logic, and structured element/data browsing.

**How to Use:**

```powershell
.\scripts\New-UEAddin.ps1 -AddinName "MyExplorerAddin" -Template "FlexibleExplorerAddInTemplate"
```

### NetGridAddInTemplate

**Purpose:** Template for creating a docked add-in that displays and interacts with data in a .NET grid control.

**Description:**  
The NetGridAddInTemplate provides a ready-to-customize grid-based UI add-in. It includes:

- **NetGridAddInTemplate.cs** - Main add-in class
- **ShowNetGridAddInTemplateCommand.cs** - Command handler for launching the grid panel
- **NetGridAddInTemplateControl.cs** - User control containing grid UI logic
- **NetGridAddInTemplateControl.resx** - UI resource file for the grid control
- **NetGridAddInTemplate.uic** - Ribbon/toolbar UI customization definition
- **NetGridAddInTemplate.csproj** - C# project file
- **NetGridAddInTemplate.sln** - Visual Studio solution file

**Use When:**  
You need tabular data presentation/editing in a docked panel using standard .NET UI components.

**How to Use:**

```powershell
.\scripts\New-UEAddin.ps1 -AddinName "MyGridAddin" -Template "NetGridAddInTemplate"
```

### PMLExtensionTemplate

**Purpose:** Template for creating PML extension logic with C#-backed methods and packaged PML function definitions.

**Description:**  
The PMLExtensionTemplate is focused on extending PML behavior rather than building a docked WinForms UI. It includes:

- **PMLExtensionTemplateMethods.cs** - C# implementation of extension methods exposed to PML
- **PMLExtensionTemplate.pmlfnc** - PML function definition file
- **PMLExtensionTemplate.csproj** - C# project file
- **PMLExtensionTemplate.sln** - Visual Studio solution file

**Use When:**  
You want to add backend/business logic callable from PML scripts without building a full docked form add-in.

**How to Use:**

```powershell
.\scripts\New-UEAddin.ps1 -AddinName "MyPMLExtension" -Template "PMLExtensionTemplate"
```

### PMLGridTemplate

**Purpose:** Template for defining a PML-based grid/form UI structure.

**Description:**  
The PMLGridTemplate is a lightweight template that currently contains core PML grid/form assets:

- **PMLGridTemplate.pmlfrm** - PML form/grid definition
- **PMLGridTemplate.csproj** - Project file for packaging/build integration

**Use When:**  
You need a simple starting point for PML form/grid development and plan to build out UI behavior in PML.

**How to Use:**

```powershell
.\scripts\New-UEAddin.ps1 -AddinName "MyPMLGrid" -Template "PMLGridTemplate"
```

**Note:** This template is intentionally minimal compared with docked-form templates.

### PMLMLNetPredictTemplate

**Purpose:** Template for creating ML.NET-based prediction functions callable from PML scripts.

**Description:**  
The PMLMLNetPredictTemplate provides a foundation for integrating machine learning predictions into AVEVA Unified Engineering using ML.NET. It includes:

- **PMLMLNetPredictTemplateMethods.cs** - C# implementation of ML.NET prediction logic
- **PMLMLNetPredictTemplate.pmlfnc** - PML function definition file for invoking predictions
- **PMLMLNetPredictTemplate.csproj** - C# project file with ML.NET package references

**Use When:**  
You need to integrate trained machine learning models into PML workflows, enabling data-driven predictions and intelligent automation within AVEVA Unified Engineering.

**How to Use:**

```powershell
.\scripts\New-UEAddin.ps1 -AddinName "MyMLPrediction" -Template "PMLMLNetPredictTemplate"
```

**Note:** This template requires ML.NET packages and a trained model file for full functionality.

## Adding New Templates

To add a new template to this directory:

1. **Create a new folder** in `templates/` following the naming convention: `[Functionality]AddInTemplate` (e.g., `ReportExtensionAddInTemplate`, `DataHandlerAddInTemplate`)
2. **Implement the template** with all necessary source files for your specific use case
3. **Document the template** by adding a new section to this README with:
   - Purpose
   - Description of included files
   - Use cases
   - How to use it with the scripting framework
4. **Update the New-UEAddin script** if needed to support multiple template types

## Template Naming Convention

For consistency, template folder names should follow the pattern:
- **Format**: `[FunctionalityName]AddInTemplate`
- Use PascalCase for the functionality name
- Always end with `AddInTemplate`

Examples:
- `ReportExtensionAddInTemplate` - For add-ins that extend reporting functionality
- `DataHandlerAddInTemplate` - For add-ins that handle data processing
- `PropertyEditorAddInTemplate` - For add-ins that edit object properties
- `CustomToolAddInTemplate` - For add-ins that add custom tools

**Note:** Some templates in this repository are specialized (for example `PMLExtensionTemplate` and `PMLGridTemplate`) and intentionally do not end with `AddInTemplate`.

## Best Practices

When creating a new template:
- Include a `.sln` (Solution) and `.csproj` (Project) file for Visual Studio compatibility
- Include all necessary `.uic` (User Interface Customization) files
- Provide placeholder implementations with comments explaining key extension points
- Use naming conventions consistent with existing templates in this repository
- Exclude build artifacts (bin/, obj/, .vs/ folders) before committing
- Include XML documentation comments for public classes and methods
