---
name: ue-examples
description: 'Interactive guide to AVEVA Unified Engineering C# code examples. Use when user asks "show me how to...", "example of...", "how do I create/work with [elements/attributes/events/etc]", or needs UE API usage patterns. Provides relevant code snippets from example files covering database operations, elements, attributes, commands, events, spatial operations, clash detection, tree navigation, filters, collections, undo, and user changes.'
license: MIT
argument-hint: 'Describe what you want to learn (e.g., "create elements", "handle events", "work with attributes")'
---

# AVEVA UE Add-In Code Examples

## Overview

This skill provides interactive access to a comprehensive collection of C# code examples demonstrating AVEVA Unified Engineering add-in development patterns.

When you ask for examples or guidance on UE API usage, I'll read the relevant example files and show you the applicable code with explanations.

---

## How to Use This Skill

Simply ask me questions like:
- "Show me how to create elements in UE"
- "How do I work with attributes?"
- "Give me an example of handling events"
- "How do I query the database?"
- "Show me clash detection examples"

I'll automatically find and present the relevant code from the example files.

---

## Agent Workflow

When a user asks for an example or guidance:

### 1. Parse the user's request

Identify keywords and map to example topics:
- **Elements/primitives/objects/EQUI/ZONE** → ExampleElement.cs
- **Attributes/properties/read attribute/write attribute** → ExampleAttributes.cs, ExamplePseudoAttribute.cs
- **Commands/actions/execute command** → ExampleCommand.cs
- **Events/event handlers/subscriptions/notifications** → ExampleEvents.cs
- **Database/DB queries/CurrentElement/DbElement** → ExampleDatabase.cs
- **MDB/Multi-Disciplinary Database** → ExampleMDB.cs
- **Name table/naming/NAMD** → ExampleNameTable.cs
- **CE/Catalogue Entry/catalog** → ExampleCE.cs
- **Clash/clash detection/interference** → ExampleClash.cs
- **Collections/lists/DbElementCollection** → ExampleCollections.cs
- **Spatial/3D/geometry/position/orientation** → ExampleSpatial.cs
- **Tree/hierarchy/navigation/parent/child** → ExampleTreeNavigator.cs
- **Undo/redo/transactions** → ExampleUndo.cs
- **User changes/tracking changes/modifications** → ExampleUserChanges.cs
- **Filters/DbAttributeFilter** → ExampleFilters.cs
- **Assembly/metadata/project setup** → AssemblyInfo.cs, Example.cs
- **Project structure/build/dependencies** → Examples.csproj, README.md

### 2. Read the relevant example file(s)

Example files are located at:
```
plugins/unified-engineering/skills/examples/Examples/{filename}
```

Read the complete file to understand the full context, then extract the most relevant portions.

### 3. Present the code

- Show relevant code snippets (methods, classes, or key sections)
- Provide brief explanations of what the code does
- Highlight important API patterns or best practices
- If multiple examples are relevant, show snippets from each
- Keep explanations concise but informative

### 4. Offer to show more

After presenting code, offer to:
- Show additional examples from the same or related files
- Explain specific parts in more detail
- Show how to adapt the example to their use case
- Open the full example file if they want to see everything

---

## Example File Reference

### Core Patterns
- **Example.cs** - Basic add-in structure, initialization, DbElement fundamentals
- **AssemblyInfo.cs** - Assembly metadata and versioning

### Element & Database Operations
- **ExampleElement.cs** - Creating, modifying, querying elements; working with DbElement
- **ExampleDatabase.cs** - Database operations, queries, navigation, CurrentElement
- **ExampleMDB.cs** - Multi-Disciplinary Database operations
- **ExampleNameTable.cs** - Name table operations (NAMD)

### Attributes & Properties  
- **ExampleAttributes.cs** - Reading/writing attributes, system attributes
- **ExamplePseudoAttribute.cs** - Working with pseudo attributes

### Commands & Events
- **ExampleCommand.cs** - Creating custom commands, command handlers
- **ExampleEvents.cs** - Event handling, subscriptions, notifications

### Advanced Features
- **ExampleCE.cs** - Catalogue Entry (CE) operations
- **ExampleClash.cs** - Clash detection and analysis
- **ExampleCollections.cs** - Working with DbElementCollection and other collections
- **ExampleFilters.cs** - Creating and using DbAttributeFilter
- **ExampleSpatial.cs** - Spatial queries, 3D operations, geometry
- **ExampleTreeNavigator.cs** - Hierarchy navigation, parent/child relationships
- **ExampleUndo.cs** - Undo/redo operations, transactions
- **ExampleUserChanges.cs** - Tracking user modifications

### Project Files
- **Examples.csproj** - Project configuration, dependencies, build settings
- **Examples.sln** - Visual Studio solution
- **README.md** - Example documentation

---

## Usage Examples for Users

**Example 1: Creating Elements**
```
User: "Show me how to create elements in UE"
Agent: [Reads ExampleElement.cs, shows CreateAfter/CreateLast methods with explanations]
```

**Example 2: Event Handling**  
```
User: "How do I handle events?"
Agent: [Reads ExampleEvents.cs, shows event subscription and handler patterns]
```

**Example 3: Database Queries**
```
User: "Give me examples of database queries"
Agent: [Reads ExampleDatabase.cs, shows query methods and CurrentElement usage]
```

---

## Common Usage Patterns

### Event Handling


### Quick API Reference

When showing code examples, highlight these common patterns:

**Creating Elements:**
```csharp
// Create element after another
DbElement newElement = existingElement.CreateAfter(DbElementTypeInstance.EQUIPMENT);

// Create element at end of collection
DbElement lastElement = container.CreateLast(DbElementTypeInstance.ZONE);
```

**Reading Attributes:**
```csharp
// Get attribute value
DbAttribute attr = element.GetAttribute(DbAttributeInstance.NAME);
string name = attr.GetString();

// Check if attribute exists
if (element.HasAttribute(DbAttributeInstance.DESCRIPTION)) {
    // Process attribute
}
```

**Querying Database:**
```csharp
// Get element by path
DbElement element = DbElement.GetElement("/SITE/ZONE1");

// Iterate children
foreach (DbElement child in element.Members()) {
    // Process child
}
```

**Event Handling:**
```csharp
// Subscribe to events
EventManager.EventNotification += OnEvent;

// Handle event
private void OnEvent(object sender, EventNotificationArgs e) {
    // Process event
}
```

---

## Presentation Guidelines for Agent

When presenting code examples:

1. **Show context**: Include enough code to understand the pattern
2. **Explain key concepts**: Don't just dump code - explain what it does
3. **Highlight API usage**: Point out important UE API calls and patterns
4. **Keep it relevant**: Focus on code that answers the user's specific question
5. **Offer drill-down**: Ask if they want to see more details or related examples

**Good Example Response:**
```
To create elements in AVEVA UE, you use the CreateAfter() or CreateLast() methods on existing elements.

Here's an example from ExampleElement.cs:

[Show 10-20 lines of relevant code]

This code shows:
- Getting an existing element by path
- Creating a new EQUIPMENT element after it
- Setting attributes on the new element

Would you like to see more examples of element creation, or learn about setting attributes on elements?
```

---

## Common Topics and File Mapping

Use this mapping to quickly find relevant examples:

| User asks about... | Read this file |
|-------------------|----------------|
| "create elements" | ExampleElement.cs |
| "read/write attributes" | ExampleAttributes.cs |
| "handle events" | ExampleEvents.cs |
| "database queries" | ExampleDatabase.cs |
| "commands" | ExampleCommand.cs |
| "clash detection" | ExampleClash.cs |
| "3D/spatial/geometry" | ExampleSpatial.cs |
| "hierarchy/tree" | ExampleTreeNavigator.cs |
| "undo/redo" | ExampleUndo.cs |
| "filters" | ExampleFilters.cs |
| "collections" | ExampleCollections.cs |
| "catalogue/CE" | ExampleCE.cs |
| "MDB" | ExampleMDB.cs |
| "name table" | ExampleNameTable.cs |
| "project setup" | Examples.csproj, Example.cs |

---

## Error Handling

If an example file cannot be found or read:
1. List the available example topics (see table above)
2. Ask the user to rephrase their request
3. Suggest the closest matching topic

---

## Best Practices to Highlight

When showing examples, mention these UE API best practices where applicable:

- **Dispose properly**: UE objects should be disposed when done
- **Check null**: Always verify elements exist before using them
- **Use transactions**: Wrap multiple modifications in transactions for undo support
- **Handle events carefully**: Unsubscribe from events to avoid memory leaks
- **Query efficiently**: Use filters instead of iterating all elements when possible
- **Test in UE**: Examples should be tested in actual UE environment

---

## Integration Notes

Users can integrate these examples into their add-ins created via the `create-addin` skill:

1. Create an add-in using one of the templates
2. Copy relevant code from examples
3. Add necessary `using` statements
4. Reference required assemblies (check Examples.csproj for dependencies)
5. Build and test in UE

---

## Further Resources

- **AVEVA UE API Documentation**: Official API reference
- **create-addin skill**: Create new add-ins from templates
- **build-addins skill**: Build add-in projects
- **Examples README**: `plugins/unified-engineering/skills/examples/Examples/README.md`
