# AVEVA API Examples

This directory contains example code demonstrating how to use various AVEVA APIs for Unified Engineering customization. These examples are intended as reference material for developers learning to work with the AVEVA database and presentation APIs.

## Overview

The examples are organized by API topic. Each file contains a `Run()` method with working code samples that demonstrate common usage patterns.

## Building

Build the examples using the Build-AddIns script:

```powershell
.\scripts\Build-AddIns.ps1 -Directory "Examples"
```

## Example Files

### [Example.cs](Example.cs)
**Setup and Test Data Creation**

Creates a sample database hierarchy used by all other examples:
- Creates a Site, Zone, Equipment, Pipe, Branch, and various primitives
- Establishes element relationships (nozzles, connections, etc.)
- Provides static references to test elements via `Example.Instance`

### [ExampleAttributes.cs](ExampleAttributes.cs)
**Reading and Writing Attributes**

Demonstrates how to get and set different attribute types:
- **String attributes**: `DESC` (description)
- **Boolean attributes**: `BUIL` (built status)
- **Integer attributes**: `REV` (revision)
- **Double attributes**: `PRES` (pressure)
- **Element references**: `HREF` (head reference)
- **Word attributes**: `LNTP` (line type)
- **Direction attributes**: `HDIR` (head direction)
- **Position attributes**: `POS` (position)
- **Orientation attributes**: `ORI` (orientation)

### [ExampleCE.cs](ExampleCE.cs)
**Current Element Handling**

Shows how to work with the Current Element (CE):
- Subscribe to `CurrentElementChanged` events
- Programmatically change the current element
- Handle CE change notifications

### [ExampleClash.cs](ExampleClash.cs)
**Clash Detection**

Demonstrates the clash detection API:
- Check and build spatial maps for databases
- Configure clash options (touches, clearance)
- Run clash checks using `Clasher.Instance.CheckAll()`
- Inspect clash results (first/second elements, clash type, position)

### [ExampleCollections.cs](ExampleCollections.cs)
**Element Collections and Iteration**

Shows how to create and iterate through element collections:
- Create filtered collections using `TypeFilter`
- Use `DBElementCollection` for scanning hierarchies
- Iterate with `foreach` or `DBElementEnumerator`
- Configure collection options like `IncludeRoot`

### [ExampleCommand.cs](ExampleCommand.cs)
**Application Framework Commands**

Demonstrates creating a list-based command:
- Extend `Aveva.ApplicationFramework.Presentation.Command`
- Populate command list with selectable options
- Execute different examples based on selection

### [ExampleDatabase.cs](ExampleDatabase.cs)
**Database Operations**

Basic database access patterns:
- Get array of databases by type using `MDB.CurrentMDB.GetDBArray()`
- Iterate through design databases
- Access database properties

### [ExampleElement.cs](ExampleElement.cs)
**Element Manipulation**

Comprehensive element operations:
- **Element Types**: Get element type by hash code, retrieve system attributes
- **Creation**: `Create()`, `CreateAfter()`, `CreateFirst()`, `CreateLast()`
- **Copying**: `Copy()`, `CopyHierarchy()` with rename options
- **Navigation**: `FirstMember()`, `Next()`, `Previous`, `Members()`
- **Type-filtered navigation**: `FirstMember(type)`, `Next(type)`, `Members(type)`
- **Expressions**: Parse and evaluate expressions like `"HEIGHT OF PREV * 2"`
- **Rules**: Create, set, get, delete, and verify database rules

### [ExampleEvents.cs](ExampleEvents.cs)
**Database Change Events**

Subscribe to element and attribute change notifications:
- `PostCreateElement` - After element creation
- `PreDeleteElement` - Before element deletion
- `PostMoveElement` - After element moved
- `PostAttributeChange` - After attribute modification
- `PostRefAttributeChange` - After reference attribute change

### [ExampleFilters.cs](ExampleFilters.cs)
**Element Filtering**

Various filter types for element selection:
- `TypeFilter` - Filter by element type
- `AttributeTrueFilter` - Filter by boolean attribute value
- `AndFilter` - Combine multiple filter conditions
- `BelowOrAtType` - Check element type at or below hierarchy
- Filter operations: `FirstMember()`, `Next()`, `Members()`, `Parent()`, `Valid()`

### [ExampleMDB.cs](ExampleMDB.cs)
**Multi-Database (MDB) Operations**

Working with the MDB:
- Get first world element by database type
- Access MDB name and properties
- Save work with comments using `SaveWork()`
- Quit/discard changes using `QuitWork()`
- Close MDB connection

### [ExampleNameTable.cs](ExampleNameTable.cs)
**Name Table Queries**

Search for elements by name pattern:
- Get `NameTable` for a specific database and attribute
- Search with name prefix patterns
- Iterate through matching elements

### [ExampleProject.cs](ExampleProject.cs)
**Project Information**

Access project-level information:
- Get current project name via `Project.CurrentProject.Name`
- Get current user name via `Project.CurrentProject.UserName`
- Get current MDB name via `MDB.CurrentMDB.Name`

### [ExamplePseudoAttribute.cs](ExamplePseudoAttribute.cs)
**Pseudo (User-Defined) Attributes**

Create computed/pseudo attributes:
- Get UDA attribute definition with `DbAttribute.GetDbAttribute(":VOLUME")`
- Create delegate for attribute calculation
- Register delegate with `DbPseudoAttribute.AddGetDoubleAttribute()`
- Return computed values (e.g., volume = XLEN × YLEN × ZLEN)

### [ExampleSpatial.cs](ExampleSpatial.cs)
**Spatial Queries**

Find elements by spatial location:
- Create `LimitsBox` from two positions
- Find elements in box: `Spatial.Instance.ElementsInBox()`
- Find elements in element's bounding box: `ElementsInElementBox()`
- Check if element intersects box: `ElementInBox()`, `ElementInElementBox()`
- Options for partial vs. fully contained elements

### [ExampleTreeNavigator.cs](ExampleTreeNavigator.cs)
**Filtered Tree Navigation**

Navigate element hierarchy with type filters:
- Create `CompoundFilter` with multiple element types
- Use `ElementTreeNavigator` for filtered navigation
- Methods: `FirstMemberInScan()`, `NextInScan()`, `Parent()`, `MembersInScan()`
- Navigate through filtered hierarchy views

### [ExampleUndo.cs](ExampleUndo.cs)
**Undo/Redo Transactions**

Implement undo/redo functionality:
- Create transactions with `UndoTransaction.StartTransaction()`/`EndTransaction()`
- Perform undo: `UndoTransaction.PerformUndo()`
- Perform redo: `UndoTransaction.PerformRedo()`
- Create custom `UndoSubscriber` for non-database state
- Register/unregister subscribers with `UndoCaretaker`

### [ExampleUserChanges.cs](ExampleUserChanges.cs)
**Tracking Database Changes**

Monitor database modifications:
- Subscribe to `DatabaseService.Changes` event
- Access change lists via `DbChangesEventArgs`
- Get specific change types:
  - `GetCreations()` - Newly created elements
  - `GetDeletions()` - Deleted elements
  - `GetMemberChanges()` - Hierarchy changes
  - `GetModified()` - Modified elements

## Key Namespaces

| Namespace | Description |
|-----------|-------------|
| `Aveva.Core.Database` | Core database access, elements, attributes |
| `Aveva.Core.Database.Filters` | Element filtering and queries |
| `Aveva.Core.Geometry` | Positions, directions, orientations |
| `Aveva.Core.Presentation` | Current element, database service |
| `Aveva.Core.Utilities.Messaging` | Messaging utilities |
| `Aveva.Core.Utilities.Undo` | Undo/redo framework |
| `Aveva.Core3D.Clasher` | Clash detection |
| `Aveva.ApplicationFramework.Presentation` | Commands and UI framework |

## Common Patterns

### Getting an Element by Name
```csharp
DbElement element = DbElement.GetElement("/ElementName");
```

### Creating Child Elements
```csharp
DbElement child = parent.Create(0, DbElementTypeInstance.EQUIPMENT);
child.SetAttribute(DbAttributeInstance.NAME, "/NewEquipment");
```

### Iterating with Filters
```csharp
TypeFilter filter = new TypeFilter(DbElementTypeInstance.NOZZLE);
DBElementCollection collection = new DBElementCollection(parent, filter);
foreach (DbElement element in collection)
{
    // Process element
}
```

### Subscribing to Events
```csharp
CurrentElement.CurrentElementChanged += (sender, e) => 
{
    Console.WriteLine("CE changed to: " + e.Element);
};
```
