TITLE: Declaring SwiftNIO Package Dependency in Swift
DESCRIPTION: This code snippet illustrates how to declare a dependency on the SwiftNIO project within a `Package.swift` file using Swift Package Manager. The `from: "2.0.0"` parameter specifies that the project requires version 2.0.0 or newer, up to the next major version, aligning with SwiftNIO's recommended dependency management for forward compatibility.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-api.md#_snippet_12

LANGUAGE: Swift
CODE:
```
.package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),
```

----------------------------------------

TITLE: Bootstrapping a TCP Server with ServerBootstrap and NIOAsyncChannel (Swift)
DESCRIPTION: This snippet demonstrates how to set up a TCP server using `ServerBootstrap` in SwiftNIO with Swift Concurrency. It binds to a specific host and port, configuring each inbound connection to be wrapped in a `NIOAsyncChannel` for asynchronous byte buffer handling. It then processes incoming connections within a `withThrowingDiscardingTaskGroup`, echoing back received data.
SOURCE: https://github.com/apple/swift-nio/blob/main/Sources/NIOCore/Docs.docc/swift-concurrency.md#_snippet_2

LANGUAGE: Swift
CODE:
```
let serverChannel = try await ServerBootstrap(group: eventLoopGroup)
    .bind(
        host: "127.0.0.1",
        port: 1234
    ) { childChannel in
        // This closure is called for every inbound connection
        childChannel.eventLoop.makeCompletedFuture {
            return try NIOAsyncChannel<ByteBuffer, ByteBuffer>(
                synchronouslyWrapping: childChannel
            )
        }
    }

try await withThrowingDiscardingTaskGroup { group in
    try await serverChannel.executeThenClose { serverChannelInbound in
        for try await connectionChannel in serverChannelInbound {
            group.addTask {
                do {
                    try await connectionChannel.executeThenClose { connectionChannelInbound, connectionChannelOutbound in
                        for try await inboundData in connectionChannelInbound {
                            // Let's echo back all inbound data
                            try await connectionChannelOutbound.write(inboundData)
                        }
                    }
                } catch {
                    // Handle errors
                }
            }
        }
    }
}
```

----------------------------------------

TITLE: Bridging EventLoopFuture/Promise with Swift Concurrency
DESCRIPTION: This snippet demonstrates how to use `EventLoopPromise/completeWithTask(_:)` to complete a promise with the result of an asynchronous task and `EventLoopFuture/get()` to await the result of a future in a Swift Concurrency context. It highlights the interoperation between NIO's future/promise system and Swift's `async`/`await`.
SOURCE: https://github.com/apple/swift-nio/blob/main/Sources/NIOCore/Docs.docc/swift-concurrency.md#_snippet_0

LANGUAGE: Swift
CODE:
```
let eventLoop: EventLoop

let promise = eventLoop.makePromise(of: Bool.self)

promise.completeWithTask {
    try await Task.sleep(for: .seconds(1))
    return true
}

let result = try await promise.futureResult.get()
```

----------------------------------------

TITLE: Handling Channel Read Operations in SwiftNIO
DESCRIPTION: The `channelRead` method is invoked when data has been received from the remote peer. It provides the `ChannelHandlerContext` and the `data` read (wrapped in `NIOAny`). Handlers should process the data and then call `context.fireChannelRead` to forward the data to the next `_ChannelInboundHandler` in the pipeline for further processing.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_48

LANGUAGE: Swift
CODE:
```
public func channelRead(context: NIOCore.ChannelHandlerContext, data: NIOCore.NIOAny)
```

----------------------------------------

TITLE: Adding SwiftNIO as a SwiftPM Dependency (Basic)
DESCRIPTION: This snippet shows the basic way to declare SwiftNIO as a package dependency in a `Package.swift` file. It specifies the Git repository URL and the minimum version required for the dependency.
SOURCE: https://github.com/apple/swift-nio/blob/main/README.md#_snippet_5

LANGUAGE: Swift
CODE:
```
dependencies: [
    .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0")
]
```

----------------------------------------

TITLE: Binding Server to Host and Port with SwiftNIO ServerBootstrap
DESCRIPTION: Binds a `ServerBootstrap` to a specified host and port, creating a `ServerSocketChannel`. It allows an optional `serverBackPressureStrategy` and requires a `childChannelInitializer` closure to configure accepted client channels. This method is available on macOS 10.15+, iOS 13+, tvOS 13+, and watchOS 6+.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_19

LANGUAGE: swift
CODE:
```
@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
    public func bind<Output>(host: String, port: Int, serverBackPressureStrategy: NIOCore.NIOAsyncSequenceProducerBackPressureStrategies.HighLowWatermark? = nil, childChannelInitializer: @escaping @Sendable (NIOCore.Channel) -> NIOCore.EventLoopFuture<Output>) async throws -> NIOCore.NIOAsyncChannel<Output, Never> where Output : Sendable
```

----------------------------------------

TITLE: Adding Specific SwiftNIO Modules as Target Dependencies (Swift 5.4+)
DESCRIPTION: This code demonstrates how to add specific SwiftNIO modules (`NIOCore`, `NIOPosix`, `NIOHTTP1`) as target dependencies within a `Package.swift` file for Swift 5.4 and newer. This approach allows for granular control over which parts of SwiftNIO are included in a project.
SOURCE: https://github.com/apple/swift-nio/blob/main/README.md#_snippet_6

LANGUAGE: Swift
CODE:
```
dependencies: [.product(name: "NIOCore", package: "swift-nio"),
                   .product(name: "NIOPosix", package: "swift-nio"),
                   .product(name: "NIOHTTP1", package: "swift-nio")]
```

----------------------------------------

TITLE: Making NIOAsyncChannelOutboundWriter.TestSink Sendable in Swift
DESCRIPTION: This extension makes the `NIOAsyncChannelOutboundWriter.TestSink` type conform to the `Sendable` protocol. This conformance is available on specific Apple platforms (macOS 10.15+, iOS 13+, tvOS 13+, watchOS 6+) and ensures that instances of `TestSink` can be safely passed across concurrency domains.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_14

LANGUAGE: Swift
CODE:
```
@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension NIOAsyncChannelOutboundWriter.TestSink : Sendable {}
```

----------------------------------------

TITLE: Connecting to TCP Host and Port with SwiftNIO ClientBootstrap
DESCRIPTION: Connects a `ClientBootstrap` to a specified host and port to establish a TCP `Channel`. It requires a `channelInitializer` closure to configure the channel, returning the result of this initialization. This method is available on macOS 10.15+, iOS 13+, tvOS 13+, and watchOS 6+.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_15

LANGUAGE: swift
CODE:
```
@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
    public func connect<Output>(host: String, port: Int, channelInitializer: @escaping @Sendable (NIOCore.Channel) -> NIOCore.EventLoopFuture<Output>) async throws -> Output where Output : Sendable
```

----------------------------------------

TITLE: Wrapping Channel with NIOAsyncChannel for Async I/O
DESCRIPTION: This example illustrates how to wrap an existing NIO `Channel` into a `NIOAsyncChannel` to enable asynchronous reading and writing using Swift Concurrency. It shows how to consume inbound data as an `AsyncSequence` and echo it back outbound, emphasizing the importance of proper wrapping timing to prevent data loss.
SOURCE: https://github.com/apple/swift-nio/blob/main/Sources/NIOCore/Docs.docc/swift-concurrency.md#_snippet_1

LANGUAGE: Swift
CODE:
```
let channel = ...
let asyncChannel = try NIOAsyncChannel<ByteBuffer, ByteBuffer>(wrappingChannelSynchronously: channel)

try await asyncChannel.executeThenClose { inbound, outbound in
    for try await inboundData in inbound {
        try await outbound.write(inboundData)
    }
}
```

----------------------------------------

TITLE: Defining NIOAsyncChannel for Swift Concurrency
DESCRIPTION: This Swift code defines the `NIOAsyncChannel` struct, which wraps a `NIOCore.Channel` to integrate with Swift Concurrency. It provides an `AsyncSequence` for inbound data (`inbound`) and an `NIOAsyncChannelOutboundWriter` for sending data (`outbound`). The nested `Configuration` struct allows customization of back pressure strategy and outbound half-closure. Initializers are provided to synchronously wrap a channel, emphasizing the requirement to be called on the channel's event loop to prevent data loss.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_0

LANGUAGE: Swift
CODE:
```
/// Wraps a NIO ``Channel`` object into a form suitable for use in Swift Concurrency.
///
/// ``NIOAsyncChannel`` abstracts the notion of a NIO ``Channel`` into something that
/// can safely be used in a structured concurrency context. In particular, this exposes
/// the following functionality:
///
/// - reads are presented as an `AsyncSequence`
/// - writes can be written to with async functions on a writer, providing back pressure
/// - channels can be closed seamlessly
///
/// This type does not replace the full complexity of NIO's ``Channel``. In particular, it
/// does not expose the following functionality:
///
/// - user events
/// - traditional NIO back pressure such as writability signals and the ``Channel/read()`` call
///
/// Users are encouraged to separate their ``ChannelHandler``s into those that implement
/// protocol-specific logic (such as parsers and encoders) and those that implement business
/// logic. Protocol-specific logic should be implemented as a ``ChannelHandler``, while business
/// logic should use ``NIOAsyncChannel`` to consume and produce data to the network.
@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public struct NIOAsyncChannel<Inbound, Outbound> : Sendable where Inbound : Sendable, Outbound : Sendable {
    public struct Configuration : Sendable {
        /// The back pressure strategy of the ``NIOAsyncChannel/inbound``.
        public var backPressureStrategy: NIOCore.NIOAsyncSequenceProducerBackPressureStrategies.HighLowWatermark

        /// If outbound half closure should be enabled. Outbound half closure is triggered once
        /// the ``NIOAsyncChannelOutboundWriter`` is either finished or deinitialized.
        public var isOutboundHalfClosureEnabled: Bool

        /// The ``NIOAsyncChannel/inbound`` message's type.
        public var inboundType: Inbound.Type

        /// The ``NIOAsyncChannel/outbound`` message's type.
        public var outboundType: Outbound.Type

        /// Initializes a new ``NIOAsyncChannel/Configuration``.
        ///
        /// - Parameters:
        ///   - backPressureStrategy: The back pressure strategy of the ``NIOAsyncChannel/inbound``. Defaults
        ///     to a watermarked strategy (lowWatermark: 2, highWatermark: 10).
        ///   - isOutboundHalfClosureEnabled: If outbound half closure should be enabled. Outbound half closure is triggered once
        ///     the ``NIOAsyncChannelOutboundWriter`` is either finished or deinitialized. Defaults to `false`.
        ///   - inboundType: The ``NIOAsyncChannel/inbound`` message's type.
        ///   - outboundType: The ``NIOAsyncChannel/outbound`` message's type.
        public init(backPressureStrategy: NIOCore.NIOAsyncSequenceProducerBackPressureStrategies.HighLowWatermark = .init(lowWatermark: 2, highWatermark: 10), isOutboundHalfClosureEnabled: Bool = false, inboundType: Inbound.Type = Inbound.self, outboundType: Outbound.Type = Outbound.self)
    }

    /// The underlying channel being wrapped by this ``NIOAsyncChannel``.
    public let channel: NIOCore.Channel

    /// The stream of inbound messages.
    ///
    /// - Important: The `inbound` stream is a unicast `AsyncSequence` and only one iterator can be created.
    public let inbound: NIOCore.NIOAsyncChannelInboundStream<Inbound>

    /// The writer for writing outbound messages.
    public let outbound: NIOCore.NIOAsyncChannelOutboundWriter<Outbound>

    /// Initializes a new ``NIOAsyncChannel`` wrapping a ``Channel``.
    ///
    /// - Important: This **must** be called on the channel's event loop otherwise this init will crash. This is necessary because
    /// we must install the handlers before any other event in the pipeline happens otherwise we might drop reads.
    ///
    /// - Parameters:
    ///   - channel: The ``Channel`` to wrap.
    ///   - configuration: The ``NIOAsyncChannel``s configuration.
    @inlinable public init(synchronouslyWrapping channel: NIOCore.Channel, configuration: NIOCore.NIOAsyncChannel<Inbound, Outbound>.Configuration = .init()) throws

    /// Initializes a new ``NIOAsyncChannel`` wrapping a ``Channel`` where the outbound type is `Never`.
    ///
    /// This initializer will finish the ``NIOAsyncChannel/outboundWriter`` immediately.
    ///
    /// - Important: This **must** be called on the channel's event loop otherwise this init will crash. This is necessary because
    /// we must install the handlers before any other event in the pipeline happens otherwise we might drop reads.
    ///
    /// - Parameters:
    ///   - channel: The ``Channel`` to wrap.
    ///   - configuration: The ``NIOAsyncChannel``s configuration.
    @inlinable public init(synchronouslyWrapping channel: NIOCore.Channel, configuration: NIOCore.NIOAsyncChannel<Inbound, Outbound>.Configuration = .init()) throws where Outbound == Never

    /// This method is only used from our server bootstrap to allow us to run the child channel initializer
}
```

----------------------------------------

TITLE: Connecting to SocketAddress with SwiftNIO ClientBootstrap
DESCRIPTION: Connects a `ClientBootstrap` to a specific `SocketAddress` to establish a TCP `Channel`. It takes the address and a `channelInitializer` closure, which configures the channel and whose return value is propagated. This method is available on macOS 10.15+, iOS 13+, tvOS 13+, and watchOS 6+.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_16

LANGUAGE: swift
CODE:
```
@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
    public func connect<Output>(to address: NIOCore.SocketAddress, channelInitializer: @escaping @Sendable (NIOCore.Channel) -> NIOCore.EventLoopFuture<Output>) async throws -> Output where Output : Sendable
```

----------------------------------------

TITLE: Building and Running SwiftNIO Echo Server with SwiftPM
DESCRIPTION: This snippet demonstrates how to compile, test, and run the SwiftNIO Echo Server example using Swift Package Manager. It ensures the project builds correctly, passes tests, and then launches the server application.
SOURCE: https://github.com/apple/swift-nio/blob/main/README.md#_snippet_7

LANGUAGE: bash
CODE:
```
swift build
swift test
swift run NIOEchoServer
```

----------------------------------------

TITLE: Connecting a TCP Client with ClientBootstrap and NIOAsyncChannel (Swift)
DESCRIPTION: This snippet illustrates how to establish a TCP client connection using `ClientBootstrap` in SwiftNIO with Swift Concurrency. It connects to a specified host and port, wrapping the channel in a `NIOAsyncChannel`. The client then writes a 'hello' message and prints any incoming data from the server.
SOURCE: https://github.com/apple/swift-nio/blob/main/Sources/NIOCore/Docs.docc/swift-concurrency.md#_snippet_3

LANGUAGE: Swift
CODE:
```
let clientChannel = try await ClientBootstrap(group: eventLoopGroup)
    .connect(
        host: "127.0.0.1",
        port: 1234
    ) { channel in
        channel.eventLoop.makeCompletedFuture {
            return try NIOAsyncChannel<ByteBuffer, ByteBuffer>(
                wrappingChannelSynchronously: channel
            )
        }
    }

try await clientChannel.executeThenClose { inbound, outbound in
    try await outbound.write(ByteBuffer(string: "hello"))

    for try await inboundData in inbound {
        print(inboundData)
    }
}
```

----------------------------------------

TITLE: Binding Server to SocketAddress with SwiftNIO ServerBootstrap
DESCRIPTION: Binds a `ServerBootstrap` to a specific `SocketAddress`, creating a `ServerSocketChannel`. It supports an optional `serverBackPressureStrategy` and requires a `childChannelInitializer` closure for configuring accepted client channels. This method is available on macOS 10.15+, iOS 13+, tvOS 13+, and watchOS 6+.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_20

LANGUAGE: swift
CODE:
```
@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
    public func bind<Output>(to address: NIOCore.SocketAddress, serverBackPressureStrategy: NIOCore.NIOAsyncSequenceProducerBackPressureStrategies.HighLowWatermark? = nil, childChannelInitializer: @escaping @Sendable (NIOCore.Channel) -> NIOCore.EventLoopFuture<Output>) async throws -> NIOCore.NIOAsyncChannel<Output, Never> where Output : Sendable
```

----------------------------------------

TITLE: Testing SwiftNIO Echo Server Connection
DESCRIPTION: This command tests the running SwiftNIO Echo Server by sending a string 'Hello SwiftNIO' to localhost on port 9999 using netcat. It verifies that the server is active and echoes the message back.
SOURCE: https://github.com/apple/swift-nio/blob/main/README.md#_snippet_8

LANGUAGE: bash
CODE:
```
echo "Hello SwiftNIO" | nc localhost 9999
```

----------------------------------------

TITLE: Connecting a Channel to Host with Swift NIO (Swift)
DESCRIPTION: This function establishes an outbound connection from a `Channel` to a specified host using a given IP protocol. A `channelInitializer` closure is used to set up the channel after the connection is established. This method is available on macOS 10.15+, iOS 13+, tvOS 13+, and watchOS 6+.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_33

LANGUAGE: Swift
CODE:
```
@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public func connect<Output>(host: String, ipProtocol: NIOCore.NIOIPProtocol, channelInitializer: @escaping @Sendable (NIOCore.Channel) -> NIOCore.EventLoopFuture<Output>) async throws -> Output where Output : Sendable
```

----------------------------------------

TITLE: Invoking NIOChatClient via Bash
DESCRIPTION: This snippet demonstrates various command-line syntaxes for running the NIOChatClient. It covers connecting to a default local server, a specified port, a UNIX domain socket, or a remote host and port. These commands are used to establish a connection with a NIOChatServer.
SOURCE: https://github.com/apple/swift-nio/blob/main/Sources/NIOChatClient/README.md#_snippet_0

LANGUAGE: bash
CODE:
```
swift run NIOChatClient  # Connects to a server on ::1, port 9999.
swift run NIOChatClient 9899  # Connects to a server on ::1, port 9899
swift run NIOChatClient /path/to/unix/socket  # Connects to a server using the given UNIX socket
swift run NIOChatClient chat.example.com 9899  # Connects to a server on chat.example.com:9899
```

----------------------------------------

TITLE: Performing Write Operations in SwiftNIO
DESCRIPTION: The `write` method is called to request a write operation, pushing data through the `ChannelPipeline` towards the remote peer. It takes the `ChannelHandlerContext`, the `data` to be written (wrapped in `NIOAny`), and an optional `promise` to be fulfilled upon completion. Implementations should forward the write using `context.write` or complete the promise directly.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_47

LANGUAGE: Swift
CODE:
```
public func write(context: NIOCore.ChannelHandlerContext, data: NIOCore.NIOAny, promise: NIOCore.EventLoopPromise<Void>?)
```

----------------------------------------

TITLE: Writing Single Data to ChannelPipeline in Swift
DESCRIPTION: This method sends a single piece of `OutboundOut` data into the `ChannelPipeline` and flushes it immediately. It suspends execution if the underlying channel is not writable and resumes once the channel becomes writable again, providing backpressure handling.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_10

LANGUAGE: Swift
CODE:
```
@inlinable public func write(_ data: OutboundOut) async throws
```

----------------------------------------

TITLE: Running NIOEchoServer with various binding options - Bash
DESCRIPTION: This snippet demonstrates different ways to run the NIOEchoServer application, allowing it to bind to a default IPv6 address and port, a custom port, a UNIX domain socket, or a specific IPv4 address and port. These commands illustrate the flexibility in configuring the server's network interface.
SOURCE: https://github.com/apple/swift-nio/blob/main/Sources/NIOEchoServer/README.md#_snippet_0

LANGUAGE: Bash
CODE:
```
swift run NIOEchoServer  # Binds the server on ::1, port 9999.
swift run NIOEchoServer 9899  # Binds the server on ::1, port 9899
swift run NIOEchoServer /path/to/unix/socket  # Binds the server using the given UNIX socket
swift run NIOEchoServer 192.168.0.5 9899  # Binds the server on 192.168.0.5:9899
```

----------------------------------------

TITLE: Running NIOWebSocketClient via Swift CLI
DESCRIPTION: This snippet demonstrates various ways to invoke the `NIOWebSocketClient` application using the Swift command-line interface. It shows how to connect to a default local server, a specific port, a UNIX domain socket, or a remote host and port, providing flexibility for different deployment scenarios.
SOURCE: https://github.com/apple/swift-nio/blob/main/Sources/NIOWebSocketClient/README.md#_snippet_0

LANGUAGE: bash
CODE:
```
swift run NIOWebSocketClient  # Connects to a server on ::1, port 8888.
swift run NIOWebSocketClient 9899  # Connects to a server on ::1, port 9899
swift run NIOWebSocketClient /path/to/unix/socket  # Connects to a server using the given UNIX socket
swift run NIOWebSocketClient echo.example.com 9899  # Connects to a server on echo.example.com:9899
```

----------------------------------------

TITLE: Binding a Channel to Host with Swift NIO (Swift)
DESCRIPTION: This function binds a `Channel` to a specified host and IP protocol, making it ready to accept incoming connections. It requires a `channelInitializer` closure to configure the channel once bound. The function returns an `EventLoopFuture` that resolves to the output of the initializer.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_32

LANGUAGE: Swift
CODE:
```
public func bind<Output>(host: String, ipProtocol: NIOCore.NIOIPProtocol, channelInitializer: @escaping @Sendable (NIOCore.Channel) -> NIOCore.EventLoopFuture<Output>) async throws -> Output where Output : Sendable
```

----------------------------------------

TITLE: Defining AsyncStreamMultiplexer and InboundStreamChannels in SwiftNIO
DESCRIPTION: This snippet defines `NIOHTTP2Handler.AsyncStreamMultiplexer`, a variant of `StreamMultiplexer` that creates a child channel for each HTTP/2 stream, operating on `HTTP2Frame.FramePayload`. It also defines `NIOHTTP2InboundStreamChannels`, an `AsyncSequence` for accessing inbound stream channels, enabling asynchronous iteration over incoming HTTP/2 streams.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_63

LANGUAGE: Swift
CODE:
```
extension NIOHTTP2Handler {
    /// A variant of `NIOHTTP2Handler.StreamMultiplexer` which creates a child channel for each HTTP/2 stream and
    /// provides access to inbound HTTP/2 streams.
    ///
    /// In general in NIO applications it is helpful to consider each HTTP/2 stream as an
    /// independent stream of HTTP/2 frames. This multiplexer achieves this by creating a
    /// number of in-memory `HTTP2StreamChannel` objects, one for each stream. These operate
    /// on ``HTTP2Frame/FramePayload`` objects as their base communication
    /// atom, as opposed to the regular NIO `SelectableChannel` objects which use `ByteBuffer`
    /// and `IOData`.
    ///
    /// Outbound stream channel objects are initialized upon creation using the supplied `streamStateInitializer` which returns a type
    /// `Output`. This type may be `HTTP2Frame` or changed to any other type.
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    public struct AsyncStreamMultiplexer<InboundStreamOutput> {
        /// Create a stream channel initialized with the provided closure
        public func createStreamChannel<Output: Sendable>(_ initializer: @escaping NIOChannelInitializerWithOutput<Output>) async throws -> Output
    }
}

/// `NIOHTTP2InboundStreamChannels` provides access to inbound stream channels as a generic `AsyncSequence`.
/// They make use of generics to allow for wrapping the stream `Channel`s, for example as `NIOAsyncChannel`s or protocol negotiation objects.
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public struct NIOHTTP2InboundStreamChannels<Output>: AsyncSequence {
    public struct AsyncIterator: AsyncIteratorProtocol {
        public typealias Element = Output

        public mutating func next() async throws -> Output?
    }

    public typealias Element = Output

    public func makeAsyncIterator() -> AsyncIterator
}
```

----------------------------------------

TITLE: Handling Channel Active State in SwiftNIO
DESCRIPTION: The `channelActive` method is invoked when the `Channel` becomes active, meaning it is connected and ready to send and receive data. Implementations should call `context.fireChannelActive` to propagate the event down the `ChannelPipeline`, allowing subsequent inbound handlers to process the active state.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_46

LANGUAGE: Swift
CODE:
```
public func channelActive(context: NIOCore.ChannelHandlerContext)
```

----------------------------------------

TITLE: Implementing Channel Inactivity in Swift NIO
DESCRIPTION: The `channelInactive` method is part of the `ChannelHandler` protocol in Swift NIO. It is called when a `Channel` becomes inactive, typically after it has been closed or its connection has been lost. This method provides a hook for performing cleanup operations or releasing resources associated with the channel. The `context` parameter provides access to the `ChannelHandlerContext` for interacting with the channel pipeline.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_62

LANGUAGE: Swift
CODE:
```
    ///   - context: The `ChannelHandlerContext` which this `ChannelHandler` belongs to.\n    public func channelInactive(context: NIOCore.ChannelHandlerContext)\n}
```

----------------------------------------

TITLE: Calling Public SwiftNIO Methods
DESCRIPTION: Demonstrates the acceptable use of a public method on a SwiftNIO `Channel` type, adhering to the public API guidelines by not using underscored properties or methods.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-api.md#_snippet_0

LANGUAGE: Swift
CODE:
```
channel.close(promise: nil)
```

----------------------------------------

TITLE: Handling ChannelHandler Addition in SwiftNIO
DESCRIPTION: The `handlerAdded` method is a lifecycle hook invoked when this `ChannelHandler` is successfully added to the `ChannelPipeline`. It provides the `ChannelHandlerContext` for interacting with the pipeline and the channel. This method is typically used for setup tasks that depend on the handler being part of the pipeline.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_44

LANGUAGE: Swift
CODE:
```
public func handlerAdded(context: NIOCore.ChannelHandlerContext)
```

----------------------------------------

TITLE: Configuring Client-Side WebSocket Upgrade Pipeline in SwiftNIO
DESCRIPTION: This snippet demonstrates how to configure a client-side HTTP pipeline for a WebSocket upgrade using `NIOTypedHTTPClientUpgradeConfiguration`. It defines an `UpgradeResult` enum to capture the outcome and sets up a `NIOTypedWebSocketClientUpgrader` to handle the pipeline modification upon successful upgrade, wrapping the channel in `NIOAsyncChannel`.
SOURCE: https://github.com/apple/swift-nio/blob/main/Sources/NIOCore/Docs.docc/swift-concurrency.md#_snippet_4

LANGUAGE: Swift
CODE:
```
enum UpgradeResult {
    case websocket(NIOAsyncChannel<WebSocketFrame, WebSocketFrame>)
    case notUpgraded
}

let upgradeResult: EventLoopFuture<UpgradeResult> = try await ClientBootstrap(group: eventLoopGroup)
    .connect(
        host: "127.0.0.1",
        port: 1234
    ) { channel in
        channel.eventLoop.makeCompletedFuture {
            // Configure the websocket upgrader
            let upgrader = NIOTypedWebSocketClientUpgrader<UpgradeResult>(
                upgradePipelineHandler: { channel, _ in
                    // This configures the pipeline after the websocket upgrade was successful.
                    // We are wrapping the pipeline in a NIOAsyncChannel.
                    channel.eventLoop.makeCompletedFuture {
                        let asyncChannel = try NIOAsyncChannel<WebSocketFrame, WebSocketFrame>(wrappingChannelSynchronously: channel)
                        return UpgradeResult.websocket(asyncChannel)
                    }
                }
            )

            var headers = HTTPHeaders()
            headers.add(name: "Content-Type", value: "text/plain; charset=utf-8")
            headers.add(name: "Content-Length", value: "0")

            let requestHead = HTTPRequestHead(
                version: .http1_1,
                method: .GET,
                uri: "/",
                headers: headers
            )

            let clientUpgradeConfiguration = NIOTypedHTTPClientUpgradeConfiguration(
                upgradeRequestHead: requestHead,
                upgraders: [upgrader],
                notUpgradingCompletionHandler: { channel in
                    channel.eventLoop.makeCompletedFuture {
                        return UpgradeResult.notUpgraded
                    }
                }
            )

            let upgradeResult = try channel.pipeline.syncOperations.configureUpgradableHTTPClientPipeline(
                configuration: .init(upgradeConfiguration: clientUpgradeConfiguration)
            )

            return upgradeResult
        }
    }
```

----------------------------------------

TITLE: Configuring Async HTTP/2 and ALPN Pipelines in SwiftNIO Channel
DESCRIPTION: This `Channel` extension provides two functions: `configureAsyncHTTP2Pipeline` for setting up a channel to speak HTTP/2 after negotiation, and another for configuring a pipeline to negotiate between HTTP/1.1 and HTTP/2 using ALPN. Both functions allow for asynchronous stream handling and require specific initializers for inbound streams and connection types.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_64

LANGUAGE: Swift
CODE:
```
extension Channel {
    /// Configures a `ChannelPipeline` to speak HTTP/2 and sets up mapping functions so that it may be interacted with from concurrent code.
    ///
    /// In general this is not entirely useful by itself, as HTTP/2 is a negotiated protocol. This helper does not handle negotiation.
    /// Instead, this simply adds the handler required to speak HTTP/2 after negotiation has completed, or when agreed by prior knowledge.
    /// Use this function to setup a HTTP/2 pipeline if you wish to use async sequence abstractions over inbound and outbound streams.
    /// Using this rather than implementing a similar function yourself allows that pipeline to evolve without breaking your code.
    ///
    /// - Parameters:
    ///   - mode: The mode this pipeline will operate in, server or client.
    ///   - configuration: The settings that will be used when establishing the connection and new streams.
    ///   - inboundStreamInitializer: A closure that will be called whenever the remote peer initiates a new stream.
    ///     The output of this closure is the element type of the returned multiplexer
    /// - Returns: An `EventLoopFuture` containing the `AsyncStreamMultiplexer` inserted into this pipeline, which can
    ///     be used to initiate new streams and iterate over inbound HTTP/2 stream channels.
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    public func configureAsyncHTTP2Pipeline<Output: Sendable>(
        mode: NIOHTTP2Handler.ParserMode,
        configuration: NIOHTTP2Handler.Configuration = .init(),
        inboundStreamInitializer: @escaping NIOChannelInitializerWithOutput<Output>
    ) -> EventLoopFuture<NIOHTTP2Handler.AsyncStreamMultiplexer<Output>>

    /// Configures a `ChannelPipeline` to speak either HTTP/1.1 or HTTP/2 according to what can be negotiated with the client.
    ///
    /// This helper takes care of configuring the server pipeline such that it negotiates whether to
    /// use HTTP/1.1 or HTTP/2.
    ///
    /// This function doesn't configure the TLS handler. Callers of this function need to add a TLS
    /// handler appropriately configured to perform protocol negotiation.
    ///
    /// - Parameters:
    ///   - http2Configuration: The settings that will be used when establishing the HTTP/2 connections and new HTTP/2 streams.
    ///   - http1ConnectionInitializer: An optional callback that will be invoked only when the negotiated protocol
    ///     is HTTP/1.1 to configure the connection channel.
    ///   - http2ConnectionInitializer: An optional callback that will be invoked only when the negotiated protocol
    ///     is HTTP/2 to configure the connection channel.
    ///   - http2InboundStreamInitializer: A closure that will be called whenever the remote peer initiates a new stream.
    ///     The output of this closure is the element type of the returned multiplexer
    /// - Returns: An `EventLoopFuture` containing a ``NIOTypedApplicationProtocolNegotiationHandler`` that completes when the channel
}
```

----------------------------------------

TITLE: Connecting DatagramChannel to SocketAddress (SwiftNIO)
DESCRIPTION: Connects a `DatagramChannel` to a given `SocketAddress`. The `channelInitializer` closure sets up the channel, and its result is returned. This method supports modern Apple platforms and is asynchronous.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_28

LANGUAGE: Swift
CODE:
```
public func connect<Output>(to address: NIOCore.SocketAddress, channelInitializer: @escaping @Sendable (NIOCore.Channel) -> NIOCore.EventLoopFuture<Output>) async throws -> Output where Output : Sendable
```

----------------------------------------

TITLE: Writing Sequence of Data to ChannelPipeline in Swift
DESCRIPTION: This method sends a sequence of `OutboundOut` elements into the `ChannelPipeline` and flushes them right away. Similar to the single write method, it suspends if the channel is not writable and resumes when it becomes available, ensuring proper backpressure management.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_11

LANGUAGE: Swift
CODE:
```
@inlinable public func write<Writes>(contentsOf sequence: Writes) async throws where OutboundOut == Writes.Element, Writes : Sequence
```

----------------------------------------

TITLE: Finishing NIOAsyncChannelOutboundWriter in Swift
DESCRIPTION: This method explicitly finishes the `NIOAsyncChannelOutboundWriter`. Depending on how the `NIOAsyncChannel` was configured, calling this method might trigger a half-closure of the channel, signaling the end of outbound data transmission.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_13

LANGUAGE: Swift
CODE:
```
public func finish()
```

----------------------------------------

TITLE: Writing Async Sequence of Data to ChannelPipeline in Swift
DESCRIPTION: This method sends an asynchronous sequence of `OutboundOut` elements into the `ChannelPipeline`, flushing after every write. It handles backpressure by suspending if the underlying channel is not writable and resuming once it becomes writable again.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_12

LANGUAGE: Swift
CODE:
```
@inlinable public func write<Writes>(contentsOf sequence: Writes) async throws where OutboundOut == Writes.Element, Writes : AsyncSequence
```

----------------------------------------

TITLE: Running SwiftNIO Examples with SwiftPM
DESCRIPTION: This command demonstrates how to build and run a specific SwiftNIO example project using the Swift Package Manager. Replace `TARGET_NAME` with the name of the desired example folder located under `./Sources`.
SOURCE: https://github.com/apple/swift-nio/blob/main/README.md#_snippet_3

LANGUAGE: Bash
CODE:
```
swift run TARGET_NAME
```

----------------------------------------

TITLE: Binding Datagram Channel to Socket Address in Swift NIO
DESCRIPTION: This function binds a `DatagramChannel` to a given `SocketAddress`. It takes a channel initializer and returns its result.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_25

LANGUAGE: Swift
CODE:
```
public func bind<Output>(to address: NIOCore.SocketAddress, channelInitializer: @escaping @Sendable (NIOCore.Channel) -> NIOCore.EventLoopFuture<Output>) async throws -> Output where Output : Sendable
```

----------------------------------------

TITLE: Invoking NIOEchoClient with various connection options (Bash)
DESCRIPTION: This snippet demonstrates different ways to invoke the `NIOEchoClient` application from the command line, allowing connections to a default local server, a specified port, a UNIX domain socket, or a remote host and port. It shows the flexibility in configuring the client's connection target.
SOURCE: https://github.com/apple/swift-nio/blob/main/Sources/NIOEchoClient/README.md#_snippet_0

LANGUAGE: bash
CODE:
```
swift run NIOEchoClient  # Connects to a server on ::1, port 9999.
swift run NIOEchoClient 9899  # Connects to a server on ::1, port 9899
swift run NIOEchoClient /path/to/unix/socket  # Connects to a server using the given UNIX socket
swift run NIOEchoClient echo.example.com 9899  # Connects to a server on echo.example.com:9899
```

----------------------------------------

TITLE: Handling ChannelHandler Removal in SwiftNIO
DESCRIPTION: The `handlerRemoved` method is a lifecycle hook called when this `ChannelHandler` is removed from the `ChannelPipeline`. It receives the `ChannelHandlerContext` and is typically used for cleanup operations, such as releasing resources or unregistering from events, ensuring no lingering effects after the handler's removal.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_45

LANGUAGE: Swift
CODE:
```
public func handlerRemoved(context: NIOCore.ChannelHandlerContext)
```

----------------------------------------

TITLE: Declaring Swift Package Manager Dependency (NIO 2.0.0)
DESCRIPTION: This snippet shows how to declare a dependency on a SwiftNIO module using Swift Package Manager, specifying a minimum version of 2.0.0. This ensures compatibility with the NIO 2 API.
SOURCE: https://github.com/apple/swift-nio/blob/main/README.md#_snippet_0

LANGUAGE: Swift
CODE:
```
from: "2.0.0"
```

----------------------------------------

TITLE: Initializing WebSocket Upgrade Handler in Swift NIO
DESCRIPTION: This initializer configures a WebSocket upgrade handler within Swift NIO. It allows setting the maximum frame size, enabling automatic error handling, and providing closures to determine if an upgrade should proceed and how to handle the pipeline after a successful upgrade. It requires `NIOCore` and `NIOHTTP1` for channel and HTTP head types.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_58

LANGUAGE: Swift
CODE:
```
public init(maxFrameSize: Int = 1 << 14, enableAutomaticErrorHandling: Bool = true, shouldUpgrade: @escaping @Sendable (NIOCore.Channel, NIOHTTP1.HTTPRequestHead) -> NIOCore.EventLoopFuture<NIOHTTP1.HTTPHeaders?>, upgradePipelineHandler: @escaping @Sendable (NIOCore.Channel, NIOHTTP1.HTTPRequestHead) -> NIOCore.EventLoopFuture<UpgradeResult>)
```

----------------------------------------

TITLE: Configuring Asynchronous HTTP Server Pipeline in Swift NIO
DESCRIPTION: This function configures a `ChannelPipeline` to negotiate between HTTP/1.1 and HTTP/2 for an asynchronous server. It returns a future that resolves to another future containing the negotiation result, allowing access to the specific HTTP version and its associated output.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_65

LANGUAGE: Swift
CODE:
```
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public func configureAsyncHTTPServerPipeline<HTTP1ConnectionOutput: Sendable, HTTP2ConnectionOutput: Sendable, HTTP2StreamOutput: Sendable>(
    http2Configuration: NIOHTTP2Handler.Configuration = .init(),
    http1ConnectionInitializer: @escaping NIOChannelInitializerWithOutput<HTTP1ConnectionOutput>,
    http2ConnectionInitializer: @escaping NIOChannelInitializerWithOutput<HTTP2ConnectionOutput>,
    http2InboundStreamInitializer: @escaping NIOChannelInitializerWithOutput<HTTP2StreamOutput>
) -> EventLoopFuture<EventLoopFuture<NIONegotiatedHTTPVersion<
        HTTP1ConnectionOutput,
        (HTTP2ConnectionOutput, NIOHTTP2Handler.AsyncStreamMultiplexer<HTTP2StreamOutput>)
    >>>
```

----------------------------------------

TITLE: Performing WebSocket Channel Upgrade in Swift NIO
DESCRIPTION: This function executes the final steps of a WebSocket channel upgrade. It is invoked once the upgrade response has been sent, allowing for safe modification of the channel pipeline to integrate necessary handlers. All incoming data is buffered until the returned `EventLoopFuture` completes successfully, indicating the pipeline is ready.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_60

LANGUAGE: Swift
CODE:
```
public func upgrade(channel: NIOCore.Channel, upgradeRequest: NIOHTTP1.HTTPRequestHead) -> NIOCore.EventLoopFuture<UpgradeResult>
```

----------------------------------------

TITLE: Example Usage of writeLengthPrefixed in Swift
DESCRIPTION: This Swift example demonstrates how to use the `writeLengthPrefixed` method on a `ByteBuffer` instance. It utilizes the `.quic` strategy and provides a closure to write various data types, such as a string and a complex object, allowing the method to calculate and prefix the total length.
SOURCE: https://github.com/apple/swift-nio/blob/main/Sources/NIOCore/Docs.docc/ByteBuffer-lengthPrefix.md#_snippet_1

LANGUAGE: Swift
CODE:
```
myBuffer.writeLengthPrefixed(strategy: .quic) { buffer in
    buffer.writeString("something")
    buffer.writeSomethingComplex(something)
}
```

----------------------------------------

TITLE: Creating Inbound Stream Async Iterator in Swift NIO
DESCRIPTION: This method creates and returns an instance of the `AsyncIterator` for `NIOAsyncChannelInboundStream`. This iterator is essential for consuming elements from the asynchronous sequence, enabling iteration over inbound messages using Swift's `for-await-in` syntax.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_6

LANGUAGE: Swift
CODE:
```
@inlinable public func makeAsyncIterator() -> NIOCore.NIOAsyncChannelInboundStream<Inbound>.AsyncIterator
```

----------------------------------------

TITLE: Running the NIOHTTP1Server Example
DESCRIPTION: This command provides a concrete example of how to execute the `NIOHTTP1Server` project, illustrating the usage of the `swift run` command for a specific SwiftNIO example.
SOURCE: https://github.com/apple/swift-nio/blob/main/README.md#_snippet_4

LANGUAGE: Bash
CODE:
```
swift run NIOHTTP1Server
```

----------------------------------------

TITLE: Defining writeLengthPrefixed API in Swift ByteBuffer
DESCRIPTION: This Swift function signature defines the `writeLengthPrefixed` API for `ByteBuffer`. It allows writing data with a length-prefix where the length is determined by a `writeData` closure, using a specified `NIOBinaryIntegerEncodingStrategy`. It returns the total bytes written, including the length prefix.
SOURCE: https://github.com/apple/swift-nio/blob/main/Sources/NIOCore/Docs.docc/ByteBuffer-lengthPrefix.md#_snippet_0

LANGUAGE: Swift
CODE:
```
public mutating func writeLengthPrefixed<Strategy: NIOBinaryIntegerEncodingStrategy>(
    strategy: Strategy,
    writeData: (_ buffer: inout ByteBuffer) throws -> Int
) rethrows -> Int
```

----------------------------------------

TITLE: Declaring Swift Package Manager Dependency (Up To Next Minor)
DESCRIPTION: This snippet demonstrates how to declare a dependency on a SwiftNIO module using Swift Package Manager, allowing updates up to the next minor version from 0.2.0. This provides flexibility for patch and minor version updates.
SOURCE: https://github.com/apple/swift-nio/blob/main/README.md#_snippet_2

LANGUAGE: Swift
CODE:
```
.upToNextMinor(from: "0.2.0")
```

----------------------------------------

TITLE: Configuring Asynchronous HTTP/2 Pipeline in Swift NIO
DESCRIPTION: This function configures a `ChannelPipeline` to handle HTTP/2, enabling interaction from concurrent code. It's intended for use after HTTP/2 negotiation or when prior knowledge dictates HTTP/2, providing an `AsyncStreamMultiplexer` for managing streams. This operation must be called on the event loop.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_66

LANGUAGE: Swift
CODE:
```
extension ChannelPipeline.SynchronousOperations {
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    public func configureAsyncHTTP2Pipeline<Output: Sendable>(
        mode: NIOHTTP2Handler.ParserMode,
        configuration: NIOHTTP2Handler.Configuration = .init(),
        inboundStreamInitializer: @escaping NIOChannelInitializerWithOutput<Output>
    ) throws -> NIOHTTP2Handler.AsyncStreamMultiplexer<Output>
}
```

----------------------------------------

TITLE: Implementing ALPN Protocol Negotiation with NIOTypedApplicationProtocolNegotiationHandler in Swift
DESCRIPTION: This Swift class, `NIOTypedApplicationProtocolNegotiationHandler`, acts as a `ChannelInboundHandler` to manage channel pipeline changes driven by ALPN negotiation. It buffers incoming data until the ALPN result is processed by a provided closure, then replays the data and removes itself from the pipeline. It also exposes a `protocolNegotiationResult` promise, enabling integration with `NIOAsyncChannel` based bootstraps.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_61

LANGUAGE: Swift
CODE:
```
/// A helper ``ChannelInboundHandler`` that makes it easy to swap channel pipelines
/// based on the result of an ALPN negotiation.
///
/// The standard pattern used by applications that want to use ALPN is to select
/// an application protocol based on the result, optionally falling back to some
/// default protocol. To do this in SwiftNIO requires that the channel pipeline be
/// reconfigured based on the result of the ALPN negotiation. This channel handler
/// encapsulates that logic in a generic form that doesn't depend on the specific
/// TLS implementation in use by using ``TLSUserEvent``
///
/// The user of this channel handler provides a single closure that is called with
/// an ``ALPNResult`` when the ALPN negotiation is complete. Based on that result
/// the user is free to reconfigure the ``ChannelPipeline`` as required, and should
/// return an ``EventLoopFuture`` that will complete when the pipeline is reconfigured.
///
/// Until the ``EventLoopFuture`` completes, this channel handler will buffer inbound
/// data. When the ``EventLoopFuture`` completes, the buffered data will be replayed
/// down the channel. Then, finally, this channel handler will automatically remove
/// itself from the channel pipeline, leaving the pipeline in its final
/// configuration.
///
/// Importantly, this is a typed variant of the ``ApplicationProtocolNegotiationHandler`` and allows the user to
/// specify a type that must be returned from the supplied closure. The result will then be used to succeed the ``NIOTypedApplicationProtocolNegotiationHandler/protocolNegotiationResult``
/// promise. This allows us to construct pipelines that include protocol negotiation handlers and be able to bridge them into ``NIOAsyncChannel``
/// based bootstraps.
final public class NIOTypedApplicationProtocolNegotiationHandler<NegotiationResult> : NIOCore.ChannelInboundHandler, NIOCore.RemovableChannelHandler {

    /// The type of the inbound data which is wrapped in `NIOAny`.
    public typealias InboundIn = Any

    /// The type of the inbound data which will be forwarded to the next `ChannelInboundHandler` in the `ChannelPipeline`.
    public typealias InboundOut = Any

    public var protocolNegotiationResult: NIOCore.EventLoopFuture<NegotiationResult> { get }

    /// Create an `ApplicationProtocolNegotiationHandler` with the given completion
    /// callback.
    ///
    /// - Parameter alpnCompleteHandler: The closure that will fire when ALPN
    ///   negotiation has completed.
    public init(alpnCompleteHandler: @escaping (NIOTLS.ALPNResult, NIOCore.Channel) -> NIOCore.EventLoopFuture<NegotiationResult>)

    /// Create an `ApplicationProtocolNegotiationHandler` with the given completion
    /// callback.
    ///
    /// - Parameter alpnCompleteHandler: The closure that will fire when ALPN
    ///   negotiation has completed.
    public convenience init(alpnCompleteHandler: @escaping (NIOTLS.ALPNResult) -> NIOCore.EventLoopFutureNegotiationResult>)

    /// Called when this `ChannelHandler` is added to the `ChannelPipeline`.
    ///
    /// - Parameters:
    ///   - context: The `ChannelHandlerContext` which this `ChannelHandler` belongs to.
    public func handlerAdded(context: NIOCore.ChannelHandlerContext)

    /// Called when this `ChannelHandler` is removed from the `ChannelPipeline`.
    ///
    /// - Parameters:
    ///   - context: The `ChannelHandlerContext` which this `ChannelHandler` belongs to.
    public func handlerRemoved(context: NIOCore.ChannelHandlerContext)

    /// Called when a user inbound event has been triggered.
    ///
    /// This should call `context.fireUserInboundEventTriggered` to forward the operation to the next `_ChannelInboundHandler` in the `ChannelPipeline` if you want to allow the next handler to also handle the event.
    ///
    /// - Parameters:
    ///   - context: The `ChannelHandlerContext` which this `ChannelHandler` belongs to.
    ///   - event: The event.
    public func userInboundEventTriggered(context: NIOCore.ChannelHandlerContext, event: Any)

    /// Called when some data has been read from the remote peer.
    ///
    /// This should call `context.fireChannelRead` to forward the operation to the next `_ChannelInboundHandler` in the `ChannelPipeline` if you want to allow the next handler to also handle the event.
    ///
    /// - Parameters:
    ///   - context: The `ChannelHandlerContext` which this `ChannelHandler` belongs to.
    ///   - data: The data read from the remote peer, wrapped in a `NIOAny`.
    public func channelRead(context: NIOCore.ChannelHandlerContext, data: NIOCore.NIOAny)

    /// Called when the `Channel` has become inactive and is no longer able to send and receive data.
    ///
    /// This should call `context.fireChannelInactive` to forward the operation to the next `_ChannelInboundHandler` in the `ChannelPipeline` if you want to allow the next handler to also handle the event.
    ///
    /// - Parameters:
```

----------------------------------------

TITLE: Invoking NIOHTTP1Server with Various Binding Options (Bash)
DESCRIPTION: This snippet demonstrates various ways to invoke the NIOHTTP1Server application from the command line. It shows how to bind the server to the default IPv6 loopback address and port 8888, a specified port, a UNIX domain socket, or a specific IP address and port. These commands are used for setting up the server's network listener.
SOURCE: https://github.com/apple/swift-nio/blob/main/Sources/NIOHTTP1Server/README.md#_snippet_0

LANGUAGE: bash
CODE:
```
swift run NIOHTTP1Server  # Binds the server on ::1, port 8888.
swift run NIOHTTP1Server 8988  # Binds the server on ::1, port 8988
swift run NIOHTTP1Server /path/to/unix/socket  # Binds the server using the given UNIX socket
swift run NIOHTTP1Server 192.168.0.5 8988  # Binds the server on 192.168.0.5:8988
```

----------------------------------------

TITLE: Asynchronously Configuring Upgradable HTTP Server Pipeline in Swift
DESCRIPTION: This extension method on `ChannelPipeline` configures an HTTP server pipeline that supports upgrades. It takes a `NIOUpgradableHTTPServerPipelineConfiguration` and returns a nested `EventLoopFuture`. The outer future indicates pipeline configuration completion, while the inner future resolves with the `UpgradeResult` once the upgrade process (or lack thereof) is finalized.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_36

LANGUAGE: Swift
CODE:
```
extension ChannelPipeline {

    /// Configure a `ChannelPipeline` for use as an HTTP server.
    ///
    /// - Parameters:
    ///   - configuration: The HTTP pipeline's configuration.
    /// - Returns: An `EventLoopFuture` that will fire when the pipeline is configured. The future contains an `EventLoopFuture`
    /// that is fired once the pipeline has been upgraded or not and contains the `UpgradeResult`.
    @available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
    public func configureUpgradableHTTPServerPipeline<UpgradeResult>(configuration: NIOHTTP1.NIOUpgradableHTTPServerPipelineConfiguration<UpgradeResult>) -> NIOCore.EventLoopFuture<NIOCore.EventLoopFuture<UpgradeResult>> where UpgradeResult : Sendable
}
```

----------------------------------------

TITLE: Implementing SwiftNIO Typed HTTP Server Upgrade Handler (Swift)
DESCRIPTION: This `ChannelInboundHandler` manages the server-side HTTP upgrade process. It removes itself from the pipeline after the first request, regardless of upgrade success, to prevent issues with pipelined requests. It requires an `HTTPResponseEncoder`, other HTTP-related handlers, and an `upgradeConfiguration` to initialize.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_55

LANGUAGE: Swift
CODE:
```
@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
final public class NIOTypedHTTPServerUpgradeHandler<UpgradeResult> : NIOCore.ChannelInboundHandler, NIOCore.RemovableChannelHandler where UpgradeResult : Sendable {

    /// The type of the inbound data which is wrapped in `NIOAny`.
    public typealias InboundIn = NIOHTTP1.HTTPServerRequestPart

    /// The type of the inbound data which will be forwarded to the next `ChannelInboundHandler` in the `ChannelPipeline`.
    public typealias InboundOut = NIOHTTP1.HTTPServerRequestPart

    /// The type of the outbound data which will be forwarded to the next `ChannelOutboundHandler` in the `ChannelPipeline`.
    public typealias OutboundOut = NIOHTTP1.HTTPServerResponsePart

    /// The upgrade future which will be completed once protocol upgrading has been done.
    public var upgradeResultFuture: NIOCore.EventLoopFuture<UpgradeResult> { get }

    /// Create a ``NIOTypedHTTPServerUpgradeHandler``.
    ///
    /// - Parameters:
    ///   - httpEncoder: The ``HTTPResponseEncoder`` encoding responses from this handler and which will
    ///     be removed from the pipeline once the upgrade response is sent. This is used to ensure
    ///     that the pipeline will be in a clean state after upgrade.
    ///  - extraHTTPHandlers: Any other handlers that are directly related to handling HTTP. At the very least
    ///     this should include the `HTTPDecoder`, but should also include any other handler that cannot tolerate
    ///     receiving non-HTTP data.
    ///  - upgradeConfiguration: The upgrade configuration.
    public init(httpEncoder: NIOHTTP1.HTTPResponseEncoder, extraHTTPHandlers: [NIOCore.RemovableChannelHandler], upgradeConfiguration: NIOHTTP1.NIOTypedHTTPServerUpgradeConfiguration<UpgradeResult>)

    /// Called when this `ChannelHandler` is added to the `ChannelPipeline`.
    ///
    /// - Parameters:
    ///   - context: The `ChannelHandlerContext` which this `ChannelHandler` belongs to.
    public func handlerAdded(context: NIOCore.ChannelHandlerContext)

    /// Called when this `ChannelHandler` is removed from the `ChannelPipeline`.
    ///
    /// - Parameters:
    ///   - context: The `ChannelHandlerContext` which this `ChannelHandler` belongs to.
    public func handlerRemoved(context: NIOCore.ChannelHandlerContext)

    /// Called when some data has been read from the remote peer.
    ///
    /// This should call `context.fireChannelRead` to forward the operation to the next `_ChannelInboundHandler` in the `ChannelPipeline` if you want to allow the next handler to also handle the event.
    ///
    /// - Parameters:
    ///   - context: The `ChannelHandlerContext` which this `ChannelHandler` belongs to.
    ///   - data: The data read from the remote peer, wrapped in a `NIOAny`.
    public func channelRead(context: NIOCore.ChannelHandlerContext, data: NIOCore.NIOAny)
}
```

----------------------------------------

TITLE: Conforming Custom Types to SwiftNIO Protocols
DESCRIPTION: Shows the acceptable practice of conforming a user-defined type (`MyHandler`) to a SwiftNIO protocol (`ChannelHandler`), which is encouraged for integration.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-api.md#_snippet_6

LANGUAGE: Swift
CODE:
```
extension MyHandler: ChannelHandler { ... }
```

----------------------------------------

TITLE: Advancing Inbound Stream Async Iterator in Swift NIO
DESCRIPTION: This method, part of the `AsyncIterator` for `NIOAsyncChannelInboundStream`, asynchronously advances to the next element in the sequence. It returns the next element if available, or `nil` to indicate the end of the sequence, and can throw an error if the stream terminates abnormally.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_5

LANGUAGE: Swift
CODE:
```
@inlinable public mutating func next() async throws -> NIOCore.NIOAsyncChannelInboundStream<Inbound>.Element?
```

----------------------------------------

TITLE: Configuring Typed HTTP Client Upgrade in SwiftNIO
DESCRIPTION: This struct encapsulates the configuration for the `NIOTypedHTTPClientUpgradeHandler`. It includes the initial HTTP request head, an array of potential protocol upgraders, and a completion handler for scenarios where no upgrade occurs. This struct is available on macOS 13+, iOS 16+, tvOS 16+, and watchOS 9+.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_41

LANGUAGE: Swift
CODE:
```
@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
public struct NIOTypedHTTPClientUpgradeConfiguration<UpgradeResult> where UpgradeResult : Sendable {

    /// The initial request head that is sent out once the channel becomes active.
    public var upgradeRequestHead: NIOHTTP1.HTTPRequestHead

    /// The array of potential upgraders.
    public var upgraders: [NIOHTTP1.NIOTypedHTTPClientProtocolUpgrader<UpgradeResult>]

    /// A closure that is run once it is determined that no protocol upgrade is happening. This can be used
    /// to configure handlers that expect HTTP.
    public var notUpgradingCompletionHandler: @Sendable (NIOCore.Channel) -> NIOCore.EventLoopFuture<UpgradeResult>

    public init(upgradeRequestHead: NIOHTTP1.HTTPRequestHead, upgraders: [NIOHTTP1.NIOTypedHTTPClientProtocolUpgrader<UpgradeResult>], notUpgradingCompletionHandler: @escaping @Sendable (NIOCore.Channel) -> NIOCore.EventLoopFuture<UpgradeResult>)
}
```

----------------------------------------

TITLE: Handling WebSocket Upgrade Results in SwiftNIO
DESCRIPTION: This code block shows how to process the `EventLoopFuture<UpgradeResult>` obtained from a dynamic pipeline configuration. It uses a `switch` statement to exhaustively handle the `websocket` case, where the connection is established, and the `notUpgraded` case, indicating the upgrade failed, allowing for distinct post-upgrade logic.
SOURCE: https://github.com/apple/swift-nio/blob/main/Sources/NIOCore/Docs.docc/swift-concurrency.md#_snippet_5

LANGUAGE: Swift
CODE:
```
switch try await upgradeResult.get() {
case .websocket(let websocketChannel):
    print("Handling websocket connection")
    try await self.handleWebsocketChannel(websocketChannel)
    print("Done handling websocket connection")
case .notUpgraded:
    // The upgrade to websocket did not succeed.
    print("Upgrade declined")
}
```

----------------------------------------

TITLE: Binding Datagram Channel to Unix Domain Socket Path in Swift NIO
DESCRIPTION: This function binds a `DatagramChannel` to a Unix domain socket path, with an option to clean up an existing socket file. It requires a channel initializer and returns its result.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_26

LANGUAGE: Swift
CODE:
```
public func bind<Output>(unixDomainSocketPath: String, cleanupExistingSocketFile: Bool = false, channelInitializer: @escaping @Sendable (NIOCore.Channel) -> NIOCore.EventLoopFuture<Output>) async throws -> Output where Output : Sendable
```

----------------------------------------

TITLE: Configuring Upgradable HTTP Server Pipeline in Swift
DESCRIPTION: This struct defines the configuration parameters for an upgradable HTTP server pipeline in SwiftNIO. It includes options for enabling request pipelining assistance, automatic protocol error handling (sending 400 errors), and outbound response header validation. The initializer sets up these features by default, enhancing server robustness.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_35

LANGUAGE: Swift
CODE:
```
/// Configuration for an upgradable HTTP pipeline.
@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
public struct NIOUpgradableHTTPServerPipelineConfiguration<UpgradeResult> where UpgradeResult : Sendable {

    /// Whether to provide assistance handling HTTP clients that pipeline
    /// their requests. Defaults to `true`. If `false`, users will need to handle clients that pipeline themselves.
    public var enablePipelining: Bool

    /// Whether to provide assistance handling protocol errors (e.g. failure to parse the HTTP
    /// request) by sending 400 errors. Defaults to `true`.
    public var enableErrorHandling: Bool

    /// Whether to validate outbound response headers to confirm that they are
    /// spec compliant. Defaults to `true`.
    public var enableResponseHeaderValidation: Bool

    /// The configuration for the ``HTTPResponseEncoder``.
    public var encoderConfiguration: NIOHTTP1.HTTPResponseEncoder.Configuration

    /// The configuration for the ``NIOTypedHTTPServerUpgradeHandler``.
    public var upgradeConfiguration: NIOHTTP1.NIOTypedHTTPServerUpgradeConfiguration<UpgradeResult>

    /// Initializes a new ``NIOUpgradableHTTPServerPipelineConfiguration`` with default values.
    ///
    /// The current defaults provide the following features:
    /// 1. Assistance handling clients that pipeline HTTP requests.
    /// 2. Assistance handling protocol errors.
    /// 3. Outbound header fields validation to protect against response splitting attacks.
    public init(upgradeConfiguration: NIOHTTP1.NIOTypedHTTPServerUpgradeConfiguration<UpgradeResult>)
}
```

----------------------------------------

TITLE: Running NIOChatServer with Various Binding Options (Bash)
DESCRIPTION: This snippet demonstrates how to invoke the NIOChatServer application using the `swift run` command, showcasing different methods for binding the server. It covers default binding (IPv6 loopback, port 9999), specifying a custom port, using a UNIX domain socket, and binding to a specific IPv4 address and port.
SOURCE: https://github.com/apple/swift-nio/blob/main/Sources/NIOChatServer/README.md#_snippet_0

LANGUAGE: bash
CODE:
```
swift run NIOChatServer  # Binds the server on ::1, port 9999.
swift run NIOChatServer 9899  # Binds the server on ::1, port 9899
swift run NIOChatServer /path/to/unix/socket  # Binds the server using the given UNIX socket
swift run NIOChatServer 192.168.0.5 9899  # Binds the server on 192.168.0.5:9899
```

----------------------------------------

TITLE: Defining NIOTypedHTTPServerProtocolUpgrader in Swift
DESCRIPTION: This protocol defines the interface for an object capable of handling HTTP protocol upgrades on a server-side channel. It includes an associated type `UpgradeResult` which must conform to `Sendable`, representing the outcome of a successful upgrade. Implementers of this protocol provide the logic for negotiating and performing the protocol switch.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_49

LANGUAGE: Swift
CODE:
```
public protocol NIOTypedHTTPServerProtocolUpgrader<UpgradeResult> {

    associatedtype UpgradeResult : Sendable
```

----------------------------------------

TITLE: Invoking NIOHTTP1Client via Command Line (Bash)
DESCRIPTION: This snippet demonstrates various ways to invoke the `NIOHTTP1Client` application from the command line. It shows how to connect to a default local server, a specified port, a UNIX socket, or a remote host and port. This client sends a basic HTTP request and waits for a response.
SOURCE: https://github.com/apple/swift-nio/blob/main/Sources/NIOHTTP1Client/README.md#_snippet_0

LANGUAGE: bash
CODE:
```
swift run NIOHTTP1Client  # Connects to a server on ::1, port 8888.
swift run NIOHTTP1Client 9899  # Connects to a server on ::1, port 9899
swift run NIOHTTP1Client /path/to/unix/socket  # Connects to a server using the given UNIX socket
swift run NIOHTTP1Client echo.example.com 9899  # Connects to a server on echo.example.com:9899
```

----------------------------------------

TITLE: Conforming SwiftNIO Types to Standard Library Protocols (Forbidden)
DESCRIPTION: Illustrates an unacceptable attempt to extend a SwiftNIO type (`EventLoopFuture`) to conform to a standard library protocol (`DebugStringConvertible`), which is disallowed by the public API guidelines.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-api.md#_snippet_5

LANGUAGE: Swift
CODE:
```
extension EventLoopFuture: DebugStringConvertible { ... }
```

----------------------------------------

TITLE: Defining NIOTypedWebSocketServerUpgrader in SwiftNIO
DESCRIPTION: This class acts as a `NIOTypedHTTPServerProtocolUpgrader` for WebSocket server connections, managing the upgrade handshake. It allows users to provide a `shouldUpgrade` callback to validate upgrade requests based on HTTP headers. Key initialization parameters include `maxFrameSize` for incoming frames and `automaticErrorHandling` for protocol error management, with the expectation that `HTTPServerUpgradeHandler` handles pipeline mutations.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_57

LANGUAGE: Swift
CODE:
```
/// A `NIOTypedHTTPServerProtocolUpgrader` that knows how to do the WebSocket upgrade dance.
///
/// Users may frequently want to offer multiple websocket endpoints on the same port. For this
/// reason, this `WebServerSocketUpgrader` only knows how to do the required parts of the upgrade and to
/// complete the handshake. Users are expected to provide a callback that examines the HTTP headers
/// (including the path) and determines whether this is a websocket upgrade request that is acceptable
/// to them.
///
/// This upgrader assumes that the `HTTPServerUpgradeHandler` will appropriately mutate the pipeline to
/// remove the HTTP `ChannelHandler`s.
final public class NIOTypedWebSocketServerUpgrader<UpgradeResult> : NIOHTTP1.NIOTypedHTTPServerProtocolUpgrader, Sendable where UpgradeResult : Sendable {

    /// RFC 6455 specs this as the required entry in the Upgrade header.
    public let supportedProtocol: String

    /// We deliberately do not actually set any required headers here, because the websocket
    /// spec annoyingly does not actually force the client to send these in the Upgrade header,
    /// which NIO requires. We check for these manually.
    public let requiredUpgradeHeaders: [String]

    /// Create a new ``NIOTypedWebSocketServerUpgrader``.
    ///
    /// - Parameters:
    ///   - maxFrameSize: The maximum frame size the decoder is willing to tolerate from the
    ///         remote peer. WebSockets in principle allows frame sizes up to `2**64` bytes, but
    ///         this is an objectively unreasonable maximum value (on AMD64 systems it is not
    ///         possible to even. Users may set this to any value up to `UInt32.max`.
    ///   - automaticErrorHandling: Whether the pipeline should automatically handle protocol
    ///         errors by sending error responses and closing the connection. Defaults to `true`,
    ///         may be set to `false` if the user wishes to handle their own errors.
    ///   - shouldUpgrade: A callback that determines whether the websocket request should be
    ///         upgraded. This callback is responsible for creating a `HTTPHeaders` object with
    ///         any headers that it needs on the response *except for* the `Upgrade`, `Connection`,
    ///         and `Sec-WebSocket-Accept` headers, which this upgrader will handle. Should return
    ///         an `EventLoopFuture` containing `nil` if the upgrade should be refused.
    ///   - enableAutomaticErrorHandling: A function that will be called once the upgrade response is
    ///         flushed, and that is expected to mutate the `Channel` appropriately to handle the
```

----------------------------------------

TITLE: Extending SwiftNIO Types with Prefixed Public Methods
DESCRIPTION: Shows an acceptable method of extending a SwiftNIO type (`ByteBuffer`) with a public method that uses a custom prefix (`myProject`), ensuring uniqueness and avoiding API clashes.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-api.md#_snippet_9

LANGUAGE: Swift
CODE:
```
extension ByteBuffer { public mutating func myProjectReadInteger(at: Int) -> Int {...} }
```

----------------------------------------

TITLE: Defining NIOTypedWebSocketClientUpgrader in SwiftNIO
DESCRIPTION: This class serves as a `NIOTypedHTTPClientProtocolUpgrader` for WebSocket client connections, handling the upgrade handshake. It expects `HTTPClientUpgradeHandler` to manage the upgrade request and pipeline mutations. Key parameters for initialization include `requestKey`, `maxFrameSize`, and `enableAutomaticErrorHandling`, along with a `upgradePipelineHandler` closure for post-upgrade channel configuration.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_56

LANGUAGE: Swift
CODE:
```
/// A `NIOTypedHTTPClientProtocolUpgrader` that knows how to do the WebSocket upgrade dance.
///
/// This upgrader assumes that the `HTTPClientUpgradeHandler` will create and send the upgrade request.
/// This upgrader also assumes that the `HTTPClientUpgradeHandler` will appropriately mutate the
/// pipeline to remove the HTTP `ChannelHandler`s.
@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
final public class NIOTypedWebSocketClientUpgrader<UpgradeResult> : NIOHTTP1.NIOTypedHTTPClientProtocolUpgrader where UpgradeResult : Sendable {

    /// RFC 6455 specs this as the required entry in the Upgrade header.
    public let supportedProtocol: String

    /// None of the websocket headers are actually defined as 'required'.
    public let requiredUpgradeHeaders: [String]

    /// - Parameters:
    ///   - requestKey: Sent to the server in the `Sec-WebSocket-Key` HTTP header. Default is random request key.
    ///   - maxFrameSize: Largest incoming `WebSocketFrame` size in bytes. Default is 16,384 bytes.
    ///   - enableAutomaticErrorHandling: If true, adds `WebSocketProtocolErrorHandler` to the channel pipeline to catch and respond to WebSocket protocol errors. Default is true.
    ///   - upgradePipelineHandler: Called once the upgrade was successful.
    public init(requestKey: String = NIOWebSocketClientUpgrader.randomRequestKey(), maxFrameSize: Int = 1 << 14, enableAutomaticErrorHandling: Bool = true, upgradePipelineHandler: @escaping @Sendable (NIOCore.Channel, NIOHTTP1.HTTPResponseHead) -> NIOCore.EventLoopFuture<UpgradeResult>)

    /// Additional headers to be added to the request, beyond the "Upgrade" and "Connection" headers.
    public func addCustom(upgradeRequestHeaders: inout NIOHTTP1.HTTPHeaders)

    /// Gives the receiving upgrader the chance to deny the upgrade based on the upgrade HTTP response.
    public func shouldAllowUpgrade(upgradeResponse: NIOHTTP1.HTTPResponseHead) -> Bool

    /// Called when the upgrade response has been flushed. At this time it is safe to mutate the channel
    /// pipeline to add whatever channel handlers are required.
    /// Until the returned `EventLoopFuture` succeeds, all received data will be buffered.
    public func upgrade(channel: NIOCore.Channel, upgradeResponse: NIOHTTP1.HTTPResponseHead) -> NIOCore.EventLoopFuture<UpgradeResult>
}
```

----------------------------------------

TITLE: Invoking NIOWebSocketServer using Bash
DESCRIPTION: This snippet demonstrates various command-line syntaxes to run the NIOWebSocketServer. It shows how to bind the server to the default localhost:8888, a custom port, a UNIX socket, or a specific IP address and port, providing flexibility for deployment and testing.
SOURCE: https://github.com/apple/swift-nio/blob/main/Sources/NIOWebSocketServer/README.md#_snippet_0

LANGUAGE: Bash
CODE:
```
swift run NIOWebSocketServer  # Binds the server on 'localhost', port 8888.
swift run NIOWebSocketServer 9899  # Binds the server on 'localhost', port 9899
swift run NIOWebSocketServer /path/to/unix/socket  # Binds the server using the given UNIX socket
swift run NIOWebSocketServer 192.168.0.5 9899  # Binds the server on 192.168.0.5:9899
```

----------------------------------------

TITLE: Configuring Upgradable HTTP Client Pipeline in Swift
DESCRIPTION: This extension method on `ChannelPipeline` configures an HTTP client pipeline that supports protocol upgrades. It takes a `NIOUpgradableHTTPClientPipelineConfiguration` and returns a nested `EventLoopFuture`. The outer future signals the completion of pipeline setup, while the inner future provides the `UpgradeResult` after the upgrade attempt (or lack thereof) is resolved.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_38

LANGUAGE: Swift
CODE:
```
extension ChannelPipeline {

    /// Configure a `ChannelPipeline` for use as an HTTP client.
    ///
    /// - Parameters:
    ///   - configuration: The HTTP pipeline's configuration.
    /// - Returns: An `EventLoopFuture` that will fire when the pipeline is configured. The future contains an `EventLoopFuture`
    /// that is fired once the pipeline has been upgraded or not and contains the `UpgradeResult`.
    @available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
    public func configureUpgradableHTTPClientPipeline<UpgradeResult>(configuration: NIOHTTP1.NIOUpgradableHTTPClientPipelineConfiguration<UpgradeResult>) -> NIOCore.EventLoopFuture<NIOCore.EventLoopFuture<UpgradeResult>> where UpgradeResult : Sendable
}
```

----------------------------------------

TITLE: Declaring Swift Package Manager Dependency (NIO 1.0.0)
DESCRIPTION: This snippet shows how to declare a dependency on a SwiftNIO module using Swift Package Manager, specifying a minimum version of 1.0.0. This is common for modules that align with the NIO 1 API.
SOURCE: https://github.com/apple/swift-nio/blob/main/README.md#_snippet_1

LANGUAGE: Swift
CODE:
```
from: "1.0.0"
```

----------------------------------------

TITLE: Configuring Upgradable HTTP Client Pipeline in SwiftNIO
DESCRIPTION: This extension method configures a `ChannelPipeline` for use as an HTTP client with upgrade capabilities. It takes a `NIOUpgradableHTTPClientPipelineConfiguration` and returns an `EventLoopFuture` indicating the upgrade result. This function is available on macOS 13+, iOS 16+, tvOS 16+, and watchOS 9+.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_39

LANGUAGE: Swift
CODE:
```
extension ChannelPipeline.SynchronousOperations {

    /// Configure a `ChannelPipeline` for use as an HTTP client.
    ///
    /// - Parameters:
    ///   - configuration: The HTTP pipeline's configuration.
    /// - Returns: An `EventLoopFuture` that is fired once the pipeline has been upgraded or not and contains the `UpgradeResult`.
    @available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
    public func configureUpgradableHTTPClientPipeline<UpgradeResult>(configuration: NIOHTTP1.NIOUpgradableHTTPClientPipelineConfiguration<UpgradeResult>) throws -> NIOCore.EventLoopFuture<UpgradeResult> where UpgradeResult : Sendable
}
```

----------------------------------------

TITLE: Extending SwiftNIO Types with Custom Return Types
DESCRIPTION: Illustrates an acceptable way to extend a SwiftNIO type (`ByteBuffer`) with a public method that returns a custom type (`MyType`), preventing potential name clashes.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-api.md#_snippet_8

LANGUAGE: Swift
CODE:
```
extension ByteBuffer { public mutating func readMyType(at: Int) -> MyType {...} }
```

----------------------------------------

TITLE: Defining NIONegotiatedHTTPVersion Enum in Swift NIO
DESCRIPTION: This enum serves as a generic container for the result of HTTP protocol negotiation, distinguishing between HTTP/1.1 and HTTP/2. It holds the specific output types for each protocol version, allowing for type-safe handling of the negotiation outcome.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_67

LANGUAGE: Swift
CODE:
```
public enum NIONegotiatedHTTPVersion<HTTP1Output: Sendable, HTTP2Output: Sendable> {
    case http1_1(HTTP1Output)
    case http2(HTTP2Output)
}
```

----------------------------------------

TITLE: Synchronously Configuring Upgradable HTTP Server Pipeline in Swift
DESCRIPTION: This extension method on `ChannelPipeline.SynchronousOperations` provides a synchronous way to configure an upgradable HTTP server pipeline. It accepts a `NIOUpgradableHTTPServerPipelineConfiguration` and returns an `EventLoopFuture` that will contain the `UpgradeResult` once the pipeline has either been upgraded or determined not to upgrade. This method can throw errors during configuration.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_37

LANGUAGE: Swift
CODE:
```
extension ChannelPipeline.SynchronousOperations {

    /// Configure a `ChannelPipeline` for use as an HTTP server.
    ///
    /// - Parameters:
    ///   - configuration: The HTTP pipeline's configuration.
    /// - Returns: An `EventLoopFuture` that is fired once the pipeline has been upgraded or not and contains the `UpgradeResult`.
    @available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
    public func configureUpgradableHTTPServerPipeline<UpgradeResult>(configuration: NIOHTTP1.NIOUpgradableHTTPServerPipelineConfiguration<UpgradeResult>) throws -> NIOCore.EventLoopFuture<UpgradeResult> where UpgradeResult : Sendable
}
```

----------------------------------------

TITLE: Accessing Required Upgrade Headers in Swift HTTP Upgrader
DESCRIPTION: The `requiredUpgradeHeaders` property lists the HTTP header fields that must be present in the client's upgrade request for a successful protocol switch. These headers are validated against the `Connection` header of the inbound request and are provided to the upgrader when it's asked to handle the upgrade.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_51

LANGUAGE: Swift
CODE:
```
var requiredUpgradeHeaders: [String] { get }
```

----------------------------------------

TITLE: Implementing Typed HTTP Client Upgrade Handler in SwiftNIO
DESCRIPTION: This final class acts as a client-side channel handler for performing HTTP upgrades. It manages the handshake, adds necessary headers, and modifies the pipeline upon successful upgrade or removes itself if the upgrade fails. It defines associated types for inbound and outbound data and provides an `upgradeResultFuture`.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_42

LANGUAGE: Swift
CODE:
```
@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
final public class NIOTypedHTTPClientUpgradeHandler<UpgradeResult> : NIOCore.ChannelDuplexHandler, NIOCore.RemovableChannelHandler where UpgradeResult : Sendable {

    /// The type of the outbound data which is wrapped in `NIOAny`.
    public typealias OutboundIn = NIOHTTP1.HTTPClientRequestPart

    /// The type of the outbound data which will be forwarded to the next `ChannelOutboundHandler` in the `ChannelPipeline`.
    public typealias OutboundOut = NIOHTTP1.HTTPClientRequestPart

    /// The type of the inbound data which is wrapped in `NIOAny`.
    public typealias InboundIn = NIOHTTP1.HTTPClientResponsePart

    /// The type of the inbound data which will be forwarded to the next `ChannelInboundHandler` in the `ChannelPipeline`.
    public typealias InboundOut = NIOHTTP1.HTTPClientResponsePart

    /// The upgrade future which will be completed once protocol upgrading has been done.
    public var upgradeResultFuture: NIOCore.EventLoopFuture<UpgradeResult> { get }
}
```

----------------------------------------

TITLE: Defining HTTP Client Protocol Upgrader in SwiftNIO
DESCRIPTION: This protocol defines the interface for an object that handles HTTP upgrade to a specific protocol on a client-side channel. It includes properties for supported protocol and required headers, and methods to add custom headers, determine upgrade allowance, and perform the actual pipeline upgrade.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_40

LANGUAGE: Swift
CODE:
```
public protocol NIOTypedHTTPClientProtocolUpgrader<UpgradeResult> {

    associatedtype UpgradeResult : Sendable

    /// The protocol this upgrader knows how to support.
    var supportedProtocol: String { get }

    /// All the header fields the protocol requires in the request to successfully upgrade.
    /// These header fields will be added to the outbound request's "Connection" header field.
    /// It is the responsibility of the custom headers call to actually add these required headers.
    var requiredUpgradeHeaders: [String] { get }

    /// Additional headers to be added to the request, beyond the "Upgrade" and "Connection" headers.
    func addCustom(upgradeRequestHeaders: inout NIOHTTP1.HTTPHeaders)

    /// Gives the receiving upgrader the chance to deny the upgrade based on the upgrade HTTP response.
    func shouldAllowUpgrade(upgradeResponse: NIOHTTP1.HTTPResponseHead) -> Bool

    /// Called when the upgrade response has been flushed. At this time it is safe to mutate the channel
    /// pipeline to add whatever channel handlers are required.
    /// Until the returned `EventLoopFuture` succeeds, all received data will be buffered.
    func upgrade(channel: NIOCore.Channel, upgradeResponse: NIOHTTP1.HTTPResponseHead) -> NIOCore.EventLoopFuture<Self.UpgradeResult>
}
```

----------------------------------------

TITLE: Conforming SwiftNIO Types to Custom Protocols
DESCRIPTION: Demonstrates the acceptable practice of extending a SwiftNIO type (`EventLoopFuture`) to conform to a protocol (`MyOwnProtocol`) that is defined within the user's own codebase.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-api.md#_snippet_4

LANGUAGE: Swift
CODE:
```
extension EventLoopFuture: MyOwnProtocol { ... }
```

----------------------------------------

TITLE: Accessing Supported Protocol in Swift HTTP Upgrader
DESCRIPTION: The `supportedProtocol` property, part of `NIOTypedHTTPServerProtocolUpgrader`, specifies the string identifier of the protocol that this upgrader is designed to support (e.g., "websocket"). This property is used by the HTTP upgrade handler to match incoming upgrade requests with the appropriate upgrader.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_50

LANGUAGE: Swift
CODE:
```
var supportedProtocol: String { get }
```

----------------------------------------

TITLE: Configuring SwiftNIO Typed HTTP Server Upgrades (Swift)
DESCRIPTION: This struct defines the configuration for a typed HTTP server upgrade. It holds an array of `NIOTypedHTTPServerProtocolUpgrader` instances and a `notUpgradingCompletionHandler` closure, which is executed if no upgrade occurs. This allows for flexible handling of different upgrade protocols and a default path for standard HTTP.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_54

LANGUAGE: Swift
CODE:
```
@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
public struct NIOTypedHTTPServerUpgradeConfiguration<UpgradeResult> where UpgradeResult : Sendable {

    /// The array of potential upgraders.
    public var upgraders: [NIOHTTP1.NIOTypedHTTPServerProtocolUpgrader<UpgradeResult>]

    /// A closure that is run once it is determined that no protocol upgrade is happening. This can be used
    /// to configure handlers that expect HTTP.
    public var notUpgradingCompletionHandler: @Sendable (NIOCore.Channel) -> NIOCore.EventLoopFuture<UpgradeResult>

    public init(upgraders: [NIOHTTP1.NIOTypedHTTPServerProtocolUpgrader<UpgradeResult>], notUpgradingCompletionHandler: @escaping @Sendable (NIOCore.Channel) -> NIOCore.EventLoopFuture<UpgradeResult>)
}
```

----------------------------------------

TITLE: Binding Datagram Channel to Host and Port in Swift NIO
DESCRIPTION: This function binds a `DatagramChannel` to a specified host and port. It requires a channel initializer and returns its output.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_24

LANGUAGE: Swift
CODE:
```
public func bind<Output>(host: String, port: Int, channelInitializer: @escaping @Sendable (NIOCore.Channel) -> NIOCore.EventLoopFuture<Output>) async throws -> Output where Output : Sendable
```

----------------------------------------

TITLE: Configuring Upgradable HTTP Client Pipeline in Swift
DESCRIPTION: This struct defines the configuration parameters for an upgradable HTTP client pipeline in SwiftNIO. It allows specifying strategies for handling leftover bytes, enabling outbound header validation, and configuring the HTTP request encoder and client upgrade handler. The `init` method provides default settings, including protection against response splitting attacks.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_34

LANGUAGE: Swift
CODE:
```
/// Configuration for an upgradable HTTP pipeline.
@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
public struct NIOUpgradableHTTPClientPipelineConfiguration<UpgradeResult> where UpgradeResult : Sendable {

    /// The strategy to use when dealing with leftover bytes after removing the ``HTTPDecoder`` from the pipeline.
    public var leftOverBytesStrategy: NIOHTTP1.RemoveAfterUpgradeStrategy

    /// Whether to validate outbound response headers to confirm that they are
    /// spec compliant. Defaults to `true`.
    public var enableOutboundHeaderValidation: Bool

    /// The configuration for the ``HTTPRequestEncoder``.
    public var encoderConfiguration: NIOHTTP1.HTTPRequestEncoder.Configuration

    /// The configuration for the ``NIOTypedHTTPClientUpgradeHandler``.
    public var upgradeConfiguration: NIOHTTP1.NIOTypedHTTPClientUpgradeConfiguration<UpgradeResult>

    /// Initializes a new ``NIOUpgradableHTTPClientPipelineConfiguration`` with default values.
    ///
    /// The current defaults provide the following features:
    /// 1. Outbound header fields validation to protect against response splitting attacks.
    public init(upgradeConfiguration: NIOHTTP1.NIOTypedHTTPClientUpgradeConfiguration<UpgradeResult>)
}
```

----------------------------------------

TITLE: Connecting DatagramChannel to Host and Port (SwiftNIO)
DESCRIPTION: Connects a `DatagramChannel` to a specified host and port. The `channelInitializer` closure configures the channel, and its return value is propagated. This method is asynchronous and can throw errors.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_27

LANGUAGE: Swift
CODE:
```
public func connect<Output>(host: String, port: Int, channelInitializer: @escaping @Sendable (NIOCore.Channel) -> NIOCore.EventLoopFuture<Output>) async throws -> Output where Output : Sendable
```

----------------------------------------

TITLE: Creating PipeChannel from Single File Descriptor (SwiftNIO)
DESCRIPTION: Creates a `PipeChannel` using a single Unix file descriptor for both input and output. SwiftNIO takes ownership of the descriptor upon success, closing it when the channel becomes inactive. Users must not close it manually if successful.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_30

LANGUAGE: Swift
CODE:
```
public func takingOwnershipOfDescriptor<Output>(inputOutput: CInt, channelInitializer: @escaping @Sendable (NIOCore.Channel) -> NIOCore.EventLoopFuture<Output>) async throws -> Output where Output : Sendable
```

----------------------------------------

TITLE: Running NIOUDPEchoServer with various binding options
DESCRIPTION: These commands demonstrate how to run the NIOUDPEchoServer, allowing it to bind to different addresses and ports. Options include default binding to ::1:9999, custom port on ::1, a specified UNIX domain socket path, or a specific IP address and port combination. This flexibility allows the server to be deployed in various network configurations.
SOURCE: https://github.com/apple/swift-nio/blob/main/Sources/NIOUDPEchoServer/README.md#_snippet_0

LANGUAGE: bash
CODE:
```
swift run NIOUDPEchoServer  # Binds the server on ::1, port 9999.
swift run NIOUDPEchoServer 9899  # Binds the server on ::1, port 9899
swift run NIOUDPEchoServer /path/to/unix/socket  # Binds the server using the given UNIX socket
swift run NIOUDPEchoServer 192.168.0.5 9899  # Binds the server on 192.168.0.5:9899
```

----------------------------------------

TITLE: Invoking NIOHTTP1Server to Serve Static Files (Bash)
DESCRIPTION: This command demonstrates how to start the NIOHTTP1Server to serve static files from a specified directory. It binds the server to `localhost` on port `80` and configures it to serve content from the `/var/www` directory. This is useful for setting up a local web server for development or testing static assets.
SOURCE: https://github.com/apple/swift-nio/blob/main/Sources/NIOHTTP1Server/README.md#_snippet_1

LANGUAGE: bash
CODE:
```
swift run NIOHTTP1Server localhost 80 /var/www
```

----------------------------------------

TITLE: Running NIOUDPEchoClient with various arguments (Bash)
DESCRIPTION: This snippet demonstrates how to invoke the NIOUDPEchoClient application from the command line using `swift run`. It shows different argument combinations for specifying the server's IP address/hostname, server UDP port, and the client's listening UDP port. The default connection is to `::1` on port `9999` with the client listening on `8888`.
SOURCE: https://github.com/apple/swift-nio/blob/main/Sources/NIOUDPEchoClient/README.md#_snippet_0

LANGUAGE: Bash
CODE:
```
swift run NIOUDPEchoClient # Connects to a server on ::1, server UDP port 9999 and listening port 8888.
swift run NIOUDPEchoClient 9899 9888 # Connects to a server on ::1, server UDP port 9899 and listening port 9888
swift run NIOUDPEchoClient echo.example.com 9899 9888 # Connects to a server on echo.example.com:9899 and listens on UDP port 9888
```

----------------------------------------

TITLE: Binding Unix Domain Socket with Back Pressure Strategy in Swift NIO
DESCRIPTION: This function binds a server socket channel to a Unix domain socket path. It allows specifying a back pressure strategy and a child channel initializer. It returns the result of the channel initializer.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_21

LANGUAGE: Swift
CODE:
```
public func bind<Output>(unixDomainSocketPath: String, cleanupExistingSocketFile: Bool = false, serverBackPressureStrategy: NIOCore.NIOAsyncSequenceProducerBackPressureStrategies.HighLowWatermark? = nil, childChannelInitializer: @escaping @Sendable (NIOCore.Channel) -> NIOCore.EventLoopFuture<Output>) async throws -> NIOCore.NIOAsyncChannel<Output, Never> where Output : Sendable
```

----------------------------------------

TITLE: Initializing NIOTypedHTTPClientUpgradeHandler in Swift
DESCRIPTION: This initializer creates a new instance of `NIOTypedHTTPClientUpgradeHandler`. It requires a list of `httpHandlers` to be removed from the pipeline post-upgrade, ensuring a clean state, and an `upgradeConfiguration` specifying the upgrade details. This setup is crucial for managing the channel's state during and after an HTTP protocol upgrade.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_43

LANGUAGE: Swift
CODE:
```
public init(httpHandlers: [NIOCore.RemovableChannelHandler], upgradeConfiguration: NIOHTTP1.NIOTypedHTTPClientUpgradeConfiguration<UpgradeResult>)
```

----------------------------------------

TITLE: Running the NIOTCPEchoServer Application (Bash)
DESCRIPTION: This command executes the NIOTCPEchoServer application, starting the TCP server. It uses the Swift Package Manager's `run` command to build and launch the executable from the project's root directory, making the server ready to accept client connections.
SOURCE: https://github.com/apple/swift-nio/blob/main/Sources/NIOTCPEchoServer/README.md#_snippet_0

LANGUAGE: Bash
CODE:
```
swift run NIOTCPEchoServer
```

----------------------------------------

TITLE: Connecting to Unix Domain Socket with SwiftNIO ClientBootstrap
DESCRIPTION: Connects a `ClientBootstrap` to a specified Unix Domain Socket path to establish a UDS `Channel`. It requires the `unixDomainSocketPath` and a `channelInitializer` closure, which configures the channel and whose return value is propagated. This method is available on macOS 10.15+, iOS 13+, tvOS 13+, and watchOS 6+.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_17

LANGUAGE: swift
CODE:
```
@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
    public func connect<Output>(unixDomainSocketPath: String, channelInitializer: @escaping @Sendable (NIOCore.Channel) -> NIOCore.EventLoopFuture<Output>) async throws -> Output where Output : Sendable
```

----------------------------------------

TITLE: Performing Protocol Upgrade in Swift HTTP Upgrader
DESCRIPTION: The `upgrade` function is invoked after the 101 Switching Protocols response has been successfully flushed to the client. At this point, it is safe to modify the `ChannelPipeline` by adding or removing handlers specific to the newly upgraded protocol. All incoming data will be buffered until the returned `EventLoopFuture` completes, signifying the pipeline is ready.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_53

LANGUAGE: Swift
CODE:
```
func upgrade(channel: NIOCore.Channel, upgradeRequest: NIOHTTP1.HTTPRequestHead) -> NIOCore.EventLoopFuture<Self.UpgradeResult>
```

----------------------------------------

TITLE: Running the NIOTCPEchoClient
DESCRIPTION: Executes the NIOTCPEchoClient application from the root of the repository using the Swift Package Manager's run command. This client interacts with a TCP echo server and should only be run after the `NIOTCPEchoServer` is active.
SOURCE: https://github.com/apple/swift-nio/blob/main/Sources/NIOTCPEchoClient/README.md#_snippet_0

LANGUAGE: bash
CODE:
```
swift run NIOTCPEchoClient
```

----------------------------------------

TITLE: Installing SwiftNIO Prerequisites on Fedora 28+
DESCRIPTION: This command installs the required packages for SwiftNIO development and integration tests on Fedora 28 and newer. It includes the Swift language package (swift-lang) and utilities like netcat, lsof, and shasum.
SOURCE: https://github.com/apple/swift-nio/blob/main/README.md#_snippet_10

LANGUAGE: bash
CODE:
```
dnf install swift-lang /usr/bin/nc /usr/bin/lsof /usr/bin/shasum
```

----------------------------------------

TITLE: Accessing Underscored SwiftNIO Properties (Forbidden)
DESCRIPTION: Illustrates an unacceptable use case where an internal, underscored property (`_channelCore`) of a SwiftNIO `Channel` is accessed. This violates the public API guidelines.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-api.md#_snippet_1

LANGUAGE: Swift
CODE:
```
channel._channelCore.flush0()
```

----------------------------------------

TITLE: Building Upgrade Response in Swift HTTP Upgrader
DESCRIPTION: The `buildUpgradeResponse` function is responsible for constructing the HTTP headers for the 101 Switching Protocols response. It takes the channel, the upgrade request, and initial response headers as input. If the upgrade cannot proceed, this function should return a failed `EventLoopFuture`, indicating the inability to switch protocols.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_52

LANGUAGE: Swift
CODE:
```
func buildUpgradeResponse(channel: NIOCore.Channel, upgradeRequest: NIOHTTP1.HTTPRequestHead, initialResponseHeaders: NIOHTTP1.HTTPHeaders) -> NIOCore.EventLoopFuture<NIOHTTP1.HTTPHeaders>
```

----------------------------------------

TITLE: Conforming Standard Library Types to SwiftNIO Protocols (Forbidden)
DESCRIPTION: Demonstrates an unacceptable attempt to conform a standard library type (`Array`) to a SwiftNIO protocol (`EventLoopGroup`), as this is not allowed by the public API rules.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-api.md#_snippet_7

LANGUAGE: Swift
CODE:
```
extension Array: EventLoopGroup where Element: EventLoop { ... }
```

----------------------------------------

TITLE: Extending SwiftNIO Types with Standard Library Return Types (Forbidden)
DESCRIPTION: Highlights an unacceptable attempt to extend a SwiftNIO type (`ByteBuffer`) with a public method that returns a standard library type (`Bool`), as this can lead to API clashes.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-api.md#_snippet_11

LANGUAGE: Swift
CODE:
```
extension ByteBuffer { public mutating func readBool(at: Int) -> Bool {...} }
```

----------------------------------------

TITLE: Installing SwiftNIO Prerequisites on Ubuntu 18.04
DESCRIPTION: This command installs necessary dependencies for compiling and running SwiftNIO and its integration tests on Ubuntu 18.04. It includes tools like git, curl, and libraries required for SwiftNIO, along with netcat-openbsd, lsof, and perl for testing.
SOURCE: https://github.com/apple/swift-nio/blob/main/README.md#_snippet_9

LANGUAGE: bash
CODE:
```
# install swift tarball from https://swift.org/downloads
apt-get install -y git curl libatomic1 libxml2 netcat-openbsd lsof perl
```

----------------------------------------

TITLE: Defining writeInteger with Reserved Capacity in Swift
DESCRIPTION: This Swift function signature defines an optional method for the `NIOBinaryIntegerEncodingStrategy` protocol. It allows encoding an integer into a `ByteBuffer` while considering a pre-reserved capacity, potentially enabling more efficient or fixed-size encodings for certain strategies like QUIC, and returns the number of bytes used.
SOURCE: https://github.com/apple/swift-nio/blob/main/Sources/NIOCore/Docs.docc/ByteBuffer-lengthPrefix.md#_snippet_2

LANGUAGE: Swift
CODE:
```
func writeInteger(
    _ integer: Int,
    reservedCapacity: Int,
    to buffer: inout ByteBuffer
) -> Int
```

----------------------------------------

TITLE: Connecting DatagramChannel to UNIX Domain Socket (SwiftNIO)
DESCRIPTION: Establishes a connection for a `DatagramChannel` to a specified UNIX Domain Socket path. The path must not exist prior to connection, as the system will create it. The `channelInitializer` configures the channel.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_29

LANGUAGE: Swift
CODE:
```
public func connect<Output>(unixDomainSocketPath: String, channelInitializer: @escaping @Sendable (NIOCore.Channel) -> NIOCore.EventLoopFuture<Output>) async throws -> Output where Output : Sendable
```

----------------------------------------

TITLE: Importing Non-NIO Prefixed Modules (Forbidden)
DESCRIPTION: Shows an unacceptable attempt to import a module (`CNIOAtomics`) whose name does not start with `NIO`, indicating it's not part of the public API.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-api.md#_snippet_2

LANGUAGE: Swift
CODE:
```
import CNIOAtomics
```

----------------------------------------

TITLE: Using Existing Bound Socket File Descriptor for Datagram Channel in Swift NIO
DESCRIPTION: This function allows using an already bound Unix file descriptor for a `DatagramChannel`. It takes a channel initializer and returns its result.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_23

LANGUAGE: Swift
CODE:
```
public func withBoundSocket<Output>(_ socket: NIOCore.NIOBSDSocket.Handle, channelInitializer: @escaping @Sendable (NIOCore.Channel) -> NIOCore.EventLoopFuture<Output>) async throws -> Output where Output : Sendable
```

----------------------------------------

TITLE: Using Existing Connected Socket with SwiftNIO ClientBootstrap
DESCRIPTION: Initializes a `ClientBootstrap` channel using an already connected Unix file descriptor. It takes the `socket` handle and a `channelInitializer` closure, which configures the channel and whose return value is propagated. This method is available on macOS 10.15+, iOS 13+, tvOS 13+, and watchOS 6+.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_18

LANGUAGE: swift
CODE:
```
@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
    public func withConnectedSocket<Output>(_ socket: NIOCore.NIOBSDSocket.Handle, channelInitializer: @escaping @Sendable (NIOCore.Channel) -> NIOCore.EventLoopFuture<Output>) async throws -> Output where Output : Sendable
```

----------------------------------------

TITLE: Binding Existing Socket File Descriptor with Back Pressure in Swift NIO
DESCRIPTION: This function binds a server socket channel using an existing Unix file descriptor. It supports a back pressure strategy and a child channel initializer, returning the result of the initializer.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_22

LANGUAGE: Swift
CODE:
```
public func bind<Output>(_ socket: NIOCore.NIOBSDSocket.Handle, cleanupExistingSocketFile: Bool = false, serverBackPressureStrategy: NIOCore.NIOAsyncSequenceProducerBackPressureStrategies.HighLowWatermark? = nil, childChannelInitializer: @escaping @Sendable (NIOCore.Channel) -> NIOCore.EventLoopFuture<Output>) async throws -> NIOCore.NIOAsyncChannel<Output, Never> where Output : Sendable
```

----------------------------------------

TITLE: Using Underscored Initializer Arguments (Forbidden)
DESCRIPTION: Highlights an unacceptable use of a SwiftNIO `ByteBuffer` initializer where the first argument (`_enableSuperSpecialAllocationMode`) is underscored, violating public API rules.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-api.md#_snippet_3

LANGUAGE: Swift
CODE:
```
ByteBuffer(_enableSuperSpecialAllocationMode: true)
```

----------------------------------------

TITLE: Creating PipeChannel from Separate File Descriptors (SwiftNIO)
DESCRIPTION: Creates a `PipeChannel` using distinct input and output Unix file descriptors. SwiftNIO assumes ownership of both descriptors on success, closing them when the channel becomes inactive. Users are responsible for closing them only if the method fails.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_31

LANGUAGE: Swift
CODE:
```
public func takingOwnershipOfDescriptors<Output>(input: CInt, output: CInt, channelInitializer: @escaping @Sendable (NIOCore.Channel) -> NIOCore.EventLoopFuture<Output>) async throws -> Output where Output : Sendable
```

----------------------------------------

TITLE: Extending SwiftNIO Types with Internal Methods
DESCRIPTION: Demonstrates that extending a SwiftNIO type (`ByteBuffer`) with `internal` or `private` methods is always acceptable, regardless of argument or return types, as they don't expose public API.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-api.md#_snippet_10

LANGUAGE: Swift
CODE:
```
extension ByteBuffer { internal mutating func readFloat(at: Int) -> Float {...} }
```

----------------------------------------

TITLE: Diffing Malloc Aggregation Outputs with stackdiff-dtrace.py
DESCRIPTION: This command shows how to use the `stackdiff-dtrace.py` Python script to compare two outputs generated by `malloc-aggregation.d`. It helps identify differences in allocation patterns between two test runs by highlighting stacks that are unique to each run or have changed in allocation count.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/debugging-allocations.md#_snippet_14

LANGUAGE: bash
CODE:
```
~/path/to/swift-nio/dev/stackdiff-dtrace.py stack_aggregation.old stack_aggregation.new
```

----------------------------------------

TITLE: Building WebSocket Upgrade Response Headers in Swift NIO
DESCRIPTION: This function is responsible for constructing the HTTP headers required for the 101 Switching Protocols response during a WebSocket upgrade. It takes the channel, the upgrade request, and initial response headers as input, returning an `EventLoopFuture` containing the final HTTP headers. A failed future indicates the upgrade cannot proceed.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md#_snippet_59

LANGUAGE: Swift
CODE:
```
public func buildUpgradeResponse(channel: NIOCore.Channel, upgradeRequest: NIOHTTP1.HTTPRequestHead, initialResponseHeaders: NIOHTTP1.HTTPHeaders) -> NIOCore.EventLoopFuture<NIOHTTP1.HTTPHeaders>
```

----------------------------------------

TITLE: Comparing Instruction Counts for Performance Changes with perf stat (Linux)
DESCRIPTION: These commands use `perf stat` to specifically measure and compare the number of CPU instructions executed before and after a code change. This helps confirm if performance improvements or regressions are correlated with a reduction or increase in instruction counts, providing a quantitative metric for optimization.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/advanced-performance-analysis.md#_snippet_1

LANGUAGE: Bash
CODE:
```
perf stat -e instructions -- ./benchmark-before-change
```

LANGUAGE: Bash
CODE:
```
perf stat -e instructions -- ./benchmark-after-change
```

----------------------------------------

TITLE: Detailed Memory Allocation Stack (Before) in Swift-NIO
DESCRIPTION: This detailed stack trace, also from the 'before' state, shows 11,000 memory allocations. It provides a deeper call chain, including `ChannelOptions.Storage.applyAllChannelOptions`, `ServerBootstrap.bind0`, and `EventLoop.submit`, indicating allocations related to channel setup and event loop operations in Swift-NIO. This trace helps pinpoint the exact origin of memory allocations.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/debugging-allocations.md#_snippet_16

LANGUAGE: Swift
CODE:
```
	11000
		libsystem_malloc.dylib`malloc
		libswiftCore.dylib`swift_slowAlloc+0x19
		libswiftCore.dylib`swift_allocObject+0x27
		test_1_reqs_1000_conn`$s3NIO7Channel_pxq_q0_r1_lyypypAA15EventLoopFutureCyytGIsegnnr_Iegnr_AaB_pypypAEIegnno_Ieggo_TR+0x54
		test_1_reqs_1000_conn`$s3NIO7Channel_pypypAA15EventLoopFutureCyytGIegnno_Ieggo_AaB_pxq_q0_r1_lyypypAEIsegnnr_Iegnr_TR+0x20
		test_1_reqs_1000_conn`$s3NIO7Channel_pypypAA15EventLoopFutureCyytGIegnno_Ieggo_AaB_pxq_q0_r1_lyypypAEIsegnnr_Iegnr_TRTA+0x11
		test_1_reqs_1000_conn`$s3NIO7Channel_pypypAA15EventLoopFutureCyytGIegnno_Ieggo_AaB_pxq_q0_r1_lyypypAEIsegnnr_Iegnr_TRTA.33+0x9
		test_1_reqs_1000_conn`$s3NIO7Channel_pxq_q0_r1_lyypypAA15EventLoopFutureCyytGIsegnnr_Iegnr_AaB_pypypAEIegnno_Ieggo_TR+0x2e
		test_1_reqs_1000_conn`specialized applyNext #1 () in ChannelOptions.Storage.applyAllChannelOptions(to:)+0x1a9
		test_1_reqs_1000_conn`closure #2 in ServerBootstrap.bind0(makeServerChannel:_:)+0xf8
		test_1_reqs_1000_conn`partial apply for closure #2 in ServerBootstrap.bind0(makeServerChannel:_:)+0x39
		test_1_reqs_1000_conn`partial apply for thunk for @escaping @callee_guaranteed () -> (@owned EventLoopFuture<Channel>, @error @owned Error)+0x14
		test_1_reqs_1000_conn`thunk for @escaping @callee_guaranteed () -> (@owned EventLoopFuture<Channel>, @error @owned Error)partial apply+0x9
		test_1_reqs_1000_conn`closure #1 in EventLoop.submit<A>(_:)+0x3c
		test_1_reqs_1000_conn`partial apply for thunk for @escaping @callee_guaranteed () -> ()+0x11
		test_1_reqs_1000_conn`partial apply for thunk for @escaping @callee_guaranteed () -> (@out ())+0x11
		test_1_reqs_1000_conn`partial apply for closure #3 in SelectableEventLoop.run()+0x11
		test_1_reqs_1000_conn`thunk for @callee_guaranteed () -> (@error @owned Error)+0xc
		test_1_reqs_1000_conn`partial apply for thunk for @callee_guaranteed () -> (@error @owned Error)+0x11
		test_1_reqs_1000_conn`thunk for @callee_guaranteed () -> (@error @owned Error)partial apply+0x9
```

----------------------------------------

TITLE: Running Basic Performance Statistics with perf stat (Linux)
DESCRIPTION: This command executes a benchmark program and collects general performance statistics using `perf stat` on Linux. It provides an overview of CPU utilization, context switches, page faults, cycles, instructions, and branch predictions, useful for initial performance assessment.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/advanced-performance-analysis.md#_snippet_0

LANGUAGE: Bash
CODE:
```
perf stat -- ./benchmark arguments
```

----------------------------------------

TITLE: Running malloc-aggregation.d DTrace Script (macOS)
DESCRIPTION: This snippet demonstrates how to execute the `malloc-aggregation.d` DTrace script on macOS to aggregate memory allocations by stack trace. It requires superuser privileges and targets a specific SwiftNIO test binary for analysis, providing insights into where allocations occur.
SOURCE: https://github.com/apple/swift-nio/blob/main/docs/debugging-allocations.md#_snippet_13

LANGUAGE: bash
CODE:
```
sudo ~/path/to/swift-nio/dev/malloc-aggregation.d -c .build/release/test_future_lots_of_callbacks
```