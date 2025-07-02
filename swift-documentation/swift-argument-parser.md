TITLE: Add Swift ArgumentParser Dependency to Package.swift
DESCRIPTION: This snippet shows how to configure your Swift package to include `swift-argument-parser` as a dependency. It specifies the GitHub repository URL and version, and then adds `ArgumentParser` as a product dependency for your executable target.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/GettingStarted.md#_snippet_0

LANGUAGE: Swift
CODE:
```
// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "Count",
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0")
    ],
    targets: [
        .executableTarget(
            name: "count",
            dependencies: [.product(name: "ArgumentParser", package: "swift-argument-parser")]),
    ]
)
```

----------------------------------------

TITLE: Define Command-Line Tool with Swift Argument Parser
DESCRIPTION: This Swift code demonstrates how to create a command-line tool using `ArgumentParser`. It defines a `Repeat` command with flags, options, and arguments using property wrappers like `@Flag`, `@Option`, and `@Argument`. The `run()` method contains the core logic for repeating a phrase.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/README.md#_snippet_0

LANGUAGE: swift
CODE:
```
import ArgumentParser

@main
struct Repeat: ParsableCommand {
    @Flag(help: "Include a counter with each repetition.")
    var includeCounter = false

    @Option(name: .shortAndLong, help: "The number of times to repeat 'phrase'.")
    var count: Int? = nil

    @Argument(help: "The phrase to repeat.")
    var phrase: String

    mutating func run() throws {
        let repeatCount = count ?? 2

        for i in 1...repeatCount {
            if includeCounter {
                print("\(i): \(phrase)")
            } else {
                print(phrase)
            }
        }
    }
}
```

----------------------------------------

TITLE: Add Swift ArgumentParser to SwiftPM Package.swift
DESCRIPTION: This Swift code snippet demonstrates how to configure your `Package.swift` file to include the `swift-argument-parser` library as a dependency. It specifies the package URL and version range, and then adds `ArgumentParser` as a product dependency to an executable target, enabling its use in your command-line tool.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/README.md#_snippet_2

LANGUAGE: Swift
CODE:
```
let package = Package(
    // name, platforms, products, etc.
    dependencies: [
        // other dependencies
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0")
    ],
    targets: [
        .executableTarget(name: "<command-line-tool>", dependencies: [
            // other dependencies
            .product(name: "ArgumentParser", package: "swift-argument-parser")
        ]),
        // other targets
    ]
)
```

----------------------------------------

TITLE: Implement a Complete Command-Line Word Counter in Swift
DESCRIPTION: This snippet demonstrates a full ParsableCommand implementation for a word counting utility. It shows how to define options and flags, read from an input file, process text (trimming, lowercasing, counting words), and write results to an output file. It also includes a custom RuntimeError struct for error handling.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/GettingStarted.md#_snippet_8

LANGUAGE: Swift
CODE:
```
import ArgumentParser
import Foundation

@main
struct Count: ParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Word counter.")

    @Option(name: [.short, .customLong("input")], help: "A file to read.")
    var inputFile: String

    @Option(name: [.short, .customLong("output")], help: "A file to save word counts to.")
    var outputFile: String

    @Flag(name: .shortAndLong, help: "Print status updates while counting.")
    var verbose = false

    mutating func run() throws {
        if verbose {
            print("""
                Counting words in '\(inputFile)' \
                and writing the result into '\(outputFile)'.
                """)
        }

        guard let input = try? String(contentsOfFile: inputFile) else {
            throw RuntimeError("Couldn't read from '\(inputFile)'!")
        }

        let words = input.components(separatedBy: .whitespacesAndNewlines)
            .map { word in
                word.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
                    .lowercased()
            }
            .compactMap { word in word.isEmpty ? nil : word }

        let counts = Dictionary(grouping: words, by: { $0 })
            .mapValues { $0.count }
            .sorted(by: { $0.value > $1.value })

        if verbose {
            print("Found \(counts.count) words.")
        }

        let output = counts.map { word, count in "\(word): \(count)" }
            .joined(separator: "\n")

        guard let _ = try? output.write(toFile: outputFile, atomically: true, encoding: .utf8) else {
            throw RuntimeError("Couldn't write to '\(outputFile)'!")
        }
    }
}

struct RuntimeError: Error, CustomStringConvertible {
    var description: String

    init(_ description: String) {
        self.description = description
    }
}
```

----------------------------------------

TITLE: Swift struct with Argument, Option, and Flag declarations
DESCRIPTION: Defines a `ParsableCommand` struct demonstrating the use of `@Argument`, `@Option`, and `@Flag` property wrappers with default values. Shows how `ArgumentParser` derives names and requirements from property types and defaults.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/DeclaringArguments.md#_snippet_1

LANGUAGE: swift
CODE:
```
struct Example: ParsableCommand {
    @Argument var files: [String] = []
    @Option var count: Int?
    @Option var index = 0
    @Flag var verbose = false
    @Flag var stripWhitespace = false
}
```

----------------------------------------

TITLE: Implementing `Add` and `Multiply` Subcommands
DESCRIPTION: This Swift code defines the `Add` and `Multiply` subcommands within the `Math` extension. Both subcommands use the `@OptionGroup` property wrapper to incorporate the shared `Options` arguments. They implement the `run()` method to perform their respective calculations and print formatted results, with `Multiply` also demonstrating the use of `aliases`.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/CommandsAndSubcommands.md#_snippet_4

LANGUAGE: swift
CODE:
```
extension Math {
    struct Add: ParsableCommand {
        static let configuration
            = CommandConfiguration(abstract: "Print the sum of the values.")

        @OptionGroup var options: Math.Options

        mutating func run() {
            let result = options.values.reduce(0, +)
            print(format(result: result, usingHex: options.hexadecimalOutput))
        }
    }

    struct Multiply: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Print the product of the values.",
            aliases: ["mul"])

        @OptionGroup var options: Math.Options

        mutating func run() {
            let result = options.values.reduce(1, *)
            print(format(result: result, usingHex: options.hexadecimalOutput))
        }
    }
}
```

----------------------------------------

TITLE: Implement Asynchronous Command with AsyncParsableCommand in Swift
DESCRIPTION: This snippet illustrates how to use AsyncParsableCommand to create command-line tools that leverage Swift's concurrency features. It demonstrates an async run function that reads a file line by line asynchronously using FileHandle.bytes.lines. It also highlights the importance of using AsyncParsableCommand when run is async.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/GettingStarted.md#_snippet_9

LANGUAGE: Swift
CODE:
```
@main
struct FileUtility: AsyncParsableCommand {
    @Argument(
        help: "File to be parsed.",
        transform: URL.init(fileURLWithPath:)
    )
    var file: URL

    mutating func run() async throws {
        let handle = try FileHandle(forReadingFrom: file)

        for try await line in handle.bytes.lines {
            // do something with each line
        }

        try handle.close()
    }
}
```

----------------------------------------

TITLE: Define Custom Error and Data Model for Argument Parsing
DESCRIPTION: This Swift code defines a custom error type `ExampleTransformError` and a `Codable` data model `ExampleDataModel`. It then shows how to use these with `ArgumentParser`'s `@Argument` and `@Option` properties, applying transform closures that can throw errors during parsing. The `dataModel` static method handles JSON decoding, throwing `ValidationError` for malformed input, while the `failOption` demonstrates throwing a custom error.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/Validation.md#_snippet_8

LANGUAGE: swift
CODE:
```
struct ExampleTransformError: Error, CustomStringConvertible {
  var description: String
}

struct ExampleDataModel: Codable {
  let identifier: UUID
  let tokens: [String]
  let tokenCount: Int

  static func dataModel(_ jsonString: String) throws -> ExampleDataModel  {
    guard let data = jsonString.data(using: .utf8) else { throw ValidationError("Badly encoded string, should be UTF-8") }
    return try JSONDecoder().decode(ExampleDataModel.self, from: data)
  }
}

struct Example: ParsableCommand {
  // Reads in the argument string and attempts to transform it to
  // an `ExampleDataModel` object using the `JSONDecoder`. If the
  // string is not valid JSON, `decode` will throw an error and
  // parsing will halt.
  @Argument(transform: ExampleDataModel.dataModel)
  var inputJSON: ExampleDataModel

  // Specifiying this option will always cause the parser to exit
  // and print the custom error.
  @Option(transform: { throw ExampleTransformError(description: "Trying to write to failOption always produces an error. Input: \($0)") })
  var failOption: String?
}
```

----------------------------------------

TITLE: Define Swift Command with Positional Arguments using ParsableCommand
DESCRIPTION: This Swift code defines the initial structure of the `Count` command, conforming to `ParsableCommand`. It uses the `@Argument` property wrapper to declare `inputFile` and `outputFile` as positional command-line inputs, and implements the `run()` method for command logic.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/GettingStarted.md#_snippet_2

LANGUAGE: Swift
CODE:
```
import ArgumentParser

@main
struct Count: ParsableCommand {
    @Argument var inputFile: String
    @Argument var outputFile: String

    mutating func run() throws {
        print("""
            Counting words in '\(inputFile)' \
            and writing the result into '\(outputFile)'.
            """)

        // Read 'inputFile', count the words, and save to 'outputFile'.
    }
}
```

----------------------------------------

TITLE: Generating Automatic Help Text for Swift Command-Line Tools
DESCRIPTION: Illustrates how Swift Argument Parser automatically generates help messages and how to add descriptive text to options and flags using the `help` parameter. It shows the command-line output of the help screen before and after adding descriptions.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/GettingStarted.md#_snippet_7

LANGUAGE: Shell
CODE:
```
% count --help
USAGE: count --input <input> --output <output> [--verbose]

OPTIONS:
  -i, --input <input>
  -o, --output <output>
  -v, --verbose
  -h, --help              Show help information.
```

LANGUAGE: Swift
CODE:
```
@main
struct Count: ParsableCommand {
    @Option(name: [.short, .customLong("input")], help: "A file to read.")
    var inputFile: String

    @Option(name: [.short, .customLong("output")], help: "A file to save word counts to.")
    var outputFile: String

    @Flag(name: .shortAndLong, help: "Print status updates while counting.")
    var verbose = false

    mutating func run() throws { ... }
}
```

LANGUAGE: Shell
CODE:
```
% count -h
USAGE: count --input <input> --output <output> [--verbose]

OPTIONS:
  -i, --input <input>     A file to read.
  -o, --output <output>   A file to save word counts to.
  -v, --verbose           Print status updates while counting.
  -h, --help              Show help information.
```

----------------------------------------

TITLE: Command-line examples for Arguments, Options, and Flags
DESCRIPTION: Illustrates how command-line arguments, options, and flags are typically invoked by users.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/DeclaringArguments.md#_snippet_0

LANGUAGE: bash
CODE:
```
% example file1.swift file2.swift file3.swift
% example --count=5 --index 2
% example --verbose --strip-whitespace
```

----------------------------------------

TITLE: Demonstrate Swift Argument Parser Command-Line Interaction
DESCRIPTION: This snippet shows command-line interactions with a tool built using Swift Argument Parser. It illustrates successful execution with arguments, an error message for a missing required argument, and the automatically generated help output, highlighting the library's robust error handling and user guidance.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/README.md#_snippet_1

LANGUAGE: bash
CODE:
```
$ repeat hello --count 3
hello
hello
hello
$ repeat --count 3
Error: Missing expected argument 'phrase'.
Help:  <phrase>  The phrase to repeat.
Usage: repeat [--count <count>] [--include-counter] <phrase>
  See 'repeat --help' for more information.
$ repeat --help
USAGE: repeat [--count <count>] [--include-counter] <phrase>

ARGUMENTS:
  <phrase>                The phrase to repeat.

OPTIONS:
  --include-counter       Include a counter with each repetition.
  -c, --count <count>     The number of times to repeat 'phrase'.
  -h, --help              Show help for this command.
```

----------------------------------------

TITLE: Implement Boolean Flags with Inversions
DESCRIPTION: Demonstrates how to generate `true`/`false` flag pairs for `Bool` properties using flag inversions like `.prefixedNo` or `.prefixedEnableDisable`. It also explains how to set default values or require the user to specify one of the inversions.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/DeclaringArguments.md#_snippet_11

LANGUAGE: Swift
CODE:
```
struct Example: ParsableCommand {
    @Flag(inversion: .prefixedNo)
    var index = true

    @Flag(inversion: .prefixedEnableDisable)
    var requiredElement: Bool

    mutating func run() throws {
        print(index, requiredElement)
    }
}
```

----------------------------------------

TITLE: Define Average and StandardDeviation Subcommands in Swift
DESCRIPTION: This Swift code defines two subcommands, `Average` and `StandardDeviation`, for a command-line tool. The `Average` subcommand calculates mean, median, or mode based on user input, while `StandardDeviation` computes the standard deviation of provided values. Both demonstrate how to configure independent subcommands with specific arguments and aliases using `swift-argument-parser`.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/CommandsAndSubcommands.md#_snippet_7

LANGUAGE: swift
CODE:
```
extension Math.Statistics {
    struct Average: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Print the average of the values.",
            aliases: ["avg"])

        enum Kind: String, ExpressibleByArgument {
            case mean, median, mode
        }

        @Option(help: "The kind of average to provide.")
        var kind: Kind = .mean

        @Argument(help: "A group of floating-point values to operate on.")
        var values: [Double] = []

        func calculateMean() -> Double { ... }
        func calculateMedian() -> Double { ... }
        func calculateMode() -> [Double] { ... }

        mutating func run() {
            switch kind {
            case .mean:
                print(calculateMean())
            case .median:
                print(calculateMedian())
            case .mode:
                let result = calculateMode()
                    .map(String.init(describing:))
                    .joined(separator: " ")
                print(result)
            }
        }
    }

    struct StandardDeviation: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "stdev",
            abstract: "Print the standard deviation of the values.")

        @Argument(help: "A group of floating-point values to operate on.")
        var values: [Double] = []

        mutating func run() {
            if values.isEmpty {
                print(0.0)
            } else {
                let sum = values.reduce(0, +)
                let mean = sum / Double(values.count)
                let squaredErrors = values
                    .map { $0 - mean }
                    .map { $0 * $0 }
                let variance = squaredErrors.reduce(0, +) / Double(values.count)
                let result = variance.squareRoot()
                print(result)
            }
        }
    }
}
```

----------------------------------------

TITLE: Implementing Custom Input Validation in Swift ArgumentParser
DESCRIPTION: This Swift code demonstrates how to add custom validation logic to a `ParsableCommand` using the `validate()` method. It checks for valid `count` and `elements` inputs for a `Select` command, throwing `ValidationError` with specific messages if conditions are not met, preventing the `run()` method from executing with invalid arguments.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/Validation.md#_snippet_0

LANGUAGE: Swift
CODE:
```
struct Select: ParsableCommand {
    @Option var count: Int = 1
    @Argument var elements: [String] = []

    mutating func validate() throws {
        guard count >= 1 else {
            throw ValidationError("Please specify a 'count' of at least 1.")
        }

        guard !elements.isEmpty else {
            throw ValidationError("Please provide at least one element to choose from.")
        }

        guard count <= elements.count else {
            throw ValidationError("Please specify a 'count' less than the number of elements.")
        }
    }

    mutating func run() {
        print(elements.shuffled().prefix(count).joined(separator: "\n"))
    }
}
```

----------------------------------------

TITLE: Defining the Root `Math` Command with Subcommands
DESCRIPTION: This Swift code defines the main `Math` command, conforming to `ParsableCommand`. It uses `CommandConfiguration` to specify its subcommands (`Add`, `Multiply`, `Statistics`) and sets `Add` as the default subcommand, which is invoked if no subcommand name is provided.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/CommandsAndSubcommands.md#_snippet_1

LANGUAGE: swift
CODE:
```
struct Math: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "A utility for performing maths.",
        subcommands: [Add.self, Multiply.self, Statistics.self],
        defaultSubcommand: Add.self)
}
```

----------------------------------------

TITLE: Set Main Entry Point with @main Attribute in Swift
DESCRIPTION: This Swift snippet illustrates how to use the `@main` attribute to mark the root command of a `swift-argument-parser` application. This attribute tells the Swift compiler to use the decorated type as the program's entry point, automatically handling argument parsing and subcommand execution.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/CommandsAndSubcommands.md#_snippet_8

LANGUAGE: swift
CODE:
```
@main
struct Math: ParsableCommand {
    // ...
}
```

----------------------------------------

TITLE: Swift struct with required Argument and Option
DESCRIPTION: Illustrates a `ParsableCommand` struct where properties lack default values, making them required command-line inputs. This demonstrates how `ArgumentParser` enforces user input for such properties.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/DeclaringArguments.md#_snippet_2

LANGUAGE: swift
CODE:
```
struct Example: ParsableCommand {
    @Option var userName: String
    @Argument var value: Int
}
```

----------------------------------------

TITLE: Adding a Verbose Flag to a Swift Command-Line Tool
DESCRIPTION: Demonstrates how to add a `--verbose` flag to a Swift command-line tool using the `@Flag` property wrapper. The tool prints a status message only when the flag is present. It shows the command-line usage and the corresponding Swift code.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/GettingStarted.md#_snippet_5

LANGUAGE: Shell
CODE:
```
% count --input-file readme.md --output-file readme.counts
(no output)
% count --verbose --input-file readme.md --output-file readme.counts
Counting words in 'readme.md' and writing the result into 'readme.counts'.
```

LANGUAGE: Swift
CODE:
```
@main
struct Count: ParsableCommand {
    @Option var inputFile: String
    @Option var outputFile: String
    @Flag var verbose = false

    mutating func run() throws {
        if verbose {
            print("""
                Counting words in '\(inputFile)' \
                and writing the result into '\(outputFile)'.
                """)
        }

        // Read 'inputFile', count the words, and save to 'outputFile'.
    }
}
```

----------------------------------------

TITLE: Define a basic command-line tool with ArgumentParser in Swift
DESCRIPTION: This Swift code defines a `Repeat` command using `ArgumentParser`. It demonstrates how to declare command-line arguments (`@Argument`) and options (`@Option`), and implement the command's logic within the `run()` method to repeat a phrase a specified number of times.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Extensions/ParsableCommand.md#_snippet_0

LANGUAGE: swift
CODE:
```
@main
struct Repeat: ParsableCommand {
    @Argument(help: "The phrase to repeat.")
    var phrase: String

    @Option(help: "The number of times to repeat 'phrase'.")
    var count: Int? = nil

    mutating func run() throws {
        let repeatCount = count ?? 2
        for _ in 0..<repeatCount {
            print(phrase)
        }
    }
}
```

----------------------------------------

TITLE: Define a basic command-line tool with Swift ArgumentParser
DESCRIPTION: This Swift code defines a command-line tool named 'Repeat' using the ArgumentParser library. It demonstrates how to declare command arguments and options using property wrappers (@Argument, @Option) and implement the command's logic within the `run()` method. The tool takes a phrase and an optional count, then prints the phrase the specified number of times.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/ArgumentParser.md#_snippet_0

LANGUAGE: Swift
CODE:
```
import ArgumentParser

@main
struct Repeat: ParsableCommand {
    @Argument(help: "The phrase to repeat.")
    var phrase: String

    @Option(help: "The number of times to repeat 'phrase'.")
    var count: Int? = nil

    mutating func run() throws {
        let repeatCount = count ?? 2
        for _ in 0..<repeatCount {
            print(phrase)
        }
    }
}
```

----------------------------------------

TITLE: Define Swift Command with Named Options using ParsableCommand
DESCRIPTION: This Swift code modifies the `Count` command to use `@Option` property wrappers for `inputFile` and `outputFile`. This change allows users to specify inputs with explicit labels, improving clarity and making the order of arguments flexible.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/GettingStarted.md#_snippet_4

LANGUAGE: Swift
CODE:
```
@main
struct Count: ParsableCommand {
    @Option var inputFile: String
    @Option var outputFile: String

    mutating func run() throws {
        print("""
            Counting words in '\(inputFile)' \
            and writing the result into '\(outputFile)'.
            """)

        // Read 'inputFile', count the words, and save to 'outputFile'.
    }
}
```

----------------------------------------

TITLE: Define Custom Type Conforming to ExpressibleByArgument
DESCRIPTION: Demonstrates how to make a custom struct conform to the `ExpressibleByArgument` protocol by implementing its `init?(argument:)` initializer, allowing instances of the type to be parsed directly from command-line arguments.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/DeclaringArguments.md#_snippet_8

LANGUAGE: Swift
CODE:
```
struct Path: ExpressibleByArgument {
    var pathString: String

    init?(argument: String) {
        self.pathString = argument
    }
}

struct Example: ParsableCommand {
    @Argument var inputFile: Path
}
```

----------------------------------------

TITLE: Defining the `Statistics` Subcommand with Nested Structure
DESCRIPTION: This Swift code defines the `Statistics` subcommand, which acts as a parent for further nested subcommands like `Average` and `StandardDeviation`. It demonstrates setting a custom `commandName` (`stats`) and structuring a deeper command hierarchy within the application.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/CommandsAndSubcommands.md#_snippet_6

LANGUAGE: swift
CODE:
```
extension Math {
    struct Statistics: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "stats",
            abstract: "Calculate descriptive statistics.",
            subcommands: [Average.self, StandardDeviation.self])
    }
}
```

----------------------------------------

TITLE: Define RawRepresentable Enum Conforming to ExpressibleByArgument
DESCRIPTION: Illustrates how string-backed enumerations, which conform to `RawRepresentable`, can easily conform to `ExpressibleByArgument` by simply declaring conformance, leveraging the default implementation provided by the library.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/DeclaringArguments.md#_snippet_9

LANGUAGE: Swift
CODE:
```
enum ReleaseMode: String, ExpressibleByArgument {
    case debug, release
}

struct Example: ParsableCommand {
    @Option var mode: ReleaseMode

    mutating func run() throws {
        print(mode)
    }
}
```

----------------------------------------

TITLE: Command-Line Invocation of Default Subcommand
DESCRIPTION: This example shows how the `Math` utility behaves when no explicit subcommand is provided. Due to `Add` being set as the `defaultSubcommand`, the input values are automatically processed by the `Add` command.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/CommandsAndSubcommands.md#_snippet_2

LANGUAGE: shell
CODE:
```
% math 10 15 7
32
```

----------------------------------------

TITLE: Transform Non-ExpressibleByArgument Types with Custom Function
DESCRIPTION: Shows how to use a throwing `transform` function with `@Argument` to convert a parsed string into a custom type that does not conform to `ExpressibleByArgument`. This approach is suitable for more complex types or types not defined by the user, allowing for custom parsing logic and error handling.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/DeclaringArguments.md#_snippet_10

LANGUAGE: Swift
CODE:
```
enum Format {
    case text
    case other(String)

    init(_ string: String) throws {
        if string == "text" {
            self = .text
        } else {
            self = .other(string)
        }
    }
}

struct Example: ParsableCommand {
    @Argument(transform: Format.init)
    var format: Format
}
```

----------------------------------------

TITLE: Enumerate Possible Values for Swift Arguments using allValueStrings
DESCRIPTION: Shows how to provide a list of possible values for an `ExpressibleByArgument` enum by implementing the `allValueStrings` static property. This allows the help screen to display the valid options for an argument or option.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/CustomizingHelp.md#_snippet_2

LANGUAGE: Swift
CODE:
```
enum Fruit: String, ExpressibleByArgument {
    case apple
    case banana
    case coconut
    case dragonFruit = "dragon-fruit"

    static var allValueStrings: [String] {
        ["apple", "banana", "coconut", "dragon-fruit"]
    }
}

struct FruitStore: ParsableCommand {
    @Argument(help: "The fruit to purchase")
    var fruit: Fruit

    @Option(help: "The number of fruit to purchase")
    var quantity: Int = 1
}
```

LANGUAGE: Shell
CODE:
```
USAGE: fruit-store <fruit> [--quantity <quantity>]

ARGUMENTS:
  <fruit>                 The fruit to purchase (values: apple, banana,
                          coconut, dragon-fruit)

OPTIONS:
  --quantity <quantity>   The number of fruit to purchase (default: 1)
  -h, --help              Show help information.
```

----------------------------------------

TITLE: Validate Parsed Arguments and Exit on Error
DESCRIPTION: Performs a validation check to ensure the number of elements is greater than or equal to the specified count. If the condition is not met, it creates a `ValidationError` and exits the script gracefully using `SelectOptions.exit(withError:)`, which also includes usage information.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/ManualParsing.md#_snippet_2

LANGUAGE: swift
CODE:
```
guard options.elements.count >= options.count else {
    let error = ValidationError("Please specify a 'count' less than the number of elements.")
    SelectOptions.exit(withError: error)
}
```

----------------------------------------

TITLE: Use Integer Flags for Counting Occurrences
DESCRIPTION: Illustrates how an `Int` type flag automatically counts the number of times it is specified on the command line. This is useful for scenarios like controlling verbosity levels, where the flag's value increments with each occurrence.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/DeclaringArguments.md#_snippet_13

LANGUAGE: Swift
CODE:
```
struct Example: ParsableCommand {
    @Flag(name: .shortAndLong)
    var verbose: Int

    mutating func run() throws {
        print("Verbosity level: \(verbose)")
    }
}
```

----------------------------------------

TITLE: Demonstrating Custom Validation Error Messages in Shell
DESCRIPTION: These shell commands illustrate the user experience when the `Select` command (defined previously) encounters invalid inputs. It shows how `ArgumentParser` displays the custom `ValidationError` messages along with usage information, guiding the user to correct their input.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/Validation.md#_snippet_1

LANGUAGE: Shell
CODE:
```
% select
Error: Please provide at least one element to choose from.
Usage: select [--count <count>] [<elements> ...]
  See 'select --help' for more information.
% select --count 2 hello
Error: Please specify a 'count' less than the number of elements.
Usage: select [--count <count>] [<elements> ...]
  See 'select --help' for more information.
% select --count 0 hello hey hi howdy
Error: Please specify a 'count' of at least 1.
Usage: select [--count <count>] [<elements> ...]
  See 'select --help' for more information.
% select --count 2 hello hey hi howdy
howdy
hey
```

----------------------------------------

TITLE: Controlling Program Exit Codes with ExitCode in Swift
DESCRIPTION: This Swift code demonstrates how to use the `ExitCode` error type to explicitly control the program's exit status. This is useful when your command handles and prints its own error messages, allowing you to throw an `ExitCode` to ensure the correct exit code without `ArgumentParser` printing a redundant error message.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/Validation.md#_snippet_4

LANGUAGE: Swift
CODE:
```
struct RuntimeError: Error, CustomStringConvertible {
    var description: String
}

struct Example: ParsableCommand {
    @Argument var inputFile: String

    mutating func run() throws {
        if !ExampleCore.processFile(inputFile) {
            // ExampleCore.processFile(_:) prints its own errors
            // and returns `false` on failure.
            throw ExitCode.failure
        }
    }
}
```

----------------------------------------

TITLE: Programmatically Generate Help Text for Commands
DESCRIPTION: This Swift code demonstrates how to programmatically generate the help text for a command using the 'helpMessage()' method on the command type. It shows how to get the default help message and how to format it to a specific column width. It also notes the method for generating help for subcommands.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/CustomizingCommandHelp.md#_snippet_6

LANGUAGE: swift
CODE:
```
let help = Repeat.helpMessage()
// `help` matches the output above

let fortyColumnHelp = Repeat.helpMessage(columns: 40)
// `fortyColumnHelp` is the same help screen, but wrapped to 40 columns
```

----------------------------------------

TITLE: Derive Possible Values for Swift Arguments from CaseIterable Enums
DESCRIPTION: Illustrates a simplified approach to enumerating possible values for `ExpressibleByArgument` types by conforming the enum to `CaseIterable`. This automatically derives the list of values for the help screen without needing to implement `allValueStrings` manually.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/CustomizingHelp.md#_snippet_3

LANGUAGE: Swift
CODE:
```
enum Fruit: String, CaseIterable, ExpressibleByArgument {
    case apple
    case banana
    case coconut
    case dragonFruit = "dragon-fruit"
}
```

LANGUAGE: Shell
CODE:
```
USAGE: fruit-store <fruit> [--quantity <quantity>]

ARGUMENTS:
  <fruit>                 The fruit to purchase (values: apple, banana,
                          coconut, dragon-fruit)

OPTIONS:
  --quantity <quantity>   The number of fruit to purchase (default: 1)
  -h, --help              Show help information.
```

----------------------------------------

TITLE: Define ParsableArguments Type for Command Options
DESCRIPTION: Defines a `ParsableArguments` struct, `SelectOptions`, to specify command-line options. It includes an `@Option` for an integer `count` with a default value and an `@Argument` for an array of `String` `elements`.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/ManualParsing.md#_snippet_0

LANGUAGE: swift
CODE:
```
struct SelectOptions: ParsableArguments {
    @Option var count: Int = 1
    @Argument var elements: [String] = []
}
```

----------------------------------------

TITLE: Define Basic Help Text for Swift Arguments
DESCRIPTION: Demonstrates how to add simple help descriptions to `@Flag`, `@Option`, and `@Argument` properties in a `ParsableCommand` struct using string literals. It also shows the automatically generated help output in the command line.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/CustomizingHelp.md#_snippet_0

LANGUAGE: Swift
CODE:
```
struct Example: ParsableCommand {
    @Flag(help: "Display extra information while processing.")
    var verbose = false

    @Option(help: "The number of extra lines to show.")
    var extraLines = 0

    @Argument(help: "The input file.")
    var inputFile: String?
}
```

LANGUAGE: Shell
CODE:
```
% example --help
USAGE: example [--verbose] [--extra-lines <extra-lines>] <input-file>

ARGUMENTS:
  <input-file>            The input file.

OPTIONS:
  --verbose               Display extra information while processing.
  --extra-lines <extra-lines>
                          The number of extra lines to show. (default: 0)
  -h, --help              Show help information.
```

----------------------------------------

TITLE: Run Basic Swift Command with Positional Arguments
DESCRIPTION: This example demonstrates how to execute the `count` command from the command line, providing the input and output file paths as positional arguments. The output confirms the files being processed.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/GettingStarted.md#_snippet_1

LANGUAGE: Shell
CODE:
```
% count readme.md readme.counts
Counting words in 'readme.md' and writing the result into 'readme.counts'.
```

----------------------------------------

TITLE: Customize Swift Argument Help with ArgumentHelp Instance
DESCRIPTION: Explains how to use the `ArgumentHelp` type for more granular control over help text, including adding a `discussion` and specifying a `valueName` for arguments and options. It illustrates how these customizations appear in the generated help screen.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/CustomizingHelp.md#_snippet_1

LANGUAGE: Swift
CODE:
```
struct Example: ParsableCommand {
    @Flag(help: "Display extra information while processing.")
    var verbose = false

    @Option(help: ArgumentHelp(
        "The number of extra lines to show.",
        valueName: "n"))
    var extraLines = 0

    @Argument(help: ArgumentHelp(
        "The input file.",
        discussion: "If no input file is provided, the tool reads from stdin.",
        valueName: "file"))
    var inputFile: String?
}
```

LANGUAGE: Shell
CODE:
```
USAGE: example [--verbose] [--extra-lines <n>] [<file>]

ARGUMENTS:
  <file>                  The input file.
        If no input file is provided, the tool reads from stdin.

OPTIONS:
  --verbose               Display extra information while processing.
  --extra-lines <n>       The number of extra lines to show. (default: 0)
  -h, --help              Show help information.
```

----------------------------------------

TITLE: Implement Custom Completion Function for Swift Arguments
DESCRIPTION: This Swift example demonstrates using the `.custom` completion kind to provide completions via a user-defined function. The `listExecutables` function generates a list of executables, which is then used for the `--target` option's completions.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/CustomizingCompletions.md#_snippet_2

LANGUAGE: Swift
CODE:
```
func listExecutables(_ arguments: [String]) -> [String] {
    // Generate the list of executables in the current directory
}

struct SwiftRun {
    @Option(help: "The target to execute.", completion: .custom(listExecutables))
    var target: String?
}
```

----------------------------------------

TITLE: Swift ArgumentParser: Initialize Single Arguments
DESCRIPTION: This section lists initializers for creating single arguments within Swift's ArgumentParser. These initializers allow developers to configure help messages, define completion behaviors, and apply optional transformation functions to the argument's value.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Extensions/Argument.md#_snippet_0

LANGUAGE: APIDOC
CODE:
```
init(help:completion:)-6pqzn
```

LANGUAGE: APIDOC
CODE:
```
init(help:completion:)-4p94d
```

LANGUAGE: APIDOC
CODE:
```
init(help:completion:transform:)-3fjtc
```

LANGUAGE: APIDOC
CODE:
```
init(help:completion:transform:)-7yn32
```

LANGUAGE: APIDOC
CODE:
```
init(wrappedValue:help:completion:)-9yifn
```

LANGUAGE: APIDOC
CODE:
```
init(wrappedValue:help:completion:transform:)-667t1
```

----------------------------------------

TITLE: API Reference: ParsableArguments.validate() Method
DESCRIPTION: Documents the `validate()` method, a key extension point in Swift ArgumentParser for implementing custom validation logic on command properties. It details its purpose, behavior upon error, and applicability to various command types.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/Validation.md#_snippet_5

LANGUAGE: APIDOC
CODE:
```
ParsableArguments protocol:
  validate() throws -> Void
    Purpose: Implement custom validation logic for command properties after parsing.
    Behavior:
      - Called after command-line inputs are parsed.
      - Throwing an error from this method causes the program to print a message to standard error and exit with an error code.
      - Prevents the 'run()' method from being called with invalid inputs.
    Applicable to: ParsableCommand, ParsableArguments, AsyncParsableCommand types.
```

----------------------------------------

TITLE: Implement Asynchronous Command with AsyncParsableCommand in Swift
DESCRIPTION: Demonstrates how to create an asynchronous command using `AsyncParsableCommand` in Swift Argument Parser. The `CountLines` example reads lines from a file asynchronously using Foundation's `FileHandle.AsyncBytes` and counts them within an `async throws run()` method, showcasing the core functionality.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Extensions/AsyncParsableCommand.md#_snippet_0

LANGUAGE: Swift
CODE:
```
import Foundation

@main
struct CountLines: AsyncParsableCommand {
    @Argument(transform: URL.init(fileURLWithPath:))
    var inputFile: URL

    mutating func run() async throws {
        let fileHandle = try FileHandle(forReadingFrom: inputFile)
        let lineCount = try await fileHandle.bytes.lines.reduce(into: 0)
            { count, _ in count += 1 }
        print(lineCount)
    }
}
```

----------------------------------------

TITLE: Run Swift Command with Named Options
DESCRIPTION: This snippet illustrates how to run the `count` command using named options (`--input-file` and `--output-file`) instead of positional arguments. This approach makes the command-line interface more explicit and order-independent.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/GettingStarted.md#_snippet_3

LANGUAGE: Shell
CODE:
```
% count --input-file readme.md --output-file readme.counts
Counting words in 'readme.md' and writing the result into 'readme.counts'.
```

----------------------------------------

TITLE: Customizing Command-Line Option and Flag Names in Swift
DESCRIPTION: Explains how to use custom short and long names for command-line options and flags in Swift Argument Parser. It shows examples of using `-v` for `--verbose` and custom long names for input/output files, along with the Swift code modifications.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/GettingStarted.md#_snippet_6

LANGUAGE: Shell
CODE:
```
% count -v -i readme.md -o readme.counts
Counting words in 'readme.md' and writing the result into 'readme.counts'.
% count --input readme.md --output readme.counts -v
Counting words in 'readme.md' and writing the result into 'readme.counts'.
% count -o readme.counts -i readme.md --verbose
Counting words in 'readme.md' and writing the result into 'readme.counts'.
```

LANGUAGE: Swift
CODE:
```
@main
struct Count: ParsableCommand {
    @Option(name: [.short, .customLong("input")])
    var inputFile: String

    @Option(name: [.short, .customLong("output")])
    var outputFile: String

    @Flag(name: .shortAndLong)
    var verbose = false

    mutating func run() throws { ... }
}
```

----------------------------------------

TITLE: Define Command Configuration with Custom Help Text
DESCRIPTION: This Swift code defines a 'Repeat' command using 'ParsableCommand'. It customizes the command's help output by providing an 'abstract', 'usage' string, and 'discussion' within the 'CommandConfiguration'. It also defines arguments and options for the command, demonstrating how to structure a command with custom help information.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/CustomizingCommandHelp.md#_snippet_0

LANGUAGE: swift
CODE:
```
struct Repeat: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Repeats your input phrase.",
        usage: """
            repeat <phrase>
            repeat --count <count> <phrase>
            """,
        discussion: """
            Prints to stdout forever, or until you halt the program.
            "")

    @Argument(help: "The phrase to repeat.")
    var phrase: String

    @Option(help: "How many times to repeat.")
    var count: Int? = nil

    mutating func run() throws {
        for _ in 0..<(count ?? 2) {
            print(phrase)
        }
    }
}
```

----------------------------------------

TITLE: Defining Shared `Options` for Subcommands
DESCRIPTION: This Swift struct `Options` conforms to `ParsableArguments` and defines common command-line arguments that can be shared across multiple subcommands. It includes a `--hexadecimal-output` flag and an array of `Int` values, making it reusable for various operations.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/CommandsAndSubcommands.md#_snippet_3

LANGUAGE: swift
CODE:
```
struct Options: ParsableArguments {
    @Flag(name: [.long, .customShort("x")], help: "Use hexadecimal notation for the result.")
    var hexadecimalOutput = false

    @Argument(help: "A group of integers to operate on.")
    var values: [Int]
}
```

----------------------------------------

TITLE: Specify Default Values for Arguments, Options, and Flags in Swift Argument Parser
DESCRIPTION: Demonstrates how to assign default values to properties representing arguments, options, and flags using standard Swift initialization syntax. This applies to most types, with exceptions for Optional-typed values and Int flags. Non-optional Bool flags must explicitly default to 'false'.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/DeclaringArguments.md#_snippet_14

LANGUAGE: swift
CODE:
```
enum CustomFlag: String, EnumerableFlag {
    case foo, bar, baz
}

struct Example: ParsableCommand {
    @Flag
    var booleanFlag = false

    @Flag
    var arrayFlag: [CustomFlag] = [.foo, .baz]

    @Option
    var singleOption = 0

    @Option
    var arrayOption = ["bar", "qux"]

    @Argument
    var singleArgument = "quux"

    @Argument
    var arrayArgument = ["quux", "quuz"]
}
```

----------------------------------------

TITLE: Swift struct with array Argument and custom run method
DESCRIPTION: Demonstrates a `ParsableCommand` struct with an array argument that has a default value. It also includes a `run()` method to show how user-supplied values replace the entire default array.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/DeclaringArguments.md#_snippet_4

LANGUAGE: swift
CODE:
```
struct Lucky: ParsableCommand {
    @Argument var numbers = [7, 14, 21]

    mutating func run() throws {
        print("""
        Your lucky numbers are:
        \(numbers.map(String.init).joined(separator: " "))
        """)
    }
}
```

----------------------------------------

TITLE: Swift Argument Parser: Group Arguments in Help Screen
DESCRIPTION: Shows how to organize related arguments under a custom title in the help screen. By providing a `title` parameter to `@OptionGroup`, properties of the associated `ParsableArguments` type are grouped together, improving help screen readability.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/CustomizingHelp.md#_snippet_6

LANGUAGE: Swift
CODE:
```
struct BuildOptions: ParsableArguments {
    @Option(help: "A setting to pass to the compiler.")
    var compilerSetting: [String] = []

    @Option(help: "A setting to pass to the linker.")
    var linkerSetting: [String] = []
}

struct Example: ParsableCommand {
    @Argument(help: "The input file to process.")
    var inputFile: String

    @Flag(help: "Show extra output.")
    var verbose: Bool = false

    @Option(help: "The path to a configuration file.")
    var configFile: String?

    @OptionGroup(title: "Build Options")
    var buildOptions: BuildOptions
}
```

LANGUAGE: Shell
CODE:
```
% example --help
USAGE: example <input-file> [--verbose] [--config-file <config-file>] [--compiler-setting <compiler-setting> ...] [--linker-setting <linker-setting> ...]

ARGUMENTS:
  <input-file>            The input file to process.

BUILD OPTIONS:
  --compiler-setting <compiler-setting>
                          A setting to pass to the compiler.
  --linker-setting <linker-setting>
                          A setting to pass to the linker.

OPTIONS:
  --verbose               Show extra output.
  --config-file <config-file>
                          The path to a configuration file.
  -h, --help              Show help information.
```

----------------------------------------

TITLE: Swift Argument Parser: Control Individual Flag Visibility
DESCRIPTION: Demonstrates how to use `visibility: .hidden` and `visibility: .private` with `@Flag` to control whether an argument appears in the standard or extended help screen. Hidden flags appear only with `--help-hidden`, while private flags remain hidden even then.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/CustomizingHelp.md#_snippet_4

LANGUAGE: Swift
CODE:
```
struct Example: ParsableCommand {
    @Flag(help: ArgumentHelp("Show extra info.", visibility: .hidden))
    var verbose: Bool = false

    @Flag(help: ArgumentHelp("Use the legacy format.", visibility: .private))
    var useLegacyFormat: Bool = false
}
```

LANGUAGE: Shell
CODE:
```
% example --help
USAGE: example

OPTIONS:
  -h, --help              Show help information.

% example --help-hidden
USAGE: example [--verbose]

OPTIONS:
  --verbose               Show extra info.
  -h, --help              Show help information.
```

----------------------------------------

TITLE: Swift Argument Parser: Control OptionGroup Visibility
DESCRIPTION: Illustrates how to hide an entire group of arguments defined in a `ParsableArguments` type by setting `visibility: .hidden` on the `@OptionGroup` property. This makes all flags within the group visible only in the extended help screen.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/CustomizingHelp.md#_snippet_5

LANGUAGE: Swift
CODE:
```
struct ExperimentalFlags: ParsableArguments {
    @Flag(help: "Use the remote access token. (experimental)")
    var experimentalUseRemoteAccessToken: Bool = false

    @Flag(help: "Use advanced security. (experimental)")
    var experimentalAdvancedSecurity: Bool = false
}

struct Example: ParsableCommand {
    @OptionGroup(visibility: .hidden)
    var flags: ExperimentalFlags
}
```

LANGUAGE: Shell
CODE:
```
% example --help
USAGE: example

OPTIONS:
  -h, --help              Show help information.

% example --help-hidden
USAGE: example [--experimental-use-remote-access-token] [--experimental-advanced-security]

OPTIONS:
  --experimental-use-remote-access-token
                          Use the remote access token. (experimental)
  --experimental-advanced-security
                          Use advanced security. (experimental)
  -h, --help              Show help information.
```

----------------------------------------

TITLE: API Reference: ExitCode Type
DESCRIPTION: Documents the `ExitCode` type, an error provided by Swift ArgumentParser to explicitly control the program's exit status. It explains its utility in preventing redundant error messages when custom error output is already handled, and lists its static properties for common exit statuses.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/Validation.md#_snippet_7

LANGUAGE: APIDOC
CODE:
```
ExitCode type:
  Purpose: An error type used to control the program's exit status.
  Behavior: Throwing an ExitCode error prevents ArgumentParser from printing additional error messages if custom output is already provided.
  Static Properties:
    - .success
    - .failure
    - .validationError
  Custom Exit Code: Allows specifying a specific integer exit code.
```

----------------------------------------

TITLE: Swift ArgumentParser: Initialize Array Arguments and Parsing Strategy
DESCRIPTION: This section details initializers designed for creating arguments that parse into arrays of values. It also includes the `ArgumentArrayParsingStrategy` type, providing options for defining how multiple values are parsed, along with standard configurations for help messages, completion, and value transformations.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Extensions/Argument.md#_snippet_1

LANGUAGE: APIDOC
CODE:
```
init(parsing:help:completion:)
```

LANGUAGE: APIDOC
CODE:
```
init(parsing:help:completion:transform:)
```

LANGUAGE: APIDOC
CODE:
```
init(wrappedValue:parsing:help:completion:)
```

LANGUAGE: APIDOC
CODE:
```
init(wrappedValue:parsing:help:completion:transform:)
```

LANGUAGE: APIDOC
CODE:
```
ArgumentArrayParsingStrategy
```

----------------------------------------

TITLE: Swift struct with custom ArgumentParser option and flag names
DESCRIPTION: Shows how to customize the command-line names for `@Option` and `@Flag` properties using `.long`, `.short`, `.customLong`, and `.customShort` initializers, overriding the default name derivation.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/DeclaringArguments.md#_snippet_6

LANGUAGE: swift
CODE:
```
struct Example: ParsableCommand {
    @Flag(name: .long)  // Same as the default
    var stripWhitespace = false

    @Flag(name: .short)
    var verbose = false

    @Option(name: .customLong("count"))
    var iterationCount: Int

    @Option(name: [.customShort("I"), .long])
    var inputFile: String
}
```

----------------------------------------

TITLE: ArgumentParser Option: Array Initializers and Strategies
DESCRIPTION: Documents initializers and parsing strategies for array options within Swift's ArgumentParser framework, enabling the collection of multiple command-line arguments into an array.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Extensions/Option.md#_snippet_1

LANGUAGE: APIDOC
CODE:
```
ArgumentParser/Option - Array Options:
  init(name:parsing:help:completion:)-238hg
  init(name:parsing:help:completion:transform:)-74hnp
  init(wrappedValue:name:parsing:help:completion:)-1dtbf
  init(wrappedValue:name:parsing:help:completion:transform:)-1kpto
  ArrayParsingStrategy
```

----------------------------------------

TITLE: Command-line examples for array argument replacement
DESCRIPTION: Illustrates how user-provided values for an array argument replace the default array entirely, rather than appending to it.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/DeclaringArguments.md#_snippet_5

LANGUAGE: bash
CODE:
```
% lucky
Your lucky numbers are:
7 14 21
% lucky 1 2 3
Your lucky numbers are:
1 2 3
```

----------------------------------------

TITLE: ArgumentParser Option: Single-Value Initializers and Strategies
DESCRIPTION: Documents initializers and parsing strategies for single-value options within Swift's ArgumentParser framework, allowing configuration of how a single command-line argument is parsed.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Extensions/Option.md#_snippet_0

LANGUAGE: APIDOC
CODE:
```
ArgumentParser/Option - Single-Value Options:
  init(name:parsing:help:completion:)-4yske
  init(name:parsing:help:completion:)-7slrf
  init(wrappedValue:name:parsing:help:completion:)-7ilku
  init(name:parsing:help:completion:transform:)-2wf44
  init(name:parsing:help:completion:transform:)-25g7b
  init(wrappedValue:name:parsing:help:completion:transform:)-2llve
  SingleValueParsingStrategy
```

----------------------------------------

TITLE: Parse Command-Line Arguments with parseOrExit
DESCRIPTION: Parses the command-line input into an instance of `SelectOptions` using the static `parseOrExit()` method. This method returns a fully initialized instance of the type or exits the program with an error message and code if parsing fails.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/ManualParsing.md#_snippet_1

LANGUAGE: swift
CODE:
```
let options = SelectOptions.parseOrExit()
```

----------------------------------------

TITLE: ArgumentParser Flag: Boolean Flag Initializers
DESCRIPTION: Initializers for creating simple boolean flags that represent a true or false state based on their presence or absence in command-line arguments.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Extensions/Flag.md#_snippet_0

LANGUAGE: APIDOC
CODE:
```
init(wrappedValue:name:help:)
```

----------------------------------------

TITLE: Customize Argument Completions with CompletionKind in Swift
DESCRIPTION: This Swift code demonstrates how to use `CompletionKind` with `@Option` properties to provide specific shell completions for command-line arguments. It shows examples for file paths, directory paths, a predefined list of strings, and automatic completions for `CaseIterable` enums.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/CustomizingCompletions.md#_snippet_0

LANGUAGE: Swift
CODE:
```
struct Example: ParsableCommand {
    @Option(help: "The file to read from.", completion: .file())
    var input: String

    @Option(help: "The output directory.", completion: .directory)
    var outputDir: String

    @Option(help: "The preferred file format.", completion: .list(["markdown", "rst"]))
    var format: String

    enum CompressionType: String, CaseIterable, ExpressibleByArgument {
        case zip, gzip
    }

    @Option(help: "The compression type to use.")
    var compression: CompressionType
}
```

----------------------------------------

TITLE: Configure Custom Help Flag Names for a Command
DESCRIPTION: This Swift code demonstrates how to change the default help flag names ('-h', '--help') to custom ones like '--help' and '-?' using the 'helpNames' property in 'CommandConfiguration'. This allows the '-h' flag to be used for other options, such as 'historyDepth', without conflicting with the help display.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/CustomizingCommandHelp.md#_snippet_2

LANGUAGE: swift
CODE:
```
struct Example: ParsableCommand {
    static let configuration = CommandConfiguration(
        helpNames: [.long, .customShort("?")])

    @Option(name: .shortAndLong, help: "The number of history entries to show.")
    var historyDepth: Int

    mutating func run() throws {
        printHistory(depth: historyDepth)
    }
}
```

----------------------------------------

TITLE: Command-line examples for custom option and flag names
DESCRIPTION: Illustrates how to invoke a command using custom long and short names for options and flags, as defined in the Swift struct.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/DeclaringArguments.md#_snippet_7

LANGUAGE: bash
CODE:
```
% example --strip-whitespace -v
% example --count 10 -I file1.swift
% example --input-file file1.swift
```

----------------------------------------

TITLE: Define Default CompletionKind for Custom ExpressibleByArgument Types in Swift
DESCRIPTION: This Swift code shows how to implement `defaultCompletionKind` for a custom `ExpressibleByArgument` type. By defining this static property, any arguments or options using the `File` type will automatically suggest file completions.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/CustomizingCompletions.md#_snippet_1

LANGUAGE: Swift
CODE:
```
struct File: Hashable, ExpressibleByArgument {
    var path: String

    init?(argument: String) {
        self.path = argument
    }

    static var defaultCompletionKind: CompletionKind {
        .file()
    }
}
```

----------------------------------------

TITLE: Define Enumerable Flags for Custom Choices and Collections
DESCRIPTION: Explains how to use the `EnumerableFlag` protocol with enumerations to create flags that offer custom names, exclusive choices, or allow collecting multiple values from a predefined set. Flag names are derived from the raw values of the enumeration.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/DeclaringArguments.md#_snippet_12

LANGUAGE: Swift
CODE:
```
enum CacheMethod: String, EnumerableFlag {
    case inMemoryCache
    case persistentCache
}

enum Color: String, EnumerableFlag {
    case pink, purple, silver
}

struct Example: ParsableCommand {
    @Flag var cacheMethod: CacheMethod
    @Flag var colors: [Color] = []

    mutating func run() throws {
        print(cacheMethod)
        print(colors)
    }
}
```

----------------------------------------

TITLE: Swift ArgumentParser: Default Positional Argument Parsing
DESCRIPTION: Demonstrates the default `.remaining` parsing strategy for arrays of positional arguments. This strategy collects all non-dash-prefixed inputs after known options and flags, treating inputs after a `--` terminator as positional.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/DeclaringArguments.md#_snippet_20

LANGUAGE: swift
CODE:
```
struct Example: ParsableCommand {
    @Flag var verbose = false
    @Argument var files: [String] = []

    mutating func run() throws {
        print("Verbose: \(verbose), files: \(files)")
    }
}
```

----------------------------------------

TITLE: Demonstrate Custom Help Flag Usage and Option Conflict Resolution
DESCRIPTION: This snippet illustrates how the custom help flag ('-?') works, distinguishing it from an option that uses '-h'. It shows the command-line output when '-h' is used for the 'history-depth' option and when '-?' is used to display the help screen, confirming the custom help flag's functionality.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/CustomizingCommandHelp.md#_snippet_3

LANGUAGE: shell
CODE:
```
% example -h 3
nmap -v -sS -O 10.2.2.2
sshnuke 10.2.2.2 -rootpw="Z1ON0101"
ssh 10.2.2.2 -l root
% example -?
USAGE: example --history-depth <history-depth>

ARGUMENTS:
  <phrase>                The phrase to repeat.

OPTIONS:
  -h, --history-depth     The number of history entries to show.
  -?, --help              Show help information.
```

----------------------------------------

TITLE: Swift ArgumentParser: Default Array Option Parsing
DESCRIPTION: Demonstrates the default parsing strategy for array options, where each value must be explicitly associated with the option key. Shows how missing values result in an error.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/DeclaringArguments.md#_snippet_16

LANGUAGE: swift
CODE:
```
struct Example: ParsableCommand {
    @Option var file: [String] = []
    @Flag var verbose = false

    mutating func run() throws {
        print("Verbose: \(verbose), files: \(file)")
    }
}
```

----------------------------------------

TITLE: Verify Inherited Help Flag Usage in Subcommand
DESCRIPTION: This snippet shows the command-line output for the 'parent child' subcommand. It confirms that the custom help flag ('-?') defined in the parent command is inherited and works correctly for the subcommand, allowing '-h' to be used for a subcommand-specific option ('--host') without conflict.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/CustomizingCommandHelp.md#_snippet_5

LANGUAGE: shell
CODE:
```
% parent child -h 192.0.0.0
...
% parent child -?
USAGE: parent child --host <host>

OPTIONS:
  -h, --host <host>       The host the server will run on.
  -?, --help              Show help information.
```

----------------------------------------

TITLE: Command-line error messages for missing required inputs
DESCRIPTION: Shows the error output when a user fails to provide required arguments or options for a command defined with non-optional properties.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/DeclaringArguments.md#_snippet_3

LANGUAGE: bash
CODE:
```
% example 5
Error: Missing '--user-name <user-name>'
Usage: example --user-name <user-name> <value>
  See 'example --help' for more information.
% example --user-name kjohnson
Error: Missing '<value>'
Usage: example --user-name <user-name> <value>
  See 'example --help' for more information.
```

----------------------------------------

TITLE: Filter and Parse Custom Command-Line Arguments
DESCRIPTION: Illustrates how to provide a custom array of command-line inputs to `parseOrExit()`. This example filters out any words that are entirely uppercase from `CommandLine.arguments` before passing them to the parser, enabling pre-parse filtering or testing with specific input sets.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/ManualParsing.md#_snippet_5

LANGUAGE: swift
CODE:
```
let noShoutingArguments = CommandLine.arguments.dropFirst().filter { phrase in
    phrase.uppercased() != phrase
}
let options = SelectOptions.parseOrExit(noShoutingArguments)
```

----------------------------------------

TITLE: Example of Generated Help Screen and Command Execution
DESCRIPTION: This snippet shows the command-line output of the 'repeat --help' command, demonstrating how the customized 'abstract', 'discussion', and 'usage' strings appear in the generated help screen. It also includes an example of the command's basic execution, showing how the 'phrase' argument is repeated.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/CustomizingCommandHelp.md#_snippet_1

LANGUAGE: shell
CODE:
```
% repeat --help
OVERVIEW: Repeats your input phrase.

Prints to stdout forever, or until you halt the program.

USAGE: repeat <phrase>
       repeat --count <count> <phrase>

ARGUMENTS:
  <phrase>                The phrase to repeat.

OPTIONS:
  -h, --help              Show help information.

% repeat hello!
hello!
hello!
hello!
hello!
hello!
hello!
...
```

----------------------------------------

TITLE: Handling General Runtime Errors in Swift ArgumentParser
DESCRIPTION: This Swift snippet shows how to handle non-validation specific errors, such as file I/O issues, within a `ParsableCommand`'s `run()` method. It demonstrates that `ArgumentParser` automatically catches and reports errors thrown from `run()`, providing a clear message to the user and exiting with an appropriate error code.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/Validation.md#_snippet_2

LANGUAGE: Swift
CODE:
```
struct LineCount: ParsableCommand {
    @Argument var file: String

    mutating func run() throws {
        let contents = try String(contentsOfFile: file, encoding: .utf8)
        let lines = contents.split(separator: "\n")
        print(lines.count)
    }
}
```

----------------------------------------

TITLE: Command Line Output for Custom Option Transform Error
DESCRIPTION: This example demonstrates the command line output when the `failOption` is provided, triggering the custom error `ExampleTransformError` defined in the Swift code. The custom error's description is displayed to the user, providing clear context about the failure.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/Validation.md#_snippet_10

LANGUAGE: shell
CODE:
```
% example '{"tokenCount":0,"tokens":[],"identifier":"F77D661C-C5B7-448E-9344-267B284F66AD"}' --fail-option="Some Text Here!"
Error: The value 'Some Text Here!' is invalid for '--fail-option <fail-option>': Trying to write to failOption always produces an error. Input: Some Text Here!
Usage: example <input-json> --fail-option <fail-option>
  See 'select --help' for more information.
```

----------------------------------------

TITLE: Inherit Custom Help Names in Subcommands
DESCRIPTION: This Swift code defines a 'Parent' command with a 'Child' subcommand. It sets custom help names ('--help', '-?') for the 'Parent' command. This demonstrates that these custom help names are automatically inherited by its subcommands, such as 'Child', ensuring consistent help invocation across the command hierarchy.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/CustomizingCommandHelp.md#_snippet_4

LANGUAGE: swift
CODE:
```
struct Parent: ParsableCommand {
    static let configuration = CommandConfiguration(
        subcommands: [Child.self],
        helpNames: [.long, .customShort("?")])

    struct Child: ParsableCommand {
        @Option(name: .shortAndLong, help: "The host the server will run on.")
        var host: String
    }
}
```

----------------------------------------

TITLE: Configure Shell-Specific Completions in Swift Argument Parser
DESCRIPTION: This Swift code illustrates how to provide shell-specific completion candidates using `CompletionShell.requesting` and `CompletionShell.requestingVersion`. It defines functions `generateCommandPerShell` and `generateCompletionCandidatesPerShell` to return different completion logic or candidates based on the requesting shell (Bash, Fish, Zsh).
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/CustomizingCompletions.md#_snippet_3

LANGUAGE: Swift
CODE:
```
struct Tool {
    @Option(completion: .shellCommand(generateCommandPerShell()))
    var x: String?

    @Option(completion: .custom(generateCompletionCandidatesPerShell))
    var y: String?
}

/// Runs when a completion script is generated; results hardcoded into script.
func generateCommandPerShell() -> String {
    switch CompletionShell.requesting {
    case CompletionShell.bash:
        return "bash-specific script"
    case CompletionShell.fish:
        return "fish-specific script"
    case CompletionShell.zsh:
        return "zsh-specific script"
    default:
        // return a universal no-op for unknown shells
        return ":"
    }
}

/// Runs during completion while user is typing command line to use your tool
/// Note that the `Version` struct is not included in Swift Argument Parser
func generateCompletionCandidatesPerShell(_ arguments: [String]) -> [String] {
    switch CompletionShell.requesting {
    case CompletionShell.bash:
        if Version(CompletionShell.requestingVersion).major >= 4 {
            return ["A:in:bash4+:syntax", "B:in:bash4+:syntax", "C:in:bash4+:syntax"]
        } else {
            return ["A:in:bash:syntax", "B:in:bash:syntax", "C:in:bash:syntax"]
        }
    case CompletionShell.fish:
        return ["A:in:fish:syntax", "B:in:bash:syntax", "C:in:bash:syntax"]
    case CompletionShell.zsh:
        return ["A:in:zsh:syntax",  "B:in:zsh:syntax",  "C:in:zsh:syntax"]
    default:
        return []
    }
}
```

----------------------------------------

TITLE: Configure Zsh for Completion Autoloading
DESCRIPTION: Provides the necessary Zsh configuration lines to add to `~/.zshrc` to enable completion script autoloading by defining a function path and initializing `compinit`.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/InstallingCompletionScripts.md#_snippet_2

LANGUAGE: zsh
CODE:
```
fpath=(~/.zsh/completion $fpath)
autoload -U compinit
compinit
```

----------------------------------------

TITLE: Generate Bash Completion Script
DESCRIPTION: Demonstrates how to generate a Bash completion script using the `--generate-completion-script` option of a command-line tool built with ArgumentParser. The output is a shell script that defines completion functions.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/InstallingCompletionScripts.md#_snippet_0

LANGUAGE: bash
CODE:
```
$ example --generate-completion-script bash
#compdef example

_example() {
    ...
}

_example
```

----------------------------------------

TITLE: Source Bash Completion Script
DESCRIPTION: Instructs how to source a Bash completion script directly from `~/.bash_profile` or `~/.bashrc` when `bash-completion` is not installed, ensuring the script is loaded upon shell startup.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/InstallingCompletionScripts.md#_snippet_3

LANGUAGE: bash
CODE:
```
source ~/.bash_completions/example.bash
```

----------------------------------------

TITLE: ArgumentParser Flag: Counted Flag Initializers
DESCRIPTION: Initializers for flags that count their occurrences, useful for scenarios like specifying verbosity levels (e.g., -v, -vv).
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Extensions/Flag.md#_snippet_2

LANGUAGE: APIDOC
CODE:
```
init(name:help:)
```

----------------------------------------

TITLE: ArgumentParser Flag: Custom Enumerable Flag Initializers
DESCRIPTION: Initializers for flags that map to custom enumerable types, providing a flexible way to define a set of mutually exclusive options for a flag.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Extensions/Flag.md#_snippet_3

LANGUAGE: APIDOC
CODE:
```
init(help:)
```

LANGUAGE: APIDOC
CODE:
```
init(exclusivity:help:)-38n7u
```

LANGUAGE: APIDOC
CODE:
```
init(exclusivity:help:)-5fggj
```

LANGUAGE: APIDOC
CODE:
```
init(wrappedValue:exclusivity:help:)
```

LANGUAGE: APIDOC
CODE:
```
init(wrappedValue:help:)
```

----------------------------------------

TITLE: Define Parsing Strategies for Command-Line Inputs in Swift Argument Parser
DESCRIPTION: Explains how ArgumentParser distinguishes between dash-prefixed keys and un-prefixed values. By default, values must be adjacent and un-prefixed. Alternative strategies like '.unconditional' (takes the next input, even if dashed) and '.scanningForValue' (scans for the first un-prefixed value) can be used, but may lead to unexpected user behavior.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/DeclaringArguments.md#_snippet_15

LANGUAGE: swift
CODE:
```
struct Example: ParsableCommand {
    @Flag var verbose = false
    @Option var name: String
    @Argument var file: String?

    mutating func run() throws {
        print("Verbose: \(verbose), name: \(name), file: \(file ?? "none")")
    }
}
```

----------------------------------------

TITLE: CLI Usage for math help command
DESCRIPTION: Outlines the usage of the `math help` subcommand, which is used to display help information for other subcommands within the `math` utility.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Tests/ArgumentParserGenerateDoccReferenceTests/Snapshots/testMathDoccReference().md#_snippet_7

LANGUAGE: CLI
CODE:
```
math help [<subcommands>...]  [--version]
```

LANGUAGE: APIDOC
CODE:
```
math help command:
  subcommands: (No description provided)
  --version: Show the version.
```

----------------------------------------

TITLE: Swift ArgumentParser: Up To Next Option Array Parsing Strategy
DESCRIPTION: Explains the `.upToNextOption` parsing strategy for array options. This allows users to specify multiple values for an option without repeating the option key, consuming inputs until another dash-prefixed option or flag is encountered.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/DeclaringArguments.md#_snippet_18

LANGUAGE: swift
CODE:
```
struct Example: ParsableCommand {
    @Option(parsing: .upToNextOption) var file: [String] = []
    @Flag var verbose = false

    mutating func run() throws {
        print("Verbose: \(verbose), files: \(file)")
    }
}
```

----------------------------------------

TITLE: Basic repeat Command Usage
DESCRIPTION: Demonstrates the fundamental command-line syntax for the `repeat` utility, including optional arguments like `--count` and `--include-counter`, and the required `<phrase>`.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Tests/ArgumentParserGenerateDoccReferenceTests/Snapshots/testRepeatMarkdownReference().md#_snippet_0

LANGUAGE: Shell
CODE:
```
repeat [--count=<count>] [--include-counter] <phrase> [--help]
```

----------------------------------------

TITLE: Install Zsh Completion Script with oh-my-zsh
DESCRIPTION: Shows how to generate and redirect a Zsh completion script directly into the `oh-my-zsh` completions directory for automatic loading. The script must be named `_example`.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/InstallingCompletionScripts.md#_snippet_1

LANGUAGE: zsh
CODE:
```
$ example --generate-completion-script zsh > ~/.oh-my-zsh/completions/_example
```

----------------------------------------

TITLE: CLI Usage for math multiply command
DESCRIPTION: Illustrates how to use the `math multiply` subcommand to calculate the product of integer values. It supports an option for hexadecimal output.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Tests/ArgumentParserGenerateDoccReferenceTests/Snapshots/testMathDoccReference().md#_snippet_2

LANGUAGE: CLI
CODE:
```
math multiply [--hex-output] [<values>...] [--version] [--help]
```

LANGUAGE: APIDOC
CODE:
```
math multiply command:
  --hex-output: Use hexadecimal notation for the result.
  values: A group of integers to operate on.
  --version: Show the version.
  --help: Show help information.
```

----------------------------------------

TITLE: Shell Usage for roll Command
DESCRIPTION: Illustrates the general command-line syntax for the `roll` command, including all available options and their placeholders for customization.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Tests/ArgumentParserGenerateDoccReferenceTests/Snapshots/testRollMarkdownReference().md#_snippet_0

LANGUAGE: Shell
CODE:
```
roll [--times=<n>] [--sides=<m>] [--seed=<seed>] [--verbose] [--help]
```

----------------------------------------

TITLE: CLI: math multiply Command
DESCRIPTION: Calculates and prints the product of a group of integers. Supports hexadecimal output.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Tests/ArgumentParserGenerateDoccReferenceTests/Snapshots/testMathMarkdownReference().md#_snippet_2

LANGUAGE: APIDOC
CODE:
```
math multiply [--hex-output] [<values>...] [--version] [--help]
  --hex-output: Use hexadecimal notation for the result.
  values: A group of integers to operate on.
  --version: Show the version.
  --help: Show help information.
```

----------------------------------------

TITLE: Swift ArgumentParser: Unconditional Single Value Array Option Parsing
DESCRIPTION: Illustrates the `.unconditionalSingleValue` parsing strategy for array options. This strategy treats the input immediately following the option key as its value, even if it's dash-prefixed, allowing options to consume subsequent flags as values.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/DeclaringArguments.md#_snippet_17

LANGUAGE: swift
CODE:
```
struct Example: ParsableCommand {
    @Option(parsing: .unconditionalSingleValue) var file: [String] = []
    @Flag var verbose = false

    mutating func run() throws {
        print("Verbose: \(verbose), files: \(file)")
    }
}
```

----------------------------------------

TITLE: Swift ArgumentParser: Remaining Array Option Parsing Strategy
DESCRIPTION: Details the `.remaining` parsing strategy for array options. This strategy consumes all subsequent command-line inputs as values for the option, regardless of their prefix, meaning any flags must be specified before this option.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/DeclaringArguments.md#_snippet_19

LANGUAGE: swift
CODE:
```
struct Example: ParsableCommand {
    @Option(parsing: .remaining) var file: [String] = []
    @Flag var verbose = false

    mutating func run() throws {
        print("Verbose: \(verbose), files: \(file)")
    }
}
```

----------------------------------------

TITLE: Swift ArgumentParser: Collecting Unknown Arguments
DESCRIPTION: Shows how to use the `.allUnrecognized` parsing strategy with an `@Argument` to collect and silently ignore any unknown command-line arguments, preventing `ArgumentParser` from throwing an error.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/DeclaringArguments.md#_snippet_22

LANGUAGE: swift
CODE:
```
struct Example: ParsableCommand {
    @Flag var verbose = false

    @Argument(parsing: .allUnrecognized)
    var unknowns: [String] = []

    func run() throws {
        print("Verbose: \(verbose)")
    }
}
```

----------------------------------------

TITLE: Swift ArgumentParser: Unconditional Remaining Positional Argument Parsing
DESCRIPTION: Illustrates the `.unconditionalRemaining` parsing strategy for positional arguments. This strategy collects all remaining command-line inputs after known options and flags, including dash-prefixed values and the `--` terminator itself.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/DeclaringArguments.md#_snippet_21

LANGUAGE: swift
CODE:
```
struct Example: ParsableCommand {
    @Flag var verbose = false
    @Argument(parsing: .unconditionalRemaining) var files: [String] = []

    mutating func run() throws {
        print("Verbose: \(verbose), files: \(files)")
    }
}
```

----------------------------------------

TITLE: ArgumentParser Flag: Supporting Types
DESCRIPTION: Related types that provide additional configuration and context for `ArgumentParser/Flag` instances, such as defining exclusivity rules.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Extensions/Flag.md#_snippet_5

LANGUAGE: APIDOC
CODE:
```
FlagExclusivity
```

----------------------------------------

TITLE: Manually Parse Root Command with parseAsRoot
DESCRIPTION: Demonstrates how to manually parse a command tree using `Math.parseAsRoot()`, which returns a type-erased `ParsableCommand`. The code includes a `do-catch` block for error handling and a `switch` statement to handle different subcommand types, allowing for custom logic before running the command.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/ManualParsing.md#_snippet_4

LANGUAGE: swift
CODE:
```
do {
    var command = try Math.parseAsRoot()

    switch command {
    case var command as Math.Add:
        print("You chose to add \(command.options.values.count) values.")
        command.run()
    default:
        print("You chose to do something else.")
        try command.run()
    }
} catch {
    Math.exit(withError: error)
}
```

----------------------------------------

TITLE: ArgumentParser Flag: Boolean Flags with Inversions
DESCRIPTION: Initializers for boolean flags that support explicit inversion, allowing for both positive and negative forms of the flag (e.g., --enable and --disable). Includes the FlagInversion type.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Extensions/Flag.md#_snippet_1

LANGUAGE: APIDOC
CODE:
```
init(wrappedValue:name:inversion:exclusivity:help:)
```

LANGUAGE: APIDOC
CODE:
```
init(name:inversion:exclusivity:help:)-12okg
```

LANGUAGE: APIDOC
CODE:
```
init(name:inversion:exclusivity:help:)-1h8f7
```

LANGUAGE: APIDOC
CODE:
```
FlagInversion
```

----------------------------------------

TITLE: Demonstrating File I/O Error Handling in Shell
DESCRIPTION: These shell commands illustrate the behavior of the `LineCount` command when encountering a non-existent file. It shows how `ArgumentParser` presents the underlying system error message, providing clear feedback to the user about the failure.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/Validation.md#_snippet_3

LANGUAGE: Shell
CODE:
```
% line-count file1.swift
37
% line-count non-existing-file.swift
Error: The file “non-existing-file.swift” couldn’t be opened because
there is no such file.
```

----------------------------------------

TITLE: CLI: math stats stdev Command
DESCRIPTION: Calculates and prints the standard deviation of a group of floating-point values.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Tests/ArgumentParserGenerateDoccReferenceTests/Snapshots/testMathMarkdownReference().md#_snippet_5

LANGUAGE: APIDOC
CODE:
```
math stats stdev [<values>...] [--version] [--help]
  values: A group of floating-point values to operate on.
  --version: Show the version.
  --help: Show help information.
```

----------------------------------------

TITLE: count-lines Command Line Interface
DESCRIPTION: Describes the main `count-lines` command, its optional `input-file` argument, and flags such as `--prefix`, `--verbose`, and `--help`. It explains how to count lines from a specified file or standard input, with options to filter by prefix or include verbose output.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Tests/ArgumentParserGenerateDoccReferenceTests/Snapshots/testCountLinesMarkdownReference().md#_snippet_0

LANGUAGE: APIDOC
CODE:
```
count-lines [<input-file>] [--prefix=<prefix>] [--verbose] [--help]

input-file:
  A file to count lines in. If omitted, counts the lines of stdin.

--prefix=<prefix>:
  Only count lines with this prefix.

--verbose:
  Include extra information in the output.

--help:
  Show help information.
```

----------------------------------------

TITLE: ArgumentParser AsyncParsableCommand API Reference
DESCRIPTION: Reference for key methods and protocols related to `ArgumentParser/AsyncParsableCommand`, detailing elements for implementing command behavior and starting the program.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Extensions/AsyncParsableCommand.md#_snippet_2

LANGUAGE: APIDOC
CODE:
```
Implementing a Command's Behavior:
- run()

Starting the Program:
- main()
- AsyncMainProtocol
```

----------------------------------------

TITLE: repeat Command Arguments Reference
DESCRIPTION: Detailed reference for the arguments and options available for the `repeat` command, explaining their purpose and usage.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Tests/ArgumentParserGenerateDoccReferenceTests/Snapshots/testRepeatMarkdownReference().md#_snippet_1

LANGUAGE: APIDOC
CODE:
```
--count=<count>:
  The number of times to repeat 'phrase'.
--include-counter:
  Include a counter with each repetition.
phrase:
  The phrase to repeat.
--help:
  Show help information.
```

----------------------------------------

TITLE: ArgumentParser ParsableArguments Protocol API Reference
DESCRIPTION: Comprehensive API documentation for the `ParsableArguments` protocol, outlining its various methods for handling command-line argument parsing, validation, program control, help generation, error management, and shell completion script generation.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Extensions/ParsableArguments.md#_snippet_0

LANGUAGE: APIDOC
CODE:
```
ParsableArguments Protocol:
  Topics:
    Handling Validation:
      - validate()
    Parsing a Type:
      - parse(_:)
      - parseOrExit(_:)
    Exiting a Program:
      - exit(withError:)
    Generating Help Text:
      - helpMessage(includeHidden:columns:)
    Handling Errors:
      - message(for:)
      - fullMessage(for:columns:)
      - exitCode(for:)
    Generating Completion Scripts:
      - completionScript(for:)
      - CompletionShell
    Infrequently Used APIs:
      - init()
```

----------------------------------------

TITLE: Process and Print Selected Elements
DESCRIPTION: Processes the parsed elements by shuffling them and then taking a prefix based on the `count` option. The chosen elements are then joined by newlines and printed to the console, demonstrating the final output logic.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/ManualParsing.md#_snippet_3

LANGUAGE: swift
CODE:
```
let chosen = options.elements
    .shuffled()
    .prefix(options.count)
print(chosen.joined(separator: "\n"))
```

----------------------------------------

TITLE: ArgumentParser Experimental Feature: Dump Help as JSON
DESCRIPTION: Describes the `--experimental-dump-help` feature in Swift ArgumentParser, available from version 0.5.0. This experimental flag outputs detailed command, argument, and help information in a structured JSON format. Users should be aware that this feature is unstable and its behavior or existence may change in future releases.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/ExperimentalFeatures.md#_snippet_0

LANGUAGE: JSON
CODE:
```
{
  "command": {
    "name": "<command_name>",
    "description": "<command_description>",
    "arguments": [
      {
        "name": "<argument_name>",
        "type": "<argument_type>",
        "description": "<argument_description>",
        "required": "<boolean>"
      }
    ],
    "subcommands": [
      {
        "name": "<subcommand_name>",
        "description": "<subcommand_description>"
      }
    ]
  },
  "help": "<full_help_text>"
}
```

----------------------------------------

TITLE: color Command Main Usage
DESCRIPTION: Illustrates the basic command-line usage of the `color` tool, showing how to specify favorite and optional second favorite colors, and how to request help.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Tests/ArgumentParserGenerateDoccReferenceTests/Snapshots/testColorDoccReference().md#_snippet_0

LANGUAGE: CLI
CODE:
```
color --fav=<fav> [--second=<second>] [--help]
```

----------------------------------------

TITLE: ArgumentParser ParsableCommand API Reference
DESCRIPTION: Reference for key methods and configurations related to `ArgumentParser/ParsableCommand`.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Extensions/ParsableCommand.md#_snippet_1

LANGUAGE: APIDOC
CODE:
```
Topics:
  Essentials:
    - CommandsAndSubcommands
    - CustomizingCommandHelp
  Implementing a Command's Behavior:
    - run()
    - ParsableArguments/validate()
  Customizing a Command:
    - configuration
    - CommandConfiguration
  Generating Help Text:
    - helpMessage(for:includeHidden:columns:)
  Starting the Program:
    - main()
    - main(_:)
  Manually Parsing Input:
    - parseAsRoot(_)
```

----------------------------------------

TITLE: CLI Usage for math command
DESCRIPTION: Shows the basic usage of the top-level `math` command, including options to display the version and help information.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Tests/ArgumentParserGenerateDoccReferenceTests/Snapshots/testMathDoccReference().md#_snippet_0

LANGUAGE: CLI
CODE:
```
math [--version] [--help]
```

LANGUAGE: APIDOC
CODE:
```
math command:
  --version: Show the version.
  --help: Show help information.
```

----------------------------------------

TITLE: ArgumentParser CommandConfiguration API Reference
DESCRIPTION: This snippet provides a structured overview of the `CommandConfiguration` type in Swift's ArgumentParser library. It lists the main initializer and various properties categorized by their purpose, such as configuring help messages, managing subcommands, and setting general command attributes.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Extensions/CommandConfiguration.md#_snippet_0

LANGUAGE: APIDOC
CODE:
```
ArgumentParser/CommandConfiguration:
  Topics:
    Creating a Configuration:
      - init(commandName:abstract:usage:discussion:version:shouldDisplay:subcommands:groupedSubcommands:defaultSubcommand:helpNames:aliases:)
    Customizing the Help Screen:
      - abstract
      - discussion
      - usage
      - helpNames
    Declaring Subcommands:
      - subcommands
      - defaultSubcommand
    Defining Command Properties:
      - commandName
      - version
      - shouldDisplay
      - aliases
```

----------------------------------------

TITLE: Example `math` Utility Command-Line Usage
DESCRIPTION: This snippet demonstrates the command-line interface of a `math` utility, showcasing how to use its `add`, `multiply`, and `stats` subcommands. It also illustrates the use of options like `--kind` and how the help output is structured for subcommands.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Articles/CommandsAndSubcommands.md#_snippet_0

LANGUAGE: shell
CODE:
```
% math add 10 15 7
32
% math multiply 10 15 7
1050
% math stats average 3 4 13 15 15
10.0
% math stats average --kind median 3 4 13 15 15
13.0
% math stats
OVERVIEW: Calculate descriptive statistics.

USAGE: math stats <subcommand>

OPTIONS:
  -h, --help              Show help information.

SUBCOMMANDS:
  average, avg            Print the average of the values.
  stdev                   Print the standard deviation of the values.
  quantiles               Print the quantiles of the values (TBD).

  See 'math help stats <subcommand>' for detailed help.
```

----------------------------------------

TITLE: Declare Asynchronous Main Entry Point for Swift 5.5 Argument Parser
DESCRIPTION: Provides the necessary structure for declaring an asynchronous `@main` entry point when using Swift Argument Parser with Swift 5.5. Unlike newer Swift versions, the root command cannot be directly marked `@main`; instead, a separate `AsyncMain` struct conforming to `AsyncMainProtocol` is used as the entry point, replacing a placeholder with the actual root command name.
SOURCE: https://github.com/apple/swift-argument-parser/blob/main/Sources/ArgumentParser/Documentation.docc/Extensions/AsyncParsableCommand.md#_snippet_1

LANGUAGE: Swift
CODE:
```
@main struct AsyncMain: AsyncMainProtocol {
    typealias Command = <#RootCommand#>
}
```