---
title: BoxLang Core Guidelines
description: BoxLang modern JVM language syntax, class structure, data types, collections, interoperability, and best practices
---

# BoxLang Core Guidelines

## Overview

BoxLang is a modern, dynamic JVM language that compiles to Java bytecode. It combines features from Java, CFML, Python, Ruby, Go, and PHP into a clean, expressive syntax optimized for the JVM.

## Key Features

- **Modern class syntax** - Uses `class` instead of `component`
- **Dynamic typing** - Optional type declarations with type inference
- **Full Java interoperability** - Direct access to Java libraries and classes
- **Closure expressions** - Arrow function syntax `() => result` carries the external state of its definition context
- **Lambda expressions** - Arrow function syntax `() -> result` carries no external state, using only its parameters
- **Streams API** - Functional data processing
- **Low verbosity** - Minimal ceremony, highly readable code
- **Multiple runtimes** - Web servers, CLI, AWS Lambda, Docker, and more

## Class Syntax

### Basic Class Structure

Annotations are supported in Boxlang using the `@` symbol. The `@inject` annotation is used for dependency injection by a framework. The annotation can be applied to classes, properties and functions.  They can have no value, or the value within `( )` can be a boolean, integer, string, array or struct.

```boxlang
@singleton
@anotherAnnotation( true )
@anotherOne( "value" )
@arrayAnnotation( [ "item1", "item2" ] )
@structAnnotation( { key: "value" } )
class{
	@inject
    property name="userDAO";

	@inject( "logbox:logger:{this}" )
    property name="log";

    function getAll() {
        return userDAO.findAll()
    }

    function create( required struct data ) {
        log.info( "Creating user: #data.email#" )
        return userDAO.create( data )
    }

    function getById( required numeric id ) {
        return userDAO.find( id )
    }
}
```

### Properties

```boxlang
// Auto-inject by name
@inject
property name="userService";

// Explicit injection
@inject( "cachebox:default" )
property name="cache";

// Typed properties
property name="count" type="numeric";
property name="active" type="boolean";

// Property with default value
property name="status" type="string" default="pending";
```

### Constructors

```boxlang
class {
    property name="firstName";
    property name="lastName";

    // Constructor (optional - auto-generated if not provided)
    function init( required string firstName, required string lastName ) {
        variables.firstName = arguments.firstName
        variables.lastName = arguments.lastName
        return this
    }

    function getFullName() {
        return "#firstName# #lastName#"
    }
}
```

### Accessors

Automatic getters and setters are supported by default. You can enable or disable them at the class level with the `@accessors` annotation, but they are on by default for all properties. You can also define custom getters and setters if you need custom logic.

Implicit invokers are also on by default, allowing you to call getters and setters as if they were properties or functions without the `get`/`set` prefix.

```boxlang
class {
    property name="firstName";
    property name="lastName";
    property name="email";
}

// Usage
user = new User()
// Use setters and getters
user.setFirstName( "Luis" )
user.setLastName( "Majano" )
var name = user.getFirstName()
// Use implicit invokers
user.firstName = "Luis"
user.lastName = "Majano"
var name = user.firstName
```

## Lambda Expressions

### Arrow Functions

```boxlang
// Single expression (implicit return)
var double = ( n ) => n * 2

// Multiple arguments
var add = ( a, b ) => a + b

// Block body (explicit return)
var calculate = ( x, y ) => {
    var result = x * y
    return result + 10
}

// No arguments
var now = () => now()
```

### Array Operations

```boxlang
var numbers = [ 1, 2, 3, 4, 5 ]

// Map
var doubled = numbers.map( ( n ) => n * 2 )

// Filter
var evens = numbers.filter( ( n ) => n % 2 == 0 )

// Reduce
var sum = numbers.reduce( ( acc, n ) => acc + n, 0 )

// Sort
var sorted = numbers.sort( ( a, b ) => b - a )
```

### Struct Operations

```boxlang
var users = [
    { name: "Luis", age: 40 },
    { name: "Brad", age: 35 },
    { name: "Jon", age: 38 }
]

// Filter adult users
var adults = users.filter( ( user ) => user.age >= 18 )

// Get names only
var names = users.map( ( user ) => user.name )

// Find specific user
var luis = users.find( ( user ) => user.name == "Luis" )
```

## Streams API

```boxlang
// Chain operations efficiently
var result = userService.getAll()
    .stream()
    .filter( ( user ) => user.active )
    .map( ( user ) => user.email )
    .sorted()
    .collect()

// Complex transformations
var summary = orders
    .stream()
    .filter( ( order ) => order.status == "completed" )
    .map( ( order ) => order.total )
    .reduce( 0, ( sum, total ) => sum + total )
```

## Java Interoperability

### Creating Java Objects

```boxlang
// Using createObject
var stringBuffer = createObject( "java", "java.lang.StringBuffer" )
stringBuffer.append( "Hello" )
stringBuffer.append( " World" )
var result = stringBuffer.toString()

// Using new operator
var uuid = new java:java.util.UUID.randomUUID()
var dateFormatter = new java:java.text.SimpleDateFormat( "yyyy-MM-dd" )

// Importing Java classes
import java.util.ArrayList
var list = new ArrayList()
list.add( "item1" )
list.add( "item2" )
```

### Java Casting

```boxlang
// Cast to Java types
var intValue = javaCast( "int", 42 )
var longValue = javaCast( "long", 1000000 )
var boolValue = javaCast( "boolean", true )

// Use the castAs is prefferred.
var intValue = 42 castAs int
var longValue = 1000000 castAs long
var boolValue = true castAs boolean

// Array casting
var javaArray = [ 1, 2, 3 ] castAs java.lang.Object[]
```

### Using Java Libraries

```boxlang
// Import Java classes
import java:java.util.ArrayList
import java:java.util.HashMap

class DataProcessor {
    function processData() {
        var list = new ArrayList()
        list.add( "item1" )
        list.add( "item2" )

        var map = new HashMap()
        map.put( "key", "value" )

        return { list: list, map: map }
    }
}
```

## Type System

### Optional Typing

```boxlang
// Untyped (dynamic)
function calculate( a, b ) {
    return a + b
}

// Typed
function calculate( numeric a, numeric b ) {
    return a + b
}

// Return type
function string getFullName( required string first, required string last ) {
    return "#first# #last#"
}
```

### Type Inference

```boxlang
// BoxLang infers types
var count = 10           // numeric
var name = "Luis"        // string
var active = true        // boolean
var created = now()      // date
var items = []           // array
var user = {}            // struct
```

## Control Structures

```boxlang
// If/else
if ( user.active ) {
    sendEmail( user.email )
} else {
    log.warn( "Inactive user: #user.id#" )
}

// Ternary
var status = user.active ? "active" : "inactive"

// Elvis (null coalescing)
var name = user.name ?: "Unknown"

// Switch
switch ( status ) {
    case "pending":
        processPending()
        break
    case "approved":
        processApproved()
        break
    default:
        handleUnknown()
}

// Loops
for ( var i = 1; i <= 10; i++ ) {
    print( i )
}

for ( var user in users ) {
    print( user.name )
}

users.each( ( user ) => {
    print( user.name )
} )
```

## Exception Handling

```boxlang
try {
    var user = userService.getById( id )
    processUser( user )
} catch ( EntityNotFound e ) {
    log.error( "User not found: #id#", e )
    return { error: true, message: "User not found" }
} catch ( any e ) {
    log.fatal( "Unexpected error", e )
    rethrow
} finally {
    cleanup()
}
```

## Best Practices

- Use **arrow functions** for concise operations
- Leverage **streams** for efficient data processing
- Utilize **type hints** for better IDE support and documentation
- Take advantage of **Java interoperability** for performance-critical code
- Use **property injection** for dependency management
- Write **pure functions** when possible (no side effects)
- Prefer **immutability** for safer concurrent code

## Documentation

For complete BoxLang documentation, advanced features, and Java integration, consult the BoxLang MCP server or visit:
https://boxlang.ortusbooks.com

---

> **Implementation patterns are in skills.** Load the relevant skill with `read_file` when implementing:
> - Classes & OOP: `.ai/skills/boxlang-classes-and-oop/SKILL.md`
> - Functional programming & lambdas: `.ai/skills/boxlang-functional-programming/SKILL.md`
> - ColdBox handler patterns: `.ai/skills/coldbox-handler-development/SKILL.md`
> - Testing: `.ai/skills/boxlang-testing/SKILL.md`