TITLE: Initialize Swift Project for OpenAPI Generator
DESCRIPTION: These commands demonstrate how to create a new directory for a Swift project and initialize it as an executable Swift package. This is a common first step when setting up a client or server using Swift OpenAPI Generator.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Tutorials/_Resources/client.console.2.1.txt#_snippet_0

LANGUAGE: Shell
CODE:
```
% mkdir GreetingServiceClient

% swift package --package-path GreetingServiceClient init --type executable
```

----------------------------------------

TITLE: Initialize and use a Swift OpenAPI client
DESCRIPTION: This Swift code demonstrates how to initialize a generated API client using OpenAPIURLSession and URLSessionTransport. It shows how to make an asynchronous API call (getGreeting) and access the parsed JSON message from the successful response.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/README.md#_snippet_0

LANGUAGE: Swift
CODE:
```
import OpenAPIURLSession
import Foundation

let client = Client(
    serverURL: URL(string: "http://localhost:8080/api")!,
    transport: URLSessionTransport()
)
let response = try await client.getGreeting()
print(try response.ok.body.json.message)
```

----------------------------------------

TITLE: Clone Swift OpenAPI Generator Repository and Access Example
DESCRIPTION: These shell commands facilitate the initial setup of the Swift OpenAPI Generator project. First, the 'git clone' command downloads the entire repository from GitHub. Subsequently, the 'cd' command changes the current working directory to a specific example project within the cloned repository, 'hello-world-vapor-server-example', preparing the environment for further development or testing.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Tutorials/_Resources/client.console.1.0.txt#_snippet_0

LANGUAGE: Shell
CODE:
```
git clone https://github.com/apple/swift-openapi-generator
cd swift-openapi-generator/Examples/hello-world-vapor-server-example
```

----------------------------------------

TITLE: Enabling Swift OpenAPI Generator Build Plugin in Xcode and Xcode Cloud
DESCRIPTION: This snippet provides instructions to enable the Swift OpenAPI Generator build plugin, addressing the 'OpenAPIGenerator' is disabled error. It includes steps for enabling the plugin directly in Xcode and a Bash script for Xcode Cloud environments.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Articles/Frequently-asked-questions.md#_snippet_1

LANGUAGE: Bash
CODE:
```
#!/usr/bin/env bash

set -e

# NOTE: the misspelling of validation as "validatation" is intentional and the spelling Xcode expects.
defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidatation -bool YES
```

----------------------------------------

TITLE: Using a generated API client in Swift
DESCRIPTION: This Swift code snippet demonstrates how to initialize and use a generated 'Client' type. It shows how to connect to a server using 'URLSessionTransport' and make an asynchronous API call (getGreeting) to retrieve and print a message from the response.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Swift-OpenAPI-Generator.md#_snippet_0

LANGUAGE: swift
CODE:
```
import OpenAPIURLSession
import Foundation

let client = Client(
    serverURL: URL(string: "http://localhost:8080/api")!,
    transport: URLSessionTransport()
)
let response = try await client.getGreeting()
print(try response.ok.body.json.message)
```

----------------------------------------

TITLE: Implementing API server stubs with Swift and Vapor
DESCRIPTION: This Swift code snippet illustrates how to implement an API server using generated stubs. It defines a 'Handler' struct conforming to 'APIProtocol' to handle the 'getGreeting' operation, dynamically setting the greeting message. The example then integrates this handler with the Vapor web framework using 'VaporTransport' to set up and run a simple HTTP server.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Swift-OpenAPI-Generator.md#_snippet_1

LANGUAGE: swift
CODE:
```
import OpenAPIRuntime
import OpenAPIVapor
import Vapor

struct Handler: APIProtocol {
    func getGreeting(_ input: Operations.GetGreeting.Input) async throws -> Operations.GetGreeting.Output {
        let name = input.query.name ?? "Stranger"
        return .ok(.init(body: .json(.init(message: "Hello, \(name)!" ))))
    }
}

@main struct HelloWorldVaporServer {
    static func main() async throws {
        let app = try await Application.make()
        let transport = VaporTransport(routesBuilder: app)
        let handler = Handler()
        try handler.registerHandlers(on: transport, serverURL: URL(string: "/api")!)
        try await app.execute()
    }
}
```

----------------------------------------

TITLE: Build Swift Project
DESCRIPTION: This command demonstrates how to build the Swift project using the Swift Package Manager from the console.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/type-overrides-example/README.md#_snippet_0

LANGUAGE: console
CODE:
```
% swift build
Build complete!
```

----------------------------------------

TITLE: API Stability Impact of OpenAPI Document Changes
DESCRIPTION: Outlines the impact of various changes to an OpenAPI document on the HTTP, OpenAPI specification, and generated Swift code, indicating whether each change is breaking (❌) or non-breaking (✅). It also includes important notes on specific change types.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Articles/API-stability-of-generated-code.md#_snippet_1

LANGUAGE: APIDOC
CODE:
```
| Change | HTTP | OpenAPI | Swift |
| -: | :-: | :-: | :-: |
| Add a new schema | ✅ | ✅ | ✅ |
| Add a new property to an existing schema (†) | ✅ | ✅ | ⚠️ |
| Add a new operation | ✅ | ✅ | ✅ |
| Add a new response to an existing operation (‡) | ✅ | ❌ | ❌ |
| Add a new content type to an existing response (§) | ✅ | ❌ | ❌ |
| Remove a required property | ❌ | ❌ | ❌ |
| Rename a schema | ✅ | ❌ | ❌ |

Notes:
†: Safe change to make as long as no adopter captured the Swift function signature of the initializer of the generated struct, which gains a new parameter. Rare, but something to be aware of. Note that when upgrading the generator to a newer version, we reserve the right to add new defaulted properties to generated structs, so such a change is considered non-breaking. For that reason, avoid capturing the function signature of the initializer of any generated struct.
‡: Adding a new response to an existing operation introduces a new enum case that the adopter needs to handle, so is a breaking change in OpenAPI and Swift.
§: Adding a new content type to an existing response is similar to ‡: it introduces a new enum case that the adopter needs to handle, so is a breaking change in OpenAPI and Swift.
```

----------------------------------------

TITLE: Implement a Swift OpenAPI server with generated stubs
DESCRIPTION: This Swift example shows how to implement an API server by conforming to a generated APIProtocol. It defines a Handler to process the getGreeting operation, extracts a query parameter, and constructs a JSON response. The HelloWorldVaporServer then registers this handler with VaporTransport.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/README.md#_snippet_1

LANGUAGE: Swift
CODE:
```
import OpenAPIRuntime
import OpenAPIVapor
import Vapor

struct Handler: APIProtocol {
    func getGreeting(_ input: Operations.GetGreeting.Input) async throws -> Operations.GetGreeting.Output {
        let name = input.query.name ?? "Stranger"
        return .ok(.init(body: .json(.init(message: "Hello, \(name)!"))))
    }
}

@main struct HelloWorldVaporServer {
    static func main() async throws {
        let app = try await Application.make()
        let transport = VaporTransport(routesBuilder: app)
        let handler = Handler()
        try handler.registerHandlers(on: transport, serverURL: URL(string: "/api")!)
        try await app.execute()
    }
}
```

----------------------------------------

TITLE: Example OpenAPI Document for Greeting Service
DESCRIPTION: A sample OpenAPI 3.1.0 document defining a simple GreetingService. It includes a `/greet` endpoint with a GET method, an optional `name` query parameter, and a `200` response that returns a `Greeting` object. The `Greeting` schema defines a single `message` property.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Swift-OpenAPI-Generator.md#_snippet_2

LANGUAGE: yaml
CODE:
```
openapi: '3.1.0'
info:
  title: GreetingService
  version: 1.0.0
servers:
  - url: https://example.com/api
    description: Example service deployment.
paths:
  /greet:
    get:
      operationId: getGreeting
      parameters:
        - name: name
          required: false
          in: query
          description: The name used in the returned greeting.
          schema:
            type: string
      responses:
        '200':
          description: A success response with a greeting.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Greeting'
components:
  schemas:
    Greeting:
      type: object
      description: A value with the greeting contents.
      properties:
        message:
          type: string
          description: The string representation of the greeting.
      required:
        - message
```

----------------------------------------

TITLE: Instantiating and Using a Generated Swift OpenAPI Client
DESCRIPTION: This Swift code snippet illustrates the process of instantiating a concrete client transport implementation and then using it to create an instance of the generated OpenAPI client. It demonstrates how to make an API call using the client, showcasing the interaction between the transport and the generated client.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0005.md#_snippet_0

LANGUAGE: Swift
CODE:
```
// Instantiate a concrete transport implementation.
let transport: any ClientTransport = ... // any client transport

// Instantiate the generated client by providing it with the transport.
let client = Client(transport: transport)

// Make API calls
let response = try await client.getStats(...)
...
```

----------------------------------------

TITLE: Use Curated Library Client in Swift
DESCRIPTION: This snippet shows how to integrate and use the `CuratedLibraryClient` in another Swift package. It demonstrates initializing `GreetingClient` and asynchronously fetching a greeting message, abstracting away the underlying OpenAPI generation.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/curated-client-library-example/README.md#_snippet_0

LANGUAGE: swift
CODE:
```
import CuratedLibraryClient

let client = GreetingClient()
let message = try await client.getGreeting(name: "Frank")
print("Received the greeting message: \(message)")
```

----------------------------------------

TITLE: Swift OpenAPI Generator: Type-Safe Server URL Usage Examples
DESCRIPTION: These Swift examples illustrate the usage of the newly generated type-safe `Servers.Server1.url` function. They show how valid enum values compile successfully, while invalid or undefined enum values result in compile-time errors, demonstrating the enhanced type safety.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0012.md#_snippet_4

LANGUAGE: Swift
CODE:
```
let url = try Servers.Server1.url() // ✅ compiles

let url = try Servers.Server1.url(environment: .default)  // ✅ compiles

let url = try Servers.Server1.url(environment: .staging)  // ✅ compiles

let url = try Servers.Server1.url(environment: .stg)  // ❌ compiler error, 'stg' not defined on the enum
```

----------------------------------------

TITLE: Example API Call with Curl
DESCRIPTION: Demonstrates a simple API call to an example endpoint using the curl command-line tool, showing a GET request with a query parameter and the expected JSON response.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Articles/API-stability-of-generated-code.md#_snippet_0

LANGUAGE: Shell
CODE:
```
% curl http://example.com/api/hello/Maria?greeting=Howdy
{
  "message": "Howdy, Maria!"
}
```

----------------------------------------

TITLE: Making a GET Request with Curl and Receiving JSON Response
DESCRIPTION: This snippet demonstrates how to make a GET request to the '/api/greet' endpoint using the 'curl' command-line tool, including the expected JSON response from the server. It shows a basic interaction with an API endpoint, passing a 'name' query parameter.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Tutorials/_Resources/server.console.2.txt#_snippet_0

LANGUAGE: Shell
CODE:
```
% curl 'http://localhost:8080/api/greet?name=Jane'
```

LANGUAGE: JSON
CODE:
```
{
  "message" : "Hello, Jane!"
}
```

----------------------------------------

TITLE: Build and Run Server CLI
DESCRIPTION: Instructions to build and start the server CLI application using Swift Package Manager, which will launch the server on http://127.0.0.1:8080.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/various-content-types-server-example/README.md#_snippet_1

LANGUAGE: console
CODE:
```
% swift run
2023-12-01T14:14:35+0100 notice codes.vapor.application : [Vapor] Server starting on http://127.0.0.1:8080
...
```

----------------------------------------

TITLE: GreetingService OpenAPI Specification
DESCRIPTION: This OpenAPI specification defines the GreetingService API. It includes a single GET endpoint at '/greet' that accepts an optional 'name' query parameter and returns a 'Greeting' object containing a message. The API is version 1.0.0 and hosted at 'https://example.com/api'.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0007.md#_snippet_9

LANGUAGE: APIDOC
CODE:
```
openapi: '3.0.3'
info:
  title: GreetingService
  version: 1.0.0
servers:
  - url: https://example.com/api
    description: Example
paths:
  /greet:
    get:
      operationId: getGreeting
      parameters:
      - name: name
        required: false
        in: query
        description: A name used in the returned greeting.
        schema:
          type: string
      responses:
        '200':
          description: A success response with a greeting.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Greeting'
components:
  schemas:
    Greeting:
      type: object
      properties:
        message:
          type: string
      required:
        - message
```

----------------------------------------

TITLE: Swift: Consume MultipartBody as Async Sequence
DESCRIPTION: This code demonstrates consuming a `MultipartBody` in a streaming fashion by iterating over it as an `AsyncSequence`. It shows how to handle different part types using a `switch` statement and process their individual bodies. Part bodies can be processed in chunks or accumulated into a byte array, enabling efficient handling of large multipart data without buffering the entire content.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0009.md#_snippet_25

LANGUAGE: Swift
CODE:
```
let multipartBody: MultipartBody<MyPartType> = ...
for try await part in multipartBody {
   switch part {
   case .myCaseA(let myCaseAValue):
       // Handle myCaseAValue.
   case .myCaseB(let myCaseBValue):
       // Handle myCaseBValue, which is a raw type with a streaming part body.
       //
       // Option 1: Process the part body bytes in chunks.
       for try await bodyChunk in myCaseBValue.body {
           // Handle bodyChunk.
       }
       // Option 2: Accumulate the body into a byte array.
       // (For other convenience initializers, check out ``HTTPBody``.
       let fullPartBody = try await [UInt8](collecting: myCaseBValue.body, upTo: 1024)
   // ...
   }
}
```

----------------------------------------

TITLE: Swift Extensions for Simplified Output Handling
DESCRIPTION: Demonstrates extensions for Operations.getGreeting.Output and Operations.getGreeting.Output.Ok.Body. These extensions add throwing computed properties (ok, json) that allow direct access to specific documented response outcomes and content types, simplifying error handling for unexpected responses.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0007.md#_snippet_7

LANGUAGE: APIDOC
CODE:
```
// Note: Generating an extension is not prescriptive; implementations may
// generate these properties within the primary type definition.
extension Operations.getGreeting.Output {
    // A throwing computed property is generated for each documented outcome.
    var ok: Operations.getGreeting.Output.Ok {
        get throws {
            guard case let .ok(response) = self else {
                // This error will be added to the OpenAPIRuntime library.
                throw UnexpectedResponseError(expected: "ok", actual: self)
            }
            return response
        }
    }
    // Note: a property is _not_ generated for the undocumented enum case.
}

// Note: Generating an extension is not prescriptive; implementations may
// generate these properties within the primary type definition.
extension Operations.getGreeting.Output.Ok.Body {
    // A throwing computed property is generated for each document content type.
    var json: Components.Schemas.Greeting {
        get throws {
            guard case let .json(body) = self else {
                // This error will be added to the OpenAPIRuntime library.
                throw UnexpectedContentError(expected: "json", actual: self)
            }
            return body
        }
    }
}
```

----------------------------------------

TITLE: Swift OpenAPI Generator Configuration File Schema Reference
DESCRIPTION: Detailed reference for the `openapi-generator-config.yaml` file, outlining all available keys, their types, descriptions, default values, and possible options for customizing the Swift OpenAPI Generator's behavior.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Articles/Configuring-the-generator.md#_snippet_1

LANGUAGE: APIDOC
CODE:
```
openapi-generator-config.yaml:
  generate:
    type: array of strings
    required: true
    description: Modes for generator invocation.
    values:
      - types: Common types and abstractions.
      - client: Client code.
      - server: Server code.
  accessModifier:
    type: string
    required: false
    default: internal
    description: Customizes visibility of generated code API.
    values:
      - public: Accessible from other modules/packages.
      - package: Accessible from other modules in same package/project.
      - internal: Accessible from containing module only.
  additionalImports:
    type: array of strings
    required: false
    description: Swift module names to import.
  additionalFileComments:
    type: array of strings
    required: false
    description: Comments added to top of generated files.
  filter:
    type: object
    required: false
    description: Filters to apply to OpenAPI document.
    properties:
      operations:
        type: array of strings
        description: Operation IDs to include.
      tags:
        type: array of strings
        description: Tags to include.
      paths:
        type: array of strings
        description: Paths to include.
      schemas:
        type: array of strings
        description: Additional schemas to include.
  namingStrategy:
    type: string
    required: false
    default: defensive
    description: Strategy for converting OpenAPI identifiers to Swift identifiers.
    values:
      - defensive: Produces non-conflicting Swift identifiers.
      - idiomatic: Produces more idiomatic Swift identifiers (might conflict).
  nameOverrides:
    type: string to string dictionary
    required: false
    description: Customize OpenAPI to Swift identifier conversion.
  typeOverrides:
    type: object
    required: false
    description: Replace generated types with custom types.
    properties:
      schemas:
        type: string to string dictionary
        required: false
        description: Key is schema name, value is custom type name.
  featureFlags:
    type: array of strings
    required: false
    description: Valid feature flags to enable.
```

----------------------------------------

TITLE: Run Swift OpenAPI Client CLI
DESCRIPTION: This command builds and executes the Swift OpenAPI client command-line tool. The client then makes a request to the local Greeting Service and prints the received response to the console.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/hello-world-async-http-client-example/README.md#_snippet_0

LANGUAGE: Console
CODE:
```
% swift run
Hello, Stranger!
```

----------------------------------------

TITLE: Consuming and Processing Multipart Body Sequence in Swift
DESCRIPTION: Demonstrates how to iterate over an `OpenAPIRuntime.MultipartBody` sequence to consume its parts. It includes a `switch` statement to handle different part types (metadata, contents, undocumented), print metadata, and write file contents to disk. It also highlights the requirement to consume streaming bodies before moving to the next part.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0009.md#_snippet_8

LANGUAGE: swift
CODE:
```
let multipartBody: OpenAPIRuntime.MultipartBody<Operations.uploadPhoto.Input.Body.multipartFormPayload> = ...
for try await part in multipartBody {
    switch part {
    case .metadata(let metadataPart):
        let metadata = metadataPart.payload
        print("x-sender-id: \(metadata.headers.x_dash_sender_dash_id ?? "<nil>")")
        print("Cat name: \(metadata.body.objectCatName)")
        print("Photographer ID: \(metadata.body.photographerId?.description ?? "<nil>")")
    case .contents(let contentsPart):
        // Ensure the incoming filepath doesn't try to escape to a parent directory, and so on, before using it.
        let fileName = contentsPart.filename ?? "\(UUID().uuidString).jpg"
        guard let outputStream = OutputStream(toFileAtPath: "/tmp/received-cat-photos/\(fileName)", shouldAppend: false) else {
            // failed to open a stream
        }
        outputStream.open()
        defer {
            outputStream.close()
        }
        // Consume the body before moving to the next part.
        for try await chunk in contentsPart.body {
            chunk.withUnsafeBufferPointer { _ = outputStream.write($0.baseAddress!, maxLength: $0.count) }
        }
    case .undocumented(let rawPart):
        print("Received an undocumented part with header fields: \(rawPart.headerFields)")
        // Consume the body before moving to the next part.
        _ = try await ArraySlice<UInt8>(collecting: rawPart.body, upTo: 10 * 1024 * 1024)
    }
}
```

----------------------------------------

TITLE: Greeting Service OpenAPI 3.1.0 Specification
DESCRIPTION: This is a partial OpenAPI 3.1.0 specification for a 'GreetingService'. It defines basic API information, a server URL, and a GET endpoint at '/greet' with an 'operationId' and a 'name' parameter.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Tutorials/_Resources/server-openapi-endpoints.console.2.txt#_snippet_1

LANGUAGE: APIDOC
CODE:
```
openapi: '3.1.0'
info:
  title: GreetingService
  version: 1.0.0
servers:
  - url: https://example.com/api
    description: Example service deployment.
paths:
  /greet:
    get:
      operationId: getGreeting
      parameters:
        - name: name
```

----------------------------------------

TITLE: Run Swift CLI Client
DESCRIPTION: Builds and runs the client command-line interface using the Swift Package Manager. Ensure the server is running locally before executing this command.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/various-content-types-client-example/README.md#_snippet_0

LANGUAGE: Console
CODE:
```
% swift run
```

----------------------------------------

TITLE: Swift OpenAPI Generator: Type-Safe Server URL Generation
DESCRIPTION: This Swift code demonstrates the generation of type-safe server URL construction from OpenAPI definitions. It defines an `Environment` enum for server environments (prod, staging, dev) and a `url` static function that uses this enum for compile-time validation. It also includes a deprecated `server1` function for backward compatibility, which accepts string-based environment values.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0012.md#_snippet_3

LANGUAGE: Swift
CODE:
```
/// Server URLs defined in the OpenAPI document.
internal enum Servers {
    /// Example service deployment.
    internal enum Server1 {
        /// Server environment.
        ///
        /// The "environment" variable defined in the OpenAPI document. The default value is ``prod``.
        internal enum Environment: Swift.String {
            case prod
            case staging
            case dev
        }
        ///
        /// - Parameters:
        ///   - environment: Server environment.
        ///   - version:
        internal static func url(
            environment: Environment = Environment.prod,
            version: Swift.String = "v1"
        ) throws -> Foundation.URL {
            try Foundation.URL(
                validatingOpenAPIServerURL: "https://{environment}.example.com/api/{version}",
                variables: [
                    .init(
                        name: "environment",
                        value: environment.rawValue
                    ),
                    .init(
                        name: "version",
                        value: version
                    )
                ]
            )
        }
    }
    /// Example service deployment.
    ///
    /// - Parameters:
    ///   - environment: Server environment.
    ///   - version:
    @available(*, deprecated, message: "Migrate to the new type-safe API for server URLs.")
    internal static func server1(
        environment: Swift.String = "prod",
        version: Swift.String = "v1"
    ) throws -> Foundation.URL {
        try Foundation.URL(
            validatingOpenAPIServerURL: "https://{environment}.example.com/api/{version}",
            variables: [
                .init(
                    name: "environment",
                    value: environment,
                    allowedValues: [
                        "prod",
                        "staging",
                        "dev"
                    ]
                ),
                .init(
                    name: "version",
                    value: version
                )
            ]
        )
    }
}
```

----------------------------------------

TITLE: Example of Manual Error Mapping in Swift Handler
DESCRIPTION: This Swift code snippet illustrates the current, verbose method of handling errors within an OpenAPI handler. It uses a `do-catch` block with a `switch` statement to manually map different `GreetingError` types to specific HTTP responses, demonstrating the linear scaling of complexity with more error types.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0011.md#_snippet_0

LANGUAGE: Swift
CODE:
```
func getGreeting(_ input: Operations.getGreeting.Input) async throws -> Operations.getGreeting.Output {
  do {
      let response = try callGreetingLib()
      return .ok(.init(body: response))
  } catch let error {
    switch error {
      case GreetingError.authorizationError:
        return .unauthorized(.init())
      case GreetingError.timeout:
        return ...
    }
  }
}
```

----------------------------------------

TITLE: OpenAPI Schema for JSON Lines Streaming Response
DESCRIPTION: This OpenAPI YAML snippet defines a GET endpoint `/greetings` that is configured to return a stream of `Greeting` objects. The `application/jsonl` content type specifies that the response body will consist of individual JSON objects, each terminated by a newline, representing a stream of events. The `schema` references a `Greeting` component, which defines the structure of each object within the stream.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0010.md#_snippet_0

LANGUAGE: yaml
CODE:
```
paths:
  /greetings:
    get:
      operationId: getGreetingsStream
      responses:
        '200':
          content:
            application/jsonl:
              schema:
                $ref: '#/components/schemas/Greeting'
components:
  schemas:
    Greeting:
      type: object
      properties:
        ...
```

----------------------------------------

TITLE: Swift OpenAPI Generated API Protocol and Types
DESCRIPTION: Defines the core APIProtocol with its getGreeting operation requirement. It also details the Operations.getGreeting enum, including its Input struct (with initializer) and Output enum, which covers Ok responses and undocumented cases. This snippet illustrates the fundamental structure of the generated API surface for an operation.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0007.md#_snippet_5

LANGUAGE: APIDOC
CODE:
```
public protocol APIProtocol: Sendable {
    // A function requirement is generated for each operation. It takes an
    // input type, comprising all parameters, and returns an output type, which
    // is an nested enum covering all possible responses.
    func getGreeting(_ input: Operations.getGreeting.Input) async throws -> Operations.getGreeting.Output
}

public enum Operations {
    public enum getGreeting {
        public struct Input: Sendable, Hashable {
            // If all parameters have default values, then the initializer
            // parameter also has a default value.
            public init(
                query: Operations.getGreeting.Input.Query = .init(),
                headers: Operations.getGreeting.Input.Headers = .init()
            ) {
                self.query = query
                self.headers = headers
            }
        }
        @frozen public enum Output: Sendable, Hashable {
            public struct Ok: Sendable, Hashable {
                @frozen public enum Body: Sendable, Hashable {
                    case json(Components.Schemas.Greeting)
                }
                public var body: Operations.getGreeting.Output.Ok.Body
                public init(body: Operations.getGreeting.Output.Ok.Body) { self.body = body }
            }
            // An enum case is generated for each documented response.
            case ok(Operations.getGreeting.Output.Ok)
            // An additional enum case is generated for any undocumented response.
            case undocumented(statusCode: Int, OpenAPIRuntime.UndocumentedPayload)
        }
    }
}
```

----------------------------------------

TITLE: HTTP POST Request with Multipart Form Data
DESCRIPTION: Shows an HTTP POST request using 'multipart/form-data' to send multiple payloads in a single message. It includes two parts: one for JSON metadata and another for an image, each with its own headers and content. This demonstrates the use of a boundary string to separate individual parts within the request body.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0009.md#_snippet_2

LANGUAGE: HTTP
CODE:
```
> POST /photos HTTP/1.1
> content-type: multipart/form-data; boundary=___MY_BOUNDARY_1234__
>
> --___MY_BOUNDARY_1234__
> content-disposition: form-data; name="metadata"
> content-type: application/json
> x-sender-id: zoom123
>
> {"objectCatName":"Waffles","photographerId":24}
> --___MY_BOUNDARY_1234__
> content-disposition: form-data; name="contents"
> content-type: image/jpeg
>
> ...
> --___MY_BOUNDARY_1234__--
---
< HTTP/1.1 204 No Content
```

----------------------------------------

TITLE: OpenAPI Generator Helper Method Reference Table
DESCRIPTION: A comprehensive reference table listing helper methods for client and server operations, detailing their context (common, client, server), action (set/get), data location (header, path, query, body), coding strategy (URI, JSON, binary, urlEncodedForm, multipart), and optionality/requirement, along with the exact method name.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Development/Converting-between-data-and-Swift-types.md#_snippet_4

LANGUAGE: APIDOC
CODE:
```
Method: setHeaderFieldAsURI
  Context: common
  Operation: set
  Location: header field
  Strategy: URI
  Optionality: both
---
Method: setHeaderFieldAsJSON
  Context: common
  Operation: set
  Location: header field
  Strategy: JSON
  Optionality: both
---
Method: getOptionalHeaderFieldAsURI
  Context: common
  Operation: get
  Location: header field
  Strategy: URI
  Optionality: optional
---
Method: getRequiredHeaderFieldAsURI
  Context: common
  Operation: get
  Location: header field
  Strategy: URI
  Optionality: required
---
Method: getOptionalHeaderFieldAsJSON
  Context: common
  Operation: get
  Location: header field
  Strategy: JSON
  Optionality: optional
---
Method: getRequiredHeaderFieldAsJSON
  Context: common
  Operation: get
  Location: header field
  Strategy: JSON
  Optionality: required
---
Method: renderedPath
  Context: client
  Operation: set
  Location: request path
  Strategy: URI
  Optionality: required
---
Method: setQueryItemAsURI
  Context: client
  Operation: set
  Location: request query
  Strategy: URI
  Optionality: both
---
Method: setOptionalRequestBodyAsJSON
  Context: client
  Operation: set
  Location: request body
  Strategy: JSON
  Optionality: optional
---
Method: setRequiredRequestBodyAsJSON
  Context: client
  Operation: set
  Location: request body
  Strategy: JSON
  Optionality: required
---
Method: setOptionalRequestBodyAsBinary
  Context: client
  Operation: set
  Location: request body
  Strategy: binary
  Optionality: optional
---
Method: setRequiredRequestBodyAsBinary
  Context: client
  Operation: set
  Location: request body
  Strategy: binary
  Optionality: required
---
Method: setOptionalRequestBodyAsURLEncodedForm
  Context: client
  Operation: set
  Location: request body
  Strategy: urlEncodedForm
  Optionality: optional
---
Method: setRequiredRequestBodyAsURLEncodedForm
  Context: client
  Operation: set
  Location: request body
  Strategy: urlEncodedForm
  Optionality: required
---
Method: setRequiredRequestBodyAsMultipart
  Context: client
  Operation: set
  Location: request body
  Strategy: multipart
  Optionality: required
---
Method: getResponseBodyAsJSON
  Context: client
  Operation: get
  Location: response body
  Strategy: JSON
  Optionality: required
---
Method: getResponseBodyAsBinary
  Context: client
  Operation: get
  Location: response body
  Strategy: binary
  Optionality: required
---
Method: getResponseBodyAsMultipart
  Context: client
  Operation: get
  Location: response body
  Strategy: multipart
  Optionality: required
---
Method: getPathParameterAsURI
  Context: server
  Operation: get
  Location: request path
  Strategy: URI
  Optionality: required
---
Method: getOptionalQueryItemAsURI
  Context: server
  Operation: get
  Location: request query
  Strategy: URI
  Optionality: optional
---
Method: getRequiredQueryItemAsURI
  Context: server
  Operation: get
  Location: request query
  Strategy: URI
  Optionality: required
---
Method: getOptionalRequestBodyAsJSON
  Context: server
  Operation: get
  Location: request body
  Strategy: JSON
  Optionality: optional
---
Method: getRequiredRequestBodyAsJSON
  Context: server
  Operation: get
  Location: request body
  Strategy: JSON
  Optionality: required
---
Method: getOptionalRequestBodyAsBinary
  Context: server
  Operation: get
  Location: request body
  Strategy: binary
  Optionality: optional
---
Method: getRequiredRequestBodyAsBinary
  Context: server
  Operation: get
  Location: request body
  Strategy: binary
  Optionality: required
---
Method: getOptionalRequestBodyAsURLEncodedForm
  Context: server
  Operation: get
  Location: request body
  Strategy: urlEncodedForm
  Optionality: optional
---
Method: getRequiredRequestBodyAsURLEncodedForm
  Context: server
  Operation: get
  Location: request body
  Strategy: urlEncodedForm
  Optionality: required
---
Method: getRequiredRequestBodyAsMultipart
  Context: server
  Operation: get
  Location: request body
  Strategy: multipart
  Optionality: required
---
Method: setResponseBodyAsJSON
  Context: server
  Operation: set
  Location: response body
  Strategy: JSON
  Optionality: required
---
Method: setResponseBodyAsBinary
  Context: server
  Operation: set
  Location: response body
  Strategy: binary
  Optionality: required
---
Method: setResponseBodyAsMultipart
  Context: server
  Operation: set
  Location: response body
  Strategy: multipart
  Optionality: required
```

----------------------------------------

TITLE: OpenAPI 3.1.0 Definition for Multipart Request
DESCRIPTION: Defines a `POST` request to `/photos` with a `multipart/form-data` body. The body contains two parts: 'metadata' (JSON, referencing `PhotoMetadata` schema) and 'contents' (binary JPEG). The `schema` defines the parts, and `encoding` specifies content types and headers for individual parts.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0009.md#_snippet_3

LANGUAGE: yaml
CODE:
```
paths:
  /photos:
    post:
      requestBody:
        required: true
        content:
          multipart/form-data:
            schema:
              type: object
              properties:
                metadata:
                  $ref: '#/components/schemas/PhotoMetadata'
                contents:
                  type: string
                  contentEncoding: binary
              required:
                - metadata
                - contents
            encoding:
              metadata:
                headers:
                  x-sender-id:
                    schema:
                      type: string
              contents:
                contentType: image/jpeg
```

----------------------------------------

TITLE: OpenAPI Encoding Object for Multipart Form Data
DESCRIPTION: This YAML snippet illustrates the use of the `encoding` object in an OpenAPI document. It demonstrates how to explicitly set the `contentType` for a part (e.g., `image/jpeg` for `contents`) and define custom `headers` (e.g., `x-sender-id` for `metadata`) within a `multipart/form-data` request body schema.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0009.md#_snippet_15

LANGUAGE: YAML
CODE:
```
multipart/form-data:
  schema:
    type: object
    properties:
      metadata:
        $ref: '#/components/schemas/PhotoMetadata'
      contents:
        type: string
        contentEncoding: binary
    required:
      - metadata
      - contents
  encoding:
    metadata:
      headers:
        x-sender-id:
          schema:
            type: string
    contents:
      contentType: image/jpeg
```

----------------------------------------

TITLE: Integrate Swift OpenAPI Generator with Existing Vapor App
DESCRIPTION: Shows how to integrate the Swift OpenAPI Generator into an existing Vapor application. This code registers both the original code-driven routes and prepares for generated routes from an OpenAPI document, allowing for incremental migration without affecting existing functionality.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Articles/Practicing-spec-driven-API-development.md#_snippet_3

LANGUAGE: swift
CODE:
```
let app = try await Vapor.Application.make()

// Registers your existing routes.
app.get("foo") { ... a, b, c ... }
app.post("foo") { ... a, b, c ... }
app.get("bar") { ... a, b, c ... }

struct Handler: APIProtocol {} // this is where you'll implement your logic in the next step

let transport = VaporTransport(routesBuilder: app)

// Registers your generated routes from the OpenAPI document. Right now, there are 0.
try handler.registerHandlers(on: transport, serverURL: ...)

try await app.execute()
```

----------------------------------------

TITLE: Consume JSONL Event Stream in Swift
DESCRIPTION: This snippet demonstrates how to consume an event stream of JSON Lines (JSONL) from an HTTP response body. It uses `asDecodedJSONLines(of:decoder:)` to parse each line into a `Components.Schemas.Greeting` object, which can then be iterated over using a `for try await` loop.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0010.md#_snippet_1

LANGUAGE: swift
CODE:
```
let response = try await client.getGreetingsStream()
let httpBody = try response.ok.body.application_jsonl
let greetingStream = httpBody.asDecodedJSONLines(of: Components.Schemas.Greeting.self)
for try await greeting in greetingStream {
    print("Got greeting: \(greeting.message)")
}
```

----------------------------------------

TITLE: OpenAPI Specification Example Showing Content Type Naming Conflict
DESCRIPTION: This OpenAPI YAML snippet illustrates a scenario where multiple content types (application/json, application/vendor1+json, application/vendor2+json) defined for a 200 response would previously all be mapped to the same Swift identifier 'json'. This conflict would cause build failures in the generated Swift code, highlighting the need for the improved naming scheme proposed in SOAR-0002.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0002.md#_snippet_0

LANGUAGE: YAML
CODE:
```
paths:
  /foo:
    get:
      responses:
        '200':
          content:
            application/json: {}
            application/vendor1+json: {}
            application/vendor2+json: {}
```

----------------------------------------

TITLE: Illustrating API Call with curl
DESCRIPTION: Demonstrates a basic API interaction with a personalized greeting service using the `curl` command. This example shows the command-line request and the expected JSON response, setting the context for the subsequent discussion on generated API verbosity.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0007.md#_snippet_0

LANGUAGE: console
CODE:
```
% curl 'localhost:8080/api/greet?name=Maria'
{ "message" : "Hello, Maria" }
```

----------------------------------------

TITLE: Swift ServerTransport Protocol Evolution
DESCRIPTION: Compares the existing and proposed `ServerTransport` protocol definitions. Key changes include the separation of request/response bodies, the `method` parameter changing to `HTTPRequest.Method`, and the `path` parameter becoming a templated URI string, enhancing routing flexibility and simplifying query string decoding.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0005.md#_snippet_3

LANGUAGE: swift
CODE:
```
public protocol ServerTransport {
    func register(
        _ handler: @Sendable @escaping (Request, ServerRequestMetadata) async throws -> Response,
        method: HTTPMethod,
        path: [RouterPathComponent],
        queryItemNames: Set<String>
    ) throws
}
```

LANGUAGE: swift
CODE:
```
public protocol ServerTransport {
    func register(
        _ handler: @Sendable @escaping (HTTPRequest, HTTPBody?, ServerRequestMetadata) async throws -> (HTTPResponse, HTTPBody?), // <<< changed
        method: HTTPRequest.Method, // <<< changed
        path: String // <<< changed
    ) throws
}
```

----------------------------------------

TITLE: Example OpenAPI Generator Configuration for Tag-Based Filtering
DESCRIPTION: This YAML snippet provides a concrete example of how to configure the 'openapi-generator-config.yaml' file to filter an OpenAPI document. It demonstrates using the 'tags' filter to include only operations tagged with 'issues', along with the 'generate' options for 'types' and 'client'.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0008.md#_snippet_4

LANGUAGE: yaml
CODE:
```
# openapi-generator-config.yaml
generate:
- types
- client

filter:
  tags:
  - issues
```

----------------------------------------

TITLE: Define Custom Error Type Conforming to HTTPResponseConvertible in Swift
DESCRIPTION: This Swift code snippet demonstrates how to extend a custom error type, `MyAppError`, to conform to the `HTTPResponseConvertible` protocol. This conformance allows the error to be mapped to appropriate HTTP status codes, such as `badRequest` for invalid input or `forbidden` for authorization issues, enabling standardized error responses in an OpenAPI context.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0011.md#_snippet_3

LANGUAGE: swift
CODE:
```
extension MyAppError: HTTPResponseConvertible {
    var httpStatus: HTTPResponse.Status {
        switch self {
        case .invalidInputFormat:
            .badRequest
        case .authorizationError:
            .forbidden
        }
    }
}
```

----------------------------------------

TITLE: Define an open OpenAPI enum using anyOf
DESCRIPTION: This YAML snippet demonstrates how to create an open enum in OpenAPI using `anyOf`. It allows for a "default" value that preserves unknown values during decoding, preventing failures when new cases are added without breaking API compatibility.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Articles/Useful-OpenAPI-patterns.md#_snippet_1

LANGUAGE: YAML
CODE:
```
anyOf:
  - type: string
    enum:
      - foo
      - bar
      - baz
  - type: string
```

----------------------------------------

TITLE: Run Swift OpenAPI Client Service
DESCRIPTION: This command executes the Swift OpenAPI client service, typically used to test or interact with an API defined by an OpenAPI specification.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Tutorials/_Resources/client.console.3.0.txt#_snippet_0

LANGUAGE: shell
CODE:
```
% swift run --package-path GreetingServiceClient
```

----------------------------------------

TITLE: OpenAPI 3.0.3 Specification for Stats Service
DESCRIPTION: This OpenAPI document defines the API for a 'Stats service'. It includes two endpoints under /stats: a GET operation to retrieve statistics and a POST operation to submit statistics. It also defines the StatItem and StatItems schemas for data representation.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0004.md#_snippet_34

LANGUAGE: yaml
CODE:
```
openapi: 3.0.3
info:
  title: Stats service
  version: 1.0.0
paths:
  /stats:
    get:
      operationId: getStats
      responses:
        '200':
          description: A successful response.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/StatItems'
            text/plain: {}
            application/octet-stream: {}
    post:
      operationId: postStats
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/StatItems'
          text/plain: {}
          application/octet-stream: {}
      responses:
        '202':
          description: Successfully submitted.
components:
  schemas:
    StatItem:
      type: object
      properties:
        name:
          type: string
        value:
          type: integer
      required: [name, value]
    StatItems:
      type: array
      items:
        $ref: '#/components/schemas/StatItem'
```

----------------------------------------

TITLE: Implement Generated getFoo Handler in Swift Vapor
DESCRIPTION: This Swift code illustrates the implementation of the `getFoo` operation within the `Handler` struct, typically after accepting an Xcode Fix-it. The original manual route for `GET /foo` can now be removed. The key benefit is that only the core business logic needs to be implemented, as input deserialization, validation, and output serialization are handled by the generated code.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Articles/Practicing-spec-driven-API-development.md#_snippet_6

LANGUAGE: swift
CODE:
```
let app = try await Vapor.Application.make()

// Registers your existing routes.
// <<< now you can just delete the first original route, as you've moved the business logic below into the Handler type
app.post("foo") { ... a, b, c ... }
app.get("bar") { ... a, b, c ... }

struct Handler: APIProtocol {
  func getFoo(input: Operations.getFoo.Input) async throws -> Operations.getFoo.Output {
    ... b ... // <<< notice that here you just implement your business logic, but input deserialization and validation, and output serialization is handled by the generated code.
  }
}
let transport = VaporTransport(routesBuilder: app)
try handler.registerHandlers(on: transport, serverURL: ...)

try await app.execute()
```

----------------------------------------

TITLE: Simplify API Input Handling in Swift
DESCRIPTION: Demonstrates how to simplify API input by generating overloads for operations, allowing direct parameter passing or no parameters, removing the need for explicit `Input.init` calls.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0007.md#_snippet_3

LANGUAGE: swift
CODE:
```
// after (with parameters, shorthand)
_ = try await client.getGreeting(query: .init(name: "Maria"))

// after (no parameters)
_ = try await client.getGreeting()
```

----------------------------------------

TITLE: Swift: Create MultipartBody using AsyncStream
DESCRIPTION: This snippet shows how to construct a `MultipartBody` using `AsyncStream` or `AsyncThrowingStream`. This pattern allows parts to be produced asynchronously by another task and then streamed into the body. It provides flexibility for generating multipart content dynamically over time.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0009.md#_snippet_24

LANGUAGE: Swift
CODE:
```
let (stream, continuation) = AsyncStream.makeStream(of: MyPartType.self)
// Pass the continuation to another task that produces the parts asynchronously.
Task {
    continuation.yield(.myCaseA(...))
    // ... later
    continuation.yield(.myCaseB(...))
    continuation.finish()
}
let body = MultipartBody(stream)
```

----------------------------------------

TITLE: Create HTTPBody from AsyncStream
DESCRIPTION: Shows how to construct an `HTTPBody` using an `AsyncStream` or `AsyncThrowingStream`, providing byte chunks and known length.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0004.md#_snippet_18

LANGUAGE: swift
CODE:
```
let body = HTTPBody(
    AsyncStream(ArraySlice<UInt8>.self, { continuation in
        continuation.yield([72, 69])
        continuation.yield([76, 76, 79])
        continuation.finish()
    }),
    length: .known(5)
)
```

----------------------------------------

TITLE: Define GET /foo Operation in OpenAPI
DESCRIPTION: This YAML snippet demonstrates how to add the definition for the `GET /foo` operation to an OpenAPI document. This specification drives the code generation process, allowing tools to create corresponding handlers and models.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Articles/Practicing-spec-driven-API-development.md#_snippet_4

LANGUAGE: yaml
CODE:
```
openapi: 3.1.0
info:
  title: MyService
  version: 1.0.0
paths:
  /foo:
    get:
      ... (the definition of the operation, its inputs and outputs)
```

----------------------------------------

TITLE: Register Error Handling Middleware in Swift OpenAPI Generator
DESCRIPTION: This Swift code snippet illustrates how to register the `ErrorHandlingMiddleware` with a `RequestHandler` instance. By including this middleware during handler registration, the application opts into the custom error conversion behavior, ensuring that errors are processed and converted into HTTP responses according to the defined `HTTPResponseConvertible` conformance.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0011.md#_snippet_4

LANGUAGE: swift
CODE:
```
let handler = try await RequestHandler()
try handler.registerHandlers(on: transport, middlewares: [ErrorHandlingMiddleware()])

```

----------------------------------------

TITLE: Generated Swift Code for OpenAPI Service
DESCRIPTION: This Swift code is automatically generated by `swift-openapi-generator` from an OpenAPI specification. It defines the `APIProtocol` for service operations, `Servers` for API endpoints, `Components` for shared schemas like `Greeting`, and `Operations` for specific API endpoints like `getGreeting`, including their input and output structures.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0007.md#_snippet_11

LANGUAGE: swift
CODE:
```
// Types.swift
// -----------
// Generated by swift-openapi-generator, do not modify.
@_spi(Generated) import OpenAPIRuntime
#if os(Linux)
@preconcurrency import struct Foundation.URL
@preconcurrency import struct Foundation.Data
@preconcurrency import struct Foundation.Date
#else
import struct Foundation.URL
import struct Foundation.Data
import struct Foundation.Date
#endif
/// A type that performs HTTP operations defined by the OpenAPI document.
public protocol APIProtocol: Sendable {
    /// - Remark: HTTP `GET /greet`.
    /// - Remark: Generated from `#/paths//greet/get(getGreeting)`.
    func getGreeting(_ input: Operations.getGreeting.Input) async throws -> Operations.getGreeting.Output
}
/// Server URLs defined in the OpenAPI document.
public enum Servers {
    /// Example
    public static func server1() throws -> URL { try URL(validatingOpenAPIServerURL: "https://example.com/api") }
}
/// Types generated from the components section of the OpenAPI document.
public enum Components {
    /// Types generated from the `#/components/schemas` section of the OpenAPI document.
    public enum Schemas {
        /// - Remark: Generated from `#/components/schemas/Greeting`.
        public struct Greeting: Codable, Hashable, Sendable {
            /// - Remark: Generated from `#/components/schemas/Greeting/message`.
            public var message: Swift.String
            /// Creates a new `Greeting`.
            ///
            /// - Parameters:
            ///   - message:
            public init(message: Swift.String) { self.message = message }
            public enum CodingKeys: String, CodingKey { case message }
        }
    }
    /// Types generated from the `#/components/parameters` section of the OpenAPI document.
    public enum Parameters {}
    /// Types generated from the `#/components/requestBodies` section of the OpenAPI document.
    public enum RequestBodies {}
    /// Types generated from the `#/components/responses` section of the OpenAPI document.
    public enum Responses {}
    /// Types generated from the `#/components/headers` section of the OpenAPI document.
    public enum Headers {}
}
/// API operations, with input and output types, generated from `#/paths` in the OpenAPI document.
public enum Operations {
    /// - Remark: HTTP `GET /greet`.
    /// - Remark: Generated from `#/paths//greet/get(getGreeting)`.
    public enum getGreeting {
        public static let id: String = "getGreeting"
        public struct Input: Sendable, Hashable {
            /// - Remark: Generated from `#/paths/greet/GET/query`.
            public struct Query: Sendable, Hashable {
                /// A name used in the returned greeting.
                ///
                /// - Remark: Generated from `#/paths/greet/GET/query/name`.
                public var name: Swift.String?
                /// Creates a new `Query`.
                ///
                /// - Parameters:
                ///   - name: A name used in the returned greeting.
                public init(name: Swift.String? = nil) { self.name = name }
            }
            public var query: Operations.getGreeting.Input.Query
            /// - Remark: Generated from `#/paths/greet/GET/header`.
            public struct Headers: Sendable, Hashable {
                public var accept:
                    [OpenAPIRuntime.AcceptHeaderContentType<Operations.getGreeting.AcceptableContentType>]
                /// Creates a new `Headers`.
                ///
                /// - Parameters:
                ///   - accept:
                public init(
                    accept: [OpenAPIRuntime.AcceptHeaderContentType<Operations.getGreeting.AcceptableContentType>] =
                        .defaultValues()
                ) { self.accept = accept }
            }
            public var headers: Operations.getGreeting.Input.Headers
            /// Creates a new `Input`.
            ///
            /// - Parameters:
            ///   - query:
            ///   - headers:
            public init(
                query: Operations.getGreeting.Input.Query = .init(),
                headers: Operations.getGreeting.Input.Headers = .init()
            ) {
                self.query = query
                self.headers = headers
            }
        }
        @frozen public enum Output: Sendable, Hashable {
            public struct Ok: Sendable, Hashable {
                /// - Remark: Generated from `#/paths/greet/GET/responses/200/content`.
                @frozen public enum Body: Sendable, Hashable {
                    /// - Remark: Generated from `#/paths/greet/GET/responses/200/content/application\/json`.
                    case json(Components.Schemas.Greeting)
                }
                /// Received HTTP response body

```

----------------------------------------

TITLE: Swift OpenAPI Naming Strategy Comparison Examples
DESCRIPTION: This table illustrates the conversion of various OpenAPI names into Swift identifiers using both the existing 'defensive' naming strategy and the proposed 'idiomatic' naming strategy, demonstrating capitalization differences for types and members.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0013.md#_snippet_1

LANGUAGE: Markdown
CODE:
```
| OpenAPI name | Defensive | Idiomatic (capitalized) | Idiomatic (non-capitalized) |
| ------------ | --------- | ------------------------ | ---------------------------- |
| `foo` | `foo` | `Foo` | `foo` |
| `Hello world` | `Hello_space_world` | `HelloWorld` | `helloWorld` |
| `My_URL_value` | `My_URL_value` | `MyURLValue` | `myURLValue` |
| `Retry-After` | `Retry_hyphen_After` | `RetryAfter` | `retryAfter` |
| `NOT_AVAILABLE` | `NOT_AVAILABLE` | `NotAvailable` | `notAvailable` |
| `version 2.0` | `version_space_2_period_0` | `Version2_0` | `version2_0` |
| `naïve café` | `naïve_space_café` | `NaïveCafé` | `naïveCafé` |
| `__user` | `__user` | `__User` | `__user` |
| `get/pets/{petId}` _Changed in v1.2_ | `get_sol_pets_sol__lcub_petId_rcub_` | `GetPetsPetId` | `getPetsPetId` |
| `HTTPProxy` _Added in v1.2_ | `HTTPProxy` | `HTTPProxy` | `httpProxy` |
| `application/myformat+json` _Added in v1.3_ | `application_myformat_plus_json` | - | `applicationMyformatJson` |
| `order#123` | `order_num_123` | `order_num_123` | `order_num_123` |
```

----------------------------------------

TITLE: Build and Run Server CLI
DESCRIPTION: Provides the command to compile and start the server application, illustrating the console output indicating the server has started and is listening on `http://127.0.0.1:8080`.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/hello-world-vapor-server-example/README.md#_snippet_1

LANGUAGE: console
CODE:
```
% swift run
2023-12-01T14:14:35+0100 notice codes.vapor.application : [Vapor] Server starting on http://127.0.0.1:8080
...
```

----------------------------------------

TITLE: Run Swift OpenAPI Vapor Server Example
DESCRIPTION: Executes the Swift command to build and run the 'HelloWorldVaporServer' application. The output includes the server's startup log, indicating it is listening for incoming connections on http://127.0.0.1:8080.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Tutorials/_Resources/client.console.1.2.txt#_snippet_1

LANGUAGE: Shell
CODE:
```
% swift run HelloWorldVaporServer
..
Build complete! (37.91s)
2023-12-12T09:06:32+0100 notice codes.vapor.application : [Vapor] Server starting on http://127.0.0.1:8080
```

----------------------------------------

TITLE: Collect HTTPBody into a buffer
DESCRIPTION: Demonstrates how to collect the entire `HTTPBody` into an `ArraySlice<UInt8>` buffer, with an important note on setting a maximum size to prevent out-of-memory errors.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0004.md#_snippet_20

LANGUAGE: swift
CODE:
```
let buffer = try await ArraySlice(collecting: body, upTo: 2 * 1024 * 1024)
```

----------------------------------------

TITLE: Swift API: Encode Server-Sent Events with JSON Data from AsyncSequence
DESCRIPTION: This extension method encodes an `AsyncSequence` of `ServerSentEventWithJSONData` into a Server-Sent Events stream, where the event's data field contains JSON. A custom JSON encoder can be provided, with default settings for sorted keys and unescaped slashes.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0010.md#_snippet_18

LANGUAGE: APIDOC
CODE:
```
public func asEncodedServerSentEventsWithJSONData<JSONDataType>(encoder: JSONEncoder = {
  let encoder = JSONEncoder()
  encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
  return encoder
}()) -> ServerSentEventsSerializationSequence<AsyncThrowingMapSequence<Self, ServerSentEvent>> where JSONDataType : Encodable, Self.Element == ServerSentEventWithJSONData<JSONDataType>
  - Parameter encoder: The JSON encoder to use.
  - Returns: A sequence that provides the serialized Server-sent Events.
```

----------------------------------------

TITLE: Swift: Create MultipartBody from Async Sequence
DESCRIPTION: This example illustrates initializing a `MultipartBody` from an `AsyncSequence` of parts. It requires specifying an `iterationBehavior` to indicate whether the sequence can be iterated once or multiple times. Sequences supporting multiple iterations are beneficial for scenarios like HTTP request retries or redirects.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0009.md#_snippet_23

LANGUAGE: Swift
CODE:
```
let producingSequence = ... // an AsyncSequence of MyPartType
let body = MultipartBody(
    producingSequence,
    iterationBehavior: .single // or .multiple
)
```

----------------------------------------

TITLE: Generated Swift Code for Multipart Request Body
DESCRIPTION: Illustrates the proposed type-safe Swift representation for a multipart body, generated by Swift OpenAPI Generator. It uses an async sequence (`OpenAPIRuntime.MultipartBody`) of type-safe parts, represented by an enum (`multipartFormPayload`) where each case corresponds to a defined part (e.g., `metadata`, `contents`) or an undocumented part.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0009.md#_snippet_4

LANGUAGE: swift
CODE:
```
/// - Remark: Generated from `#/paths/photos/POST/requestBody/content`.
/* nested in Operations.uploadPhoto.Input */ {
    enum Body {
        enum multipartFormPayload {
            struct metadataPayload {
                struct Headers {
                    var x_dash_sender_dash_id: String?
                }
                var headers: Headers
                var body: Components.Schemas.PhotoMetadata
            }
            case metadata(MultipartPart<metadataPayload>)
            struct contentsPayload {
                var body: HTTPBody
            }
            case contents(MultipartPart<contentsPayload>)
            case undocumented(MultipartRawPart)
        }
        /// - Remark: Generated from `#/paths/photos/POST/requestBody/content/multipart\/form-data`.
        case multipartForm(MultipartBody<multipartFormPayload>)
    }
}
```

----------------------------------------

TITLE: Call Hello World API Endpoint with Curl
DESCRIPTION: Demonstrates how to use the 'curl' command-line tool to make a GET request to the running Vapor server's '/api/greet' endpoint, passing a 'name' query parameter. The expected JSON response from the server is also shown.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Tutorials/_Resources/client.console.1.2.txt#_snippet_2

LANGUAGE: Shell
CODE:
```
% curl 'localhost:8080/api/greet?name=Jane'
```

LANGUAGE: JSON
CODE:
```
{
  "message" : "Hello, Jane"
}
```

----------------------------------------

TITLE: Invoke Greeting Service with cURL
DESCRIPTION: Demonstrates how to make a GET request to the `/api/greet` endpoint of the running server using cURL, showing the expected JSON response with a 'Hello, Stranger!' message.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/hello-world-vapor-server-example/README.md#_snippet_0

LANGUAGE: console
CODE:
```
% curl http://localhost:8080/api/greet
{
  "message" : "Hello, Stranger!"
}
```

----------------------------------------

TITLE: Example OpenAPI Specification for GreetingService
DESCRIPTION: An example OpenAPI 3.1.0 document defining a simple 'GreetingService'. It includes a '/greet' endpoint with a GET operation, an optional 'name' query parameter, and a 'Greeting' schema for the 200 OK response, which contains a 'message' property.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/README.md#_snippet_2

LANGUAGE: YAML
CODE:
```
openapi: '3.1.0'
info:
  title: GreetingService
  version: 1.0.0
servers:
  - url: https://example.com/api
    description: Example service deployment.
paths:
  /greet:
    get:
      operationId: getGreeting
      parameters:
        - name: name
          required: false
          in: query
          description: The name used in the returned greeting.
          schema:
            type: string
      responses:
        '200':
          description: A success response with a greeting.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Greeting'
components:
  schemas:
    Greeting:
      type: object
      description: A value with the greeting contents.
      properties:
        message:
          type: string
          description: The string representation of the greeting.
      required:
        - message
```

----------------------------------------

TITLE: Generate Swift OpenAPI Code via CLI
DESCRIPTION: This console command invokes the `swift-openapi-generator` to produce Swift code for API types and client components. It requires an OpenAPI specification file and an output directory, where it will create `Types.swift` and `Client.swift`, potentially overwriting existing files.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Articles/Manually-invoking-the-generator-CLI.md#_snippet_0

LANGUAGE: Console
CODE:
```
% swift run swift-openapi-generator generate \
    --mode types --mode client \
    --output-directory path/to/desired/output-dir \
    path/to/openapi.yaml
```

----------------------------------------

TITLE: Define a constrained open OpenAPI oneOf for JSON objects
DESCRIPTION: This YAML snippet shows how to create a more constrained open `oneOf` by specifying `type: object` for the second schema in `anyOf`. This is useful when the unknown payload is guaranteed to be a JSON object, providing more specific validation.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Articles/Useful-OpenAPI-patterns.md#_snippet_4

LANGUAGE: YAML
CODE:
```
MyOpenOneOf:
  anyOf:
    - oneOf:
        - #/components/schemas/Foo
        - #/components/schemas/Bar
        - #/components/schemas/Baz
    - type: object
```

----------------------------------------

TITLE: Add File Comments to Exclude from Formatting Tools
DESCRIPTION: This configuration adds custom file comments, such as `swift-format-ignore-file` and `swiftlint:disable all`, to the top of generated files. This helps exclude them from formatting and linting tools.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Articles/Configuring-the-generator.md#_snippet_7

LANGUAGE: yaml
CODE:
```
generate:
  - types
  - client
namingStrategy: idiomatic
additionalFileComments:
  - "swift-format-ignore-file"
  - "swiftlint:disable all"
```

----------------------------------------

TITLE: Initialize Swagger UI with OpenAPI Specification
DESCRIPTION: This JavaScript snippet initializes Swagger UI to display an OpenAPI specification from 'openapi.yaml'. It sets up deep linking and disables validation.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/swagger-ui-endpoint-example/Public/openapi.html#_snippet_0

LANGUAGE: JavaScript
CODE:
```
window.onload = function() { const ui = SwaggerUIBundle({ url: "openapi.yaml", dom_id: "#openapi", deepLinking: true, validatorUrl: "none" }) }
```

----------------------------------------

TITLE: Create an Empty OpenAPI Document
DESCRIPTION: Illustrates the creation of an initial, valid OpenAPI 3.1.0 document. This document describes a service named 'MyService' with version 1.0.0 but contains no defined paths, serving as a starting point for spec-driven development.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Articles/Practicing-spec-driven-API-development.md#_snippet_2

LANGUAGE: yaml
CODE:
```
openapi: 3.1.0
info:
  title: MyService
  version: 1.0.0
paths: {}
```

----------------------------------------

TITLE: Filter OpenAPI Document by Schemas
DESCRIPTION: Shows how to filter the OpenAPI document to include only specific schemas (`B`). The configuration targets schema 'B', and the filtered output contains only schema 'B' and its dependencies, demonstrating schema-based filtering.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0008.md#_snippet_10

LANGUAGE: yaml
CODE:
```
# openapi-generator-config.yaml
filter:
  schemas:
  - B
```

LANGUAGE: yaml
CODE:
```
# filtered OpenAPI document
openapi: 3.1.0
info:
  title: ExampleService
  version: 1.0.0
tags:
- name: t
paths:
  /things/b:
    get:
      operationId: getB
      responses:
        200:
          $ref: '#/components/responses/B'
components:
  schemas:
    A:
      type: string
    B:
      $ref: '#/components/schemas/A'
  responses:
    B:
      description: success
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/B'
```

----------------------------------------

TITLE: Generate Swift OpenAPI Code with Swift Package Plugin Command
DESCRIPTION: This console command utilizes the Swift package plugin to generate OpenAPI code directly into a target's `GeneratedSources` directory. It requires `openapi.yaml` and `openapi-generator-config.yaml` to be configured, similar to the build plugin workflow, and allows checking generated code into source control.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Articles/Manually-invoking-the-generator-CLI.md#_snippet_2

LANGUAGE: Console
CODE:
```
% swift package plugin generate-code-from-openapi --target HelloWorldURLSessionClient
```

----------------------------------------

TITLE: Swift: ServerSentEventsDeserializationSequence
DESCRIPTION: A sequence that parses raw byte chunks into `ServerSentEvent` objects according to the Server-Sent Events format. It provides an initializer to specify the upstream byte sequence and conforms to `AsyncSequence`.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0010.md#_snippet_11

LANGUAGE: Swift
CODE:
```
public struct ServerSentEventsDeserializationSequence<Upstream> : Sendable where Upstream : Sendable, Upstream : AsyncSequence, Upstream.Element == ArraySlice<UInt8> {

    /// Creates a new sequence.
    /// - Parameter upstream: The upstream sequence of arbitrary byte chunks.
    public init(upstream: Upstream)
}

extension ServerSentEventsDeserializationSequence : AsyncSequence {
    public typealias Element = ServerSentEvent
    public struct Iterator<UpstreamIterator> : AsyncIteratorProtocol where UpstreamIterator : AsyncIteratorProtocol, UpstreamIterator.Element == ArraySlice<UInt8> {
        public mutating func next() async throws -> ServerSentEvent?
    }
    public func makeAsyncIterator() -> Iterator<Upstream.AsyncIterator>
}
```

----------------------------------------

TITLE: Run Swift OpenAPI Generator CLI to Greet
DESCRIPTION: Build and run the command-line client to send a greeting request with a specified name. This command interacts with a local Greeting Service, expecting a 'Hello, [name]!' response.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/command-line-client-example/README.md#_snippet_0

LANGUAGE: console
CODE:
```
% swift run CommandLineClient greet --name CLI
Hello, CLI!
```

----------------------------------------

TITLE: Example OpenAPI Specification Document
DESCRIPTION: A placeholder for an OpenAPI YAML document. This document serves as the source definition for the API, from which the Swift code snippets are generated, illustrating the contract for the getGreeting operation.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0007.md#_snippet_8

LANGUAGE: APIDOC
CODE:
```
# openapi.yaml

```

----------------------------------------

TITLE: Run Swift OpenAPI Generator Example Locally
DESCRIPTION: This command-line snippet demonstrates how to clone the Swift OpenAPI Generator repository and run a specific example, such as the 'hello-world-urlsession-client-example', from the command line. It involves navigating to the Examples directory and executing the example using `swift run`.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/README.md#_snippet_0

LANGUAGE: console
CODE:
```
% git clone https://github.com/apple/swift-openapi-generator
% cd swift-openapi-generator/Examples
% swift run --package-path hello-world-urlsession-client-example
```

----------------------------------------

TITLE: OpenAPI YAML Definition for Server Variables with Enum
DESCRIPTION: An example OpenAPI YAML definition for server URLs with templated variables. It demonstrates how to define an 'environment' variable with a default value and a restricted set of enum options ('prod', 'staging', 'dev'), and a 'version' variable with a default.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0012.md#_snippet_1

LANGUAGE: YAML
CODE:
```
servers:
  - url: https://{environment}.example.com/api/{version}
    description: Example service deployment.
    variables:
      environment:
        description: Server environment.
        default: prod
        enum:
          - prod
          - staging
          - dev
      version:
        default: v1
```

----------------------------------------

TITLE: Run Swift OpenAPI Generator Client CLI
DESCRIPTION: Instructions to build and execute the client command-line interface, which then makes a request to the local Greeting Service and prints the response.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/hello-world-urlsession-client-example/README.md#_snippet_0

LANGUAGE: console
CODE:
```
% swift run
Hello, Stranger!
```

----------------------------------------

TITLE: Example OpenAPI Document for Multipart Photo Upload
DESCRIPTION: This YAML snippet defines an OpenAPI 3.1.0 document that specifies an endpoint for uploading photos using `multipart/form-data`. It details the request body, including separate parts for `metadata` (referencing a schema) and `contents` (binary string), and demonstrates how to use the `encoding` object to specify content types and headers for individual parts of the multipart request. It also defines the `PhotoMetadata` schema.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0009.md#_snippet_16

LANGUAGE: YAML
CODE:
```
openapi: '3.1.0'
info:
  title: Cat photo service
  version: 2.0.0
paths:
  /photos:
    post:
      operationId: uploadPhoto
      description: Uploads the provided photo with metadata to the server.
      requestBody:
        required: true
        content:
          multipart/form-data:
            schema:
              type: object
              description: The individual parts of the photo upload.
              properties:
                metadata:
                  $ref: '#/components/schemas/PhotoMetadata'
                  description: Extra information about the uploaded photo.
                contents:
                  type: string
                  contentEncoding: binary
                  description: The raw contents of the photo.
              required:
                - metadata
                - contents
            encoding:
              metadata:
                # No need to explicitly specify `contents: application/json` because
                # it's inferred from the schema itself.
                headers:
                  x-sender-id:
                    # Note that this serves as an example of a part header.
                    # But conventionally, you'd include this property in the metadata JSON instead.
                    description: The identifier of the device sending the photo.
                    schema:
                      type: string
              contents:
                contentType: image/jpeg
      responses:
        '204':
          description: Successfully uploaded the file.
components:
  schemas:
    PhotoMetadata:
      type: object
      description: Extra information about a photo.
      properties:
        objectCatName:
          type: string
          description: The name of the cat that's in the photo.
        photographerId:
          type: integer
          description: The identifier of the photographer.
      required:
        - objectCatName
    OtherInfo:
      type: object
      description: Other information.
```

----------------------------------------

TITLE: Swift Server Implementation for Content Type Handling
DESCRIPTION: Provides an example of a server-side implementation in Swift, showing how to parse and utilize the `Accept` header to determine the preferred content type for the `getStats` operation, with a fallback to JSON.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0003.md#_snippet_6

LANGUAGE: swift
CODE:
```
struct MyHandler: APIProtocol {
  func getStats(_ input: Operations.getStats.Input) async throws -> Operations.getStats.Output {
    let contentType = input
      .headers
      .accept
      .sortedByQuality()
      .first?
      .contentType ?? .json
    switch contentType {
      case .json:
        // ... return JSON
      case .plainText:
        // ... return plain text
      case .other(let value):
        // ... inspect the value or return an error
    }
  }
}
```

----------------------------------------

TITLE: Clone and Run Swift OpenAPI Generator Vapor Server Example
DESCRIPTION: This snippet provides the shell commands to clone the Swift OpenAPI Generator repository, navigate to a specific Vapor server example, and then execute the server using `swift run`. It also includes the expected console output indicating the server has successfully started.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Tutorials/_Resources/client.console.1.1.txt#_snippet_0

LANGUAGE: Shell
CODE:
```
% git clone https://github.com/apple/swift-openapi-generator
% cd swift-openapi-generator/Examples/hello-world-vapor-server-example

% swift run HelloWorldVaporServer
..
Build complete! (37.91s)
2023-12-12T09:06:32+0100 notice codes.vapor.application : [Vapor] Server starting on http://127.0.0.1:8080
```

----------------------------------------

TITLE: Swift HTTPResponseConvertible Protocol for Error Mapping
DESCRIPTION: This API documentation defines the `HTTPResponseConvertible` protocol in Swift. It allows application-specific error types to specify how they should be converted into HTTP responses, including the status code, header fields, and body. Default implementations are provided for optional header fields and body.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0011.md#_snippet_1

LANGUAGE: APIDOC
CODE:
```
public protocol HTTPResponseConvertible {
    var httpStatus: HTTPResponse.Status { get }
    var httpHeaderFields: HTTPTypes.HTTPFields { get }
    var httpBody: OpenAPIRuntime.HTTPBody? { get }
}

extension HTTPResponseConvertible {
    var httpHeaderFields: HTTPTypes.HTTPFields { [:] }
    var httpBody: OpenAPIRuntime.HTTPBody? { nil }
}
```

----------------------------------------

TITLE: HTTPBody Type API Reference
DESCRIPTION: Defines the `HTTPBody` type and its core functionalities, including various initializers for constructing HTTP bodies from different data sources, and its conformance to standard Swift protocols.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0004.md#_snippet_22

LANGUAGE: APIDOC
CODE:
```
HTTPBody:
  // Internal Initializers
  init(
    sequence: BodySequence,
    length: Length,
    iterationBehavior: IterationBehavior
  )
    - sequence: The input sequence providing the byte chunks.
    - length: The total length of the body, in other words the accumulated length of all the byte chunks.
    - iterationBehavior: The sequence's iteration behavior, which indicates whether the sequence can be iterated multiple times.

  convenience init(
    byteChunks: some Sequence<ByteChunk> & Sendable,
    length: Length,
    iterationBehavior: IterationBehavior
  )
    - byteChunks: A sequence of byte chunks.
    - length: The total length of the body.
    - iterationBehavior: The iteration behavior of the sequence, which indicates whether it can be iterated multiple times.

  // Public Convenience Initializers
  convenience init()
    - Creates a new empty body.

  convenience init(
    bytes: ByteChunk,
    length: Length
  )
    - bytes: A byte chunk.
    - length: The total length of the body.

  convenience init(
    bytes: ByteChunk
  )
    - bytes: A byte chunk.

  convenience init(
    bytes: some Sequence<UInt8> & Sendable,
    length: Length,
    iterationBehavior: IterationBehavior
  )
    - bytes: A byte chunk.
    - length: The total length of the body.
    - iterationBehavior: The iteration behavior of the sequence, which indicates whether it can be iterated multiple times.

  convenience init(
    bytes: some Collection<UInt8> & Sendable,
    length: Length
  )
    - bytes: A byte chunk.
    - length: The total length of the body.

  convenience init(
    bytes: some Collection<UInt8> & Sendable
  )
    - bytes: A byte chunk.

  convenience init(
    stream: AsyncThrowingStream<ByteChunk, any Error>,
    length: HTTPBody.Length
  )
    - stream: An async throwing stream that provides the byte chunks.
    - length: The total length of the body.

  convenience init(
    stream: AsyncStream<ByteChunk>,
    length: HTTPBody.Length
  )
    - stream: An async stream that provides the byte chunks.
    - length: The total length of the body.

  convenience init<Bytes>(
    sequence: Bytes,
    length: HTTPBody.Length,
    iterationBehavior: IterationBehavior
  ) where Bytes : Sendable, Bytes : AsyncSequence, Bytes.Element == ArraySlice<UInt8>
    - sequence: An async sequence that provides the byte chunks.
    - length: The total length of the body.
    - iterationBehavior: The iteration behavior of the sequence, which indicates whether it can be iterated multiple times.

  convenience init<Bytes>(
    sequence: Bytes,
    length: HTTPBody.Length,
    iterationBehavior: IterationBehavior
  ) where Bytes : Sendable, Bytes : AsyncSequence, Bytes.Element : Sequence, Bytes.Element.Element == UInt8
    - sequence: An async sequence that provides the byte chunks.
    - length: The total length of the body.
    - iterationBehavior: The iteration behavior of the sequence, which indicates whether it can be iterated multiple times.

HTTPBody Equatable Conformance:
  static func == (
    lhs: HTTPBody,
    rhs: HTTPBody
  ) -> Bool

HTTPBody Hashable Conformance:
  func hash(
    into hasher: inout Hasher
  )

HTTPBody AsyncSequence Conformance:
  typealias Element = ByteChunk
    - The type of element produced by this asynchronous sequence.

  typealias AsyncIterator = Iterator
    - The type of asynchronous iterator that produces elements of this asynchronous sequence.

  func makeAsyncIterator() -> AsyncIterator
    - Creates the asynchronous iterator that produces elements of this asynchronous sequence.
    - Returns: An instance of the `AsyncIterator` type used to produce elements of the asynchronous sequence.

```

----------------------------------------

TITLE: Swift API for JSON Lines Serialization
DESCRIPTION: Provides Swift types and extensions for serializing `Encodable` Swift types into JSON Lines. This includes the `JSONLinesSerializationSequence` struct and an `AsyncSequence` extension for encoding events.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0010.md#_snippet_4

LANGUAGE: swift
CODE:
```
/// A sequence that serializes lines by concatenating them using the JSON Lines format.
public struct JSONLinesSerializationSequence<Upstream> : Sendable where Upstream : Sendable, Upstream : AsyncSequence, Upstream.Element == ArraySlice<UInt8> {

    /// Creates a new sequence.
    /// - Parameter upstream: The upstream sequence of lines.
    public init(upstream: Upstream)
}

extension JSONLinesSerializationSequence : AsyncSequence {
    public typealias Element = ArraySlice<UInt8>
    public struct Iterator<UpstreamIterator> : AsyncIteratorProtocol where UpstreamIterator : AsyncIteratorProtocol, UpstreamIterator.Element == ArraySlice<UInt8> {
        public mutating func next() async throws -> ArraySlice<UInt8>?
    }
    public func makeAsyncIterator() -> Iterator<Upstream.AsyncIterator>
}

extension AsyncSequence where Self.Element : Encodable {

    /// Returns another sequence that encodes the events using the provided encoder into JSON Lines.
    /// - Parameter encoder: The JSON encoder to use.
    /// - Returns: A sequence that provides the serialized JSON Lines.
    public func asEncodedJSONLines(encoder: JSONEncoder = {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
            return encoder
        }()) -> JSONLinesSerializationSequence<AsyncThrowingMapSequence<Self, ArraySlice<UInt8>>>
}
```

----------------------------------------

TITLE: Swift API for JSON Lines Deserialization
DESCRIPTION: Provides Swift types and extensions for deserializing byte chunks into JSON Lines and then decoding those lines into Swift `Decodable` types. This includes the `JSONLinesDeserializationSequence` struct and an `AsyncSequence` extension for decoding events.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0010.md#_snippet_3

LANGUAGE: swift
CODE:
```
/// A sequence that parses arbitrary byte chunks into lines using the JSON Lines format.
public struct JSONLinesDeserializationSequence<Upstream> : Sendable where Upstream : Sendable, Upstream : AsyncSequence, Upstream.Element == ArraySlice<UInt8> {

    /// Creates a new sequence.
    /// - Parameter upstream: The upstream sequence of arbitrary byte chunks.
    public init(upstream: Upstream)
}

extension JSONLinesDeserializationSequence : AsyncSequence {
    public typealias Element = ArraySlice<UInt8>
    public struct Iterator<UpstreamIterator> : AsyncIteratorProtocol where UpstreamIterator : AsyncIteratorProtocol, UpstreamIterator.Element == ArraySlice<UInt8> {
        public mutating func next() async throws -> ArraySlice<UInt8>?
    }
    public func makeAsyncIterator() -> Iterator<Upstream.AsyncIterator>
}

extension AsyncSequence where Self.Element == ArraySlice<UInt8> {

    /// Returns another sequence that decodes each JSON Lines event as the provided type using the provided decoder.
    /// - Parameters:
    ///   - eventType: The type to decode the JSON event into.
    ///   - decoder: The JSON decoder to use.
    /// - Returns: A sequence that provides the decoded JSON events.
    public func asDecodedJSONLines<Event>(of eventType: Event.Type = Event.self, decoder: JSONDecoder = .init()) -> AsyncThrowingMapSequence<JSONLinesDeserializationSequence<Self>, Event> where Self : Sendable, Event : Decodable
}
```

----------------------------------------

TITLE: Swift ServerMiddleware Protocol Evolution
DESCRIPTION: Compares the existing and proposed `ServerMiddleware` protocol definitions. The `intercept` method is updated to handle `HTTPBody?` separately, mirroring the changes in other transport and middleware protocols for consistent body management and alignment with the new HTTP types.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0005.md#_snippet_4

LANGUAGE: swift
CODE:
```
public protocol ServerMiddleware: Sendable {
    func intercept(
        _ request: Request,
        metadata: ServerRequestMetadata,
        operationID: String,
        next: @Sendable (Request, ServerRequestMetadata) async throws -> Response
    ) async throws -> Response

}
```

LANGUAGE: swift
CODE:
```
public protocol ServerMiddleware {
    func intercept(
        _ request: HTTPRequest, // <<< changed
        body: HTTPBody?, // <<< added
        metadata: ServerRequestMetadata,
        operationID: String,
        next: @Sendable (HTTPRequest, HTTPBody?, ServerRequestMetadata) async throws -> (HTTPResponse, HTTPBody?) // <<< changed
    ) async throws -> (HTTPResponse, HTTPBody?) // <<< changed
}
```

----------------------------------------

TITLE: Simplify API Output Handling with Chained Operations in Swift
DESCRIPTION: Illustrates how to simplify API output handling using throwing computed properties for enum cases, enabling chained operations to access expected outcomes and throwing errors for unexpected responses or malformed bodies.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0007.md#_snippet_4

LANGUAGE: swift
CODE:
```
// after
print(try await client.getGreeting().ok.body.json.message)
//                     ^             ^       ^
//                     |             |       `- (New) Throws if body did not conform to documented JSON.
//                     |             |
//                     |             `- (New) Throws if HTTP response is not 200 (OK).
//                     |
//                     `- (Existing) Throws if there is an error making the API call.
```

----------------------------------------

TITLE: Create HTTP Body from Data in Swift
DESCRIPTION: Shows how to construct an HTTPBody instance from a Foundation.Data object, useful for sending data in requests.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0004.md#_snippet_11

LANGUAGE: swift
CODE:
```
let data: Foundation.Data = ...
let body = HTTPBody(data)
```

----------------------------------------

TITLE: Run Swift Client with Authentication Token
DESCRIPTION: Demonstrates how to run the `HelloWorldURLSessionClient` from the command line, passing an authentication token. It shows both a successful request with a valid token and an unauthorized response with an invalid token.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/auth-client-middleware-example/README.md#_snippet_0

LANGUAGE: Console
CODE:
```
% swift run HelloWorldURLSessionClient token_for_Frank
Hello, Stranger! (Requested by: Frank)
% swift run HelloWorldURLSessionClient invalid_token
Unauthorized
```

----------------------------------------

TITLE: Consume HTTP Body to Data in Swift
DESCRIPTION: Illustrates how to asynchronously collect an HTTP body and convert its contents into a Foundation.Data object, with a specified maximum size limit.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0004.md#_snippet_12

LANGUAGE: swift
CODE:
```
let data: Foundation.Data = try await Data(collecting: body, upTo: 2 * 1024 * 1024)
```

----------------------------------------

TITLE: Collect HTTP Body into In-Memory Buffers (ByteChunk, Array, String, Data)
DESCRIPTION: These initializers allow collecting the full content of an `HTTPBody` into a single in-memory buffer of a specific type (e.g., `ByteChunk`, `Array<UInt8>`, `String`, `Data`). They enforce a maximum byte limit to prevent excessive memory consumption and throw `TooManyBytesError` if exceeded.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0004.md#_snippet_23

LANGUAGE: APIDOC
CODE:
```
/// Creates a byte chunk by accumulating the full body in-memory into a single buffer
/// up to the provided maximum number of bytes and returning it.
/// - Parameters:
///   - body: The HTTP body to collect.
///   - maxBytes: The maximum number of bytes this method is allowed
///     to accumulate in memory before it throws an error.
/// - Throws: `TooManyBytesError` if the body contains more
///   than `maxBytes`.
public init(collecting body: HTTPBody, upTo maxBytes: Int) async throws
```

LANGUAGE: APIDOC
CODE:
```
extension Array where Element == UInt8 {

    /// Creates a byte array by accumulating the full body in-memory into a single buffer
    /// up to the provided maximum number of bytes and returning it.
    /// - Parameters:
    ///   - body: The HTTP body to collect.
    ///   - maxBytes: The maximum number of bytes this method is allowed
    ///     to accumulate in memory before it throws an error.
    /// - Throws: `TooManyBytesError` if the body contains more
    ///   than `maxBytes`.
    public init(collecting body: HTTPBody, upTo maxBytes: Int) async throws
}
```

LANGUAGE: APIDOC
CODE:
```
extension String {

    /// Creates a string by accumulating the full body in-memory into a single buffer up to
    /// the provided maximum number of bytes, converting it to string using the provided encoding.
    /// - Parameters:
    ///   - body: The HTTP body to collect.
    ///   - maxBytes: The maximum number of bytes this method is allowed
    ///     to accumulate in memory before it throws an error.
    /// - Throws: `TooManyBytesError` if the body contains more
    ///   than `maxBytes`.
    public init(collecting body: HTTPBody, upTo maxBytes: Int) async throws
}
```

LANGUAGE: APIDOC
CODE:
```
extension Data {

    /// Creates a string by accumulating the full body in-memory into a single buffer up to
    /// the provided maximum number of bytes and converting it to `Data`.
    /// - Parameters:
    ///   - body: The HTTP body to collect.
```

----------------------------------------

TITLE: Consume HTTP Body to String in Swift
DESCRIPTION: Demonstrates how to asynchronously collect an HTTP body and convert its contents into a String, with a specified maximum size limit.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0004.md#_snippet_10

LANGUAGE: swift
CODE:
```
let string = try await String(collecting: body, upTo: 2 * 1024 * 1024)
```

----------------------------------------

TITLE: Run a Swift OpenAPI Generator example locally
DESCRIPTION: This command sequence clones the Swift OpenAPI Generator repository, navigates to the Examples directory, and runs a specific example project using `swift run`.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Articles/Checking-out-an-example-project.md#_snippet_0

LANGUAGE: Shell
CODE:
```
% git clone https://github.com/apple/swift-openapi-generator
% cd swift-openapi-generator/Examples
% swift run --package-path hello-world-urlsession-client-example
```

----------------------------------------

TITLE: Initialize HTTPBody from String Values
DESCRIPTION: These initializers create an `HTTPBody` instance from a string, encoding it as UTF-8 bytes. They provide convenience for direct string-to-body conversion, including support for `StringProtocol` and `ExpressibleByStringLiteral`.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0004.md#_snippet_24

LANGUAGE: APIDOC
CODE:
```
extension HTTPBody {

    /// Creates a new body with the provided string encoded as UTF-8 bytes.
    /// - Parameters:
    ///   - string: A string to encode as bytes.
    ///   - length: The total length of the body.
    @inlinable public convenience init(_ string: some StringProtocol & Sendable, length: Length)
}
```

LANGUAGE: APIDOC
CODE:
```
extension HTTPBody {

    /// Creates a new body with the provided string encoded as UTF-8 bytes.
    /// - Parameters:
    ///   - string: A string to encode as bytes.
    @inlinable public convenience init(_ string: some StringProtocol & Sendable)
}
```

LANGUAGE: APIDOC
CODE:
```
extension HTTPBody : ExpressibleByStringLiteral {

    /// Creates an instance initialized to the given string value.
    ///
    /// - Parameter value: The value of the new instance.
    public convenience init(stringLiteral value: String)
}
```

----------------------------------------

TITLE: Define a flexible open OpenAPI oneOf using anyOf
DESCRIPTION: This YAML snippet illustrates how to create an open `oneOf` using `anyOf` and an empty object `{}` as the second schema. This configuration is highly flexible, allowing any JSON payload that doesn't match the defined `oneOf` cases to be preserved.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Articles/Useful-OpenAPI-patterns.md#_snippet_3

LANGUAGE: YAML
CODE:
```
MyOpenOneOf:
  anyOf:
    - oneOf:
        - #/components/schemas/Foo
        - #/components/schemas/Bar
        - #/components/schemas/Baz
    - {}
```

----------------------------------------

TITLE: Run Swift OpenAPI Client
DESCRIPTION: Builds and runs the `hello-world-client` application in a separate terminal. It demonstrates the use of shared types by boxing a message, with the message being boxed twice: once by the server and once by the client.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/shared-types-client-server-example/README.md#_snippet_1

LANGUAGE: console
CODE:
```
% swift run hello-world-client
Build complete!
+––––––––––––––––––+
|+––––––––––––––––+|
||Hello, Stranger!||
|+––––––––––––––––+|
+––––––––––––––––––+
```

----------------------------------------

TITLE: OpenAPI Security Scheme Object Properties
DESCRIPTION: Lists the properties of the OpenAPI Security Scheme Object and their current support.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Articles/Supported-OpenAPI-features.md#_snippet_4

LANGUAGE: APIDOC
CODE:
```
Security Scheme Object:
  type: [ ]
  description: [ ]
  name: [ ]
  in: [ ]
  scheme: [ ]
  bearerFormat: [ ]
  flows: [ ]
  openIdConnectUrl: [ ]
```

----------------------------------------

TITLE: OpenAPI Specification for getStats Operation
DESCRIPTION: Defines the `/stats` GET operation in an OpenAPI specification, detailing `application/json` and `text/plain` as acceptable response content types and their associated schemas.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0003.md#_snippet_3

LANGUAGE: yaml
CODE:
```
/stats:
  get:
    operationId: getStats
    responses:
      '200':
        description: A successful response with stats.
        content:
          application/json:
            schema:
              ...
          text/plain: {}
```

----------------------------------------

TITLE: OpenAPI Schema for getStats Operation Body Types
DESCRIPTION: Defines the possible content types and their schemas for the 200 OK response of the `getStats` operation in the Stats service. It includes structured JSON, unstructured plain text, and binary data.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0004.md#_snippet_2

LANGUAGE: yaml
CODE:
```
application/json:
  schema:
    $ref: '#/components/schemas/StatItems'
text/plain: {}
application/octet-stream: {}
```

----------------------------------------

TITLE: Run Unit Tests
DESCRIPTION: Shows the command to execute the project's unit tests. The tests directly invoke the `Handler`'s business logic, which conforms to `APIProtocol`, allowing for independent verification without involving the server transport.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/hello-world-vapor-server-example/README.md#_snippet_2

LANGUAGE: console
CODE:
```
% swift test
```

----------------------------------------

TITLE: Generate Swift Types from OpenAPI Specification
DESCRIPTION: This console command uses the `swift-openapi-generator` tool to generate Swift types from an `openapi.yaml` file. The `--mode types` flag specifies that only type definitions should be generated.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0007.md#_snippet_10

LANGUAGE: console
CODE:
```
% swift-openapi-generator generate --mode types openapi.yaml
```

----------------------------------------

TITLE: Initial Swift Vapor App Setup Before OpenAPI Migration
DESCRIPTION: This Swift code shows a Vapor application with manually registered routes. To begin the migration, the `app.get("foo")` route is commented out. This change, combined with the `APIProtocol` conformance, leads to a build error because the `getFoo` operation is now expected but not yet implemented.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Articles/Practicing-spec-driven-API-development.md#_snippet_5

LANGUAGE: swift
CODE:
```
let app = try await Vapor.Application.make()

// Registers your existing routes.
// app.get("foo") { ... a, b, c ... } // <<< just comment this out, and this route will be registered below by registerHandlers, as it is now defined by your OpenAPI document.
app.post("foo") { ... a, b, c ... }
app.get("bar") { ... a, b, c ... }

struct Handler: APIProtocol {} // <<< this is where you now get a build error

let transport = VaporTransport(routesBuilder: app)
try handler.registerHandlers(on: transport, serverURL: ...)

try await app.execute()
```

----------------------------------------

TITLE: Swift API: Server-Sent Events Serialization Sequence Struct
DESCRIPTION: This struct represents a sequence that serializes Server-sent Events. It takes an upstream sequence of `ServerSentEvent` elements and converts them into a byte stream suitable for SSE transmission.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0010.md#_snippet_15

LANGUAGE: APIDOC
CODE:
```
public struct ServerSentEventsSerializationSequence<Upstream> : Sendable where Upstream : Sendable, Upstream : AsyncSequence, Upstream.Element == ServerSentEvent {
  public init(upstream: Upstream)
    - Parameter upstream: The upstream sequence of events.
```

----------------------------------------

TITLE: Define a simple closed OpenAPI oneOf
DESCRIPTION: This YAML snippet shows a basic `oneOf` schema in OpenAPI, which is closed by default, meaning decoding fails if an unknown schema is encountered that does not match any of the listed components.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Articles/Useful-OpenAPI-patterns.md#_snippet_2

LANGUAGE: YAML
CODE:
```
oneOf:
  - #/components/schemas/Foo
  - #/components/schemas/Bar
  - #/components/schemas/Baz
```

----------------------------------------

TITLE: OpenAPI Server Definition with Variables
DESCRIPTION: This YAML snippet defines two server URLs, each with an 'environment' variable. The variable for each server specifies different enum values, demonstrating how server variables can be defined with distinct allowed values in OpenAPI.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0012.md#_snippet_6

LANGUAGE: yaml
CODE:
```
servers:
  - url: https://{env}.example.com
    variables:
      environment:
        default: prod
        enum:
          - prod
          - staging
  - url: https://{env}.example2.com
    variables:
      environment:
        default: prod
        enum:
          - prod
          - dev
```

----------------------------------------

TITLE: Defining Required Query Parameter
DESCRIPTION: Demonstrates how to define a required query parameter (`limit`) by explicitly setting `required: true`. This ensures a non-optional `Int` value is generated in Swift.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Development/Handling-nullable-schemas.md#_snippet_6

LANGUAGE: yaml
CODE:
```
parameters:
  - name: limit
    in: query
    required: true
    schema:
      type: integer
```

----------------------------------------

TITLE: Configure Idiomatic Naming Strategy for Swift OpenAPI Generator
DESCRIPTION: This YAML configuration snippet enables the 'idiomatic' naming strategy in the Swift OpenAPI Generator. This strategy optimizes for Swift-idiomatic names by handling specific characters and special cases like all-uppercased names, improving the readability of generated Swift code.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0013.md#_snippet_3

LANGUAGE: YAML
CODE:
```
namingStrategy: idiomatic
```

----------------------------------------

TITLE: Run Unit Tests
DESCRIPTION: Command to execute the unit tests for the server's business logic. The testing strategy involves directly calling the Handler, which conforms to APIProtocol, without involving any ServerTransport.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/various-content-types-server-example/README.md#_snippet_2

LANGUAGE: console
CODE:
```
% swift test
```

----------------------------------------

TITLE: Run Swift Client CLI for Proxy Interaction
DESCRIPTION: This snippet demonstrates how to execute the `ClientCLI` to interact with the running `ProxyServer`. It shows an example command-line invocation with a query and the subsequent streaming response from the 'ChantGPT' service, illustrating the end-to-end streaming of creative chants.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/streaming-chatgpt-proxy/README.md#_snippet_1

LANGUAGE: console
CODE:
```
% swift run ClientCLI "That team with the Bull logo"
Build of product 'ClientCLI' complete! (7.24s)
🧑‍💼: That one with the bull logo
---
🤖: **"Charge Ahead, Chicago Bulls!"**

(Verse 1)
Red and black, we’re on the prowl,
Chicago Bulls, hear us growl!
From the Windy City, we take the lead,
Charging forward with lightning speed!

(Chorus)
B-U-L-L-S, Bulls! Bulls! Bulls!
We’re the team that never dulls!
Hoops and hustle, heart and soul,
Chicago Bulls, we’re on a roll!
...
```

----------------------------------------

TITLE: Run Swift OpenAPI Generator Unit Tests
DESCRIPTION: Command to execute the unit tests for the server application. The testing strategy involves directly calling the `Handler` to verify business logic, independent of the server transport.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/hello-world-hummingbird-server-example/README.md#_snippet_2

LANGUAGE: console
CODE:
```
% swift test
```

----------------------------------------

TITLE: Supported OpenAPI Specification Features
DESCRIPTION: Details the specific OpenAPI 3.0.3 and 3.1.0 features, objects, and properties that are supported by the Swift OpenAPI Generator. This includes structured content types, various OpenAPI objects (like Info, Server, Path Item, Operation, Schema), and parameter styles.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Articles/Supported-OpenAPI-features.md#_snippet_0

LANGUAGE: APIDOC
CODE:
```
Structured content types:
  - JSON: Supported (when content type is `application/json` or ends with `+json`)
  - URL-encoded form request bodies: Supported (when content type is `application/x-www-form-urlencoded`)
  - multipart: Supported (for details, see SOAR-0009)
  - XML: Not Supported

OpenAPI specification features:

OpenAPI Object:
  - openapi: Supported
  - info: Supported
  - servers: Supported
  - paths: Supported
  - components: Supported
  - security: Not Supported
  - tags: Not Supported
  - externalDocs: Not Supported

Info Object:
  - title: Supported
  - description: Supported
  - termsOfService: Not Supported
  - contact: Not Supported
  - license: Not Supported
  - version: Supported

Contact Object:
  - name: Not Supported
  - url: Not Supported
  - email: Not Supported

License Object:
  - name: Not Supported
  - url: Not Supported

Server Object:
  - url: Supported
  - description: Supported
  - variables: Supported

Server Variable Object:
  - enum: Supported
  - default: Supported
  - description: Supported

Paths Object:
  - map from pattern to Path Item Object: Supported

Path Item Object:
  - $ref: Supported
  - summary: Supported
  - description: Supported
  - get/put/post/delete/options/head/patch/trace: Supported
  - servers: Not Supported
  - parameters: Supported

Operation Object:
  - tags: Not Supported
  - summary: Supported
  - description: Supported
  - externalDocs: Not Supported
  - operationId: Supported
  - parameters: Supported
  - requestBody: Supported
  - responses: Supported
  - callbacks: Not Supported
  - deprecated: Supported
  - security: Not Supported
  - servers: Not Supported

Request Body Object:
  - description: Supported
  - content: Supported
  - required: Supported

Media Type Object:
  - schema: Supported
  - example: Not Supported
  - examples: Not Supported
  - encoding (in multipart only): Supported

Security Requirement Object:
  - map from name pattern to a list of strings: Not Supported

Responses Object:
  - default: Supported
  - map of HTTP status code to response: Supported

Response Object:
  - description: Supported
  - headers: Supported
  - content: Supported
  - links: Not Supported

Header Object:
  - a special case of Parameter Object: Supported

Callback Object:
  - map from expression to Path Item Object: Not Supported

Schema Object:
  - title: Supported
  - multipleOf: Not Supported
  - maximum: Not Supported
  - exclusiveMaximum: Not Supported
  - minimum: Not Supported
  - exclusiveMinimum: Not Supported
  - maxLength: Not Supported
  - minLength: Not Supported
  - pattern: Not Supported
  - maxItems: Not Supported
  - minItems: Not Supported
  - uniqueItems: Not Supported
  - maxProperties: Not Supported
  - minProperties: Not Supported
  - required: Supported
  - enum (when type is string or integer): Supported
  - type: Supported
  - allOf: Supported (a wrapper struct is generated, children can be any schema)
  - oneOf: Supported (if a discriminator is specified, each child must be a reference to an object schema; if no discriminator is specified, children can be any schema)
  - anyOf: Supported (a wrapper struct is generated, children can be any schema)
  - not: Not Supported
  - items: Supported
  - properties: Supported
  - additionalProperties: Supported
  - description: Supported
  - format: Supported
  - default: Not Supported
  - nullable (only in 3.0, removed in 3.1, add `null` in `types` instead): Supported
  - discriminator: Supported
  - readOnly: Not Supported
  - writeOnly: Not Supported
  - xml: Not Supported
  - externalDocs: Not Supported
  - example: Not Supported
  - deprecated: Supported

External Documentation Object:
  - description: Not Supported
  - url: Not Supported

Discriminator Object:
  - propertyName: Supported
  - mapping: Supported

XML Object:
  - name: Not Supported
  - namespace: Not Supported
  - prefix: Not Supported
  - attribute: Not Supported
  - wrapped: Not Supported

Encoding Object:
  - contentType: Supported
  - headers: Supported
  - style: Not Supported
  - explode: Not Supported
  - allowReserved: Not Supported

Parameter Object:
  - name: Supported
  - in: Supported
  - description: Supported
  - required: Supported
  - deprecated: Supported
  - allowEmptyValue: Not Supported
  - style (only defaults): Supported
  - explode (non default only for query items): Supported
  - allowReserved: Not Supported
  - schema: Supported
  - example: Not Supported
  - examples: Not Supported
  - content: Supported

Style Values:
  - matrix (in path): Not Supported
  - label (in path): Not Supported
  - form (in query): Supported
  - form (in cookie): Not Supported
  - simple (in path): Supported
  - simple (in header): Supported
  - spaceDelimited (in query): Not Supported
  - pipeDelimited (in query): Not Supported
  - deepObject (in query): Not Supported

Supported combinations:
  Location | Style  | Explode
  ---------|--------|--------
  path     | `simple` | `false`
  query    | `form`   | `true`
  query    | `form`   | `false`
  header   | `simple` | `false`

Reference Object:
  - $ref: Supported
```

----------------------------------------

TITLE: Configure Type Overrides for Swift OpenAPI Generator
DESCRIPTION: This configuration snippet demonstrates how to use the `typeOverrides` option in the Swift OpenAPI Generator. It maps the `UUID` schema defined in the OpenAPI document to `Foundation.UUID`, ensuring that the generated Swift code uses the standard library's UUID type.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0014.md#_snippet_1

LANGUAGE: YAML
CODE:
```
typeOverrides:
  schemas:
    UUID: Foundation.UUID
```

----------------------------------------

TITLE: Swift ErrorHandlingMiddleware for OpenAPI Runtime
DESCRIPTION: This API documentation describes the `ErrorHandlingMiddleware` struct, a `ServerMiddleware` designed for the Swift OpenAPI Runtime. It intercepts requests and attempts to convert application errors that conform to `HTTPResponseConvertible` into appropriate HTTP responses. Errors not conforming to the protocol are re-thrown, potentially resulting in a default 500 Internal Error.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0011.md#_snippet_2

LANGUAGE: APIDOC
CODE:
```
public struct ErrorHandlingMiddleware: ServerMiddleware {
    func intercept(_ request: HTTPTypes.HTTPRequest,
                   body: OpenAPIRuntime.HTTPBody?,
                   metadata: OpenAPIRuntime.ServerRequestMetadata,
                   operationID: String,
                   next: @Sendable (HTTPTypes.HTTPRequest, OpenAPIRuntime.HTTPBody?, OpenAPIRuntime.ServerRequestMetadata) async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?)) async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?) {
        do {
            return try await next(request, body, metadata)
        } catch let error as ServerError {
            if let appError = error.underlyingError as? HTTPResponseConvertible {
                return (HTTPResponse(status: appError.httpStatus, headerFields: appError.httpHeaderFields),
                appError.httpBody)
            } else {
                throw error
            }
        }
    }
}
```

----------------------------------------

TITLE: Run Swift Client with Retrying Middleware
DESCRIPTION: Demonstrates running the Swift client CLI, showing the retry mechanism in action for a 500 status code, and the final successful response.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/retrying-middleware-example/README.md#_snippet_0

LANGUAGE: Shell
CODE:
```
% swift run
Attempt 1
Retrying with code 500
Attempt 2
Returning the received response, either because of success or ran out of attempts.
Hello, Stranger!
```

----------------------------------------

TITLE: Initialize Swift Executable Package
DESCRIPTION: This sequence of shell commands creates a new directory, initializes a Swift executable package within that directory, and then opens the generated Package.swift file for further configuration.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Tutorials/_Resources/server.console.1.2.txt#_snippet_0

LANGUAGE: Shell
CODE:
```
% mkdir GreetingService
% swift package --package-path GreetingService init --type executable
% open GreetingService/Package.swift
```

----------------------------------------

TITLE: Initialize Swift Executable Package for Service Client
DESCRIPTION: These commands guide you through creating a new directory for your service client, initializing it as a Swift executable package, and then opening the generated Package.swift file for further configuration. This is a standard procedure for starting a new Swift project.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Tutorials/_Resources/client.console.2.2.txt#_snippet_0

LANGUAGE: Shell
CODE:
```
% mkdir GreetingServiceClient
% swift package --package-path GreetingServiceClient init --type executable
% open GreetingServiceClient/Package.swift
```

----------------------------------------

TITLE: Initialize Swift Executable Package
DESCRIPTION: These commands create a new directory named 'GreetingService' and then initialize a Swift executable package within that directory. This is a common first step when setting up a new Swift project.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Tutorials/_Resources/server.console.1.1.txt#_snippet_0

LANGUAGE: Shell
CODE:
```
mkdir GreetingService
```

LANGUAGE: Shell
CODE:
```
swift package --package-path GreetingService init --type executable
```

----------------------------------------

TITLE: Initialize Swagger UI for OpenAPI Specification
DESCRIPTION: This JavaScript snippet initializes Swagger UI to display an OpenAPI specification from 'openapi.yaml'. It configures the UI to render within the '#openapi' DOM element, enables deep linking for navigation, and explicitly disables validation checks.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Tutorials/_Resources/server-openapi-endpoints.openapi.html#_snippet_0

LANGUAGE: JavaScript
CODE:
```
window.onload = function() { const ui = SwaggerUIBundle({ url: "openapi.yaml", dom_id: "#openapi", deepLinking: true, validatorUrl: "none" }) }
```

----------------------------------------

TITLE: Final Swift Vapor App with All OpenAPI Routes
DESCRIPTION: This Swift code represents the final state of the Vapor application after all operations (`GET /foo`, `POST /foo`, `GET /bar`) have been successfully migrated to be defined by the OpenAPI document. All business logic is now encapsulated within the `APIProtocol` conforming `Handler` struct, and the routes are registered efficiently via `registerHandlers` using the generated code.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Articles/Practicing-spec-driven-API-development.md#_snippet_7

LANGUAGE: swift
CODE:
```
let app = try await Vapor.Application.make()

// Register some manual routes, for example, for serving static files.
app.middlewares.on(FileMiddleware(...))

// The business logic.
struct Handler: APIProtocol {
  func getFoo(input: Operations.getFoo.Input) async throws -> Operations.getFoo.Output {
    // ...
  }
  func postFoo(input: Operations.postFoo.Input) async throws -> Operations.postFoo.Output {
    // ...
  }
  func getBar(input: Operations.getBar.Input) async throws -> Operations.getBar.Output {
    // ...
  }
}

// Register the generated routes from OpenAPI.
let transport = VaporTransport(routesBuilder: app)
try handler.registerHandlers(on: transport, serverURL: ...)

try await app.execute()
```

----------------------------------------

TITLE: Send multiple greeting requests to the API server
DESCRIPTION: This command uses `xargs` and `curl` to send individual GET requests to the `/api/greet` endpoint for each name provided. It demonstrates interacting with the running API service and generating traffic for metric collection.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/metrics-middleware-example/README.md#_snippet_4

LANGUAGE: console
CODE:
```
% echo "Juan Mei Tom Bill Anne Ravi Maria" | xargs -n1 -I% curl "localhost:8080/api/greet?name=%"
```

----------------------------------------

TITLE: Query Prometheus metrics endpoint
DESCRIPTION: Command to retrieve the Prometheus-formatted metrics from the `/metrics` endpoint of the running server, showing collected HTTP request data.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/metrics-middleware-example/README.md#_snippet_2

LANGUAGE: console
CODE:
```
curl "localhost:8080/metrics"
# TYPE http_requests_total counter
http_requests_total{method="GET",path="/metrics",status="200"} 1
http_requests_total{method="GET",path="//api/greet",status="200"} 7
# TYPE http_request_duration_seconds histogram
http_request_duration_seconds_bucket{method="GET",path="//api/greet",status="200",le="0.005"} 5
http_request_duration_seconds_bucket{method="GET",path="//api/greet",status="200",le="0.01"} 6
http_request_duration_seconds_bucket{method="GET",path="//api/greet",status="200",le="0.025"} 7
http_request_duration_seconds_bucket{method="GET",path="//api/greet",status="200",le="0.05"} 7
http_request_duration_seconds_bucket{method="GET",path="//api/greet",status="200",le="0.1"} 7
http_request_duration_seconds_bucket{method="GET",path="//api/greet",status="200",le="0.25"} 7
http_request_duration_seconds_bucket{method="GET",path="//api/greet",status="200",le="0.5"} 7
http_request_duration_seconds_bucket{method="GET",path="//api/greet",status="200",le="1.0"} 7
http_request_duration_seconds_bucket{method="GET",path="//api/greet",status="200",le="2.5"} 7
http_request_duration_seconds_bucket{method="GET",path="//api/greet",status="200",le="5.0"} 7
http_request_duration_seconds_bucket{method="GET",path="//api/greet",status="200",le="10.0"} 7
http_request_duration_seconds_bucket{method="GET",path="//api/greet",status="200",le="+Inf"} 7
http_request_duration_seconds_sum{method="GET",path="//api/greet",status="200"} 0.025902709
http_request_duration_seconds_count{method="GET",path="//api/greet",status="200"} 7
http_request_duration_seconds_bucket{method="GET",path="/metrics",status="200",le="0.005"} 1
http_request_duration_seconds_bucket{method="GET",path="/metrics",status="200",le="0.01"} 1
http_request_duration_seconds_bucket{method="GET",path="/metrics",status="200",le="0.025"} 1
http_request_duration_seconds_bucket{method="GET",path="/metrics",status="200",le="0.05"} 1
http_request_duration_seconds_bucket{method="GET",path="/metrics",status="200",le="0.1"} 1
http_request_duration_seconds_bucket{method="GET",path="/metrics",status="200",le="0.25"} 1
http_request_duration_seconds_bucket{method="GET",path="/metrics",status="200",le="0.5"} 1
http_request_duration_seconds_bucket{method="GET",path="/metrics",status="200",le="1.0"} 1
http_request_duration_seconds_bucket{method="GET",path="/metrics",status="200",le="2.5"} 1
http_request_duration_seconds_bucket{method="GET",path="/metrics",status="200",le="5.0"} 1
http_request_duration_seconds_bucket{method="GET",path="/metrics",status="200",le="10.0"} 1
http_request_duration_seconds_bucket{method="GET",path="/metrics",status="200",le="+Inf"} 1
http_request_duration_seconds_sum{method="GET",path="/metrics",status="200"} 0.001705458
http_request_duration_seconds_count{method="GET",path="/metrics",status="200"} 1
# TYPE HelloWorldServer.getGreeting.200 counter
HelloWorldServer.getGreeting.200 7
```

----------------------------------------

TITLE: Defining Optional Query Parameter
DESCRIPTION: Shows how to define an optional query parameter (`limit`) in OpenAPI. Parameters are optional by default if the `required` field is not explicitly set to `true`. This results in an optional `Int` in generated Swift code.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Development/Handling-nullable-schemas.md#_snippet_5

LANGUAGE: yaml
CODE:
```
parameters:
  - name: limit
    in: query
    schema:
      type: integer
```

----------------------------------------

TITLE: Swift: Encode AsyncSequence to JSON Sequence
DESCRIPTION: An extension on `AsyncSequence` that encodes its `Encodable` elements into a JSON Sequence using a `JSONEncoder`. Useful for streaming JSON data.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0010.md#_snippet_8

LANGUAGE: Swift
CODE:
```
extension AsyncSequence where Self.Element : Encodable {

    /// Returns another sequence that encodes the events using the provided encoder into a JSON Sequence.
    /// - Parameter encoder: The JSON encoder to use.
    /// - Returns: A sequence that provides the serialized JSON Sequence.
    public func asEncodedJSONSequence(encoder: JSONEncoder = {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
            return encoder
        }()) -> JSONSequenceSerializationSequence<AsyncThrowingMapSequence<Self, ArraySlice<UInt8>>>
}
```

----------------------------------------

TITLE: Document an OpenAPI operation returning JSON Lines
DESCRIPTION: This YAML snippet demonstrates how to document an API operation in OpenAPI that returns an event stream formatted as JSON Lines, using `application/jsonl` as the content type. This pattern can be adapted for other event stream formats like JSON Sequence or Server-sent Events.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Articles/Useful-OpenAPI-patterns.md#_snippet_5

LANGUAGE: YAML
CODE:
```
paths:
  /events:
    get:
      operationId: getEvents
      responses:
        '200':
          content:
            application/jsonl: {}
components:
  schemas:
    MyEvent:
      type: object
      properties:
        ...
```

----------------------------------------

TITLE: Regenerate OpenAPI client code
DESCRIPTION: Instructions to regenerate client code using `make generate` whenever the `openapi.yaml` document changes. The generated files are located in `./Sources/ManualGeneratorInvocationClient/Generated/*`.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/manual-generation-generator-cli-example/README.md#_snippet_0

LANGUAGE: console
CODE:
```
% make generate
```

----------------------------------------

TITLE: HTTP POST Request for Raw File Upload
DESCRIPTION: Illustrates an HTTP POST request for uploading a raw file, such as an image. The request specifies 'image/jpeg' as the 'Content-Type'. The server responds with a '204 No Content' status, indicating successful processing without a response body.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0009.md#_snippet_1

LANGUAGE: HTTP
CODE:
```
> POST /cat-photo HTTP/1.1
> content-type: image/jpeg
>
> ...
---
< HTTP/1.1 204 No Content
```

----------------------------------------

TITLE: Run Swift Server Locally
DESCRIPTION: Command to compile and run the Swift server application locally. This server will connect to the previously started Postgres database.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/postgres-database-example/README.md#_snippet_1

LANGUAGE: console
CODE:
```
% swift run
```

----------------------------------------

TITLE: Generate Client Code with Swift OpenAPI Generator
DESCRIPTION: This YAML configuration generates client code and types for a Swift OpenAPI project. The `namingStrategy` is set to `idiomatic` for Swift-style naming conventions.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Articles/Configuring-the-generator.md#_snippet_2

LANGUAGE: yaml
CODE:
```
generate:
  - types
  - client
namingStrategy: idiomatic
```

----------------------------------------

TITLE: Rule: Parameter Optionality
DESCRIPTION: Summarizes the rule for determining if a parameter (including request bodies) is optional: it is optional if its schema is nullable OR if the parameter itself is not marked `required: true`. Parameters are optional by default.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Development/Handling-nullable-schemas.md#_snippet_7

LANGUAGE: APIDOC
CODE:
```
`parameter is optional := schema is nullable OR parameter is not marked required`
```

----------------------------------------

TITLE: Rule: Object Property Optionality
DESCRIPTION: Summarizes the rule for determining if an object property is optional: it is optional if its schema is nullable OR if the property is not included in the object's `required` array. If either condition is true, the property is generated as a single-wrapped optional.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Development/Handling-nullable-schemas.md#_snippet_4

LANGUAGE: APIDOC
CODE:
```
`property is optional := schema is nullable OR property is not required`
```

----------------------------------------

TITLE: Swift OpenAPI Generator: Compile-Time Validation on Enum Value Removal
DESCRIPTION: This Swift example demonstrates how the generated type-safe API provides compile-time alerts when an enum value, previously allowed, is removed from the OpenAPI document. This ensures that client code remains synchronized with the API definition.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0012.md#_snippet_5

LANGUAGE: Swift
CODE:
```
// some time later "staging" gets removed from OpenAPI document
let url = try Servers.Server1.url(environment: . staging)  // ❌ compiler error, 'staging' not defined on the enum
```

----------------------------------------

TITLE: Make Multiple Requests to Swift Server
DESCRIPTION: This command uses `xargs` and `curl` to send multiple GET requests to the local server's `/api/greet` endpoint with different names, demonstrating how to interact with the running service and generate traces.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/tracing-middleware-example/README.md#_snippet_2

LANGUAGE: console
CODE:
```
xargs -n1 -I% curl "localhost:8080/api/greet?name=%" <<< "Juan Mei Tom Bill Anne Ravi Maria"
```

----------------------------------------

TITLE: Swift API for JSON Sequence Serialization
DESCRIPTION: Defines a Swift `AsyncSequence` for serializing lines by concatenating them using the JSON Sequence format. This includes the `JSONSequenceSerializationSequence` struct and its `AsyncSequence` conformance.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0010.md#_snippet_6

LANGUAGE: swift
CODE:
```
/// A sequence that serializes lines by concatenating them using the JSON Sequence format.
public struct JSONSequenceSerializationSequence<Upstream> : Sendable where Upstream : Sendable, Upstream : AsyncSequence, Upstream.Element == ArraySlice<UInt8> {

    /// Creates a new sequence.
    /// - Parameter upstream: The upstream sequence of lines.
    public init(upstream: Upstream)
}

extension JSONSequenceSerializationSequence : AsyncSequence {
    public typealias Element = ArraySlice<UInt8>
}
```

----------------------------------------

TITLE: Swift API for JSON Sequence Deserialization
DESCRIPTION: Provides Swift types and extensions for deserializing byte chunks into JSON Sequence format and then decoding those into Swift `Decodable` types. This includes the `JSONSequenceDeserializationSequence` struct and an `AsyncSequence` extension for decoding events.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0010.md#_snippet_5

LANGUAGE: swift
CODE:
```
/// A sequence that parses arbitrary byte chunks into lines using the JSON Sequence format.
public struct JSONSequenceDeserializationSequence<Upstream> : Sendable where Upstream : Sendable, Upstream : AsyncSequence, Upstream.Element == ArraySlice<UInt8> {

    /// Creates a new sequence.
    /// - Parameter upstream: The upstream sequence of arbitrary byte chunks.
    public init(upstream: Upstream)
}

extension JSONSequenceDeserializationSequence : AsyncSequence {
    public typealias Element = ArraySlice<UInt8>
    public struct Iterator<UpstreamIterator> : AsyncIteratorProtocol where UpstreamIterator : AsyncIteratorProtocol, UpstreamIterator.Element == ArraySlice<UInt8> {
        public mutating func next() async throws -> ArraySlice<UInt8>?
    }
    public func makeAsyncIterator() -> Iterator<Upstream.AsyncIterator>
}

extension AsyncSequence where Self.Element == ArraySlice<UInt8> {

    /// Returns another sequence that decodes each JSON Sequence event as the provided type using the provided decoder.
    /// - Parameters:
    ///   - eventType: The type to decode the JSON event into.
    ///   - decoder: The JSON decoder to use.
    /// - Returns: A sequence that provides the decoded JSON events.
    public func asDecodedJSONSequence<Event>(of eventType: Event.Type = Event.self, decoder: JSONDecoder = .init()) -> AsyncThrowingMapSequence<JSONSequenceDeserializationSequence<Self>, Event> where Self : Sendable, Event : Decodable
}
```

----------------------------------------

TITLE: Override Default Generated Types
DESCRIPTION: This configuration allows replacing a default generated type with a custom type. For example, it overrides the `UUID` schema to use `Foundation.UUID`.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Articles/Configuring-the-generator.md#_snippet_11

LANGUAGE: yaml
CODE:
```
typeOverrides:
  schemas:
    UUID: Foundation.UUID
```

----------------------------------------

TITLE: Invoke Swift OpenAPI Greeting Service with cURL
DESCRIPTION: Command line example to interact with the running Hello World server's greeting API endpoint. It demonstrates sending a GET request and the expected JSON response from the server.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/hello-world-hummingbird-server-example/README.md#_snippet_0

LANGUAGE: console
CODE:
```
% curl http://localhost:8080/api/greet
{
  "message" : "Hello, Stranger!"
}
```

----------------------------------------

TITLE: Test Server API Endpoints with cURL
DESCRIPTION: Sequence of cURL commands to interact with the running server's API, demonstrating the 'greet', 'count', and 'reset' functionalities and verifying data persistence.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/postgres-database-example/README.md#_snippet_2

LANGUAGE: console
CODE:
```
% curl "localhost:8080/api/greet?name=Jane"
{
  "message" : "Hello, Jane!"
}


% curl "localhost:8080/api/greet?name=Jane"
{
  "message" : "Hello, Jane!"
}


% curl "localhost:8080/api/count"
{
  "count" : 2
}


% curl -X POST "localhost:8080/api/reset"


% curl "localhost:8080/api/count"
{
  "count" : 0
}
```

----------------------------------------

TITLE: Swift Client Invocation with Custom Accept Headers
DESCRIPTION: Demonstrates how a client can explicitly set the `accept` header using the generated Swift client, prioritizing JSON over plain text when invoking the `getStats` operation.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0003.md#_snippet_5

LANGUAGE: swift
CODE:
```
let response = try await client.getStats(.init(
    headers: .init(accept: [
        .init(contentType: .json),
        .init(contentType: .plainText, quality: 0.5)
    ])
))
```

----------------------------------------

TITLE: Defining Optional Standalone Schemas
DESCRIPTION: Shows how to define a standalone schema as optional, demonstrating the differences between OpenAPI 3.0.3 (JSON Schema Draft 5) using `nullable: true` and OpenAPI 3.1.0 (JSON Schema 2020-12) using `type: [string, null]`. In both cases, the schema is treated as optional and defaults to nil if omitted.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Development/Handling-nullable-schemas.md#_snippet_0

LANGUAGE: yaml
CODE:
```
MyOptionalString:
  type: string
  nullable: true
```

LANGUAGE: yaml
CODE:
```
MyOptionalString:
  type: [string, null]
```

----------------------------------------

TITLE: Build and Run Swift Proxy Server
DESCRIPTION: This snippet shows how to build and run the `ProxyServer` component of the project. It requires the `OPENAI_TOKEN` environment variable to be set for upstream calls to ChatGPT. The output demonstrates the server starting up and listening on a local address.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/streaming-chatgpt-proxy/README.md#_snippet_0

LANGUAGE: console
CODE:
```
% swift run ProxyServer
2025-01-30T09:12:23+0000 notice codes.vapor.application : [Vapor] Server starting on http://127.0.0.1:8080
...
```

----------------------------------------

TITLE: Create HTTPBody from a string
DESCRIPTION: Example of creating an `HTTPBody` directly from a Swift `String`.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0004.md#_snippet_16

LANGUAGE: swift
CODE:
```
let body = HTTPBody("Hello, world!")
```

----------------------------------------

TITLE: View Swift OpenAPI Generator CLI Help
DESCRIPTION: Execute this console command to display the comprehensive usage documentation for the `swift-openapi-generator` command-line interface. It provides details on all available modes, options, and arguments for code generation.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Articles/Manually-invoking-the-generator-CLI.md#_snippet_1

LANGUAGE: Console
CODE:
```
% swift run swift-openapi-generator --help
```

----------------------------------------

TITLE: Clone and Build Swift OpenAPI Generator Integration Tests
DESCRIPTION: Demonstrates how to clone the Swift OpenAPI Generator repository, navigate to the IntegrationTests directory, override a dependency with a local checkout, and build the project. This process is useful for testing changes in other projects, particularly from a pull request pipeline.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/IntegrationTest/README.md#_snippet_0

LANGUAGE: console
CODE:
```
% git clone https://github.com/apple/swift-openapi-generator
% cd swift-openapi-generator/IntegrationTests
% swift package edit swift-openapi-runtime path/to/checkout/of/swift-openapi-runtime
% swift build
```

----------------------------------------

TITLE: Swift OpenAPI Generator Runtime Library API Definitions
DESCRIPTION: Defines the core protocols and structs for content type negotiation in the Swift OpenAPI Generator runtime library, including `AcceptableProtocol`, `AcceptHeaderContentType`, and `QualityValue`. These types are fundamental for handling Accept headers and quality values in generated code.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0003.md#_snippet_7

LANGUAGE: APIDOC
CODE:
```
/// The protocol that all generated `AcceptableContentType` enums conform to.
public protocol AcceptableProtocol : CaseIterable, Hashable, RawRepresentable, Sendable where Self.RawValue == String {}

/// A wrapper of an individual content type in the accept header.
public struct AcceptHeaderContentType<ContentType> : Sendable, Equatable, Hashable where ContentType : Acceptable.AcceptableProtocol {

    /// The value representing the content type.
    public var contentType: ContentType

    /// The quality value of this content type.
    ///
    /// Used to describe the order of priority in a comma-separated
    /// list of values.
    ///
    /// Content types with a higher priority should be preferred by the server
    /// when deciding which content type to use in the response.
    ///
    /// Also called the "q-factor" or "q-value".
    public var quality: QualityValue

    /// Creates a new content type from the provided parameters.
    /// - Parameters:
    ///   - value: The value representing the content type.
    ///   - quality: The quality of the content type, between 0.0 and 1.0.
    /// - Precondition: Priority must be in the range 0.0 and 1.0 inclusive.
    public init(contentType: ContentType, quality: QualityValue = 1.0)

    /// Returns the default set of acceptable content types for this type, in
    /// the order specified in the OpenAPI document.
    public static var defaultValues: [`Self`] { get }
}

/// A quality value used to describe the order of priority in a comma-separated
/// list of values, such as in the Accept header.
public struct QualityValue : Sendable, Equatable, Hashable {

    /// Creates a new quality value of the default value 1.0.
    public init()

    /// Returns a Boolean value indicating whether the quality value is
    /// at its default value 1.0.
    public var isDefault: Bool { get }

    /// Creates a new quality value from the provided floating-point number.
    ///
    /// - Precondition: The value must be between 0.0 and 1.0, inclusive.
    public init(doubleValue: Double)

    /// The value represented as a floating-point number between 0.0 and 1.0, inclusive.
    public var doubleValue: Double { get }
}

extension QualityValue : RawRepresentable { ... }
extension QualityValue : ExpressibleByIntegerLiteral { ... }
extension QualityValue : ExpressibleByFloatLiteral { ... }
extension AcceptHeaderContentType : RawRepresentable { ... }

extension Array {
    /// Returns the array sorted by the quality value, highest quality first.
    public func sortedByQuality<T>() -> [AcceptHeaderContentType<T>] where Element == Acceptable.AcceptHeaderContentType<T>, T : Acceptable.AcceptableProtocol

    /// Returns the default values for the acceptable type.
    public static func defaultValues<T>() -> [AcceptHeaderContentType<T>] where Element == Acceptable.AcceptHeaderContentType<T>, T : Acceptable.AcceptableProtocol
}
```

----------------------------------------

TITLE: Defining Object Properties with Explicit Schema Nullability
DESCRIPTION: Illustrates an object schema where a property (`age`) is explicitly marked as nullable (`type: [integer, null]`), even though it's included in the `required` array. The generator's rule states that if any optionality hint is present, the property is treated as optional, resulting in the same generated Swift code as if `age` were just omitted from `required`.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Development/Handling-nullable-schemas.md#_snippet_3

LANGUAGE: yaml
CODE:
```
MyPerson:
  type: object
  properties:
    name:
      type: string
    age:
      type: [integer, null]
  required:
    - name
    - age # even though required, the nullability of the schema "wins"
```

----------------------------------------

TITLE: Proposed OpenAPI Generator Filter Configuration Structure
DESCRIPTION: This YAML snippet outlines the new 'filter' key proposed for the 'openapi-generator-config.yaml' file. It shows the potential sub-keys ('paths', 'tags', 'operations', 'schemas') that users can use to specify which parts of the OpenAPI document to include during generation.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0008.md#_snippet_3

LANGUAGE: yaml
CODE:
```
# filter:
#   paths:
#   - ...
#   tags:
#   - ...
#   operations:
#   - ...
#   schemas:
#   - ...
```

----------------------------------------

TITLE: Build and Run Swift OpenAPI Server CLI
DESCRIPTION: Command to build and start the Swift OpenAPI Generator server CLI, displaying the server's startup message and the address it is listening on.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/swagger-ui-endpoint-example/README.md#_snippet_1

LANGUAGE: console
CODE:
```
% swift run
2023-12-01T14:14:35+0100 notice codes.vapor.application : [Vapor] Server starting on http://127.0.0.1:8080
...
```

----------------------------------------

TITLE: Build and run the client CLI
DESCRIPTION: How to build and run the client CLI using `swift run` and observe its output.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/manual-generation-generator-cli-example/README.md#_snippet_1

LANGUAGE: console
CODE:
```
% swift run
Hello, Stranger!
```

----------------------------------------

TITLE: Generated API Protocol for Stats Service (Current)
DESCRIPTION: The `APIProtocol` defines the contract for the Stats service, used by both client and server. It includes `getStats` and `postStats` operations.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0004.md#_snippet_6

LANGUAGE: swift
CODE:
```
public protocol APIProtocol: Sendable {
    func getStats(_ input: Operations.getStats.Input) async throws -> Operations.getStats.Output
    func postStats(_ input: Operations.postStats.Input) async throws -> Operations.postStats.Output
}
```

----------------------------------------

TITLE: Define UUID Schema in OpenAPI
DESCRIPTION: This YAML snippet defines a `UUID` schema within the `components.schemas` section of an OpenAPI document. It specifies the type as `string` and the format as `uuid`, illustrating a common scenario where custom type handling is beneficial.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0014.md#_snippet_0

LANGUAGE: YAML
CODE:
```
components:
  schemas:
    UUID:
      type: string
      format: uuid
```

----------------------------------------

TITLE: Clone and Navigate to Swift OpenAPI Generator Example
DESCRIPTION: Commands to clone the Swift OpenAPI Generator repository from GitHub and change the current directory to the 'hello-world-vapor-server-example' within the Examples folder, preparing for server setup.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Tutorials/_Resources/client.console.1.2.txt#_snippet_0

LANGUAGE: Shell
CODE:
```
% git clone https://github.com/apple/swift-openapi-generator
% cd swift-openapi-generator/Examples/hello-world-vapor-server-example
```

----------------------------------------

TITLE: Reset Swift Package Overrides
DESCRIPTION: Shows how to reset any local package overrides applied to a Swift package. This command is useful when working manually and needing to revert dependency changes or clean up the project state.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/IntegrationTest/README.md#_snippet_1

LANGUAGE: console
CODE:
```
% swift package reset
```

----------------------------------------

TITLE: Configuring Swift Package Access Level for Swift OpenAPI Generator
DESCRIPTION: This snippet details how to resolve the 'Decl has a package access level but no -package-name was passed' build error. It covers updating `swift-tools-version` in `Package.swift` for Swift packages, setting the `SWIFT_PACKAGE_NAME` build setting in Xcode projects, and optionally changing the generated code's access modifier via generator configuration or CLI arguments.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Articles/Frequently-asked-questions.md#_snippet_0

LANGUAGE: Configuration
CODE:
```
For Swift packages, ensure 'Package.swift' has:
  swift-tools-version: 5.9 or later

For Xcode projects, set build setting:
  SWIFT_PACKAGE_NAME = YourProjectName

Alternatively, in generator configuration file:
  accessModifier: internal

Or via CLI:
  swift-openapi-generator --access-modifier internal
```

----------------------------------------

TITLE: Filter OpenAPI Document by Tags for Generation
DESCRIPTION: This configuration filters the OpenAPI document to generate client code only for operations associated with a specific tag, `myTag`. This is useful for generating a subset of a large API.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Articles/Configuring-the-generator.md#_snippet_8

LANGUAGE: yaml
CODE:
```
generate:
  - types
  - client
namingStrategy: idiomatic

filter:
  tags:
    - myTag
```

----------------------------------------

TITLE: Swift: AsyncSequence Extension for Decoding Server-Sent Events
DESCRIPTION: An extension on `AsyncSequence` where elements are `ArraySlice<UInt8>`, providing a method to decode each event's data into a specified type using a decoder. This is useful when the `data` field of a Server-Sent Event is not JSON or requires custom parsing.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0010.md#_snippet_12

LANGUAGE: Swift
CODE:
```
extension AsyncSequence where Self.Element == ArraySlice<UInt8> {

    /// Returns another sequence that decodes each event's data as the provided type using the provided decoder.
    ///
    /// Use this method if the event's `data` field is not JSON, or if you don't want to parse it using `asDecodedServerSentEventsWithJSONData`.
}
```

----------------------------------------

TITLE: Resulting OpenAPI Document After Operation Filtering
DESCRIPTION: This is the OpenAPI document after applying the filter to include only the 'deleteA' operation. It shows the relevant path, method, operation ID, and response components retained by the filter.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0008.md#_snippet_15

LANGUAGE: APIDOC
CODE:
```
# filtered OpenAPI document
openapi: 3.1.0
info:
  title: ExampleService
  version: 1.0.0
tags:
- name: t
paths:
  /things/a:
    delete:
      operationId: deleteA
      responses:
        200:
          $ref: '#/components/responses/Empty'
components:
  responses:
    Empty:
      description: success
```

----------------------------------------

TITLE: Create HTTPBody from an AsyncSequence
DESCRIPTION: Demonstrates initializing an `HTTPBody` from an `AsyncSequence`, specifying length and iteration behavior. Useful for streaming data.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0004.md#_snippet_17

LANGUAGE: swift
CODE:
```
let producingSequence = ... // an AsyncSequence
let length: HTTPBody.Length = .known(1024) // or .unknown
let body = HTTPBody(
    producingSequence,
    length: length,
    iterationBehavior: .single // or .multiple
)
```

----------------------------------------

TITLE: Consume HTTPBody as AsyncSequence
DESCRIPTION: Illustrates how to process an `HTTPBody` in a streaming fashion by mapping and iterating over its byte chunks.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0004.md#_snippet_19

LANGUAGE: swift
CODE:
```
let chunkSizes = body.map { chunk in chunk.count }
for try await chunkSize in chunkSizes {
    print("Chunk size: \(chunkSize)")
}
```

----------------------------------------

TITLE: Calling Server with cURL for Event Stream
DESCRIPTION: Demonstrates how to interact with the running server using `curl` to fetch event stream data. The command sends a request to the `/api/greetings` endpoint with `name` and `count` parameters, illustrating the JSON Lines output received from the server.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/event-streams-server-example/README.md#_snippet_0

LANGUAGE: console
CODE:
```
% curl -N http://127.0.0.1:8080/api/greetings\?name\=CLI\&count\=3
{"message":"Hey, CLI!"}
{"message":"Hello, CLI!"}
{"message":"Greetings, CLI!"}
```

----------------------------------------

TITLE: Rule: Standalone Schema Optionality
DESCRIPTION: Summarizes the rule for determining if a standalone schema is optional: it is optional if the schema itself is marked as nullable (either via `nullable: true` in Draft 5 or `type: [..., null]` in 2020-12). This nullability propagates through references.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Development/Handling-nullable-schemas.md#_snippet_1

LANGUAGE: APIDOC
CODE:
```
`schema is optional := schema is nullable`

`nullable` is represented differently between JSON Schema Draft 5 (OpenAPI 3.0.3) and JSON Schema 2020-12 (OpenAPI 3.1.0).
```

----------------------------------------

TITLE: Running Swift OpenAPI Generator Client from CLI
DESCRIPTION: This snippet illustrates the command-line execution of a client application generated by Swift OpenAPI Generator. It uses `swift run` to invoke the `GreetingServiceClient` package, demonstrating a typical command-line interaction and its expected output.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Tutorials/_Resources/client.console.4.0.txt#_snippet_0

LANGUAGE: Shell
CODE:
```
% swift run --package-path GreetingServiceClient
Hello, CLI!
```

----------------------------------------

TITLE: List All Tags in GitHub OpenAPI Document
DESCRIPTION: This command-line snippet shows how to extract and list all the tags defined within the GitHub OpenAPI document using 'yq', demonstrating the categorization of operations within the API.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0008.md#_snippet_1

LANGUAGE: console
CODE:
```
% cat api.github.com.yaml | yq '[.tags[].name] | join(", ")'
actions, activity, apps, billing, checks, code-scanning, codes-of-conduct,
emojis, dependabot, dependency-graph, gists, git, gitignore, issues, licenses,
markdown, merge-queue, meta, migrations, oidc, orgs, packages, projects, pulls,
rate-limit, reactions, repos, search, secret-scanning, teams, users,
codespaces, copilot, security-advisories, interactions, classroom
```

----------------------------------------

TITLE: Constructing Buffered Multipart Body with Specific Parts in Swift
DESCRIPTION: Illustrates how to create a buffered `OpenAPIRuntime.MultipartBody` by providing an array of part values. This example includes 'metadata' and 'contents' parts, showing how to embed headers and file data.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0009.md#_snippet_6

LANGUAGE: swift
CODE:
```
let multipartBody: OpenAPIRuntime.MultipartBody<Operations.uploadPhoto.Input.Body.multipartFormPayload> = [
    .metadata(.init(
        payload: .init(
            headers: .init(x_dash_sender_dash_id: "zoom123"),
            body: .init(objectCatName: "Waffles", photographerId: 24)
        )
    )),
    .contents(.init(
        payload: .init(
            body: .init(try Data(contentsOf: URL(fileURLWithPath: "/tmp/waffles-summer-2023.jpg")))
        ),
        filename: "cat.jpg"
    ))
]
let response = try await client.uploadPhoto(body: multipartBody)
// ...
```

----------------------------------------

TITLE: Swift OpenAPI Generator Configuration for Idiomatic Naming
DESCRIPTION: To activate the idiomatic naming strategy, add the `namingStrategy: idiomatic` entry to your `openapi-generator-config.yaml` file.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0013.md#_snippet_2

LANGUAGE: YAML
CODE:
```
namingStrategy: idiomatic
```

----------------------------------------

TITLE: Inspect Filtered OpenAPI Document using CLI
DESCRIPTION: This console command uses the `swift-openapi-generator filter` command to inspect the OpenAPI document after applying the specified filtering configuration. It requires paths to the config and OpenAPI files.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Articles/Configuring-the-generator.md#_snippet_9

LANGUAGE: console
CODE:
```
% swift-openapi-generator filter --config path/to/openapi-generator-config.yaml path/to/openapi.yaml
```

----------------------------------------

TITLE: Swift OpenAPI Generator Converter Coders and Formats
DESCRIPTION: Details the encoder and decoder implementations used by the `Converter` type, leveraging `Codable` conformance. It lists JSON, URI, and Plain text coders, their corresponding `Foundation` or `OpenAPIRuntime` implementations, and where they are supported (bodies, headers, path, query).
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Development/Converting-between-data-and-Swift-types.md#_snippet_1

LANGUAGE: APIDOC
CODE:
```
Coders and Formats:
  - Format: JSON
    Encoder: Foundation.JSONEncoder
    Decoder: Foundation.JSONDecoder
    Supported in: Bodies, headers
  - Format: URI
    Encoder: OpenAPIRuntime.URIEncoder
    Decoder: OpenAPIRuntime.URIDecoder
    Supported in: Path, query, headers
    Note: Configurable implementation of URI Template (RFC 6570), application/x-www-form-urlencoded (RFC 1866), and OpenAPI 3.0.3.
  - Format: Plain text
    Encoder: OpenAPIRuntime.StringEncoder
    Decoder: OpenAPIRuntime.StringDecoder
    Supported in: Bodies
  Note: Incompatible Codable types and locations may cause runtime errors (e.g., StringEncoder encoding an array).
```

----------------------------------------

TITLE: Make sample API requests to greet endpoint
DESCRIPTION: Uses `xargs` and `curl` to send multiple GET requests to the `/api/greet` endpoint, demonstrating the server's functionality and generating metric data.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/metrics-middleware-example/README.md#_snippet_1

LANGUAGE: console
CODE:
```
xargs -n1 -I% curl "localhost:8080/api/greet?name=%" <<< "Juan Mei Tom Bill Anne Ravi Maria"
{
  "message" : "Hello, Juan!"
}
{
  "message" : "Hello, Mei!"
}
{
  "message" : "Hello, Tom!"
}
{
  "message" : "Hello, Bill!"
}
{
  "message" : "Hello, Anne!"
}
{
  "message" : "Hello, Ravi!"
}
{
  "message" : "Hello, Maria!"
}
```

----------------------------------------

TITLE: Customize Access Modifier for Generated Code
DESCRIPTION: This configuration sets the access modifier of the generated code to `public`, making it accessible from other Swift packages. It also includes `APITypes` as an additional import.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Articles/Configuring-the-generator.md#_snippet_6

LANGUAGE: yaml
CODE:
```
generate:
  - client
namingStrategy: idiomatic
additionalImports:
  - APITypes
accessModifier: public
```

----------------------------------------

TITLE: Swift OpenAPI Client Greeting Service Output Structure
DESCRIPTION: This Swift code snippet represents a successful output or a test assertion from the GreetingServiceClient, demonstrating the expected structure of the 'GetGreeting' operation's response, including headers and a JSON body containing a 'Greeting' schema with a 'message' field.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Tutorials/_Resources/client.console.3.0.txt#_snippet_1

LANGUAGE: swift
CODE:
```
ok(GreetingServiceClient.Operations.GetGreeting.Output.Ok(
headers: GreetingServiceClient.Operations.GetGreeting.Output.Ok.Headers(),
body: GreetingServiceClient.Operations.GetGreeting.Output.Ok.Body.json(
GreetingServiceClient.Components.Schemas.Greeting(message: "Hello, CLI"))))
```

----------------------------------------

TITLE: Generate Client Code with External Type Dependencies
DESCRIPTION: This configuration generates client code that depends on types defined in another module, specified by `additionalImports`. `APITypes` is an example of such a module.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Articles/Configuring-the-generator.md#_snippet_5

LANGUAGE: yaml
CODE:
```
generate:
  - client
namingStrategy: idiomatic
additionalImports:
  - APITypes
```

----------------------------------------

TITLE: Swift AsyncSequence extensions for decoding/encoding event streams
DESCRIPTION: This API documentation details the Swift `AsyncSequence` extensions provided by Swift OpenAPI Generator's runtime library for decoding and encoding various event stream formats, including JSON Lines, JSON Sequence, and Server-sent Events, allowing for efficient stream processing.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Articles/Useful-OpenAPI-patterns.md#_snippet_6

LANGUAGE: APIDOC
CODE:
```
JSON Lines:
  decode: AsyncSequence<ArraySlice<UInt8>>.asDecodedJSONLines(of:decoder:)
  encode: AsyncSequence<some Encodable>.asEncodedJSONLines(encoder:)
JSON Sequence:
  decode: AsyncSequence<ArraySlice<UInt8>>.asDecodedJSONSequence(of:decoder:)
  encode: AsyncSequence<some Encodable>.asEncodedJSONSequence(encoder:)
Server-sent Events:
  decode (if data is JSON): AsyncSequence<ArraySlice<UInt8>>.asDecodedServerSentEventsWithJSONData(of:decoder:)
  decode (if data is JSON with a non-JSON terminating byte sequence): AsyncSequence<ArraySlice<UInt8>>.asDecodedServerSentEventsWithJSONData(of:decoder:while:)
  encode (if data is JSON): AsyncSequence<some Encodable>.asEncodedServerSentEventsWithJSONData(encoder:)
  decode (for other data): AsyncSequence<ArraySlice<UInt8>>.asDecodedServerSentEvents(while:)
  encode (for other data): AsyncSequence<some Encodable>.asEncodedServerSentEvents()
```

----------------------------------------

TITLE: Filter OpenAPI Document by Paths
DESCRIPTION: Demonstrates how to configure the `openapi-generator-config.yaml` to include only specific paths (`/things/b`) from the OpenAPI document. The filtered output shows only the specified path and its transitive dependencies, illustrating the path-based filtering capability.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0008.md#_snippet_8

LANGUAGE: yaml
CODE:
```
# openapi-generator-config.yaml
filter:
  paths:
  - /things/b
```

LANGUAGE: yaml
CODE:
```
# filtered OpenAPI document
openapi: 3.1.0
info:
  title: ExampleService
  version: 1.0.0
tags:
- name: t
paths:
  /things/b:
    get:
      operationId: getB
      responses:
        200:
          $ref: '#/components/responses/B'
components:
  schemas:
    A:
      type: string
    B:
      $ref: '#/components/schemas/A'
  responses:
    B:
      description: success
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/B'
```

----------------------------------------

TITLE: Boxed Swift Struct for Recursive Type with Copy-on-Write
DESCRIPTION: Demonstrates the transformed Swift struct `Person` after the generator applies boxing. It utilizes an internal `Storage` class and a `CopyOnWriteBox` to manage the recursive property, allowing the struct to maintain value semantics while supporting arbitrary nesting.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Development/Supporting-recursive-types.md#_snippet_4

LANGUAGE: swift
CODE:
```
public struct Person {
    public var partner: Person? {
        get { storage.value.partner }
        _modify { yield &storage.value.partner }
    }
    public init(partner: Person? = nil) {
        self.storage = .init(Storage(partner: partner))
    }
    private var storage: CopyOnWriteBox<Storage>
    private final class Storage {
        var partner: Person?
        public init(partner: Person? = nil) {
            self.partner = partner
        }
    }
}
```

----------------------------------------

TITLE: Regenerate Swift OpenAPI code using package plugin
DESCRIPTION: Demonstrates how to manually rerun the OpenAPI code generation using the Swift package plugin command when the `openapi.yaml` document changes. It shows the interactive prompt for write permission and the success message upon completion.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/manual-generation-package-plugin-example/README.md#_snippet_0

LANGUAGE: Console
CODE:
```
% swift package generate-code-from-openapi
Plugin ‘OpenAPIGeneratorCommand’ wants permission to write to the package directory.
Stated reason: “To write the generated Swift files back into the source directory of the package.”.
Allow this plugin to write to the package directory? (yes/no) yes
...
✅ OpenAPI code generation for target 'CommandPluginInvocationClient' successfully completed.
```

----------------------------------------

TITLE: Generate Server Code with Swift OpenAPI Generator
DESCRIPTION: This YAML configuration generates server code and types for a Swift OpenAPI project. The `namingStrategy` is set to `idiomatic` for Swift-style naming conventions.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Articles/Configuring-the-generator.md#_snippet_3

LANGUAGE: yaml
CODE:
```
generate:
  - types
  - server
namingStrategy: idiomatic
```

----------------------------------------

TITLE: Generate Shared Types for Client and Server
DESCRIPTION: This configuration is used when generating both client and server code, allowing types to be generated into a shared target. The `namingStrategy` is `idiomatic`.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Articles/Configuring-the-generator.md#_snippet_4

LANGUAGE: yaml
CODE:
```
generate:
  - types
namingStrategy: idiomatic
```

----------------------------------------

TITLE: HTTP POST Request with JSON Payload
DESCRIPTION: Demonstrates a standard HTTP POST request to a server with a JSON payload. The request includes a 'Content-Type' header for 'application/json' and a custom 'x-sender-id' header. The server responds with a '204 No Content' status, indicating successful processing without a response body.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0009.md#_snippet_0

LANGUAGE: HTTP
CODE:
```
> POST /cat-photo-metadata HTTP/1.1
> content-type: application/json
> x-sender-id: zoom123
>
> {"objectCatName":"Waffles","photographerId":24}
---
< HTTP/1.1 204 No Content
```

----------------------------------------

TITLE: Stop Local Postgres Database with Docker Compose
DESCRIPTION: Command to stop the local Postgres database container after testing, releasing resources.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/postgres-database-example/README.md#_snippet_3

LANGUAGE: console
CODE:
```
% docker compose stop
...
[+] Running 1/1
 ⠿ Container postgresdatabaseserver-postgres-1  Stopped            0.6s
```

----------------------------------------

TITLE: Run Swift OpenAPI Server
DESCRIPTION: Builds and runs the `hello-world-server` application. The server will start listening on `127.0.0.1:8080`.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/shared-types-client-server-example/README.md#_snippet_0

LANGUAGE: console
CODE:
```
% swift run hello-world-server
Build complete!
...
info HummingBird : [HummingbirdCore] Server started and listening on 127.0.0.1:8080
```

----------------------------------------

TITLE: Streaming Multipart Body for Client Request in Swift
DESCRIPTION: Shows how to construct an `OpenAPIRuntime.MultipartBody` from a streaming source using `AsyncStream.makeStream`. This approach is suitable for large or dynamically generated multipart data, allowing parts and their bodies to be produced asynchronously.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0009.md#_snippet_7

LANGUAGE: swift
CODE:
```
let (stream, continuation) = AsyncStream.makeStream(of: Operations.uploadPhoto.Input.Body.multipartFormPayload.self)
// Pass `continuation` to another task to start producing parts by calling `continuation.yield(...)` and at the end, `continuation.finish()`.
let response = try await client.uploadPhoto(body: .init(stream))
// ...
```

----------------------------------------

TITLE: Analyze Filtered GitHub OpenAPI Document Size and Code Generation Performance
DESCRIPTION: This snippet demonstrates the significant reduction in size of the GitHub OpenAPI document when filtered to include only 'issues'-related operations and their dependencies. It then shows the dramatic improvement in generation time and reduction in generated code lines when running 'swift-openapi-generator' on this smaller, filtered document.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0008.md#_snippet_2

LANGUAGE: console
CODE:
```
% cat issues.api.github.com.yaml | wc -l
25314

% cat issues.api.github.com.yaml | yq '.paths.* | keys' | wc -l
40

% cat issues.api.github.com.yaml | yq '.components.* | keys' | wc -l
90

% time ./swift-openapi-generator.filter.release \
  generate \
  --mode types \
  --config openapi-generator-config.yaml \
  issues.api.github.com.yaml
Writing data to file Types.swift...

real    0m1.638s
user    0m1.595s
sys     0m0.031s

% cat Types.swift | wc -l
14691
```

----------------------------------------

TITLE: Shell: Create Greeting Service Client Directory
DESCRIPTION: This command creates a new directory named 'GreetingServiceClient'. This directory is typically used to organize the client-side code for a service, serving as the initial step in setting up a new project or module.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Tutorials/_Resources/client.console.2.0.txt#_snippet_0

LANGUAGE: Shell
CODE:
```
% mkdir GreetingServiceClient
```

----------------------------------------

TITLE: Create GreetingService Directory for Swift OpenAPI Generator
DESCRIPTION: This shell command creates a new directory named 'GreetingService' in the current working directory. This is a common initial step when setting up a new service project, such as one for the Swift OpenAPI Generator.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Tutorials/_Resources/server.console.1.0.txt#_snippet_0

LANGUAGE: Shell
CODE:
```
% mkdir GreetingService
```

----------------------------------------

TITLE: Initializing Multipart Body for Client Request in Swift
DESCRIPTION: Demonstrates how to initialize an `OpenAPIRuntime.MultipartBody` for sending a multipart request or response. It shows the basic type expectation for the `multipartBody` variable.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0009.md#_snippet_5

LANGUAGE: swift
CODE:
```
let multipartBody: OpenAPIRuntime.MultipartBody<Operations.uploadPhoto.Input.Body.multipartFormPayload> = ...
let response = try await client.uploadPhoto(body: multipartBody)
// ...
```

----------------------------------------

TITLE: OpenAPI Generator Config to Include Schema 'B'
DESCRIPTION: This YAML configuration snippet specifies a filter to include only the schema named 'B' from an OpenAPI document. This demonstrates how to selectively retain specific schema definitions.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0008.md#_snippet_12

LANGUAGE: YAML
CODE:
```
# openapi-generator-config.yaml
filter:
  schemas:
  - B
```

----------------------------------------

TITLE: Defining Object Properties with Implicit Optionality
DESCRIPTION: Demonstrates an object schema where a property (`age`) is implicitly optional because it is omitted from the `required` array. The `name` property is explicitly required. This is valid for both JSON Schema and OpenAPI versions.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Development/Handling-nullable-schemas.md#_snippet_2

LANGUAGE: yaml
CODE:
```
MyPerson:
  type: object
  properties:
    name:
      type: string
    age:
      type: integer
  required:
    - name
```

----------------------------------------

TITLE: OpenAPI Schema for Recursive Person Type
DESCRIPTION: Defines an OpenAPI schema for a `Person` object where the `partner` property is a reference to another `Person` object, illustrating another form of recursion handled by the generator.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Development/Supporting-recursive-types.md#_snippet_1

LANGUAGE: yaml
CODE:
```
Person:
  type: object
  properties:
    name:
      type: string
    partner:
      $ref: '#/components/schemas/Person'
  required:
    - name
```

----------------------------------------

TITLE: Initialize HTTPBody by Collecting Bytes
DESCRIPTION: Initializes an `HTTPBody` instance by collecting a specified number of bytes from an existing `HTTPBody` stream, throwing an error if the maximum byte limit is exceeded.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0004.md#_snippet_28

LANGUAGE: APIDOC
CODE:
```
public init(collecting body: HTTPBody, upTo maxBytes: Int) async throws
  - Parameters:
    - maxBytes: The maximum number of bytes this method is allowed to accumulate in memory before it throws an error.
  - Throws: `TooManyBytesError` if the body contains more than `maxBytes`.
```

----------------------------------------

TITLE: Configure Standalone OpenAPI Document Filtering
DESCRIPTION: This configuration is used with the `filter` command as a standalone tool. It specifies an empty `generate` array and defines the filtering criteria, such as tags, to be applied to the OpenAPI document.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Articles/Configuring-the-generator.md#_snippet_10

LANGUAGE: yaml
CODE:
```
generate: []
filter:
  tags:
    - myTag
```

----------------------------------------

TITLE: Produce JSONL Event Stream in Swift
DESCRIPTION: This example illustrates how to produce an event stream of JSON Lines (JSONL) from an asynchronous sequence. It uses `AsyncStream.makeStream()` to create a stream and a continuation, which can be used by another task to yield events. The stream is then encoded into an `HTTPBody` using `asEncodedJSONLines()` for use in an HTTP response.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0010.md#_snippet_2

LANGUAGE: swift
CODE:
```
let (stream, continuation) = AsyncStream<Components.Schemas.Greeting>.makeStream()
// Pass the continuation to another task that calls
// `continuation.yield(...)` with events, and `continuation.finish()`
// at the end.

let httpBody = HTTPBody(
    stream.asEncodedJSONLines(),
    length: .unknown,
    iterationBehavior: .single
)
// Provide `httpBody` to the response, for example.
return .ok(.init(body: .application_jsonl(httpBody)))
```

----------------------------------------

TITLE: Run Docker Compose for Tracing Collector and Visualization
DESCRIPTION: This command starts the necessary Docker containers for collecting and visualizing traces, including Jaeger, Zipkin, and an OTel collector, using the provided `docker-compose.yaml`.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/tracing-middleware-example/README.md#_snippet_0

LANGUAGE: console
CODE:
```
docker compose -f docker/docker-compose.yaml up
```

----------------------------------------

TITLE: Organizing OpenAPI Specification File
DESCRIPTION: These commands create a `Public` directory, move the `openapi.yaml` file into it, and then create a symbolic link from `Sources/openapi.yaml` to the new location in `Public` to maintain compatibility with the project structure while centralizing the specification.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Tutorials/_Resources/server-openapi-endpoints.console.1.txt#_snippet_0

LANGUAGE: shell
CODE:
```
% mkdir Public

% mv Sources/openapi.yaml Public/

% ln -s ../Public/openapi.yaml Sources/openapi.yaml
```

----------------------------------------

TITLE: Fetch Example JSON from Server
DESCRIPTION: Demonstrates how to make a curl request to the running server to fetch example JSON data from the /api/exampleJSON endpoint.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/various-content-types-server-example/README.md#_snippet_0

LANGUAGE: console
CODE:
```
% curl http://localhost:8080/api/exampleJSON
{
  "message" : "Hello, Stranger!"
}
```

----------------------------------------

TITLE: Initialize HTTPBody from Async String Streams/Sequences
DESCRIPTION: These initializers construct an `HTTPBody` from asynchronous streams or sequences of string chunks. They are suitable for handling large or dynamically generated string content without loading it all into memory at once.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0004.md#_snippet_25

LANGUAGE: APIDOC
CODE:
```
extension HTTPBody {

    /// Creates a new body with the provided async throwing stream of strings.
    /// - Parameters:
    ///   - stream: An async throwing stream that provides the string chunks.
    ///   - length: The total length of the body.
    @inlinable public convenience init(_ stream: AsyncThrowingStream<some StringProtocol & Sendable, any Error & Sendable>, length: HTTPBody.Length)
}
```

LANGUAGE: APIDOC
CODE:
```
extension HTTPBody {

    /// Creates a new body with the provided async stream of strings.
    /// - Parameters:
    ///   - stream: An async stream that provides the string chunks.
    ///   - length: The total length of the body.
    @inlinable public convenience init(_ stream: AsyncStream<some StringProtocol & Sendable>, length: HTTPBody.Length)
}
```

LANGUAGE: APIDOC
CODE:
```
extension HTTPBody {

    /// Creates a new body with the provided async sequence of string chunks.
    /// - Parameters:
    ///   - sequence: An async sequence that provides the string chunks.
    ///   - length: The total lenght of the body.
    ///   - iterationBehavior: The iteration behavior of the sequence, which
    ///     indicates whether it can be iterated multiple times.
    @inlinable public convenience init<Strings>(_ sequence: Strings, length: HTTPBody.Length, iterationBehavior: IterationBehavior) where Strings : Sendable, Strings : AsyncSequence, Strings.Element : Sendable, Strings.Element : StringProtocol
}
```

----------------------------------------

TITLE: Swift Generated Code for Unsafe Server Variable Identifiers
DESCRIPTION: This Swift snippet illustrates how the generator handles server variable names or enum values that are not valid Swift identifiers. It demonstrates the conversion of names like '443' to '_443' and 'Protocol' to '_Protocol' to ensure valid Swift code generation.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0012.md#_snippet_8

LANGUAGE: swift
CODE:
```
enum Servers {
  enum Server1 {
    enum _Protocol: String {
      case https
      case https
    }
    enum Port: String {
      case _443 = "443"
      case _8443 = "8443"
    }
    static func url(/* ... */) throws -> Foundation.URL { /* omitted for brevity */ }
  }
}
```

----------------------------------------

TITLE: Swift APIProtocol Extension for Simplified Input
DESCRIPTION: Provides a convenience extension to APIProtocol that offers an overloaded getGreeting function. This overload directly accepts query and header parameters, simplifying the creation of the Operations.getGreeting.Input object for callers.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0007.md#_snippet_6

LANGUAGE: APIDOC
CODE:
```
extension APIProtocol {
    // The parameters to each overload will match those of the corresponding
    // operation input initializer, including optionality.
    public func getGreeting(
        query: Operations.getGreeting.Input.Query = .init(),
        headers: Operations.getGreeting.Input.Headers = .init()
    ) {
        // Simply wraps the call to the protocol function in an input value.
        getGreeting(Operations.getGreeting.Input(
            query: query,
            headers: headers
        ))
    }
}
```

----------------------------------------

TITLE: Swift API: Encode Raw Server-Sent Events from AsyncSequence
DESCRIPTION: This extension method on `AsyncSequence` allows encoding a sequence of `ServerSentEvent` objects into a serialized Server-Sent Events stream. It's used when the data field of the events is not JSON.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0010.md#_snippet_17

LANGUAGE: APIDOC
CODE:
```
public func asEncodedServerSentEvents() -> ServerSentEventsSerializationSequence<Self> where Self : Sendable, Self.Element == ServerSentEvent
  - Returns: A sequence that provides the serialized Server-sent Events.
```

----------------------------------------

TITLE: Generated Swift Type Alias After Type Override
DESCRIPTION: This Swift code snippet shows the result of applying a type override. The `Uuid` typealias, which would typically be generated as `Swift.String` for a `uuid` format, is now correctly aliased to `Foundation.UUID`, demonstrating the impact of the `typeOverrides` configuration.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0014.md#_snippet_2

LANGUAGE: Swift
CODE:
```
/// Types generated from the `#/components/schemas` section of the OpenAPI document.
package enum Schemas {
    /// - Remark: Generated from `#/components/schemas/UUID`.
    package typealias Uuid = Foundation.UUID
}
```

----------------------------------------

TITLE: Define Custom Name Overrides for Swift OpenAPI Generator
DESCRIPTION: This YAML configuration snippet demonstrates how to specify custom name overrides in the Swift OpenAPI Generator. It allows users to map specific OpenAPI names, such as '+1' and '-1', to more descriptive and idiomatic Swift identifiers like 'thumbsUp' and 'thumbsDown', addressing cases where automatic naming might be less ideal.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0013.md#_snippet_4

LANGUAGE: YAML
CODE:
```
nameOverrides:
  '+1': 'thumbsUp'
  '-1': 'thumbsDown'
```

----------------------------------------

TITLE: Shell Commands for OpenAPI File Setup and Retrieval
DESCRIPTION: These shell commands illustrate how to create a 'Public' directory, move an 'openapi.yaml' file into it, create a symbolic link back to the original 'Sources' directory, and finally, use 'curl' to fetch the OpenAPI document from a local server.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Tutorials/_Resources/server-openapi-endpoints.console.2.txt#_snippet_0

LANGUAGE: Shell
CODE:
```
% mkdir Public

% mv Sources/openapi.yaml Public/

% ln -s ../Public/openapi.yaml Sources/openapi.yaml

% curl "localhost:8080/openapi.yaml"
```

----------------------------------------

TITLE: Swift OpenAPI Generator: Object Schema with Typed `additionalProperties`
DESCRIPTION: Describes the custom Codable generation when 'additionalProperties' specifies a type (e.g., '{type: integer}'). An extra property of a typed dictionary (e.g., '[String: Int]') is generated. Both custom decoder and encoder are emitted, with the decoder validating values against the specified type.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Development/Generating-custom-Codable-conformance-methods.md#_snippet_3

LANGUAGE: APIDOC
CODE:
```
Generated property: `additionalProperties: [String: <SpecifiedType>]` (e.g., `[String: Int]`)
Custom decoder: yes, similar to `additionalProperties: true`, with the difference that values are validated to be of the specified type.
Custom encoder: yes, same as `additionalProperties: true`.
```

----------------------------------------

TITLE: Swift API: Server-Sent Events Serialization Sequence AsyncSequence Conformance
DESCRIPTION: This extension provides `AsyncSequence` conformance for `ServerSentEventsSerializationSequence`, allowing it to be used in asynchronous contexts. It defines the element type and the iterator for streaming serialized SSE.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0010.md#_snippet_16

LANGUAGE: APIDOC
CODE:
```
extension ServerSentEventsSerializationSequence : AsyncSequence where Upstream.Element == ServerSentEvent {
  public typealias Element = ArraySlice<UInt8>
  public struct Iterator<UpstreamIterator> : AsyncIteratorProtocol where UpstreamIterator : AsyncIteratorProtocol, Upstream.Element == ServerSentEvent, UpstreamIterator.Element == ServerSentEvent {
    public mutating func next() async throws -> ArraySlice<UInt8>?
  }
  public func makeAsyncIterator() -> Iterator<Upstream.AsyncIterator>
}
```

----------------------------------------

TITLE: Swift Enum Boxing with Indirect Keyword
DESCRIPTION: Illustrates how the `indirect` keyword is used to enable recursion for Swift enums. The first snippet shows a non-recursive enum, and the second shows its recursive, boxed equivalent.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Development/Supporting-recursive-types.md#_snippet_2

LANGUAGE: swift
CODE:
```
public enum Directory {}
```

LANGUAGE: swift
CODE:
```
public indirect enum Directory { ... }
```

----------------------------------------

TITLE: Start OSLog Stream for Swift OpenAPI Debug Logs
DESCRIPTION: This command filters and displays debug and info level logs from the 'com.apple.swift-openapi' subsystem in a compact style. It's used to observe the logging output of the Swift OpenAPI client middleware.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/logging-middleware-oslog-example/README.md#_snippet_0

LANGUAGE: console
CODE:
```
% log stream --debug --info --style compact --predicate subsystem == 'com.apple.swift-openapi'
Filtering the log data using "subsystem == \"com.apple.swift-openapi\""
```

----------------------------------------

TITLE: Start Swift server
DESCRIPTION: Command to compile and run the Swift server application.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/metrics-middleware-example/README.md#_snippet_0

LANGUAGE: console
CODE:
```
swift run
```

----------------------------------------

TITLE: Swift API: Decode Raw Server-Sent Events
DESCRIPTION: This method returns a sequence that provides deserialized Server-Sent Events. It's used to consume raw SSE streams.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0010.md#_snippet_13

LANGUAGE: APIDOC
CODE:
```
public func asDecodedServerSentEvents() -> ServerSentEventsDeserializationSequence<ServerSentEventsLineDeserializationSequence<Self>>
  - Returns: A sequence that provides the events.
```

----------------------------------------

TITLE: Swift: AsyncIteratorProtocol Iterator for ArraySlice<UInt8>
DESCRIPTION: Documents an `Iterator` struct conforming to `AsyncIteratorProtocol` for processing `ArraySlice<UInt8>` elements, typically used in asynchronous byte stream processing. It provides a `next()` method to retrieve the next element.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0010.md#_snippet_7

LANGUAGE: Swift
CODE:
```
public struct Iterator<UpstreamIterator> : AsyncIteratorProtocol where UpstreamIterator : AsyncIteratorProtocol, UpstreamIterator.Element == ArraySlice<UInt8> {
    public mutating func next() async throws -> ArraySlice<UInt8>?
}
public func makeAsyncIterator() -> Iterator<Upstream.AsyncIterator>
```

----------------------------------------

TITLE: Build and Run Client CLI
DESCRIPTION: Instructions to build and run the client command-line interface using the Swift package manager from the console.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/event-streams-client-example/README.md#_snippet_0

LANGUAGE: console
CODE:
```
% swift run
```

----------------------------------------

TITLE: Define Multipart Boundary Generator API in Swift
DESCRIPTION: Introduces the `MultipartBoundaryGenerator` protocol and its concrete implementations (`ConstantMultipartBoundaryGenerator`, `RandomMultipartBoundaryGenerator`) for generating boundary strings in multipart messages. It also provides static properties for common generator types to simplify usage.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0009.md#_snippet_17

LANGUAGE: Swift
CODE:
```
/// A generator of a new boundary string used by multipart messages to separate parts.
public protocol MultipartBoundaryGenerator : Sendable {

    /// Generates a boundary string for a multipart message.
    /// - Returns: A boundary string.
    func makeBoundary() -> String
}

extension MultipartBoundaryGenerator where Self == OpenAPIRuntime.ConstantMultipartBoundaryGenerator {

    /// A generator that always returns the same boundary string.
    public static var constant: OpenAPIRuntime.ConstantMultipartBoundaryGenerator { get }
}

extension MultipartBoundaryGenerator where Self == OpenAPIRuntime.RandomMultipartBoundaryGenerator {

    /// A generator that produces a random boundary every time.
    public static var random: OpenAPIRuntime.RandomMultipartBoundaryGenerator { get }
}


/// A generator that always returns the same constant boundary string.
public struct ConstantMultipartBoundaryGenerator : OpenAPIRuntime.MultipartBoundaryGenerator {

    /// The boundary string to return.
    public let boundary: String

    /// Creates a new generator.
    /// - Parameter boundary: The boundary string to return every time.
    public init(boundary: String = "__X_SWIFT_OPENAPI_GENERATOR_BOUNDARY__")

    /// Generates a boundary string for a multipart message.
    /// - Returns: A boundary string.
    public func makeBoundary() -> String
}

/// A generator that returns a boundary containg a constant prefix and a randomized suffix.
public struct RandomMultipartBoundaryGenerator : OpenAPIRuntime.MultipartBoundaryGenerator {

    /// The constant prefix of each boundary.
    public let boundaryPrefix: String

    /// The length, in bytes, of the randomized boundary suffix.
    public let randomNumberSuffixLength: Int

    /// Create a new generator.
    /// - Parameters:
    ///   - boundaryPrefix: The constant prefix of each boundary.
    ///   - randomNumberSuffixLength: The length, in bytes, of the randomized boundary suffix.
    public init(boundaryPrefix: String = "__X_SWIFT_OPENAPI_", randomNumberSuffixLength: Int = 20)

    /// Generates a boundary string for a multipart message.
    /// - Returns: A boundary string.
    public func makeBoundary() -> String
}
```

----------------------------------------

TITLE: Creating HTTPBody from a String in Swift
DESCRIPTION: An example demonstrating how to easily initialize an `HTTPBody` instance directly from a `String` in Swift, useful for simple cases.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0004.md#_snippet_9

LANGUAGE: swift
CODE:
```
let body = HTTPBody("Hello, world!")
```

----------------------------------------

TITLE: Create HTTPBody from Foundation.Data
DESCRIPTION: Illustrates initializing an `HTTPBody` from a `Foundation.Data` object.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0004.md#_snippet_15

LANGUAGE: swift
CODE:
```
let data: Foundation.Data = ...
let body = HTTPBody(data)
```

----------------------------------------

TITLE: Swift OpenAPI Generator Configuration File Location
DESCRIPTION: Illustrates the recommended directory structure for placing the `openapi-generator-config.yaml` file within a Swift package target, alongside `Package.swift` and `openapi.yaml`.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Articles/Configuring-the-generator.md#_snippet_0

LANGUAGE: text
CODE:
```
.\n├── Package.swift\n└── Sources\n    └── MyTarget\n        ├── MyCode.swift\n        ├── openapi-generator-config.yaml <-- place the file here\n        └── openapi.yaml
```

----------------------------------------

TITLE: OpenAPI Generator Config to Include Operation 'deleteA'
DESCRIPTION: This YAML configuration snippet specifies a filter to include only the operation with the ID 'deleteA' from an OpenAPI document. This demonstrates how to selectively retain specific API operations.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0008.md#_snippet_14

LANGUAGE: YAML
CODE:
```
# openapi-generator-config.yaml
filter:
  operations:
  - deleteA
```

----------------------------------------

TITLE: Configure Multipart Boundary Generator in Swift
DESCRIPTION: Details the addition of the `multipartBoundaryGenerator` property to the `Configuration` struct and a new initializer that allows customization of the boundary generator. The existing initializer is marked as deprecated, guiding users towards the new, more flexible configuration method.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0009.md#_snippet_18

LANGUAGE: Swift
CODE:
```
/// A set of configuration values used by the generated client and server types.
/* public struct Configuration : Sendable { */

    /// The generator to use when creating mutlipart bodies.
    public var multipartBoundaryGenerator: OpenAPIRuntime.MultipartBoundaryGenerator

    /// Creates a new configuration with the specified values.
    ///
    /// - Parameters:
    ///   - dateTranscoder: The transcoder to use when converting between date
    ///   and string values.
    ///   - multipartBoundaryGenerator: The generator to use when creating mutlipart bodies.
    public init(dateTranscoder: OpenAPIRuntime.DateTranscoder = .iso8601, multipartBoundaryGenerator: OpenAPIRuntime.MultipartBoundaryGenerator = .random)

    /// Creates a new configuration with the specified values.
    ///
    /// - Parameter dateTranscoder: The transcoder to use when converting between date
    ///   and string values.
    @available(*, deprecated, renamed: "init(dateTranscoder:multipartBoundaryGenerator:)")
    public init(dateTranscoder: OpenAPIRuntime.DateTranscoder)
/* } */
```

----------------------------------------

TITLE: OpenAPI Schema for Recursive FileItem Type
DESCRIPTION: Defines an OpenAPI schema for a `FileItem` object, representing a file system tree. The `contents` property is an array of `FileItem` references, demonstrating a recursive structure that the generator handles.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Development/Supporting-recursive-types.md#_snippet_0

LANGUAGE: yaml
CODE:
```
FileItem:
  type: object
  properties:
    name:
      type: string
    isDirectory:
      type: boolean
    contents:
      type: array
      items:
        $ref: '#/components/schemas/FileItem'
  required:
    - name
```

----------------------------------------

TITLE: Swift OpenAPI Generator: Object Schema with `additionalProperties: false`
DESCRIPTION: Explains the behavior when 'additionalProperties' is set to 'false', indicating that any additional properties are forbidden. A custom decoder is generated to detect and throw an error for unknown properties, while no custom encoder is needed.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Development/Generating-custom-Codable-conformance-methods.md#_snippet_1

LANGUAGE: APIDOC
CODE:
```
Custom decoder: yes, it decodes documented properties and then throws an error if any unknown properties are detected.
Custom encoder: no, since there is no storage to put them, so the user could not have accidentally created such an value of the struct, and there is no need to perform additional validation on encoding.
```

----------------------------------------

TITLE: Run Swift OpenAPI Client Executable
DESCRIPTION: Executes the Swift client application, which will trigger the logging middleware and generate log entries observable via `log stream`.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/logging-middleware-oslog-example/README.md#_snippet_1

LANGUAGE: console
CODE:
```
% swift run
Hello, Stranger!
```

----------------------------------------

TITLE: APIDOC: MultipartBody Class Definition and API
DESCRIPTION: Comprehensive API documentation for the `MultipartBody` class, including its properties, initializers, protocol conformances, and nested types. It details how to create and iterate over multipart bodies.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0009.md#_snippet_26

LANGUAGE: APIDOC
CODE:
```
final public class MultipartBody<Part> : @unchecked Sendable where Part : Sendable
  - Description: Represents an ordered array of values, and those cannot be reordered without changing the message's meaning. Important: Parts that contain a raw streaming body (of type HTTPBody) must have their bodies fully consumed before the multipart body sequence is asked for the next part. The multipart body sequence does not buffer internally, and since the parts and their bodies arrive in a single stream of bytes, you cannot move on to the next part until the current one is consumed.
  - Properties:
    - iterationBehavior: OpenAPIRuntime.IterationBehavior
      - Description: The iteration behavior, which controls how many times the input sequence can be iterated.

extension MultipartBody : Equatable
  - Methods:
    - static func == (lhs: OpenAPIRuntime.MultipartBody<Part>, rhs: OpenAPIRuntime.MultipartBody<Part>) -> Bool

extension MultipartBody : Hashable
  - Methods:
    - func hash(into hasher: inout Hasher)
      - Parameters:
        - hasher: inout Hasher

extension MultipartBody
  - Initializers:
    - convenience init<Input>(_ sequence: Input, iterationBehavior: OpenAPIRuntime.IterationBehavior) where Part == Input.Element, Input : AsyncSequence
      - Description: Creates a new sequence with the provided async sequence of parts.
      - Parameters:
        - sequence: An async sequence that provides the parts.
        - iterationBehavior: The iteration behavior of the sequence, which indicates whether it can be iterated multiple times.
    - convenience init(_ elements: some Collection<Part> & Sendable)
      - Description: Creates a new sequence with the provided collection of parts.
      - Parameters:
        - elements: A collection of parts.
    - convenience init(_ stream: AsyncThrowingStream<OpenAPIRuntime.MultipartBody<Part>.Element, Error>)
      - Description: Creates a new sequence with the provided async throwing stream.
      - Parameters:
        - stream: An async throwing stream that provides the parts.
    - convenience init(_ stream: AsyncStream<OpenAPIRuntime.MultipartBody<Part>.Element>)
      - Description: Creates a new sequence with the provided async stream.
      - Parameters:
        - stream: An async stream that provides the parts.

extension MultipartBody : ExpressibleByArrayLiteral
  - Type Aliases:
    - ArrayLiteralElement: OpenAPIRuntime.MultipartBody<Part>.Element
  - Initializers:
    - convenience init(arrayLiteral elements: OpenAPIRuntime.MultipartBody<Part>.Element...)

extension MultipartBody : AsyncSequence
  - Type Aliases:
    - Element: Part
    - AsyncIterator: OpenAPIRuntime.MultipartBody<Part>.Iterator
  - Methods:
    - func makeAsyncIterator() -> OpenAPIRuntime.MultipartBody<Part>.AsyncIterator

extension MultipartBody
  - Nested Types:
    - struct Iterator : AsyncIteratorProtocol
      - Methods:
        - mutating func next() async throws -> OpenAPIRuntime.MultipartBody<Part>.Element?
```

----------------------------------------

TITLE: OpenAPI Tag Object Properties
DESCRIPTION: Outlines the properties of the OpenAPI Tag Object and their support status.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Articles/Supported-OpenAPI-features.md#_snippet_3

LANGUAGE: APIDOC
CODE:
```
Tag Object:
  name: [ ]
  description: [ ]
  externalDocs: [ ]
```

----------------------------------------

TITLE: Example of Generated AcceptableContentType Enum in Swift
DESCRIPTION: Illustrates a concrete example of the `AcceptableContentType` enum generated by the Swift OpenAPI Generator for a specific operation (`getStats`). This enum demonstrates its conformance to `AcceptableProtocol` and handles content types like JSON and plain text, including an 'other' case for unknown types.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0003.md#_snippet_8

LANGUAGE: swift
CODE:
```
@frozen public enum AcceptableContentType: AcceptableProtocol {
    case json
    case plainText
    case other(String)
    public init?(rawValue: String) {
        switch rawValue.lowercased() {
        case "application/json": self = .json
        case "text/plain": self = .plainText
        default: self = .other(rawValue)
        }
    }
    public var rawValue: String {
        switch self {
        case let .other(string): return string
        case .json: return "application/json"
        case .plainText: return "text/plain"
        }
    }
    public static var allCases: [Self] { [.json, .plainText] }
}
```

----------------------------------------

TITLE: Build and Run Swift OpenAPI Hummingbird Server
DESCRIPTION: Command to compile and start the Hummingbird server application. The output shows the server successfully starting and listening on the specified local address and port.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/hello-world-hummingbird-server-example/README.md#_snippet_1

LANGUAGE: console
CODE:
```
% swift run
2023-12-01T14:14:35+0100 info HummingBird : [HummingbirdCore] Server started and listening on 127.0.0.1:8080
...
```

----------------------------------------

TITLE: Run Swift Project Tests
DESCRIPTION: This command executes the unit tests for the project. The testing strategy involves using a mock `APIProtocol` implementation, allowing tests to simulate various conditions without making live network requests.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/curated-client-library-example/README.md#_snippet_1

LANGUAGE: console
CODE:
```
% swift test
```

----------------------------------------

TITLE: Run Swift Server CLI
DESCRIPTION: Builds and runs the server CLI application. The output shows the server starting and listening on the specified address and port.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/bidirectional-event-streams-server-example/README.md#_snippet_0

LANGUAGE: console
CODE:
```
% swift run
2024-07-04T08:56:23+0200 info Hummingbird : [HummingbirdCore] Server started and listening on 127.0.0.1:8080
...
```

----------------------------------------

TITLE: Run Swift Server Locally
DESCRIPTION: This command compiles and runs the Swift server application locally, making it ready to receive requests.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/tracing-middleware-example/README.md#_snippet_1

LANGUAGE: console
CODE:
```
swift run
```

----------------------------------------

TITLE: Create HTTPBody from a byte chunk
DESCRIPTION: Shows how to create an `HTTPBody` from an `ArraySlice<UInt8>`.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0004.md#_snippet_14

LANGUAGE: swift
CODE:
```
let bytes: ArraySlice<UInt8> = ...
let body = HTTPBody(bytes)
```

----------------------------------------

TITLE: Swift: Create MultipartBody from Buffered Parts
DESCRIPTION: This snippet demonstrates how to create a `MultipartBody` instance from an array of `Part` values. This approach is suitable when all multipart parts are available and can be buffered in memory before processing or sending. The `Part` generic type is typically a generated enum representing the different documented values for the multipart body.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0009.md#_snippet_22

LANGUAGE: Swift
CODE:
```
let body: MultipartBody<MyPartType> = [
    .myCaseA(...),
    .myCaseB(...),
]
```

----------------------------------------

TITLE: OpenAPI OAuth Flows Object Properties
DESCRIPTION: Describes the properties of the OpenAPI OAuth Flows Object and their support.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Articles/Supported-OpenAPI-features.md#_snippet_5

LANGUAGE: APIDOC
CODE:
```
OAuth Flows Object:
  implicit: [ ]
  password: [ ]
  clientCredentials: [ ]
  authorizationCode: [ ]
```

----------------------------------------

TITLE: Swift OpenAPI Generator Converter Helper Method Dimensions
DESCRIPTION: Explains the various "dimensions" that differentiate the `Converter`'s helper methods, including client/server context, set/get operations, schema location (path, query, headers, body), coding strategy (JSON, URI, urlEncodedForm, multipart, binary), and optional/required value handling.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Development/Converting-between-data-and-Swift-types.md#_snippet_2

LANGUAGE: APIDOC
CODE:
```
Converter Helper Method Dimensions:
  - Client/server:
    Description: Indicates if code is for client, server, or both ("common").
  - Set/get:
    Description: Indicates if generated code sets or gets a value.
  - Schema location:
    Description: Where schemas are used in OpenAPI documents.
    Values: request path parameters, request query items, request header fields, request body, response header fields, response body
  - Coding strategy:
    Description: Chosen coder to convert between Swift type and data.
    Options:
      - JSON:
        Example content type: application/json, +json suffix
        Example data: {"color": "red", "power": 24}
      - URI:
        Example: query, path, header parameters
        Example data: color=red&power=24
      - urlEncodedForm:
        Example: request body with application/x-www-form-urlencoded
        Example data: greeting=Hello+world
      - multipart:
        Example: request body with multipart/form-data
        Example data: part 1: {"color": "red", "power": 24}, part 2: greeting=Hello+world
      - binary:
        Example: application/octet-stream
        Description: Fallback for content types without specific handling; passes binary data through without transformation.
  - Optional/required:
    Description: Indicates if method works with optional values.
    Values:
      - required: Special overload only for required values.
      - optional: Special overload only for optional values.
      - both: Special overload for optional values without negatively impacting required values (e.g., setters).
```

----------------------------------------

TITLE: OpenAPI to Swift Identifier Mapping Examples
DESCRIPTION: Illustrates the proposed identifier mapping strategy, showing how various OpenAPI property names are transformed into valid Swift identifiers using a combination of word replacement and hex encoding for unsupported characters. This is an API breaking change for users of the generator.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0001.md#_snippet_0

LANGUAGE: APIDOC
CODE:
```
yaml | swift
-- | --
a b | a_space_b
a*b | a_ast_b
ab_ | ab_
ab* | ab_ast_
/ab | _sol_ab
Hu&J_?kin | Hu_amp_J__quest_kin
$nake… | \_dollar_nake_x2026\
message | message
```

----------------------------------------

TITLE: Initialize HTTPBody from Byte Arrays or Data
DESCRIPTION: These initializers create an `HTTPBody` instance directly from raw byte arrays (`[UInt8]`) or `Data` objects. They also support initialization via `ExpressibleByArrayLiteral` for convenience.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0004.md#_snippet_26

LANGUAGE: APIDOC
CODE:
```
extension HTTPBody {

    /// Creates a new body from the provided array of bytes.
    /// - Parameter bytes: An array of bytes.
    @inlinable public convenience init(_ bytes: [UInt8])
}
```

LANGUAGE: APIDOC
CODE:
```
extension HTTPBody : ExpressibleByArrayLiteral {

    /// The type of the elements of an array literal.
    public typealias ArrayLiteralElement = UInt8

    /// Creates an instance initialized with the given elements.
    public convenience init(arrayLiteral elements: UInt8...)
}
```

LANGUAGE: APIDOC
CODE:
```
extension HTTPBody {

    /// Creates a new body from the provided data chunk.
    /// - Parameter data: A single data chunk.
    public convenience init(data: Data)
}
```

----------------------------------------

TITLE: Swift: ServerSentEventWithJSONData Struct
DESCRIPTION: Represents a Server-Sent Event with a generic JSON payload in its `data` field. It includes properties for event type, data, ID, and retry interval, conforming to the HTML Server-Sent Events specification.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0010.md#_snippet_9

LANGUAGE: Swift
CODE:
```
public struct ServerSentEventWithJSONData<JSONDataType> : Sendable, Hashable where JSONDataType : Hashable, JSONDataType : Sendable {

    /// A type of the event, helps inform how to interpret the data.
    public var event: String?

    /// The payload of the event.
    public var data: JSONDataType?

    /// A unique identifier of the event, can be used to resume an interrupted stream by
    /// making a new request with the `Last-Event-ID` header field set to this value.
    ///
    /// https://html.spec.whatwg.org/multipage/server-sent-events.html#the-last-event-id-header
    public var id: String?

    /// The amount of time, in milliseconds, the client should wait before reconnecting in case
    /// of an interruption.
    ///
    /// https://html.spec.whatwg.org/multipage/server-sent-events.html#the-eventsource-interface
    public var retry: Int64?

    /// Creates a new event.
    /// - Parameters:
    ///   - event: A type of the event, helps inform how to interpret the data.
    ///   - data: The payload of the event.
    ///   - id: A unique identifier of the event.
    ///   - retry: The amount of time, in milliseconds, to wait before retrying.
    public init(event: String? = nil, data: JSONDataType? = nil, id: String? = nil, retry: Int64? = nil)
}
```

----------------------------------------

TITLE: Test Authentication Middleware with Curl
DESCRIPTION: This `curl` command demonstrates how to interact with the authentication server, sending an `Authorization` header to verify a token and receive a personalized greeting from the `/api/greet` endpoint.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/auth-server-middleware-example/README.md#_snippet_0

LANGUAGE: console
CODE:
```
% curl -H 'Authorization: token_for_Frank' 'http://localhost:8080/api/greet?name=Jane'
{
  "message" : "Hello, Jane! (Requested by: Frank)"
}
```

----------------------------------------

TITLE: Swift: ServerSentEvent Struct
DESCRIPTION: Represents a standard Server-Sent Event, as defined by the HTML specification. It contains properties for event ID, type, string data payload, and retry interval.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0010.md#_snippet_10

LANGUAGE: Swift
CODE:
```
public struct ServerSentEvent : Sendable, Hashable {

    /// A unique identifier of the event, can be used to resume an interrupted stream by
    /// making a new request with the `Last-Event-ID` header field set to this value.
    ///
    /// https://html.spec.whatwg.org/multipage/server-sent-events.html#the-last-event-id-header
    public var id: String?

    /// A type of the event, helps inform how to interpret the data.
    public var event: String?

    /// The payload of the event.
    public var data: String?

    /// The amount of time, in milliseconds, the client should wait before reconnecting in case
    /// of an interruption.
    ///
    /// https://html.spec.whatwg.org/multipage/server-sent-events.html#the-eventsource-interface
    public var retry: Int64?

    /// Creates a new event.
    /// - Parameters:
    ///   - id: A unique identifier of the event.
    ///   - event: A type of the event, helps inform how to interpret the data.
    ///   - data: The payload of the event.
    ///   - retry: The amount of time, in milliseconds, to wait before retrying.
    public init(id: String? = nil, event: String? = nil, data: String? = nil, retry: Int64? = nil)
}
```

----------------------------------------

TITLE: OpenAPI Server Variable Object Fields Definition
DESCRIPTION: API documentation detailing the fields available for a Server Variable Object in the OpenAPI Specification. It includes 'enum' for restricted substitution options, 'default' as the required fallback value, and 'description' for optional rich text explanation.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0012.md#_snippet_0

LANGUAGE: APIDOC
CODE:
```
Server Variable Object Fields:
  enum:
    Type: [string]
    Description: An enumeration of string values to be used if the substitution options are from a limited set. The array MUST NOT be empty.
  default:
    Type: string
    Description: REQUIRED. The default value to use for substitution, which SHALL be sent if an alternate value is not supplied. If the enum is defined, the value MUST exist the enum's values.
  description:
    Type: string
    Description: An optional description for the server variable. [CommonMark] syntax MAY be used for rich text representation.
```

----------------------------------------

TITLE: Swift OpenAPI Generator Converter Type Overview
DESCRIPTION: Describes the `Converter` type, its role in converting between binary data and Swift types in the Swift OpenAPI Runtime library, and its implementation through helper methods in `Converter+Client.swift`, `Converter+Server.swift`, and `Converter+Common.swift`. It also notes its SPI status.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Development/Converting-between-data-and-Swift-types.md#_snippet_0

LANGUAGE: APIDOC
CODE:
```
Type: Converter
  Description: Structure defined in the runtime library, used by client and server generated code for conversions between binary data and Swift types.
  Status: SPI type (not public API), but critical for generated code.
  Helper Methods (implemented in extensions):
    - Converter+Client.swift: Client-specific conversion helpers.
    - Converter+Server.swift: Server-specific conversion helpers.
    - Converter+Common.swift: Reusable helpers for both client and server.
```

----------------------------------------

TITLE: Example OSLog Output from Swift OpenAPI Client
DESCRIPTION: This snippet shows the expected debug log output captured by `log stream`, demonstrating the request and response logging performed by the ClientMiddleware for a GET request to `/greet`.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Examples/logging-middleware-oslog-example/README.md#_snippet_2

LANGUAGE: console
CODE:
```
% log stream --debug --info --style compact --predicate subsystem == 'com.apple.swift-openapi'
Filtering the log data using "subsystem == \"com.apple.swift-openapi\""
Timestamp               Ty Process[PID:TID]
2023-12-07 17:09:20.256 Db HelloWorldURLSessionClient[32556:bdad678] [com.apple.swift-openapi:logging-middleware] Request: GET /greet body: <none>
2023-12-07 17:09:20.429 Db HelloWorldURLSessionClient[32556:bdad67a] [com.apple.swift-openapi:logging-middleware] Response: GET /greet 200  body: {
  "message" : "Hello, Stranger!"
}
^C
```

----------------------------------------

TITLE: Create an empty HTTPBody
DESCRIPTION: Demonstrates how to initialize an empty `HTTPBody` instance.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0004.md#_snippet_13

LANGUAGE: swift
CODE:
```
let body = HTTPBody()
```

----------------------------------------

TITLE: Map Content Types to Swift Names in Swift OpenAPI Generator
DESCRIPTION: This Swift function, `contentSwiftName`, is part of the `FileTranslator` and determines the Swift-safe name for a given content type. It uses a switch statement to assign predefined short names for common content types like JSON, URL-encoded forms, and plain text, based on real-world usage statistics. For unknown content types, it generates a name by combining the safe versions of the type and subtype.
SOURCE: https://github.com/apple/swift-openapi-generator/blob/main/Sources/swift-openapi-generator/Documentation.docc/Proposals/SOAR-0002.md#_snippet_1

LANGUAGE: swift
CODE:
```
func contentSwiftName(_ contentType: ContentType) -> String {
    switch contentType.lowercasedTypeAndSubtype {
    case "application/json":
        return "json"
    case "application/x-www-form-urlencoded":
        return "urlEncodedForm"
    case "multipart/form-data":
        return "multipartForm"
    case "text/plain":
        return "plainText"
    case "*/*":
        return "any"
    case "application/xml":
        return "xml"
    case "application/octet-stream":
        return "binary"
    case "text/html":
        return "html"
    case "application/yaml":
        return "yaml"
    case "text/csv":
        return "csv"
    case "image/png":
        return "png"
    case "application/pdf":
        return "pdf"
    case "image/jpeg":
        return "jpeg"
    default:
        let safedType = swiftSafeName(for: contentType.originallyCasedType)
        let safedSubtype = swiftSafeName(for: contentType.originallyCasedSubtype)
        return "\(safedType)_\(safedSubtype)"
    }
}
```
TITLE: Add OpenAPIRuntime Product to Swift Target
DESCRIPTION: This snippet illustrates how to add the `OpenAPIRuntime` product to a specific target's dependencies within your `Package.swift`. This makes the runtime's types and functionalities accessible to your application or library target.
SOURCE: https://github.com/apple/swift-openapi-runtime/blob/main/README.md#_snippet_1

LANGUAGE: Swift
CODE:
```
.target(name: "MyTarget", dependencies: [
    .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime")
]),
```

----------------------------------------

TITLE: Add OpenAPIRuntime Product to Swift Target Dependencies
DESCRIPTION: This snippet demonstrates how to add the `OpenAPIRuntime` product as a dependency to a specific target within your Swift package, enabling its types and functionalities for that target.
SOURCE: https://github.com/apple/swift-openapi-runtime/blob/main/Sources/OpenAPIRuntime/Documentation.docc/Documentation.md#_snippet_1

LANGUAGE: swift
CODE:
```
.target(name: "MyTarget", dependencies: [
    .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime")
]),
```

----------------------------------------

TITLE: Add OpenAPIRuntime Package Dependency to Package.swift
DESCRIPTION: This snippet shows how to add the `swift-openapi-runtime` package as a dependency in your Swift Package Manager's `Package.swift` file, specifying the URL and the minimum version for project-wide availability.
SOURCE: https://github.com/apple/swift-openapi-runtime/blob/main/Sources/OpenAPIRuntime/Documentation.docc/Documentation.md#_snippet_0

LANGUAGE: swift
CODE:
```
.package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.0.0"),
```

----------------------------------------

TITLE: Add Swift OpenAPI Runtime Package Dependency
DESCRIPTION: This code snippet demonstrates how to declare the Swift OpenAPI Runtime library as a package dependency in your `Package.swift` file, specifying its Git URL and version. This is the initial step for integrating the runtime into a Swift project.
SOURCE: https://github.com/apple/swift-openapi-runtime/blob/main/README.md#_snippet_0

LANGUAGE: Swift
CODE:
```
.package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.0.0"),
```

----------------------------------------

TITLE: OpenAPIRuntime API Reference
DESCRIPTION: Reference documentation for the core types, protocols, and enums provided by the OpenAPIRuntime library, categorized by functionality.
SOURCE: https://github.com/apple/swift-openapi-runtime/blob/main/Sources/OpenAPIRuntime/Documentation.docc/Documentation.md#_snippet_2

LANGUAGE: APIDOC
CODE:
```
OpenAPIRuntime API Reference:
  Essentials:
    - ClientTransport: Protocol for client-side HTTP transport.
    - ServerTransport: Protocol for server-side HTTP transport.
    - ClientMiddleware: Protocol for client-side HTTP request/response middleware.
    - ServerMiddleware: Protocol for server-side HTTP request/response middleware.
  Customization:
    - Configuration: Runtime configuration options.
    - DateTranscoder: Protocol for encoding/decoding dates.
    - ISO8601DateTranscoder: Default ISO8601 date transcoder.
    - MultipartBoundaryGenerator: Protocol for generating multipart boundaries.
    - RandomMultipartBoundaryGenerator: Random multipart boundary generator.
    - ConstantMultipartBoundaryGenerator: Constant multipart boundary generator.
    - IterationBehavior: Defines iteration behavior for collections.
  Content types:
    - HTTPBody: Represents an HTTP message body.
    - Base64EncodedData: Type for Base64 encoded data.
    - MultipartBody: Represents a multipart HTTP body.
    - MultipartRawPart: Raw part of a multipart body.
    - MultipartPart: Structured part of a multipart body.
    - MultipartDynamicallyNamedPart: Dynamically named part of a multipart body.
  Errors:
    - ClientError: Errors originating from the client.
    - ServerError: Errors originating from the server.
    - UndocumentedPayload: Error for undocumented API payloads.
  HTTP Currency Types:
    - HTTPBody: Represents an HTTP message body.
    - ServerRequestMetadata: Metadata associated with a server request.
    - AcceptableProtocol: Represents an acceptable protocol in an Accept header.
    - AcceptHeaderContentType: Represents a content type in an Accept header.
    - QualityValue: Represents a quality value in an Accept header.
  Dynamic Payloads:
    - OpenAPIValueContainer: Container for OpenAPI values.
    - OpenAPIObjectContainer: Container for OpenAPI object values.
    - OpenAPIArrayContainer: Container for OpenAPI array values.
```

----------------------------------------

TITLE: Run GitHub Actions Workflows Locally with Act
DESCRIPTION: Demonstrates how to use the 'act' tool to execute GitHub Actions workflows locally, including commands to run all pull request jobs, a specific job like 'soundness' with inputs, and jobs with bind-mounted directories for direct file modifications.
SOURCE: https://github.com/apple/swift-openapi-runtime/blob/main/CONTRIBUTING.md#_snippet_1

LANGUAGE: shell
CODE:
```
% act pull_request
% act workflow_call -j soundness --input shell_check_enabled=true
% act --bind workflow_call -j soundness --input format_check_enabled=true
```

----------------------------------------

TITLE: Configure Act Default Flags via .actrc
DESCRIPTION: Illustrates the structure and content of an '.actrc' file, which allows users to define default command-line flags for the 'act' tool, such as container architecture, remote name, and offline mode, simplifying repeated command execution.
SOURCE: https://github.com/apple/swift-openapi-runtime/blob/main/CONTRIBUTING.md#_snippet_2

LANGUAGE: config
CODE:
```
--container-architecture=linux/amd64
--remote-name upstream
--action-offline-mode
```