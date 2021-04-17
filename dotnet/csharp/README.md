# .NET C#

Playground for .NET C# (.NET 5.0 and higher)

## CLI

```bash
# Utility
dotnet --version # should be higher than 5.0.201

# Create new project
dotnet new # shows all templates -> search online, they can be installed :)

# Create console project
dotnet new console -o ConsoleApplication 
  # with -o we can specify output location - otherwise it is current directory
  # always use maximum one project per directory!

# Run
dotnet run --project ConsoleApplication/ConsoleApplication.csproj 
  # without --project dotnet runs the project in current directory.
  # should output "Hello World!".
```

## Language

### Properties

See PropertiesExamples

### Async/Await
### Delegates
### Annotations
### Extension Methods
### Threading 
### Socket / Communication
