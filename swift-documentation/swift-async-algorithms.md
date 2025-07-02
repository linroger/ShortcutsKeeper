TITLE: Validate AsyncSequence Merge Operation
DESCRIPTION: This example illustrates how the `validate` function can be used to test operations involving multiple `AsyncSequence` inputs, such as `merge`. It defines two input sequences ("a-c--f-|" and "-b-de-g|") and then specifies the expected merged output ("abcdefg|"). This approach ensures deterministic testing of concurrent operations, overcoming the stochastic nature often associated with testing `merge`.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncSequenceValidation/AsyncSequenceValidation.docc/Validation.md#_snippet_1

LANGUAGE: Swift
CODE:
```
validate {
  "a-c--f-|"
  "-b-de-g|"
  merge($0.inputs[0], $0.inputs[1])
  "abcdefg|"
}
```

----------------------------------------

TITLE: Example Usage of AsyncSequence Validation Diagram
DESCRIPTION: This Swift code demonstrates how to use the `validate` method with a diagram. It defines an input sequence, applies an asynchronous `map` operation to capitalize items, and specifies the expected output sequence, illustrating deterministic testing of asynchronous transformations.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncSequenceValidation/AsyncSequenceValidation.docc/Validation.md#_snippet_5

LANGUAGE: swift
CODE:
```
validate {
  "a--b--c---|"
  $0.inputs[0].map { item in await Task { item.capitalized }.value }
  "A--B--C---|"
}
```

----------------------------------------

TITLE: Add Swift Async Algorithms as a SwiftPM Dependency
DESCRIPTION: Instructions for adding the Swift Async Algorithms library as a dependency in a Swift Package Manager project by modifying the `Package.swift` file to include the package URL and specifying the product as a target dependency.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/README.md#_snippet_12

LANGUAGE: Swift
CODE:
```
.package(url: "https://github.com/apple/swift-async-algorithms", from: "1.0.0"),
```

LANGUAGE: Swift
CODE:
```
.target(name: "<target>", dependencies: [
    .product(name: "AsyncAlgorithms", package: "swift-async-algorithms")
]),
```

----------------------------------------

TITLE: Combine Async Sequences: combineLatest(_:...)
DESCRIPTION: The `combineLatest` algorithm merges two or more asynchronous sequences into a new asynchronous sequence. The resulting sequence emits a tuple of the latest elements from each base sequence whenever any of the base sequences produce a new value. This is ideal for scenarios where you need to react to changes in multiple independent data sources simultaneously.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/README.md#_snippet_1

LANGUAGE: APIDOC
CODE:
```
combineLatest(_:...)
  description: Combines two or more asynchronous sequences into an asynchronous sequence producing a tuple of elements from those base asynchronous sequences that updates when any of the base sequences produce a value.
```

----------------------------------------

TITLE: Initialize Swift Collections from Asynchronous Sequences
DESCRIPTION: API documentation for various initializers that allow populating standard Swift collections (like RangeReplaceableCollection, Dictionary, and SetAlgebra) directly from asynchronous sequences, including options for handling duplicate keys in dictionaries.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/README.md#_snippet_11

LANGUAGE: APIDOC
CODE:
```
RangeReplaceableCollection.init(_:): Creates a new instance of a collection containing the elements of an asynchronous sequence.
Dictionary.init(uniqueKeysWithValues:): Creates a new dictionary from the key-value pairs in the given asynchronous sequence.
Dictionary.init(_:uniquingKeysWith:): Creates a new dictionary from the key-value pairs in the given asynchronous sequence, using a combining closure to determine the value for any duplicate keys.
Dictionary.init(grouping:by:): Creates a new dictionary whose keys are the groupings returned by the given closure and whose values are arrays of the elements that returned each key.
SetAlgebra.init(_:): Creates a new set from an asynchronous sequence of items.
```

----------------------------------------

TITLE: Convert Synchronous Sequences to Asynchronous in Swift
DESCRIPTION: Demonstrates how to convert a standard Swift `Sequence` (like an Array or String) into an `AsyncSequence` using the `.async` property, enabling asynchronous operations on synchronous data sources.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/0009-async.md#_snippet_0

LANGUAGE: Swift
CODE:
```
let numbers = [1, 2, 3, 4].async
let characters = "abcde".async
```

----------------------------------------

TITLE: Example: Using AsyncChannel for Inter-Task Communication
DESCRIPTION: Demonstrates how to use `AsyncChannel` to facilitate communication between two concurrent tasks. One task produces values (e.g., results of a long calculation) and sends them via `channel.send()`, while another task consumes these values using a `for await` loop. The `send()` call suspends until the value is consumed, providing back pressure.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Channel.md#_snippet_1

LANGUAGE: swift
CODE:
```
let channel = AsyncChannel<String>()
Task {
  while let resultOfLongCalculation = doLongCalculations() {
    await channel.send(resultOfLongCalculation)
  }
  channel.finish()
}

for await calculationResult in channel {
  print(calculationResult)
}
```

----------------------------------------

TITLE: Swift AsyncChannel Producer-Consumer Example
DESCRIPTION: Illustrates a common pattern for `AsyncChannel` usage, where a `Task` produces values (e.g., long calculations) and sends them via `channel.send(_:)`, while a `for await` loop consumes them. This example demonstrates how `send(_:)` suspends until consumption, providing back pressure.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/NNNN-channel.md#_snippet_1

LANGUAGE: Swift
CODE:
```
let channel = AsyncChannel<String>()
Task {
  while let resultOfLongCalculation = doLongCalculations() {
    await channel.send(resultOfLongCalculation)
  }
  channel.finish()
}

for await calculationResult in channel {
  print(calculationResult)
}
```

----------------------------------------

TITLE: Manage Time-Based Asynchronous Sequences in Swift
DESCRIPTION: Documentation for asynchronous sequence operations that handle time-based events, such as debouncing to emit values after a quiescence period, throttling to ensure minimum intervals, and using AsyncTimerSequence for repeated timed emissions.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/README.md#_snippet_10

LANGUAGE: APIDOC
CODE:
```
debounce(for:tolerance:clock:): Emit values after a quiescence period has been reached.
throttle(for:clock:reducing:): Ensure a minimum interval has elapsed between events.
AsyncTimerSequence: Emit the value of now at a given interval repeatedly.
```

----------------------------------------

TITLE: Create Async Sequence: AsyncChannel
DESCRIPTION: The `AsyncChannel` provides an asynchronous sequence with built-in back pressure sending semantics. It acts as a communication channel between producers and consumers of asynchronous data, ensuring that the producer does not overwhelm the consumer. This is crucial for managing resource usage and preventing buffer overflows in concurrent systems.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/README.md#_snippet_6

LANGUAGE: APIDOC
CODE:
```
AsyncChannel
  description: An asynchronous sequence with back pressure sending semantics.
```

----------------------------------------

TITLE: Extend XCTestCase for AsyncSequence Validation
DESCRIPTION: This Swift extension adds `validate` methods to `XCTestCase`, enabling the testing of `AsyncSequence` behavior using a diagram-based syntax. It supports optional themes for validation tests and provides file/line context for test failures.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncSequenceValidation/AsyncSequenceValidation.docc/Validation.md#_snippet_4

LANGUAGE: swift
CODE:
```
extension XCTestCase {
  public func validate<Test: AsyncSequenceValidationTest, Theme: AsyncSequenceValidationTheme>(theme: Theme, @AsyncSequenceValidationDiagram _ build: (inout AsyncSequenceValidationDiagram) -> Test, file: StaticString = #file, line: UInt = #line)

  public func validate<Test: AsyncSequenceValidationTest>(@AsyncSequenceValidationDiagram _ build: (inout AsyncSequenceValidationDiagram) -> Test, file: StaticString = #file, line: UInt = #line)
}
```

----------------------------------------

TITLE: Swift Chunking Bytes by Count and Timer Example
DESCRIPTION: Illustrates how to use the `chunks` method to group byte data into `Data` instances, emitting a chunk when either 1024 bytes are accumulated or every second, whichever comes first. The example shows iterating and writing the resulting packets.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Chunked.md#_snippet_11

LANGUAGE: swift
CODE:
```
let packets = bytes.chunks(ofCount: 1024, or: .repeating(every: .seconds(1)), into: Data.self)
for try await packet in packets {
  write(packet)
}
```

----------------------------------------

TITLE: Combine Async Sequences: merge(_:...)
DESCRIPTION: The `merge` algorithm combines elements from two or more asynchronous sequences into a single asynchronous sequence. Unlike `combineLatest`, it does not produce tuples but rather emits elements from any of the underlying sequences as soon as they become available. This is suitable for interleaving events from multiple sources.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/README.md#_snippet_2

LANGUAGE: APIDOC
CODE:
```
merge(_:...)
  description: Merges two or more asynchronous sequence into a single asynchronous sequence producing the elements of all of the underlying asynchronous sequences.
```

----------------------------------------

TITLE: Applying Debounce to an AsyncSequence
DESCRIPTION: Demonstrates how to apply the `debounce` operator to an `AsyncSequence` to wait for a specified quiet period before emitting values.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/NNNN-rate-limits.md#_snippet_1

LANGUAGE: Swift
CODE:
```
fastEvents.debounce(for: .seconds(1))
```

----------------------------------------

TITLE: Combine Latest Values from Async Sequences in Swift
DESCRIPTION: This Swift code demonstrates how to use `combineLatest` to merge two asynchronous sequences, `appleFeed` and `nasdaqFeed`, representing stock ticker lines. It iterates over the combined sequence, printing the latest values from both feeds as they become available, showcasing real-time data aggregation.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/CombineLatest.md#_snippet_0

LANGUAGE: swift
CODE:
```
let appleFeed = URL("http://www.example.com/ticker?symbol=AAPL").lines
let nasdaqFeed = URL("http://www.example.com/ticker?symbol=^IXIC").lines

for try await (apple, nasdaq) in combineLatest(appleFeed, nasdaqFeed) {
  print("AAPL: \(apple) NASDAQ: \(nasdaq)")
}
```

----------------------------------------

TITLE: Swift Throttle Basic Usage Example
DESCRIPTION: A concise example demonstrating how to apply the `throttle` operator to an `AsyncSequence` named `fastEvents`. This snippet configures the sequence to emit values at most once every second, using the default `ContinuousClock` and emitting the latest value.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Throttle.md#_snippet_1

LANGUAGE: swift
CODE:
```
fastEvents.throttle(for: .seconds(1))
```

----------------------------------------

TITLE: Swift Example: Chunking by Count or Timer Signal
DESCRIPTION: Demonstrates how to use the `chunks` method to partition a byte stream into 1024-byte `Data` instances, or emit a chunk every second, whichever comes first.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/NNNN-chunk.md#_snippet_9

LANGUAGE: swift
CODE:
```
let packets = bytes.chunks(ofCount: 1024 or: .repeating(every: .seconds(1)), into: Data.self)
for try await packet in packets {
  write(packet)
}
```

----------------------------------------

TITLE: Create Async Sequence: AsyncThrowingChannel
DESCRIPTION: Similar to `AsyncChannel`, `AsyncThrowingChannel` is an asynchronous sequence with back pressure sending semantics, but with the added capability to emit failures. This allows for robust error propagation and handling within asynchronous data streams. It's essential for building resilient concurrent applications where operations might fail.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/README.md#_snippet_7

LANGUAGE: APIDOC
CODE:
```
AsyncThrowingChannel
  description: An asynchronous sequence with back pressure sending semantics that can emit failures.
```

----------------------------------------

TITLE: Merge two asynchronous sequences in Swift
DESCRIPTION: Demonstrates how to use the `merge` function to combine two `AsyncSequence` instances, such as URL lines, into a single sequence and print their elements as they become available. This example merges stock ticker data from two different feeds.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Merge.md#_snippet_0

LANGUAGE: swift
CODE:
```
let appleFeed = URL(string: "http://www.example.com/ticker?symbol=AAPL")!.lines.map { "AAPL: " + $0 }
let nasdaqFeed = URL(string:"http://www.example.com/ticker?symbol=^IXIC")!.lines.map { "^IXIC: " + $0 }

for try await ticker in merge(appleFeed, nasdaqFeed) {
  print(ticker)
}
```

----------------------------------------

TITLE: Convert Sequence to AsyncSequence using .async property
DESCRIPTION: Demonstrates how to use the `.async` property to convert a standard Swift `Sequence` (like an Array or String) into an `AsyncSyncSequence`, making it compatible with `AsyncSequence` operations.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Lazy.md#_snippet_0

LANGUAGE: swift
CODE:
```
let numbers = [1, 2, 3, 4].async
let characters = "abcde".async
```

----------------------------------------

TITLE: Swift Async Algorithms Type Effects Reference
DESCRIPTION: Provides a comprehensive reference of various `Async` types within the Swift Async Algorithms library, detailing their throwing behavior (rethrows, throws, non-throwing) and Sendability characteristics (Conditional, Not Sendable, Sendable). This table helps understand the concurrency and error handling properties of each type.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Effects.md#_snippet_0

LANGUAGE: APIDOC
CODE:
```
| Type                                                | Throws       | Sendability |
|-----------------------------------------------------|--------------|-------------|
| `AsyncAdjacentPairsSequence`                        | rethrows     | Conditional |
| `AsyncBufferedByteIterator`                         | throws       | Not Sendable|
| `AsyncBufferSequence`                               | rethrows     | Conditional |
| `AsyncBufferSequence.Iterator`                      | rethrows     | Not Sendable|
| `AsyncChain2Sequence`                               | rethrows     | Conditional |
| `AsyncChain2Sequence.Iterator`                      | rethrows     | Not Sendable|
| `AsyncChain3Sequence`                               | rethrows     | Conditional |
| `AsyncChain3Sequence.Iterator`                      | rethrows     | Not Sendable|
| `AsyncChannel`                                      | non-throwing | Sendable    |
| `AsyncChannel.Iterator`                             | non-throwing | Not Sendable|
| `AsyncChunkedByGroupSequence`                       | rethrows     | Conditional |
| `AsyncChunkedByGroupSequence.Iterator`              | rethrows     | Not Sendable|
| `AsyncChunkedOnProjectionSequence`                  | rethrows     | Conditional |
| `AsyncChunkedOnProjectionSequence.Iterator`         | rethrows     | Not Sendable|
| `AsyncChunksOfCountOrSignalSequence`                | rethrows     | Sendable    |
| `AsyncChunksOfCountOrSignalSequence.Iterator`       | rethrows     | Not Sendable|
| `AsyncChunksOfCountSequence`                        | rethrows     | Conditional |
| `AsyncChunksOfCountSequence.Iterator`               | rethrows     | Not Sendable|
| `AsyncCombineLatest2Sequence`                       | rethrows     | Sendable    |
| `AsyncCombineLatest2Sequence.Iterator`              | rethrows     | Not Sendable|
| `AsyncCombineLatest3Sequence`                       | rethrows     | Sendable    |
| `AsyncCombineLatest3Sequence.Iterator`              | rethrows     | Not Sendable|
| `AsyncCompactedSequence`                            | rethrows     | Conditional |
| `AsyncCompactedSequence.Iterator`                   | rethrows     | Not Sendable|
| `AsyncDebounceSequence`                             | rethrows     | Sendable    |
| `AsyncDebounceSequence.Iterator`                    | rethrows     | Not Sendable|
| `AsyncExclusiveReductionsSequence`                  | rethrows     | Conditional |
| `AsyncExclusiveReductionsSequence.Iterator`         | rethrows     | Not Sendable|
| `AsyncInclusiveReductionsSequence`                  | rethrows     | Conditional |
| `AsyncInclusiveReductionsSequence.Iterator`         | rethrows     | Not Sendable|
| `AsyncInterspersedSequence`                         | rethrows     | Conditional |
| `AsyncInterspersedSequence.Iterator`                | rethrows     | Not Sendable|
| `AsyncJoinedSequence`                               | rethrows     | Conditional |
| `AsyncJoinedSequence.Iterator`                      | rethrows     | Not Sendable|
| `AsyncSyncSequence`                                 | non-throwing | Conditional |
| `AsyncSyncSequence.Iterator`                        | non-throwing | Not Sendable|
| `AsyncLimitBuffer`                                  | non-throwing | Sendable    |
| `AsyncMerge2Sequence`                               | rethrows     | Sendable    |
| `AsyncMerge2Sequence.Iterator`                      | rethrows     | Not Sendable|
| `AsyncMerge3Sequence`                               | rethrows     | Sendable    |
| `AsyncMerge3Sequence.Iterator`                      | rethrows     | Not Sendable|
| `AsyncRemoveDuplicatesSequence`                     | rethrows     | Conditional |
| `AsyncRemoveDuplicatesSequence.Iterator`            | rethrows     | Not Sendable|
| `AsyncThrottleSequence`                             | rethrows     | Conditional |
| `AsyncThrottleSequence.Iterator`                    | rethrows     | Not Sendable|
| `AsyncThrowingChannel`                              | throws       | Sendable    |
| `AsyncThrowingChannel.Iterator`                     | throws       | Not Sendable|
| `AsyncThrowingExclusiveReductionsSequence`          | throws       | Conditional |
| `AsyncThrowingExclusiveReductionsSequence.Iterator` | throws       | Not Sendable|
| `AsyncThrowingInclusiveReductionsSequence`          | throws       | Conditional |
| `AsyncThrowingInclusiveReductionsSequence.Iterator` | throws       | Not Sendable|
| `AsyncTimerSequence`                                | non-throwing | Sendable    |
| `AsyncTimerSequence.Iterator`                       | non-throwing | Not Sendable|
| `AsyncZip2Sequence`                                 | rethrows     | Sendable    |
| `AsyncZip2Sequence.Iterator`                        | rethrows     | Not Sendable|
| `AsyncZip3Sequence`                                 | rethrows     | Sendable    |
```

----------------------------------------

TITLE: Swift: Merging Two Async Sequences Example
DESCRIPTION: This snippet demonstrates how to use the 'merge' function to combine two 'AsyncSequence' instances, 'appleFeed' and 'nasdaqFeed', into a single stream. It iterates over the merged sequence, printing each combined ticker value. This illustrates the basic usage of the 'merge' operator for combining real-time data feeds.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/0002-merge.md#_snippet_0

LANGUAGE: swift
CODE:
```
let appleFeed = URL(string: "http://www.example.com/ticker?symbol=AAPL")!.lines.map { "AAPL: " + $0 }
let nasdaqFeed = URL(string:"http://www.example.com/ticker?symbol=^IXIC")!.lines.map { "^IXIC: " + $0 }

for try await ticker in merge(appleFeed, nasdaqFeed) {
  print(ticker)
}
```

----------------------------------------

TITLE: Combine Async Sequences with Swift zip
DESCRIPTION: This Swift code demonstrates how to use the `zip` function to combine two asynchronous sequences, `appleFeed` and `nasdaqFeed`, into a single sequence of tuples. It iterates over the combined sequence, printing the latest values from both feeds as they become available. This example showcases basic usage for real-time data aggregation.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Zip.md#_snippet_0

LANGUAGE: swift
CODE:
```
let appleFeed = URL(string: "http://www.example.com/ticker?symbol=AAPL")!.lines
let nasdaqFeed = URL(string: "http://www.example.com/ticker?symbol=^IXIC")!.lines

for try await (apple, nasdaq) in zip(appleFeed, nasdaqFeed) {
  print("APPL: \(apple) NASDAQ: \(nasdaq)")
}
```

----------------------------------------

TITLE: Swift: Dictionary AsyncSequence Initializers
DESCRIPTION: Introduces a family of asynchronous, rethrowing initializers for Dictionary. These parallel existing Sequence-based initializers, supporting construction from AsyncSequence's with unique keys, combining values for duplicate keys, or grouping values by a key. They facilitate asynchronous key uniquing and dictionary initialization.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Collections.md#_snippet_1

LANGUAGE: swift
CODE:
```
extension Dictionary {
  public init<S: AsyncSequence>(
    uniqueKeysWithValues keysAndValues: S
  ) async rethrows
    where S.Element == (Key, Value)

  public init<S: AsyncSequence>(
    _ keysAndValues: S,
    uniquingKeysWith combine: (Value, Value) async throws -> Value
  ) async rethrows
    where S.Element == (Key, Value)

  public init<S: AsyncSequence>(
    grouping values: S,
    by keyForValue: (S.Element) async throws -> Key
  ) async rethrows
    where Value == [S.Element]
}
```

----------------------------------------

TITLE: Swift AsyncSequence: Remove Duplicates API Definitions
DESCRIPTION: Defines `removeDuplicates` methods for `AsyncSequence` to filter out consecutive duplicate values. Variants include a shorthand for `Equatable` elements and custom predicates (throwing/non-throwing) for more complex comparisons.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/NNNN-reductions.md#_snippet_4

LANGUAGE: Swift
CODE:
```
extension AsyncSequence where Element: Equatable {
  public func removeDuplicates() -> AsyncRemoveDuplicatesSequence<Self>
}
```

LANGUAGE: Swift
CODE:
```
extension AsyncSequence {
  public func removeDuplicates(
    by predicate: @escaping @Sendable (Element, Element) async -> Bool
  ) -> AsyncRemoveDuplicatesSequence<Self>

  public func removeDuplicates(
    by predicate: @escaping @Sendable (Element, Element) async throws -> Bool
  ) -> AsyncThrowingRemoveDuplicatesSequence<Self>
}
```

----------------------------------------

TITLE: Example AsyncSequence Implementation with AsyncBufferedByteIterator
DESCRIPTION: Demonstrates how to create a custom AsyncSequence, `AsyncBytes`, that leverages `AsyncBufferedByteIterator` to provide an asynchronous stream of `UInt8` elements. The `makeAsyncIterator` method initializes the byte iterator with a specified buffer capacity and a closure for reading data.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/BufferedBytes.md#_snippet_0

LANGUAGE: swift
CODE:
```
struct AsyncBytes: AsyncSequence {
  public typealias Element = UInt8
  var handle: ReadableThing

  internal init(_ readable: ReadableThing) {
    handle = readable
  }

  public func makeAsyncIterator() -> AsyncBufferedByteIterator {
    return AsyncBufferedByteIterator(capacity: 16384) { buffer in
      // This runs once every 16384 invocations of next()
      return try await handle.read(into: buffer)
    }
  }
}
```

----------------------------------------

TITLE: Implementing AsyncBytes with AsyncBufferedByteIterator
DESCRIPTION: This Swift struct `AsyncBytes` demonstrates how to conform to `AsyncSequence` using `AsyncBufferedByteIterator`. It initializes the iterator with a specified capacity and a read function that asynchronously fills the buffer from a `ReadableThing`, optimizing byte retrieval.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/0008-bytes.md#_snippet_0

LANGUAGE: swift
CODE:
```
struct AsyncBytes: AsyncSequence {
  public typealias Element = UInt8
  var handle: ReadableThing

  internal init(_ readable: ReadableThing) {
    handle = readable
  }

  public func makeAsyncIterator() -> AsyncBufferedByteIterator {
    return AsyncBufferedByteIterator(capacity: 16384) { buffer in
      // This runs once every 16384 invocations of next()
      return try await handle.read(into: buffer)
    }
  }
}
```

----------------------------------------

TITLE: Swift Chunking Logs by Timer Signal Example
DESCRIPTION: Demonstrates how to use the `chunked` method with an `AsyncTimerSequence` to group log messages into four-second segments. The example shows iterating over the resulting chunks and sending them.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Chunked.md#_snippet_9

LANGUAGE: swift
CODE:
```
let fourSecondsOfLogs = logs.chunked(by: .repeating(every: .seconds(4)))
for await chunk in fourSecondsOfLogs {
  send(chunk)
}
```

----------------------------------------

TITLE: Create Async Sequence: async
DESCRIPTION: The `async` function allows you to create an asynchronous sequence from a synchronous sequence. This bridges the gap between traditional synchronous data collections and the new `async/await` concurrency model. It enables processing existing synchronous data sources within an asynchronous context.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/README.md#_snippet_5

LANGUAGE: APIDOC
CODE:
```
async
  description: Create an asynchronous sequence composed from a synchronous sequence.
```

----------------------------------------

TITLE: Combine Latest Values from Async Sequences in Swift
DESCRIPTION: This Swift code demonstrates how to use `combineLatest` to merge two asynchronous sequences, `appleFeed` and `nasdaqFeed`, into a single sequence of tuples. It iterates over the combined sequence, printing the latest values from both feeds as they become available.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/0006-combineLatest.md#_snippet_0

LANGUAGE: swift
CODE:
```
let appleFeed = URL("http://www.example.com/ticker?symbol=AAPL").lines
let nasdaqFeed = URL("http://www.example.com/ticker?symbol=^IXIC").lines

for try await (apple, nasdaq) in combineLatest(appleFeed, nasdaqFeed) {
  print("AAPL: \(apple) NASDAQ: \(nasdaq)")
}
```

----------------------------------------

TITLE: Debounce API Extension for AsyncSequence
DESCRIPTION: Defines the `debounce` methods available on `AsyncSequence` types, allowing events to be emitted only after a period of inactivity. Includes overloads for custom clocks and `ContinuousClock`.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/NNNN-rate-limits.md#_snippet_0

LANGUAGE: Swift
CODE:
```
extension AsyncSequence {
  public func debounce<C: Clock>(
    for interval: C.Instant.Duration,
    tolerance: C.Instant.Duration? = nil,
    clock: C
  ) -> AsyncDebounceSequence<Self, C>

  public func debounce(
    for interval: Duration,
    tolerance: Duration? = nil
  ) -> AsyncDebounceSequence<Self, ContinuousClock>
}
```

----------------------------------------

TITLE: Swift AsyncSequence Debounce Extension API
DESCRIPTION: Defines public `debounce` methods as extensions on `AsyncSequence` to control event emission. The first overload allows specifying a custom `Clock` and `tolerance`, while the second provides a convenient shorthand using `ContinuousClock` and `Duration` values.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Debounce.md#_snippet_0

LANGUAGE: swift
CODE:
```
extension AsyncSequence {
  public func debounce<C: Clock>(
    for interval: C.Instant.Duration,
    tolerance: C.Instant.Duration? = nil,
    clock: C
  ) -> AsyncDebounceSequence<Self, C>

  public func debounce(
    for interval: Duration,
    tolerance: Duration? = nil
  ) -> AsyncDebounceSequence<Self, ContinuousClock>
}
```

LANGUAGE: APIDOC
CODE:
```
AsyncSequence.debounce<C: Clock>(
  for interval: C.Instant.Duration,
  tolerance: C.Instant.Duration? = nil,
  clock: C
) -> AsyncDebounceSequence<Self, C>

AsyncSequence.debounce(
  for interval: Duration,
  tolerance: Duration? = nil
) -> AsyncDebounceSequence<Self, ContinuousClock>
```

----------------------------------------

TITLE: Swift AsyncSequence Exclusive Reductions API Definitions
DESCRIPTION: Defines the `reductions` methods for `AsyncSequence` that perform exclusive reductions. These methods take an `initial` value and a `transform` closure. Variants include non-throwing transformations (by application or mutation) and throwing transformations (by application or mutation), allowing for flexible progressive accumulation of values from an asynchronous sequence.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Reductions.md#_snippet_0

LANGUAGE: APIDOC
CODE:
```
extension AsyncSequence {
  public func reductions<Result>(
    _ initial: Result,
    _ transform: @Sendable @escaping (Result, Element) async -> Result
  ) -> AsyncExclusiveReductionsSequence<Self, Result>

  public func reductions<Result>(
    into initial: Result,
    _ transform: @Sendable @escaping (inout Result, Element) async -> Void
  ) -> AsyncExclusiveReductionsSequence<Self, Result>
}

extension AsyncSequence {
  public func reductions<Result>(
    _ initial: Result,
    _ transform: @Sendable @escaping (Result, Element) async throws -> Result
  ) -> AsyncThrowingExclusiveReductionsSequence<Self, Result>

  public func reductions<Result>(
    into initial: Result,
    _ transform: @Sendable @escaping (inout Result, Element) async throws -> Void
  ) -> AsyncThrowingExclusiveReductionsSequence<Self, Result>
}
```

----------------------------------------

TITLE: Swift AsyncSequence Inclusive Reductions API Definitions
DESCRIPTION: Defines the `reductions` methods for `AsyncSequence` that perform inclusive reductions. Unlike exclusive reductions, these methods do not require an initial value and operate directly on the elements of the sequence. Variants include non-throwing and throwing transformations, suitable for scenarios like running tallies.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Reductions.md#_snippet_2

LANGUAGE: APIDOC
CODE:
```
extension AsyncSequence {
  public func reductions(
    _ transform: @Sendable @escaping (Element, Element) async -> Element
  ) -> AsyncInclusiveReductionsSequence<Self>

  public func reductions(
    _ transform: @Sendable @escaping (Element, Element) async throws -> Element
  ) -> AsyncThrowingInclusiveReductionsSequence<Self>
}
```

----------------------------------------

TITLE: Swift AsyncSequence: Inclusive Reductions API Definitions
DESCRIPTION: Defines `reductions` methods for `AsyncSequence` that do not require an `initial` value, operating on the elements themselves. These methods support both throwing and non-throwing transformations.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/NNNN-reductions.md#_snippet_2

LANGUAGE: Swift
CODE:
```
extension AsyncSequence {
  public func reductions(
    _ transform: @Sendable @escaping (Element, Element) async -> Element
  ) -> AsyncInclusiveReductionsSequence<Self>

  public func reductions(
    _ transform: @Sendable @escaping (Element, Element) async throws -> Element
  ) -> AsyncThrowingInclusiveReductionsSequence<Self>
}
```

----------------------------------------

TITLE: Extending AsyncSequence with compacted Method
DESCRIPTION: This Swift extension adds a `compacted` method to `AsyncSequence` where elements are optional. It provides a more efficient and readable alternative to `.compactMap { $0 }` for unwrapping optional values, as it avoids the overhead of a closure.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Compacted.md#_snippet_0

LANGUAGE: swift
CODE:
```
extension AsyncSequence {
  public func compacted<Unwrapped>() -> AsyncCompactedSequence<Self, Unwrapped>
    where Element == Unwrapped?
}
```

----------------------------------------

TITLE: Swift: RangeReplaceableCollection AsyncSequence Initializer
DESCRIPTION: Defines a public asynchronous initializer for RangeReplaceableCollection types. It constructs a collection from an AsyncSequence where the source elements match the collection's element type, rethrowing any errors from the sequence. This enables creating collections like Array or Data from asynchronous streams.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Collections.md#_snippet_0

LANGUAGE: swift
CODE:
```
extension RangeReplaceableCollection {
  public init<Source: AsyncSequence>(
    _ source: Source
  ) async rethrows
    where Source.Element == Element
}
```

----------------------------------------

TITLE: Swift Debounce Usage Example
DESCRIPTION: Illustrates a simple usage of the `debounce` method on an `AsyncSequence`. This example demonstrates how to transform a potentially fast asynchronous sequence of events into one that waits for a 1-second window of no events before emitting a value.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Debounce.md#_snippet_1

LANGUAGE: swift
CODE:
```
fastEvents.debounce(for: .seconds(1))
```

----------------------------------------

TITLE: Swift Example: Initializing Dictionary from Chunked Sequence
DESCRIPTION: Illustrates how an asynchronous sequence chunked by projection can be used to initialize a `Dictionary`. This is particularly useful when the elements are known to be ordered, ensuring that the projection acts as a unique key for each chunk (value).
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Chunked.md#_snippet_5

LANGUAGE: Swift
CODE:
```
let names = URL(fileURLWithPath: "/tmp/names.txt").lines
let nameDirectory = try await Dictionary(uniqueKeysWithValues: names.chunked(on: \.first!))
```

----------------------------------------

TITLE: Define AsyncBufferSequencePolicy for Buffer Overflow Handling
DESCRIPTION: This Swift struct defines the policies for handling buffer overflow within an `AsyncBufferSequence`. It provides static methods to specify different behaviors such as bounded limits, unbounded storage, or strategies for buffering the latest or oldest elements when the buffer capacity is exceeded.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/0010-buffer.md#_snippet_0

LANGUAGE: swift
CODE:
```
public struct AsyncBufferSequencePolicy: Sendable {
  public static func bounded(_ limit: Int)
  public static var unbounded
  public static func bufferingLatest(_ limit: Int)
  public static func bufferingOldest(_ limit: Int)
}
```

----------------------------------------

TITLE: Swift AsyncChannel and AsyncThrowingChannel API Definition
DESCRIPTION: Defines the public interface for `AsyncChannel` and `AsyncThrowingChannel`, including their `Iterator` structs, initializers, and methods for sending elements (`send`), signaling completion (`finish`), or failure (`fail`). These types provide back pressure for asynchronous communication.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/NNNN-channel.md#_snippet_0

LANGUAGE: Swift
CODE:
```
public final class AsyncChannel<Element: Sendable>: AsyncSequence, Sendable {
  public struct Iterator: AsyncIteratorProtocol, Sendable {
    public mutating func next() async -> Element?
  }

  public init(element elementType: Element.Type = Element.self)

  public func send(_ element: Element) async
  public func finish()

  public func makeAsyncIterator() -> Iterator
}

public final class AsyncThrowingChannel<Element: Sendable, Failure: Error>: AsyncSequence, Sendable {
  public struct Iterator: AsyncIteratorProtocol, Sendable {
    public mutating func next() async throws -> Element?
  }

  public init(element elementType: Element.Type = Element.self, failure failureType: Failure.Type = Failure.self)

  public func send(_ element: Element) async
  public func fail(_ error: Error) where Failure == Error
  public func finish()

  public func makeAsyncIterator() -> Iterator
}
```

----------------------------------------

TITLE: AsyncTimerSequence API Definition
DESCRIPTION: Defines the public interface for AsyncTimerSequence, an asynchronous sequence that produces elements of the clock's Instant type. It includes the struct definition, its Iterator, the initializer, and extensions for SuspendingClock and Sendable conformance.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Timer.md#_snippet_0

LANGUAGE: Swift
CODE:
```
public struct AsyncTimerSequence<C: Clock>: AsyncSequence {
  public typealias Element = C.Instant

  public struct Iterator: AsyncIteratorProtocol {
    public mutating func next() async -> C.Instant?
  }

  public init(
    interval: C.Instant.Duration,
    tolerance: C.Instant.Duration? = nil,
    clock: C
  )

  public func makeAsyncIterator() -> Iterator
}

extension AsyncTimerSequence where C == SuspendingClock {
  public static func repeating(every interval: Duration, tolerance: Duration? = nil) -> AsyncTimerSequence<SuspendingClock>
}

extension AsyncTimerSequence: Sendable { }
extension AsyncTimerSequence.Iterator: Sendable { }
```

----------------------------------------

TITLE: Swift AsyncSequence Throttle API Extensions
DESCRIPTION: Defines the public `throttle` methods available on `AsyncSequence` types. These overloads allow specifying a custom clock or using `ContinuousClock`, and provide options for reducing elements during the throttle interval, either by providing a custom reduction closure or by simply emitting the latest element.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Throttle.md#_snippet_0

LANGUAGE: swift
CODE:
```
extension AsyncSequence {
  public func throttle<C: Clock, Reduced>(
    for interval: C.Instant.Duration,
    clock: C,
    reducing: @Sendable @escaping (Reduced?, Element) async -> Reduced
  ) -> AsyncThrottleSequence<Self, C, Reduced>

  public func throttle<Reduced>(
    for interval: Duration,
    reducing: @Sendable @escaping (Reduced?, Element) async -> Reduced
  ) -> AsyncThrottleSequence<Self, ContinuousClock, Reduced>

  public func throttle<C: Clock>(
    for interval: C.Instant.Duration,
    clock: C,
    latest: Bool = true
  ) -> AsyncThrottleSequence<Self, C, Element>

  public func throttle(
    for interval: Duration,
    latest: Bool = true
  ) -> AsyncThrottleSequence<Self, ContinuousClock, Element>
}
```

----------------------------------------

TITLE: Combine Async Sequences: zip(_:...)
DESCRIPTION: The `zip` algorithm creates an asynchronous sequence of pairs by combining corresponding elements from two or more underlying asynchronous sequences. It waits for an element from each input sequence before emitting a new tuple. This is useful for pairing up related data points that arrive asynchronously.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/README.md#_snippet_3

LANGUAGE: APIDOC
CODE:
```
zip(_:...)
  description: Creates an asynchronous sequence of pairs built out of underlying asynchronous sequences.
```

----------------------------------------

TITLE: Swift Example: Chunking Bytes into Data Packets
DESCRIPTION: Shows how to use `chunks(ofCount:into:)` to break an asynchronous sequence of `UInt8` bytes into `Data` instances. Each `Data` packet will contain at most 1024 bytes, demonstrating how to process elements in fixed-size chunks.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Chunked.md#_snippet_7

LANGUAGE: Swift
CODE:
```
let packets = bytes.chunks(ofCount: 1024, into: Data.self)
for try await packet in packets {
  write(packet)
}
```

----------------------------------------

TITLE: Combine AsyncSequences with zip in Swift
DESCRIPTION: Example demonstrating how to use the `zip` function to combine two `AsyncSequence` instances, such as lines from URLs, and iterate over their concurrently produced elements as tuples. It shows how to print the combined values.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/0001-zip.md#_snippet_0

LANGUAGE: swift
CODE:
```
let appleFeed = URL(string: "http://www.example.com/ticker?symbol=AAPL")!.lines
let nasdaqFeed = URL(string: "http://www.example.com/ticker?symbol=^IXIC")!.lines

for try await (apple, nasdaq) in zip(appleFeed, nasdaqFeed) {
  print("APPL: \(apple) NASDAQ: \(nasdaq)")
}
```

----------------------------------------

TITLE: Validate Single Input AsyncSequence Transformation
DESCRIPTION: This Swift code demonstrates the basic usage of the `validate` function to test an `AsyncSequence`. It defines an input sequence using a string diagram ("a--b--c---|"), applies a transformation (`map { $0.capitalized }`) to the first input, and then specifies the expected output sequence ("A--B--C---|"). The diagram visually represents events over time, including values and termination.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncSequenceValidation/AsyncSequenceValidation.docc/Validation.md#_snippet_0

LANGUAGE: Swift
CODE:
```
validate {
  "a--b--c---|"
  $0.inputs[0].map { $0.capitalized }
  "A--B--C---|"
}
```

----------------------------------------

TITLE: Swift AsyncSequence: Mutating Exclusive Reduction Example
DESCRIPTION: Demonstrates using `reductions(into:)` to progressively build a result by mutating an initial value. If the input is "a", "b", "c", the output is "a", "ab", "abc".
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/NNNN-reductions.md#_snippet_1

LANGUAGE: Swift
CODE:
```
characters.reductions(into: "") { $0.append($1) }
```

----------------------------------------

TITLE: Applying Throttle to an AsyncSequence
DESCRIPTION: Demonstrates how to apply the `throttle` operator to an `AsyncSequence` to ensure a minimum interval between emitted values.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/NNNN-rate-limits.md#_snippet_3

LANGUAGE: Swift
CODE:
```
fastEvents.throttle(for: .seconds(1))
```

----------------------------------------

TITLE: Concatenate AsyncSequence of URLs with Separator in Swift
DESCRIPTION: Demonstrates how to transform an `AsyncSequence` of `URL`s into an `AsyncSequence` of lines from each file, inserting a separator line between files. This uses the `joined(separator:)` method to combine the lines from multiple URLs with a custom separator.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Joined.md#_snippet_0

LANGUAGE: swift
CODE:
```
let sequenceOfURLs: AsyncSequence<URL> = ...
let sequenceOfLines = sequenceOfURLs.map { $0.lines }
let joinedWithSeparator = sequenceOfLines.joined(separator: ["===================="].async)

for try await lineOrSeparator in joinedWithSeparator {
  print(lineOrSeparator)
}
```

----------------------------------------

TITLE: Swift: Initialize Data from AsyncBytes Example
DESCRIPTION: Example demonstrating the use of the new RangeReplaceableCollection initializer to construct a Data instance. It reads bytes asynchronously from a file URL's resourceBytes property, showcasing how to consume an AsyncSequence into a concrete collection.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Collections.md#_snippet_3

LANGUAGE: swift
CODE:
```
let contents = try await Data(URL(fileURLWithPath: "/tmp/example.bin").resourceBytes)
```

----------------------------------------

TITLE: Combine Async Sequences: chain(_:...)
DESCRIPTION: The `chain` algorithm concatenates two or more asynchronous sequences that share the same element type. It produces a single, unified asynchronous sequence by appending the elements of each input sequence in order. This is useful for combining multiple data streams into one continuous flow.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/README.md#_snippet_0

LANGUAGE: APIDOC
CODE:
```
chain(_:...)
  description: Concatenates two or more asynchronous sequences with the same element type.
```

----------------------------------------

TITLE: Iterate over adjacent pairs in Swift AsyncSequence
DESCRIPTION: This example demonstrates iterating over adjacent pairs generated by the `adjacentPairs()` method. It shows how to use a `for await` loop to process pairs from an `AsyncSequence` of integers, printing each `(first, second)` tuple.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/0005-adjacent-pairs.md#_snippet_1

LANGUAGE: Swift
CODE:
```
for await (first, second) in (1...5).async.adjacentPairs() {
   print("First: \(first), Second: \(second)")
}

// First: 1, Second: 2
// First: 2, Second: 3
// First: 3, Second: 4
// First: 4, Second: 5
```

----------------------------------------

TITLE: Swift Example: Concatenating Async Feeds with joined()
DESCRIPTION: Demonstrates how to use the `joined()` algorithm to concatenate two `AsyncSequence`s (appleFeed and nasdaqFeed) representing URL lines. The example shows iterating over their combined lines, where inner sequences are processed one after another.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/0004-joined.md#_snippet_1

LANGUAGE: swift
CODE:
```
 let appleFeed = URL("http://www.example.com/ticker?symbol=AAPL").lines
 let nasdaqFeed = URL("http://www.example.com/ticker?symbol=^IXIC").lines

 for try await line in [appleFeed, nasdaqFeed].async.joined() {
   print("\(line)")
 }
```

----------------------------------------

TITLE: Swift Example: Inclusive Reductions for Running Sum
DESCRIPTION: Demonstrates the application of inclusive reductions in Swift to calculate a running sum. Given an asynchronous sequence of numbers like `1, 2, 3, 4`, the `reductions` operation will produce `1, 3, 6, 10`, where each element is the sum of all preceding elements up to that point.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Reductions.md#_snippet_3

LANGUAGE: Swift
CODE:
```
numbers.reductions { $0 + $1 }
```

----------------------------------------

TITLE: Implement Async Debounce Sequence in Swift
DESCRIPTION: Defines the `AsyncDebounceSequence` type, which implements the debounce algorithm for asynchronous sequences. It details its `AsyncSequence` conformance, `Iterator` struct, `next()` method, and unconditional `Sendable` conformance, ensuring thread safety.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/NNNN-rate-limits.md#_snippet_4

LANGUAGE: swift
CODE:
```
public struct AsyncDebounceSequence<Base: AsyncSequence, C: Clock>: Sendable
  where Base.Element: Sendable, Base: Sendable {
}

extension AsyncDebounceSequence: AsyncSequence {
  public typealias Element = Base.Element

  public struct Iterator: AsyncIteratorProtocol {
    public mutating func next() async rethrows -> Base.Element?
  }

  public func makeAsyncIterator() -> Iterator
}
```

LANGUAGE: APIDOC
CODE:
```
AsyncDebounceSequence<Base: AsyncSequence, C: Clock>: Sendable
  where Base.Element: Sendable, Base: Sendable
  - Description: Implements the debounce algorithm, emitting the same element type as its base. Unconditionally Sendable.
  - Conforms to: AsyncSequence
  - Typealias:
    - Element: Base.Element
  - Nested Struct:
    - Iterator: AsyncIteratorProtocol
      - Method:
        - next() async rethrows -> Base.Element?
          - Description: Advances the iterator to the next element, applying debounce logic.
  - Method:
    - makeAsyncIterator() -> Iterator
      - Description: Creates and returns an iterator for the sequence.
```

----------------------------------------

TITLE: Combine AsyncSequence with chain in Swift
DESCRIPTION: This Swift example demonstrates how to use the `chain` function to sequentially combine two `AsyncSequence` instances. It prepends a custom preamble (an array converted to an `AsyncSequence`) to the lines read from a file, then iterates and prints each line from the resulting chained sequence.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/0007-chain.md#_snippet_0

LANGUAGE: swift
CODE:
```
let preamble = [
  "// Some header to add as a preamble",
  "//",
  ""
].async
let lines = chain(preamble, URL(fileURLWithPath: "/tmp/Sample.swift").lines)

for try await line in lines {
  print(line)
}
```

----------------------------------------

TITLE: Swift: Create Dictionary from AsyncSequence adjacent pairs
DESCRIPTION: This snippet illustrates how `adjacentPairs()` can be effectively combined with `Dictionary.init(_:uniquingKeysWith:)` to construct a dictionary. It assumes `url.lines` provides an `AsyncSequence` of key-value pairs, where `adjacentPairs()` transforms them into the required tuple format.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/AdjacentPairs.md#_snippet_2

LANGUAGE: Swift
CODE:
```
Dictionary(uniqueKeysWithValues: url.lines.adjacentPairs())
```

----------------------------------------

TITLE: Swift AsyncSequence Projection Example by First Character
DESCRIPTION: Demonstrates using `chunked(on:)` to group names from a file by their first character. It iterates through the resulting `(firstLetter, names)` tuples and prints them, showing how elements with the same projection are grouped together.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/NNNN-chunk.md#_snippet_4

LANGUAGE: swift
CODE:
```
let names = URL(fileURLWithPath: "/tmp/names.txt").lines
let groupedNames = names.chunked(on: \.first!)
for try await (firstLetter, names) in groupedNames {
  print(firstLetter)
  for name in names {
    print("  ", name)
  }
}
```

----------------------------------------

TITLE: Swift AsyncSequence Grouping Example with Default Array
DESCRIPTION: Demonstrates how to use the `chunked` method on an `AsyncSequence` to group numbers where each subsequent number is greater than or equal to the previous one. For the sequence `10, 20, 30, 10, 40, 40, 10, 20`, this snippet would produce the chunks: `[10, 20, 30]`, `[10, 40, 40]`, `[10, 20]`.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/NNNN-chunk.md#_snippet_1

LANGUAGE: swift
CODE:
```
let chunks = numbers.chunked { $0 <= $1 }
for await numberChunk in chunks {
  print(numberChunk)
}
```

----------------------------------------

TITLE: Define AsyncTimerSequence Struct in Swift
DESCRIPTION: Defines the `AsyncTimerSequence` struct, an `AsyncSequence` that emits `C.Instant` elements at specified intervals. It includes its `Iterator` protocol conformance, initializers for setting interval and tolerance, and an extension for `SuspendingClock` to create repeating timers. The struct is also `Sendable`.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/NNNN-chunk.md#_snippet_14

LANGUAGE: swift
CODE:
```
public struct AsyncTimerSequence<C: Clock>: AsyncSequence {
  public typealias Element = C.Instant

  public struct Iterator: AsyncIteratorProtocol {
    public mutating func next() async -> C.Instant?
  }

  public init(
    interval: C.Instant.Duration,
    tolerance: C.Instant.Duration? = nil,
    clock: C
  )

  public func makeAsyncIterator() -> Iterator
}

extension AsyncTimerSequence where C == SuspendingClock {
  public static func repeating(every interval: Duration, tolerance: Duration? = nil) -> AsyncTimerSequence<SuspendingClock>
}

extension AsyncTimerSequence: Sendable { }
```

----------------------------------------

TITLE: Swift: Initialize Set from AsyncSequence Prefix Example
DESCRIPTION: Shows how to initialize a Set from an AsyncSequence using the new SetAlgebra initializer. This example specifically uses the prefix(10) method to limit the number of elements consumed from the asynchronous sequence, demonstrating partial consumption.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Collections.md#_snippet_5

LANGUAGE: swift
CODE:
```
let allItems = await Set(items.prefix(10))
```

----------------------------------------

TITLE: Swift AsyncSequence Dictionary Initialization from Projected Chunks
DESCRIPTION: Shows how to initialize a `Dictionary` directly from an `AsyncSequence` that has been chunked by projection, assuming the elements are ordered. This leverages the `Dictionary(uniqueKeysWithValues:)` initializer, where the projection acts as the key and the chunk as the value.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/NNNN-chunk.md#_snippet_5

LANGUAGE: swift
CODE:
```
let names = URL(fileURLWithPath: "/tmp/names.txt").lines
let nameDirectory = try await Dictionary(uniqueKeysWithValues: names.chunked(on: \.first!))
```

----------------------------------------

TITLE: Swift: Initialize Dictionary with Zipped AsyncSequence Example
DESCRIPTION: Illustrates initializing a Dictionary using the uniqueKeysWithValues initializer. It takes a zipped AsyncSequence of keys and values, demonstrating how to asynchronously construct a dictionary from paired elements.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Collections.md#_snippet_4

LANGUAGE: swift
CODE:
```
let table = await Dictionary(uniqueKeysWithValues: zip(keys, values))
```

----------------------------------------

TITLE: Swift Chunking AsyncSequence by Predicate with Default Array
DESCRIPTION: Demonstrates how to use the `chunked` operation on an asynchronous sequence of numbers. The predicate `$0 <= $1` groups consecutive numbers that are in non-decreasing order. The resulting chunks are collected into the default `Array` type.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Chunked.md#_snippet_1

LANGUAGE: Swift
CODE:
```
let chunks = numbers.chunked { $0 <= $1 }
for await numberChunk in chunks {
  print(numberChunk)
}
```

----------------------------------------

TITLE: Proposed AsyncSequence compacted Extension
DESCRIPTION: This Swift code snippet shows the proposed extension to `AsyncSequence` that introduces the `compacted` method. This method filters out `nil` elements from the sequence, returning an `AsyncCompactedSequence` of non-optional `Unwrapped` elements. It's designed to be a more efficient alternative to `compactMap { $0 }`.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/0003-compacted.md#_snippet_0

LANGUAGE: swift
CODE:
```
extension AsyncSequence {
  public func compacted<Unwrapped>() -> AsyncCompactedSequence<Self, Unwrapped>
    where Element == Unwrapped?
}
```

----------------------------------------

TITLE: Combine Async Sequences: joined(separator:)
DESCRIPTION: The `joined(separator:)` algorithm concatenates the elements of an asynchronous sequence of asynchronous sequences. It inserts a specified separator between each element from the inner sequences. This is particularly useful for flattening nested asynchronous data structures while providing clear delineation between segments.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/README.md#_snippet_4

LANGUAGE: APIDOC
CODE:
```
joined(separator:)
  description: Concatenated elements of an asynchronous sequence of asynchronous sequences, inserting the given separator between each element.
```

----------------------------------------

TITLE: Swift Example: Mutating Exclusive Reductions for String Concatenation
DESCRIPTION: Illustrates the use of `reductions(into:)` for exclusive reductions in Swift. This example demonstrates how to progressively build a string by appending characters from an asynchronous sequence. If the input sequence is `"a", "b", "c"`, the output sequence will be `"a", "ab", "abc"`.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Reductions.md#_snippet_1

LANGUAGE: Swift
CODE:
```
characters.reductions(into: "") { $0.append($1) }
```

----------------------------------------

TITLE: Swift AsyncSequence Chain API Reference
DESCRIPTION: This section provides the API definitions for the `chain` functions and the `AsyncChain2Sequence` and `AsyncChain3Sequence` types. It details their generic parameters, element types, iterator protocols, and conditional `Sendable` conformance for concurrent safety, outlining how multiple asynchronous sequences are combined.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Chain.md#_snippet_1

LANGUAGE: APIDOC
CODE:
```
public func chain<Base1: AsyncSequence, Base2: AsyncSequence>(_ s1: Base1, _ s2: Base2) -> AsyncChain2Sequence<Base1, Base2> where Base1.Element == Base2.Element

public func chain<Base1: AsyncSequence, Base2: AsyncSequence, Base3: AsyncSequence>(_ s1: Base1, _ s2: Base2, _ s3: Base3) -> AsyncChain3Sequence<Base1, Base2, Base3>

public struct AsyncChain2Sequence<Base1: AsyncSequence, Base2: AsyncSequence> where Base1.Element == Base2.Element {
  public typealias Element = Base1.Element

  public struct Iterator: AsyncIteratorProtocol {
    public mutating func next() async rethrows -> Element?
  }

  public func makeAsyncIterator() -> Iterator
}

extension AsyncChain2Sequence: Sendable where Base1: Sendable, Base2: Sendable { }
extension AsyncChain2Sequence.Iterator: Sendable where Base1.AsyncIterator: Sendable, Base2.AsyncIterator: Sendable { }

public struct AsyncChain3Sequence<Base1: AsyncSequence, Base2: AsyncSequence, Base3: AsyncSequence> where Base1.Element == Base2.Element, Base1.Element == Base3.Element {
  public typealias Element = Base1.Element

  public struct Iterator: AsyncIteratorProtocol {
    public mutating func next() async rethrows -> Element?
  }

  public func makeAsyncIterator() -> Iterator
}

extension AsyncChain3Sequence: Sendable where Base1: Sendable, Base2: Sendable, Base3: Sendable { }
extension AsyncChain3Sequence.Iterator: Sendable where Base1.AsyncIterator: Sendable, Base2.AsyncIterator: Sendable, Base3.AsyncIterator: Sendable { }
```

----------------------------------------

TITLE: Explore Core Asynchronous Sequence Operations in Swift
DESCRIPTION: Overview of fundamental asynchronous sequence operations provided by Swift Async Algorithms, including methods for collecting adjacent pairs, chunking values, removing nil or duplicate values, and interspersing elements.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/README.md#_snippet_9

LANGUAGE: APIDOC
CODE:
```
adjacentPairs(): Collects tuples of adjacent elements.
chunks(...) and chunked(...): Collect values into chunks.
compacted(): Remove nil values from an asynchronous sequence.
removeDuplicates(): Remove sequentially adjacent duplicate values.
interspersed(with:): Place a value between every two elements of an asynchronous sequence.
```

----------------------------------------

TITLE: Create Dictionary from adjacent pairs in Swift
DESCRIPTION: This snippet illustrates how the `adjacentPairs()` method can be combined with `Dictionary.init(_:uniquingKeysWith:)` to construct a dictionary. It's particularly useful when the `AsyncSequence` yields key-value pairs, such as lines from a URL.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/0005-adjacent-pairs.md#_snippet_2

LANGUAGE: Swift
CODE:
```
Dictionary(uniqueKeysWithValues: url.lines.adjacentPairs())
```

----------------------------------------

TITLE: Swift: Iterate over adjacent pairs from an AsyncSequence
DESCRIPTION: This example demonstrates how to use the `adjacentPairs()` method on an `AsyncSequence` (here, an async range) to iterate over and print each consecutive pair of elements. The output shows the sequence of (first, second) tuples.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/AdjacentPairs.md#_snippet_1

LANGUAGE: Swift
CODE:
```
for await (first, second) in (1...5).async.adjacentPairs() {
   print("First: \(first), Second: \(second)")
}

// First: 1, Second: 2
// First: 2, Second: 3
// First: 3, Second: 4
// First: 4, Second: 5
```

----------------------------------------

TITLE: Swift AsyncSequence Extension for Count-Based Chunking
DESCRIPTION: Defines methods to chunk an `AsyncSequence` into `Collected` or `Array` instances based on a specified element count. Chunks are emitted immediately upon reaching the count limit. The sequence preserves the rethrowing behavior of the base `AsyncSequence`.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/NNNN-chunk.md#_snippet_6

LANGUAGE: Swift
CODE:
```
extension AsyncSequence {
  public func chunks<Collected: RangeReplaceableCollection>(
    ofCount count: Int,
    into: Collected.Type
  ) -> AsyncChunksOfCountSequence<Self, Collected>
    where Collected.Element == Element

  public func chunks(
    ofCount count: Int
  ) -> AsyncChunksOfCountSequence<Self, [Element]>
}
```

LANGUAGE: Swift
CODE:
```
let packets = bytes.chunks(ofCount: 1024, into: Data.self)
for try await packet in packets {
  write(packet)
}
```

----------------------------------------

TITLE: Swift AsyncSequence: Inclusive Reduction Example
DESCRIPTION: Example demonstrating the use of `reductions(_:)` for a running tally. If the input is 1, 2, 3, 4, the produced values would be 1, 3, 6, 10.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/NNNN-reductions.md#_snippet_3

LANGUAGE: Swift
CODE:
```
numbers.reductions { $0 + $1 }
```

----------------------------------------

TITLE: Swift AsyncSequence Intersperse Basic Usage
DESCRIPTION: This snippet demonstrates the fundamental usage of the `interspersed(with:)` method on an `AsyncSequence`. It shows how a separator value (0) is inserted between elements of an array converted to an `AsyncSequence`, and also illustrates its behavior with an empty sequence.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Intersperse.md#_snippet_0

LANGUAGE: swift
CODE:
```
let numbers = [1, 2, 3].async.interspersed(with: 0)
for await number in numbers {
  print(number)
}
// prints 1 0 2 0 3

let empty = [].async.interspersed(with: 0)
// await Array(empty) == []
```

----------------------------------------

TITLE: Swift: SetAlgebra AsyncSequence Initializer
DESCRIPTION: Provides a public asynchronous initializer for SetAlgebra types. It constructs a set from an AsyncSequence where the source elements match the set's element type, rethrowing any errors from the sequence. This allows creating sets, option sets, or index sets from asynchronous streams.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Collections.md#_snippet_2

LANGUAGE: swift
CODE:
```
extension SetAlgebra {
  public init<Source: AsyncSequence>(
    _ source: Source
  ) async rethrows
    where Source.Element == Element
}
```

----------------------------------------

TITLE: APIDOC: Swift Async Merge Function and Sequence Definitions
DESCRIPTION: This section provides the API definitions for the 'merge' functions and their corresponding 'AsyncMerge2Sequence' and 'AsyncMerge3Sequence' types. It details the generic constraints, 'Sendable' requirements, and the structure of the 'AsyncIteratorProtocol' for iterating over the merged sequence. These definitions outline how the 'merge' operation supports combining two or three asynchronous sequences.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/0002-merge.md#_snippet_1

LANGUAGE: APIDOC
CODE:
```
public func merge<Base1: AsyncSequence, Base2: AsyncSequence>(_ base1: Base1, _ base2: Base2) -> AsyncMerge2Sequence<Base1, Base2>

public func merge<Base1: AsyncSequence, Base2: AsyncSequence, Base3: AsyncSequence>(_ base1: Base1, _ base2: Base2, _ base3: Base3) -> AsyncMerge3Sequence<Base1, Base2, Base3>

public struct AsyncMerge2Sequence<Base1: AsyncSequence, Base2: AsyncSequence>: Sendable
  where
    Base1.Element == Base2.Element,
    Base1: Sendable, Base2: Sendable,
    Base1.Element: Sendable, Base2.Element: Sendable {
  public typealias Element = Base1.Element

  public struct Iterator: AsyncIteratorProtocol {
    public mutating func next() async rethrows -> Element?
  }

  public func makeAsyncIterator() -> Iterator
}

public struct AsyncMerge3Sequence<Base1: AsyncSequence, Base2: AsyncSequence, Base3: AsyncSequence>: Sendable
  where
    Base1.Element == Base2.Element, Base1.Element == Base3.Element,
    Base1: Sendable, Base2: Sendable, Base3: Sendable
    Base1.Element: Sendable, Base2.Element: Sendable, Base3.Element: Sendable {
  public typealias Element = Base1.Element

  public struct Iterator: AsyncIteratorProtocol {
    public mutating func next() async rethrows -> Element?
  }

  public func makeAsyncIterator() -> Iterator
}
```

----------------------------------------

TITLE: Swift AsyncSequenceValidationDiagram.Clock API Definition
DESCRIPTION: Defines the `Clock` struct within `AsyncSequenceValidationDiagram`, which provides controlled time for validation diagrams. It includes nested `Step` (for duration) and `Instant` (for points in time) types, and methods for time manipulation like `sleep`. The clock measures time in integral 'steps', with a fixed `minimumResolution` of one step, and ignores `sleep` tolerance for deterministic execution.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncSequenceValidation/AsyncSequenceValidation.docc/Validation.md#_snippet_7

LANGUAGE: Swift
CODE:
```
extension AsyncSequenceValidationDiagram {
  public struct Clock { }
}

extension AsyncSequenceValidationDiagram.Clock: Clock {
  public struct Step: DurationProtocol, Hashable, CustomStringConvertible {
    public static func + (lhs: Step, rhs: Step) -> Step
    public static func - (lhs: Step, rhs: Step) -> Step
    public static func / (lhs: Step, rhs: Int) -> Step
    public static func * (lhs: Step, rhs: Int) -> Step
    public static func / (lhs: Step, rhs: Step) -> Double
    public static func < (lhs: Step, rhs: Step) -> Bool

    public static var zero: Step

    public static func steps(_ amount: Int) -> Step
  }

  public struct Instant: InstantProtocol, CustomStringConvertible {
    public func advanced(by duration: Step) -> Instant

    public func duration(to other: Instant) -> Step
  }

  public var now: Instant { get }
  public var minimumResolution: Step { get }

  public func sleep(
    until deadline: Instant,
    tolerance: Step? = nil
  ) async throws
}
```

----------------------------------------

TITLE: Extend AsyncSequence to Join Elements in Swift
DESCRIPTION: Provides an extension to `AsyncSequence` where its elements are also `AsyncSequence`s, allowing them to be concatenated into a single `AsyncJoinedSequence` without a separator. This method simplifies the process of flattening a sequence of sequences.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Joined.md#_snippet_1

LANGUAGE: swift
CODE:
```
extension AsyncSequence where Element: AsyncSequence {
  public func joined() -> AsyncJoinedSequence<Self> {
    return AsyncJoinedSequence(self)
  }
}
```

----------------------------------------

TITLE: Chain two AsyncSequence types in Swift
DESCRIPTION: This Swift example demonstrates how to use the `chain` function to combine two `AsyncSequence` types. It prepends a custom preamble to the lines read from a file, then iterates and prints the combined sequence.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Chain.md#_snippet_0

LANGUAGE: swift
CODE:
```
let preamble = [
  "// Some header to add as a preamble",
  "//",
  ""
].async
let lines = chain(preamble, URL(fileURLWithPath: "/tmp/Sample.swift").lines)

for try await line in lines {
  print(line)
}
```

----------------------------------------

TITLE: Import AsyncAlgorithms Module in Swift Source
DESCRIPTION: Guidance on how to import the `AsyncAlgorithms` module into Swift source code to make its functionalities available for use.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/README.md#_snippet_13

LANGUAGE: Swift
CODE:
```
import AsyncAlgorithms
```

----------------------------------------

TITLE: Swift AsyncSequence interspersed(with:) API Signature
DESCRIPTION: This API documentation defines the `interspersed(with:)` method as an extension on `AsyncSequence`. It specifies that the method takes a `separator` of the same `Element` type as the sequence and returns an `AsyncInterspersedSequence` wrapping the original sequence.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Intersperse.md#_snippet_1

LANGUAGE: APIDOC
CODE:
```
extension AsyncSequence {
  func interspersed(with separator: Element) -> AsyncInterspersedSequence<Self>
}
```

----------------------------------------

TITLE: Swift AsyncSequence interspersed Method API
DESCRIPTION: API documentation for the `interspersed` method on `AsyncSequence`, detailing its parameters, return type, and purpose of inserting elements at regular intervals. This method allows specifying the frequency and the separator value.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/0011-interspersed.md#_snippet_3

LANGUAGE: APIDOC
CODE:
```
func interspersed(every: Int = 1, with separator: @Sendable @escaping () async throws -> Element) -> AsyncThrowingInterspersedSequence<Self>
  Parameters:
    every: Int = 1
      Dictates after how many elements a separator should be inserted.
    separator: @Sendable @escaping () async throws -> Element
      A closure that produces the value to insert in between each of this async sequence’s elements.
  Returns: AsyncThrowingInterspersedSequence<Self>
    The interspersed asynchronous sequence of elements.
```

----------------------------------------

TITLE: Example: Interspersing Elements in Swift AsyncSequence
DESCRIPTION: Illustrates how to use the `interspersed(with:)` method on an `AsyncSequence` to insert a specific separator between elements. The example shows an asynchronous sequence of strings being interspersed with a hyphen and then printed.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/0011-interspersed.md#_snippet_0

LANGUAGE: swift
CODE:
```
let input = ["A", "B", "C"].async
let interspersed = input.interspersed(with: "-")
for await element in interspersed {
  print(element)
}
// Prints "A" "-" "B" "-" "C"
```

----------------------------------------

TITLE: Swift AsyncSequence chunked API for Grouping
DESCRIPTION: Defines the `chunked` methods as extensions on `AsyncSequence`. These methods allow grouping elements based on a binary predicate, determining if two consecutive elements belong to the same group. One overload allows specifying the collection type for the chunks, while the other defaults to `[Element]`.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Chunked.md#_snippet_0

LANGUAGE: APIDOC
CODE:
```
extension AsyncSequence {
  public func chunked<Collected: RangeReplaceableCollection>(
    into: Collected.Type,
  	by belongInSameGroup: @escaping @Sendable (Element, Element) -> Bool
  ) -> AsyncChunkedByGroupSequence<Self, Collected>
  	where Collected.Element == Element

  public func chunked(
  	by belongInSameGroup: @escaping @Sendable (Element, Element) -> Bool
  ) -> AsyncChunkedByGroupSequence<Self, [Element]>
}
```

----------------------------------------

TITLE: Swift AsyncSequence Extension for Chunking
DESCRIPTION: Defines various `chunks` and `chunked` methods on `AsyncSequence` to partition elements based on count, a signal, or a timer. These methods return `AsyncChunksOfCountOrSignalSequence`.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/NNNN-chunk.md#_snippet_8

LANGUAGE: swift
CODE:
```
extension AsyncSequence {
  public func chunks<Signal, Collected: RangeReplaceableCollection>(
    ofCount count: Int,
    or signal: Signal,
    into: Collected.Type
  ) -> AsyncChunksOfCountOrSignalSequence<Self, Collected, Signal>
    where Collected.Element == Element

  public func chunks<Signal>(
    ofCount count: Int,
    or signal: Signal
  ) -> AsyncChunksOfCountOrSignalSequence<Self, [Element], Signal>

  public func chunked<C: Clock, Collected: RangeReplaceableCollection>(
    by timer: AsyncTimerSequence<C>,
    into: Collected.Type
  ) -> AsyncChunksOfCountOrSignalSequence<Self, Collected, AsyncTimerSequence<C>>
    where Collected.Element == Element

  public func chunked<C: Clock>(
    by timer: AsyncTimerSequence<C>
  ) -> AsyncChunksOfCountOrSignalSequence<Self, [Element], AsyncTimerSequence<C>>
}
```

----------------------------------------

TITLE: Swift Async Zip Function and Sequence API Definition
DESCRIPTION: This section defines the public API for the `zip` function and its associated `AsyncZip2Sequence` and `AsyncZip3Sequence` types within Swift Async Algorithms. It details the generic parameters, `Sendable` requirements, and the `Element` typealias for the resulting tuples. It also outlines the `Iterator` struct and its `next()` method for asynchronous iteration.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Zip.md#_snippet_1

LANGUAGE: APIDOC
CODE:
```
public func zip<Base1: AsyncSequence, Base2: AsyncSequence>(_ base1: Base1, _ base2: Base2) -> AsyncZip2Sequence<Base1, Base2>

public func zip<Base1: AsyncSequence, Base2: AsyncSequence, Base3: AsyncSequence>(_ base1: Base1, _ base2: Base2, _ base3: Base3) -> AsyncZip3Sequence<Base1, Base2, Base3>

public struct AsyncZip2Sequence<Base1: AsyncSequence, Base2: AsyncSequence>: Sendable
  where
    Base1: Sendable, Base2: Sendable,
    Base1.Element: Sendable, Base2.Element: Sendable,
    Base1.AsyncIterator: Sendable, Base2.AsyncIterator: Sendable {
  public typealias Element = (Base1.Element, Base2.Element)

  public struct Iterator: AsyncIteratorProtocol {
    public mutating func next() async rethrows -> Element?
  }

  public func makeAsyncIterator() -> Iterator
}

public struct AsyncZip3Sequence<Base1: AsyncSequence, Base2: AsyncSequence, Base3: AsyncSequence>: Sendable
  where
    Base1: Sendable, Base2: Sendable, Base3: Sendable
    Base1.Element: Sendable, Base2.Element: Sendable, Base3.Element: Sendable
    Base1.AsyncIterator: Sendable, Base2.AsyncIterator: Sendable, Base3.AsyncIterator: Sendable {
  public typealias Element = (Base1.Element, Base2.Element, Base3.Element)

  public struct Iterator: AsyncIteratorProtocol {
    public mutating func next() async rethrows -> Element?
  }

  public func makeAsyncIterator() -> Iterator
}
```

----------------------------------------

TITLE: Swift AsyncInterspersedSequence Structure and Iterator Implementation
DESCRIPTION: This Swift code defines the `AsyncInterspersedSequence` struct and its nested `Iterator`. The sequence allows interspersing elements from a base `AsyncSequence` with a specified separator. It supports element, synchronous closure, and asynchronous closure separators. The `Iterator` manages the state to correctly yield base elements and separators, handling asynchronous operations and error propagation.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/0011-interspersed.md#_snippet_4

LANGUAGE: Swift
CODE:
```
/// An asynchronous sequence that presents the elements of a base asynchronous sequence of
/// elements with a separator between each of those elements.
public struct AsyncInterspersedSequence<Base: AsyncSequence> {
    @usableFromInline
    internal enum Separator {
        case element(Element)
        case syncClosure(@Sendable () -> Element)
        case asyncClosure(@Sendable () async -> Element)
    }

    @usableFromInline
    internal let base: Base

    @usableFromInline
    internal let separator: Separator

    @usableFromInline
    internal let every: Int

    @usableFromInline
    internal init(_ base: Base, every: Int, separator: Element) {
        precondition(every > 0, "Separators can only be interspersed every 1+ elements")
        self.base = base
        self.separator = .element(separator)
        self.every = every
    }

    @usableFromInline
    internal init(_ base: Base, every: Int, separator: @Sendable @escaping () -> Element) {
        precondition(every > 0, "Separators can only be interspersed every 1+ elements")
        self.base = base
        self.separator = .syncClosure(separator)
        self.every = every
    }

    @usableFromInline
    internal init(_ base: Base, every: Int, separator: @Sendable @escaping () async -> Element) {
        precondition(every > 0, "Separators can only be interspersed every 1+ elements")
        self.base = base
        self.separator = .asyncClosure(separator)
        self.every = every
    }
}

extension AsyncInterspersedSequence: AsyncSequence {
    public typealias Element = Base.Element

    /// The iterator for an `AsyncInterspersedSequence` asynchronous sequence.
    public struct Iterator: AsyncIteratorProtocol {
        @usableFromInline
        internal enum State {
            case start(Element?)
            case element(Int)
            case separator
            case finished
        }

        @usableFromInline
        internal var iterator: Base.AsyncIterator

        @usableFromInline
        internal let separator: Separator

        @usableFromInline
        internal let every: Int

        @usableFromInline
        internal var state = State.start(nil)

        @usableFromInline
        internal init(_ iterator: Base.AsyncIterator, every: Int, separator: Separator) {
            self.iterator = iterator
            self.separator = separator
            self.every = every
        }

        public mutating func next() async rethrows -> Base.Element? {
            // After the start, the state flips between element and separator. Before
            // returning a separator, a check is made for the next element as a
            // separator is only returned between two elements. The next element is
            // stored to allow it to be returned in the next iteration. However, if
            // the checking the next element throws, the separator is emitted before
            // rethrowing that error.
            switch state {
            case var .start(element):
                do {
                    if element == nil {
                        element = try await self.iterator.next()
                    }

                    if let element = element {
                        if every == 1 {
                            state = .separator
                        } else {
                            state = .element(1)
                        }
                        return element
                    } else {
                        state = .finished
                        return nil
                    }
                } catch {
                    state = .finished
                    throw error
                }

            case .separator:
                do {
                    if let element = try await iterator.next() {
                        state = .start(element)
                        switch separator {
                        case let .element(element):
                            return element

                        case let .syncClosure(closure):
                            return closure()

                        case let .asyncClosure(closure):
                            return await closure()
                        }
                    } else {
                        state = .finished
                        return nil
                    }
                } catch {
                    state = .finished
                    throw error
                }

            case let .element(count):
                do {
                    if let element = try await iterator.next() {

```

----------------------------------------

TITLE: AsyncJoinedBySeparatorSequence Structure and Sendable Conformance (Swift API)
DESCRIPTION: Defines the `AsyncJoinedBySeparatorSequence` struct, which concatenates an asynchronous sequence of asynchronous sequences with an inserted separator. It specifies the `Element` typealias, the `Iterator` struct, and the `makeAsyncIterator` method. It also details the conditional `Sendable` conformance for both the sequence and its iterator, ensuring thread-safety when underlying types conform.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Joined.md#_snippet_4

LANGUAGE: APIDOC
CODE:
```
public struct AsyncJoinedBySeparatorSequence<Base: AsyncSequence, Separator: AsyncSequence>: AsyncSequence
  where Base.Element: AsyncSequence, Separator.Element == Base.Element.Element {
  public typealias Element = Base.Element.Element

  public struct Iterator: AsyncIteratorProtocol {
    public mutating func next() async rethrows -> Base.Element.Element?
  }

  public func makeAsyncIterator() -> Iterator
}

extension AsyncJoinedBySeparatorSequence: Sendable
  where
    Base: Sendable,
    Base.Element: Sendable,
    Base.Element.Element: Sendable,
    Base.AsyncIterator: Sendable,
    Separator: Sendable,
    Separator.AsyncIterator: Sendable,
    Base.Element.AsyncIterator: Sendable { }

extension AsyncJoinedBySeparatorSequence.Iterator: Sendable
  where
    Base: Sendable,
    Base.Element: Sendable,
    Base.Element.Element: Sendable,
    Base.AsyncIterator: Sendable,
    Separator: Sendable,
    Separator.AsyncIterator: Sendable,
    Base.Element.AsyncIterator: Sendable { }
```

----------------------------------------

TITLE: Swift AsyncThrottleSequence Core Structure
DESCRIPTION: Defines the `AsyncThrottleSequence` struct, which is the concrete type implementing the throttle algorithm. It conforms to `AsyncSequence`, specifying its `Element` type and providing an `AsyncIteratorProtocol`. Conditional `Sendable` conformance is also shown, ensuring thread safety when base types are `Sendable`.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Throttle.md#_snippet_2

LANGUAGE: swift
CODE:
```
public struct AsyncThrottleSequence<Base: AsyncSequence, C: Clock, Reduced> {
}

extension AsyncThrottleSequence: AsyncSequence {
  public typealias Element = Reduced

  public struct Iterator: AsyncIteratorProtocol {
    public mutating func next() async rethrows -> Reduced?
  }

  public func makeAsyncIterator() -> Iterator
}

extension AsyncThrottleSequence: Sendable
  where Base: Sendable, Element: Sendable { }
extension AsyncThrottleSequence.Iterator: Sendable
  where Base.AsyncIterator: Sendable { }
```

----------------------------------------

TITLE: Extend AsyncSequence to Join Elements with Separator in Swift
DESCRIPTION: Provides an extension to `AsyncSequence` where its elements are also `AsyncSequence`s, allowing them to be concatenated into a single `AsyncJoinedBySeparatorSequence` with a specified separator sequence inserted between each joined sequence. This is useful for visually separating concatenated data streams.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Joined.md#_snippet_2

LANGUAGE: swift
CODE:
```
extension AsyncSequence where Element: AsyncSequence {
  public func joined<Separator: AsyncSequence>(separator: Separator) -> AsyncJoinedBySeparatorSequence<Self, Separator> {
    return AsyncJoinedBySeparatorSequence(self, separator: separator)
  }
}
```

----------------------------------------

TITLE: AsyncChannel and AsyncThrowingChannel Class Definitions
DESCRIPTION: Defines the public interfaces for `AsyncChannel` and `AsyncThrowingChannel`, which are reference-type asynchronous sequences. These classes provide methods for sending elements (`send`), signaling completion (`finish`), or indicating failure (`fail` for throwing channels), and include an `AsyncIteratorProtocol` for consumption.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Channel.md#_snippet_0

LANGUAGE: swift
CODE:
```
public final class AsyncChannel<Element: Sendable>: AsyncSequence, Sendable {
  public struct Iterator: AsyncIteratorProtocol, Sendable {
    public mutating func next() async -> Element?
  }

  public init(element elementType: Element.Type = Element.self)

  public func send(_ element: Element) async
  public func finish()

  public func makeAsyncIterator() -> Iterator
}

public final class AsyncThrowingChannel<Element: Sendable, Failure: Error>: AsyncSequence, Sendable {
  public struct Iterator: AsyncIteratorProtocol, Sendable {
    public mutating func next() async throws -> Element?
  }

  public init(element elementType: Element.Type = Element.self, failure failureType: Failure.Type = Failure.self)

  public func send(_ element: Element) async
  public func fail(_ error: Error) where Failure == Error
  public func finish()

  public func makeAsyncIterator() -> Iterator
}
```

----------------------------------------

TITLE: Swift Async Algorithms Combine Latest API Reference
DESCRIPTION: This section provides the API definitions for the `combineLatest` functions and their associated return types, `AsyncCombineLatest2Sequence` and `AsyncCombineLatest3Sequence`. It details the generic constraints, element types, and iterator protocols for combining two or three asynchronous sequences, emphasizing the `Sendable` requirements for concurrent execution.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/CombineLatest.md#_snippet_1

LANGUAGE: APIDOC
CODE:
```
public func combineLatest<Base1: AsyncSequence, Base2: AsyncSequence>(_ base1: Base1, _ base2: Base2) -> AsyncCombineLatest2Sequence<Base1, Base2>

public func combineLatest<Base1: AsyncSequence, Base2: AsyncSequence, Base3: AsyncSequence>(_ base1: Base1, _ base2: Base2, _ base3: Base3) -> AsyncCombineLatest3Sequence<Base1, Base2, Base3>

public struct AsyncCombineLatest2Sequence<Base1: AsyncSequence, Base2: AsyncSequence>: Sendable
  where
    Base1: Sendable, Base2: Sendable,
    Base1.Element: Sendable, Base2.Element: Sendable,
    Base1.AsyncIterator: Sendable, Base2.AsyncIterator: Sendable {
  public typealias Element = (Base1.Element, Base2.Element)

  public struct Iterator: AsyncIteratorProtocol {
    public mutating func next() async rethrows -> Element?
  }

  public func makeAsyncIterator() -> Iterator
}

public struct AsyncCombineLatest3Sequence<Base1: AsyncSequence, Base2: AsyncSequence, Base3: AsyncSequence>: Sendable
  where
    Base1: Sendable, Base2: Sendable, Base3: Sendable
    Base1.Element: Sendable, Base2.Element: Sendable, Base3.Element: Sendable
    Base1.AsyncIterator: Sendable, Base2.AsyncIterator: Sendable, Base3.AsyncIterator: Sendable {
  public typealias Element = (Base1.Element, Base2.Element, Base3.Element)

  public struct Iterator: AsyncIteratorProtocol {
    public mutating func next() async rethrows -> Element?
  }

  public func makeAsyncIterator() -> Iterator
}
```

----------------------------------------

TITLE: Swift AsyncSequence chunked(by:) API Definition
DESCRIPTION: Defines the `chunked` methods for `AsyncSequence` that group elements based on a closure comparing two consecutive elements. It includes overloads for specifying a custom `RangeReplaceableCollection` type or using the default `Array`.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/NNNN-chunk.md#_snippet_0

LANGUAGE: swift
CODE:
```
extension AsyncSequence {
  public func chunked<Collected: RangeReplaceableCollection>(
    into: Collected.Type,
  	by belongInSameGroup: @escaping @Sendable (Element, Element) -> Bool
  ) -> AsyncChunkedByGroupSequence<Self, Collected>
  	where Collected.Element == Element

  public func chunked(
  	by belongInSameGroup: @escaping @Sendable (Element, Element) -> Bool
  ) -> AsyncChunkedByGroupSequence<Self, [Element]>
}
```

----------------------------------------

TITLE: Swift AsyncSequence Chunking by Signal API
DESCRIPTION: Defines the `chunked` methods for `AsyncSequence` that group elements into collections based on an external signal. Overloads are provided for general signals and specialized `AsyncTimerSequence` signals, allowing custom collection types or defaulting to `[Element]`.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Chunked.md#_snippet_8

LANGUAGE: APIDOC
CODE:
```
extension AsyncSequence {
  public func chunked<Signal, Collected: RangeReplaceableCollection>(
    by signal: Signal,
    into: Collected.Type
  ) -> AsyncChunksOfCountOrSignalSequence<Self, Collected, Signal>
    where Collected.Element == Element

  public func chunked<Signal>(
    by signal: Signal
  ) -> AsyncChunksOfCountOrSignalSequence<Self, [Element], Signal>

  public func chunked<C: Clock, Collected: RangeReplaceableCollection>(
    by timer: AsyncTimerSequence<C>,
    into: Collected.Type
  ) -> AsyncChunksOfCountOrSignalSequence<Self, Collected, AsyncTimerSequence<C>>
    where Collected.Element == Element

  public func chunked<C: Clock>(
    by timer: AsyncTimerSequence<C>
  ) -> AsyncChunksOfCountOrSignalSequence<Self, [Element], AsyncTimerSequence<C>>
}
```

----------------------------------------

TITLE: Swift AsyncSequence Chunking by Count or Signal API
DESCRIPTION: Defines the `chunks` methods for `AsyncSequence` that group elements based on either a specified count or an external signal. This allows for flexible chunking where elements are emitted when either condition is met, with overloads for custom collection types and `AsyncTimerSequence`.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Chunked.md#_snippet_10

LANGUAGE: APIDOC
CODE:
```
extension AsyncSequence {
  public func chunks<Signal, Collected: RangeReplaceableCollection>(
    ofCount count: Int,
    or signal: Signal,
    into: Collected.Type
  ) -> AsyncChunksOfCountOrSignalSequence<Self, Collected, Signal>
    where Collected.Element == Element

  public func chunks<Signal>(
    ofCount count: Int,
    or signal: Signal
  ) -> AsyncChunksOfCountOrSignalSequence<Self, [Element], Signal>

  public func chunked<C: Clock, Collected: RangeReplaceableCollection>(
    by timer: AsyncTimerSequence<C>,
    into: Collected.Type
  ) -> AsyncChunksOfCountOrSignalSequence<Self, Collected, AsyncTimerSequence<C>>
    where Collected.Element == Element

  public func chunked<C: Clock>(
    by timer: AsyncTimerSequence<C>
  ) -> AsyncChunksOfCountOrSignalSequence<Self, [Element], AsyncTimerSequence<C>>
}
```

----------------------------------------

TITLE: Swift Async Merge API Definitions
DESCRIPTION: Defines the `merge` functions for two and three asynchronous sequences, along with the `AsyncMerge2Sequence` and `AsyncMerge3Sequence` structs and their associated iterators. It specifies `Sendable` requirements for the base sequences, their elements, and iterators, which are crucial for concurrent iteration. The sequence terminates when all base sequences terminate, and throws an error immediately if any base sequence throws.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Merge.md#_snippet_1

LANGUAGE: APIDOC
CODE:
```
public func merge<Base1: AsyncSequence, Base2: AsyncSequence>(_ base1: Base1, _ base2: Base2) -> AsyncMerge2Sequence<Base1, Base2>

public func merge<Base1: AsyncSequence, Base2: AsyncSequence, Base3: AsyncSequence>(_ base1: Base1, _ base2: Base2, _ base3: Base3) -> AsyncMerge3Sequence<Base1, Base2, Base3>

public struct AsyncMerge2Sequence<Base1: AsyncSequence, Base2: AsyncSequence>: Sendable
  where
    Base1.Element == Base2.Element,
    Base1: Sendable, Base2: Sendable,
    Base1.Element: Sendable, Base2.Element: Sendable,
    Base1.AsyncIterator: Sendable, Base2.AsyncIterator: Sendable {
  public typealias Element = Base1.Element

  public struct Iterator: AsyncIteratorProtocol {
    public mutating func next() async rethrows -> Element?
  }

  public func makeAsyncIterator() -> Iterator
}

public struct AsyncMerge3Sequence<Base1: AsyncSequence, Base2: AsyncSequence, Base3: AsyncSequence>: Sendable
  where
    Base1.Element == Base2.Element, Base1.Element == Base3.Element,
    Base1: Sendable, Base2: Sendable, Base3: Sendable
    Base1.Element: Sendable, Base2.Element: Sendable, Base3.Element: Sendable
    Base1.AsyncIterator: Sendable, Base2.AsyncIterator: Sendable, Base3.AsyncIterator: Sendable {
  public typealias Element = Base1.Element

  public struct Iterator: AsyncIteratorProtocol {
    public mutating func next() async rethrows -> Element?
  }

  public func makeAsyncIterator() -> Iterator
}
```

----------------------------------------

TITLE: Swift: Define adjacentPairs() extension for AsyncSequence
DESCRIPTION: This snippet defines the `adjacentPairs()` method as a public extension on `AsyncSequence`, which returns an `AsyncAdjacentPairsSequence` containing pairs of adjacent elements from the original sequence.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/AdjacentPairs.md#_snippet_0

LANGUAGE: Swift
CODE:
```
extension AsyncSequence {
  public func adjacentPairs() -> AsyncAdjacentPairsSequence<Self>
}
```

----------------------------------------

TITLE: Swift AsyncRemoveDuplicatesSequence Struct Definition
DESCRIPTION: This Swift struct defines `AsyncRemoveDuplicatesSequence`, an `AsyncSequence` that removes consecutive duplicate elements. It includes an `Iterator` and conforms to `Sendable` under specific conditions, rethrowing errors from its base sequence.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/RemoveDuplicates.md#_snippet_1

LANGUAGE: Swift
CODE:
```
public struct AsyncRemoveDuplicatesSequence<Base: AsyncSequence>: AsyncSequence {
  public typealias Element = Base.Element

  public struct Iterator: AsyncIteratorProtocol {
    public mutating func next() async rethrows -> Element?
  }

  public func makeAsyncIterator() -> Iterator {
    Iterator(iterator: base.makeAsyncIterator(), predicate: predicate)
  }
}

extension AsyncRemoveDuplicatesSequence: Sendable
  where Base: Sendable, Base.Element: Sendable, Base.AsyncIterator: Sendable { }

extension AsyncRemoveDuplicatesSequence.Iterator: Sendable
  where Base: Sendable, Base.Element: Sendable, Base.AsyncIterator: Sendable { }
```

----------------------------------------

TITLE: AsyncCompactedSequence and Iterator Definition
DESCRIPTION: This Swift code defines the `AsyncCompactedSequence` struct and its nested `Iterator`. It details the conformance to `AsyncSequence` and `AsyncIteratorProtocol` respectively, showing how the sequence processes optional elements from its base. Additionally, it specifies the conditions under which `AsyncCompactedSequence` and its `Iterator` become `Sendable`.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/0003-compacted.md#_snippet_1

LANGUAGE: swift
CODE:
```
public struct AsyncCompactedSequence<Base: AsyncSequence, Element>: AsyncSequence
  where Base.Element == Element? {

  public struct Iterator: AsyncIteratorProtocol {
    public mutating func next() async rethrows -> Element?
  }

  public func makeAsyncIterator() -> Iterator {
    Iterator(base.makeAsyncIterator())
  }
}

extension AsyncCompactedSequence: Sendable
  where
    Base: Sendable, Base.Element: Sendable,
    Base.AsyncIterator: Sendable { }

extension AsyncCompactedSequence.Iterator: Sendable
  where
    Base: Sendable, Base.Element: Sendable,
    Base.AsyncIterator: Sendable { }
```

----------------------------------------

TITLE: Optimize Async Iteration: AsyncBufferedByteIterator
DESCRIPTION: The `AsyncBufferedByteIterator` is a highly efficient iterator specifically designed for processing byte sequences. It's useful when iterating over data derived from asynchronous read functions, such as network streams or file I/O. This iterator optimizes performance for byte-level operations, reducing overhead in high-throughput scenarios.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/README.md#_snippet_8

LANGUAGE: APIDOC
CODE:
```
AsyncBufferedByteIterator
  description: A highly efficient iterator useful for iterating byte sequences derived from asynchronous read functions.
```

----------------------------------------

TITLE: Swift AsyncSequence: removeDuplicates() API Extensions
DESCRIPTION: These Swift extensions add `removeDuplicates()` methods to `AsyncSequence`. They provide variants for `Equatable` elements, custom non-throwing predicates, and custom throwing predicates, allowing removal of consecutive duplicate values from an asynchronous sequence.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/RemoveDuplicates.md#_snippet_0

LANGUAGE: Swift
CODE:
```
extension AsyncSequence where Element: Equatable {
  public func removeDuplicates() -> AsyncRemoveDuplicatesSequence<Self>
}

extension AsyncSequence {
  public func removeDuplicates(
    by predicate: @escaping @Sendable (Element, Element) async -> Bool
  ) -> AsyncRemoveDuplicatesSequence<Self>

  public func removeDuplicates(
    by predicate: @escaping @Sendable (Element, Element) async throws -> Bool
  ) -> AsyncThrowingRemoveDuplicatesSequence<Self>
}
```

----------------------------------------

TITLE: Extend AsyncSequence with Buffer Operator and Define AsyncBufferSequence
DESCRIPTION: This Swift code extends `AsyncSequence` with a `buffer()` operator, allowing any `AsyncSequence` to incorporate buffering. It also defines the `AsyncBufferSequence` struct, which wraps the base sequence and manages the buffering mechanism. The `AsyncBufferSequence` conforms to `AsyncSequence` and provides its own `makeAsyncIterator()` method, along with an `Iterator` struct for element consumption.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/0010-buffer.md#_snippet_1

LANGUAGE: swift
CODE:
```
extension AsyncSequence where Self: Sendable {
  public func buffer(
    policy: AsyncBufferSequencePolicy
  ) -> AsyncBufferSequence<Self> {
    AsyncBufferSequence<Self>(base: self, policy: policy)
  }
}

public struct AsyncBufferSequence<Base: AsyncSequence & Sendable>: AsyncSequence {
  public typealias Element = Base.Element

  public func makeAsyncIterator() -> Iterator

  public struct Iterator: AsyncIteratorProtocol {
    public mutating func next() async rethrows -> Element?
  }
}

extension AsyncBufferSequence: Sendable where Base: Sendable { }
```

----------------------------------------

TITLE: Swift Async Algorithms: combineLatest Function and Associated Types API
DESCRIPTION: This API documentation defines the `combineLatest` functions for two and three asynchronous sequences, along with their corresponding return types, `AsyncCombineLatest2Sequence` and `AsyncCombineLatest3Sequence`. It details the generic constraints, `Sendable` requirements, and the `Element` typealias for the resulting tuple. It also outlines the `Iterator` struct and its `next()` method for asynchronous iteration.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/0006-combineLatest.md#_snippet_1

LANGUAGE: APIDOC
CODE:
```
public func combineLatest<Base1: AsyncSequence, Base2: AsyncSequence>(_ base1: Base1, _ base2: Base2) -> AsyncCombineLatest2Sequence<Base1, Base2>

public func combineLatest<Base1: AsyncSequence, Base2: AsyncSequence, Base3: AsyncSequence>(_ base1: Base1, _ base2: Base2, _ base3: Base3) -> AsyncCombineLatest3Sequence<Base1, Base2, Base3>

public struct AsyncCombineLatest2Sequence<Base1: AsyncSequence, Base2: AsyncSequence>: Sendable
  where
    Base1: Sendable, Base2: Sendable,
    Base1.Element: Sendable, Base2.Element: Sendable {
  public typealias Element = (Base1.Element, Base2.Element)

  public struct Iterator: AsyncIteratorProtocol {
    public mutating func next() async rethrows -> Element?
  }

  public func makeAsyncIterator() -> Iterator
}

public struct AsyncCombineLatest3Sequence<Base1: AsyncSequence, Base2: AsyncSequence, Base3: AsyncSequence>: Sendable
  where
    Base1: Sendable, Base2: Sendable, Base3: Sendable
    Base1.Element: Sendable, Base2.Element: Sendable, Base3.Element: Sendable {
  public typealias Element = (Base1.Element, Base2.Element, Base3.Element)

  public struct Iterator: AsyncIteratorProtocol {
    public mutating func next() async rethrows -> Element?
  }

  public func makeAsyncIterator() -> Iterator
}
```

----------------------------------------

TITLE: Define AsyncThrowingRemoveDuplicatesSequence in Swift
DESCRIPTION: Defines the throwing duplicate removal sequence type. This variant is used with a throwing predicate. It will rethrow if the base asynchronous sequence throws and may still throw if the base does not throw due to the predicate's potential to throw. It is conditionally Sendable when the base and base element are Sendable.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/NNNN-reductions.md#_snippet_8

LANGUAGE: Swift
CODE:
```
public struct AsyncThrowingRemoveDuplicatesSequence<Base: AsyncSequence>: AsyncSequence {
  public typealias Element = Base.Element

  public struct Iterator: AsyncIteratorProtocol {
    public mutating func next() async throws -> Element?
  }

  public func makeAsyncIterator() -> Iterator
}

extension AsyncThrowingRemoveDuplicatesSequence: Sendable
  where Base: Sendable, Base.Element: Sendable { }
```

----------------------------------------

TITLE: Swift AsyncSequence chunked(on:) Extension Methods
DESCRIPTION: Defines two `chunked` methods for `AsyncSequence` that group elements based on a `projection` function. The first allows specifying a `RangeReplaceableCollection` type for the chunks, while the second defaults to an `Array` of elements. These methods are used when chunks are determined by a property of the elements themselves.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Chunked.md#_snippet_3

LANGUAGE: Swift
CODE:
```
extension AsyncSequence {
  public func chunked<Subject : Equatable, Collected: RangeReplaceableCollection>(
    into: Collected.Type,
    on projection: @escaping @Sendable (Element) -> Subject
  ) -> AsyncChunkedOnProjectionSequence<Self, Subject, Collected>

  public func chunked<Subject : Equatable>(
  	on on projection: @escaping @Sendable (Element) -> Subject
  ) -> AsyncChunkedOnProjectionSequence<Self, Subject, [Element]>
}
```

----------------------------------------

TITLE: Swift AsyncSequence Zip API Reference
DESCRIPTION: API definitions for the `zip` functions that combine two or three `AsyncSequence` instances, and the `AsyncZip2Sequence` and `AsyncZip3Sequence` structs. Includes their generic constraints, `Element` typealiases, and `Iterator` structs with the `next()` method signature, highlighting `Sendable` requirements.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/0001-zip.md#_snippet_1

LANGUAGE: APIDOC
CODE:
```
public func zip<Base1: AsyncSequence, Base2: AsyncSequence>(_ base1: Base1, _ base2: Base2) -> AsyncZip2Sequence<Base1, Base2>

public func zip<Base1: AsyncSequence, Base2: AsyncSequence, Base3: AsyncSequence>(_ base1: Base1, _ base2: Base2, _ base3: Base3) -> AsyncZip3Sequence<Base1, Base2, Base3>

public struct AsyncZip2Sequence<Base1: AsyncSequence, Base2: AsyncSequence>: Sendable
  where
    Base1: Sendable, Base2: Sendable,
    Base1.Element: Sendable, Base2.Element: Sendable {
  public typealias Element = (Base1.Element, Base2.Element)

  public struct Iterator: AsyncIteratorProtocol {
    public mutating func next() async rethrows -> Element?
  }

  public func makeAsyncIterator() -> Iterator
}

public struct AsyncZip3Sequence<Base1: AsyncSequence, Base2: AsyncSequence, Base3: AsyncSequence>: Sendable
  where
    Base1: Sendable, Base2: Sendable, Base3: Sendable
    Base1.Element: Sendable, Base2.Element: Sendable, Base3.Element: Sendable {
  public typealias Element = (Base1.Element, Base2.Element, Base3.Element)

  public struct Iterator: AsyncIteratorProtocol {
    public mutating func next() async rethrows -> Element?
  }

  public func makeAsyncIterator() -> Iterator
}
```

----------------------------------------

TITLE: Swift: Throwing Async Exclusive Reductions Sequence Definition
DESCRIPTION: Defines the `AsyncThrowingExclusiveReductionsSequence` struct for throwing asynchronous reductions. Similar to its non-throwing counterpart, it conforms to `AsyncSequence` but its `Iterator`'s `next()` method can throw errors. Sendability is also conditional.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Reductions.md#_snippet_5

LANGUAGE: swift
CODE:
```
public struct AsyncThrowingExclusiveReductionsSequence<Base: AsyncSequence, Element> {
}

extension AsyncThrowingExclusiveReductionsSequence: AsyncSequence {
  public struct Iterator: AsyncIteratorProtocol {
    public mutating func next() async throws -> Element?
  }

  public func makeAsyncIterator() -> Iterator
}

extension AsyncThrowingExclusiveReductionsSequence: Sendable
  where Base: Sendable, Element: Sendable { }

extension AsyncThrowingExclusiveReductionsSequence.Iterator: Sendable
  where Base.AsyncIterator: Sendable, Element: Sendable { }
```

----------------------------------------

TITLE: API Documentation: AsyncSequence.interspersed Method Overloads
DESCRIPTION: Defines the proposed `interspersed` method overloads for `AsyncSequence` in Swift. These methods allow inserting a separator (either a direct value or produced by a closure) between elements of an asynchronous sequence, with options for synchronous, asynchronous, or throwing separator generation.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/0011-interspersed.md#_snippet_1

LANGUAGE: APIDOC
CODE:
```
public extension AsyncSequence {
  /// Returns a new asynchronous sequence containing the elements of this asynchronous sequence, inserting
  /// the given separator between each element.
  ///
  /// Any value of this asynchronous sequence's element type can be used as the separator.
  ///
  /// - Parameters:
  ///   - every: Dictates after how many elements a separator should be inserted.
  ///   - separator: The value to insert in between each of this async sequence’s elements.
  /// - Returns: The interspersed asynchronous sequence of elements.
  @inlinable
  func interspersed(every: Int = 1, with separator: Element) -> AsyncInterspersedSequence<Self>

  /// Returns a new asynchronous sequence containing the elements of this asynchronous sequence, inserting
  /// the given separator between each element.
  ///
  /// Any value of this asynchronous sequence's element type can be used as the separator.
  ///
  /// - Parameters:
  ///   - every: Dictates after how many elements a separator should be inserted.
  ///   - separator: A closure that produces the value to insert in between each of this async sequence’s elements.
  /// - Returns: The interspersed asynchronous sequence of elements.
  @inlinable
  func interspersed(every: Int = 1, with separator: @Sendable @escaping () -> Element) -> AsyncInterspersedSequence<Self>

  /// Returns a new asynchronous sequence containing the elements of this asynchronous sequence, inserting
  /// the given separator between each element.
  ///
  /// Any value of this asynchronous sequence's element type can be used as the separator.
  ///
  /// - Parameters:
  ///   - every: Dictates after how many elements a separator should be inserted.
  ///   - separator: A closure that produces the value to insert in between each of this async sequence’s elements.
  /// - Returns: The interspersed asynchronous sequence of elements.
  @inlinable
  func interspersed(every: Int = 1, with separator: @Sendable @escaping () async -> Element) -> AsyncInterspersedSequence<Self>

  /// Returns a new asynchronous sequence containing the elements of this asynchronous sequence, inserting
  /// the given separator between each element.
  ///
  /// Any value of this asynchronous sequence's element type can be used as the separator.
  ///
  /// - Parameters:
  ///   - every: Dictates after how many elements a separator should be inserted.
  ///   - separator: A closure that produces the value to insert in between each of this async sequence’s elements.
  /// - Returns: The interspersed asynchronous sequence of elements.
  @inlinable
  public func interspersed(every: Int = 1, with separator: @Sendable @escaping () throws -> Element) -> AsyncThrowingInterspersedSequence<Self>
}
```

----------------------------------------

TITLE: Swift Chunking AsyncSequence by Predicate into ContiguousArray
DESCRIPTION: Illustrates using the `chunked` operation with a specified collection type, `ContiguousArray.self`. This allows the chunks to be collected into a different `RangeReplaceableCollection` type instead of the default `Array`, providing flexibility for memory layout or performance needs.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Chunked.md#_snippet_2

LANGUAGE: Swift
CODE:
```
let chunks = numbers.chunked(into: ContiguousArray.self) { $0 <= $1 }
for await numberChunk in chunks {
  print(numberChunk)
}
```

----------------------------------------

TITLE: Swift AsyncChain API Definitions and Conformance
DESCRIPTION: This section details the public API for the `chain` functions and associated `AsyncChainSequence` types. It includes the generic function signatures for chaining two or three `AsyncSequence` instances, the structure definitions for `AsyncChain2Sequence` and `AsyncChain3Sequence` including their `Element` typealias and `Iterator` protocols, and conditional `Sendable` conformances for both the sequences and their iterators.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/0007-chain.md#_snippet_1

LANGUAGE: APIDOC
CODE:
```
public func chain<Base1: AsyncSequence, Base2: AsyncSequence>(_ s1: Base1, _ s2: Base2) -> AsyncChain2Sequence<Base1, Base2> where Base1.Element == Base2.Element

public func chain<Base1: AsyncSequence, Base2: AsyncSequence, Base3: AsyncSequence>(_ s1: Base1, _ s2: Base2, _ s3: Base3) -> AsyncChain3Sequence<Base1, Base2, Base3>

public struct AsyncChain2Sequence<Base1: AsyncSequence, Base2: AsyncSequence> where Base1.Element == Base2.Element {
  public typealias Element = Base1.Element

  public struct Iterator: AsyncIteratorProtocol {
    public mutating func next() async rethrows -> Element?
  }

  public func makeAsyncIterator() -> Iterator
}

extension AsyncChain2Sequence: Sendable where Base1: Sendable, Base2: Sendable { }
extension AsyncChain2Sequence.Iterator: Sendable where Base1.AsyncIterator: Sendable, Base2.AsyncIterator: Sendable { }

public struct AsyncChain3Sequence<Base1: AsyncSequence, Base2: AsyncSequence, Base3: AsyncSequence> where Base1.Element == Base2.Element, Base1.Element == Base3.Element {
  public typealias Element = Base1.Element

  public struct Iterator: AsyncIteratorProtocol {
    public mutating func next() async rethrows -> Element?
  }

  public func makeAsyncIterator() -> Iterator
}

extension AsyncChain3Sequence: Sendable where Base1: Sendable, Base2: Sendable, Base3: Sendable { }
extension AsyncChain3Sequence.Iterator: Sendable where Base1.AsyncIterator: Sendable, Base2.AsyncIterator: Sendable, Base3.AsyncIterator: Sendable { }
```

----------------------------------------

TITLE: Throttle API Extension for AsyncSequence
DESCRIPTION: Defines the `throttle` methods available on `AsyncSequence` types, ensuring a minimum interval between emitted values. Includes overloads for custom clocks, `ContinuousClock`, and options for reducing values (latest/earliest).
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/NNNN-rate-limits.md#_snippet_2

LANGUAGE: Swift
CODE:
```
extension AsyncSequence {
  public func throttle<C: Clock, Reduced>(
    for interval: C.Instant.Duration,
    clock: C,
    reducing: @Sendable @escaping (Reduced?, Element) async -> Reduced
  ) -> AsyncThrottleSequence<Self, C, Reduced>

  public func throttle<Reduced>(
    for interval: Duration,
    reducing: @Sendable @escaping (Reduced?, Element) async -> Reduced
  ) -> AsyncThrottleSequence<Self, ContinuousClock, Reduced>

  public func throttle<C: Clock>(
    for interval: C.Instant.Duration,
    clock: C,
    latest: Bool = true
  ) -> AsyncThrottleSequence<Self, C, Element>

  public func throttle(
    for interval: Duration,
    latest: Bool = true
  ) -> AsyncThrottleSequence<Self, ContinuousClock, Element>
}
```

----------------------------------------

TITLE: Swift AsyncSequence Grouping Example with ContiguousArray
DESCRIPTION: Illustrates using the `chunked(into:by:)` method to group elements into a `ContiguousArray` instead of the default `Array`, showcasing the flexibility of specifying a custom `RangeReplaceableCollection` type. This variant is the funnel method for the main implementation, passing `[Element].self` as the parameter.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/NNNN-chunk.md#_snippet_2

LANGUAGE: swift
CODE:
```
let chunks = numbers.chunked(into: ContiguousArray.self) { $0 <= $1 }
for await numberChunk in chunks {
  print(numberChunk)
}
```

----------------------------------------

TITLE: Define adjacentPairs() method for AsyncSequence in Swift
DESCRIPTION: This Swift extension defines the `adjacentPairs()` method for any `AsyncSequence`. It returns an `AsyncAdjacentPairsSequence` which produces elements as tuples of two original `Element` types. The returned sequence conditionally conforms to `Sendable`.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/0005-adjacent-pairs.md#_snippet_0

LANGUAGE: Swift
CODE:
```
extension AsyncSequence {
  public func adjacentPairs() -> AsyncAdjacentPairsSequence<Self>
}
```

----------------------------------------

TITLE: Swift AsyncSequence Interspersed Element and Separator Logic
DESCRIPTION: This Swift code snippet illustrates the internal state management for an `AsyncInterspersedSequence` iterator. It handles advancing the sequence, inserting a separator after a specified number of elements (`every`), and managing error states or sequence termination. The `makeAsyncIterator` function is also included, showing how the iterator is initialized.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/0011-interspersed.md#_snippet_5

LANGUAGE: Swift
CODE:
```
                        let newCount = count + 1
                        if every == newCount {
                            state = .separator
                        } else {
                            state = .element(newCount)
                        }
                        return element
                    } else {
                        state = .finished
                        return nil
                    }
                } catch {
                    state = .finished
                    throw error
                }

            case .finished:
                return nil
            }
        }
    }

    @inlinable
    public func makeAsyncIterator() -> AsyncInterspersedSequence<Base>.Iterator {
        Iterator(base.makeAsyncIterator(), every: every, separator: separator)
    }
}
```

----------------------------------------

TITLE: Swift AsyncSequence chunks(ofCount:) Extension Methods
DESCRIPTION: Defines two `chunks` methods for `AsyncSequence` that group elements into chunks of a specified maximum `count`. The first allows specifying a `RangeReplaceableCollection` type for the chunks, while the second defaults to an `Array`. These methods are used when chunks are determined by an external size limit.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Sources/AsyncAlgorithms/AsyncAlgorithms.docc/Guides/Chunked.md#_snippet_6

LANGUAGE: Swift
CODE:
```
extension AsyncSequence {
  public func chunks<Collected: RangeReplaceableCollection>(
    ofCount count: Int,
    into: Collected.Type
  ) -> AsyncChunksOfCountSequence<Self, Collected>
    where Collected.Element == Element

  public func chunks(
    ofCount count: Int
  ) -> AsyncChunksOfCountSequence<Self, [Element]>
}
```

----------------------------------------

TITLE: Swift AsyncSequence joined() and joined(separator:) Extensions
DESCRIPTION: Defines the `joined()` and `joined(separator:)` methods as extensions on `AsyncSequence` where the elements are themselves `AsyncSequence`s, returning `AsyncJoinedSequence` or `AsyncJoinedBySeparatorSequence` respectively. These APIs enable concatenation of nested asynchronous sequences.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/0004-joined.md#_snippet_0

LANGUAGE: swift
CODE:
```
extension AsyncSequence where Element: AsyncSequence {
  public func joined() -> AsyncJoinedSequence<Self>
}

extension AsyncSequence where Element: AsyncSequence {
  public func joined<Separator: AsyncSequence>(separator: Separator) -> AsyncJoinedBySeparatorSequence<Self, Separator>
}
```

----------------------------------------

TITLE: Swift API: AsyncChunkedOnProjectionSequence
DESCRIPTION: Defines the `AsyncChunkedOnProjectionSequence` struct, an `AsyncSequence` that chunks elements based on a projected `Subject`. It includes its `Element` typealias, `Iterator` struct with a `next()` method, and `makeAsyncIterator()` method. It also shows `Sendable` conformance.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/NNNN-chunk.md#_snippet_11

LANGUAGE: swift
CODE:
```
public struct AsyncChunkedOnProjectionSequence<Base: AsyncSequence, Subject: Equatable, Collected: RangeReplaceableCollection>: AsyncSequence where Collected.Element == Base.Element {
  public typealias Element = (Subject, Collected)

  public struct Iterator: AsyncIteratorProtocol {
    public mutating func next() async rethrows -> (Subject, Collected)?
  }

  public func makeAsyncIterator() -> Iterator
}

extension AsyncChunkedOnProjectionSequence: Sendable
  where Base: Sendable, Base.Element: Sendable { }
extension AsyncChunkedOnProjectionSequence.Iterator: Sendable
  where Base.AsyncIterator: Sendable, Base.Element: Sendable, Subject: Sendable { }
```

----------------------------------------

TITLE: Swift AsyncSequence: Exclusive Reductions API Definitions
DESCRIPTION: Defines `reductions` methods for `AsyncSequence` that start with an `initial` value. These methods come in transforming and mutating variants, and can be throwing or non-throwing, similar to `reduce(_:_:)` and `reduce(into:_:)`.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/NNNN-reductions.md#_snippet_0

LANGUAGE: Swift
CODE:
```
extension AsyncSequence {
  public func reductions<Result>(
    _ initial: Result,
    _ transform: @Sendable @escaping (Result, Element) async -> Result
  ) -> AsyncExclusiveReductionsSequence<Self, Result>

  public func reductions<Result>(
    into initial: Result,
    _ transform: @Sendable @escaping (inout Result, Element) async -> Void
  ) -> AsyncExclusiveReductionsSequence<Self, Result>
}
```

LANGUAGE: Swift
CODE:
```
extension AsyncSequence {
  public func reductions<Result>(
    _ initial: Result,
    _ transform: @Sendable @escaping (Result, Element) async throws -> Result
  ) -> AsyncThrowingExclusiveReductionsSequence<Self, Result>

  public func reductions<Result>(
    into initial: Result,
    _ transform: @Sendable @escaping (inout Result, Element) async throws -> Void
  ) -> AsyncThrowingExclusiveReductionsSequence<Self, Result>
}
```

----------------------------------------

TITLE: Interspersing Elements in Swift Async Sequence
DESCRIPTION: Demonstrates how to insert a separator between elements of an asynchronous sequence using the `interspersed(with:)` method. This example uses a string literal as a separator and prints the resulting sequence.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/0011-interspersed.md#_snippet_2

LANGUAGE: Swift
CODE:
```
let input = ["A", "B", "C"].async
let interspersed = input.interspersed(with: "-")
for await element in interspersed {
  print(element)
}
// Prints "A" "-" "B" "-" "C"
```

----------------------------------------

TITLE: AsyncBufferedByteIterator Public API Reference
DESCRIPTION: This section outlines the public interface of `AsyncBufferedByteIterator`, an `AsyncIteratorProtocol` for `UInt8` elements. It details the initializer, which takes a buffer capacity and an asynchronous read function, and the `next()` method for retrieving individual bytes.
SOURCE: https://github.com/apple/swift-async-algorithms/blob/main/Evolution/0008-bytes.md#_snippet_1

LANGUAGE: APIDOC
CODE:
```
public struct AsyncBufferedByteIterator: AsyncIteratorProtocol {
  public typealias Element = UInt8

  public init(
    capacity: Int,
    readFunction: @Sendable @escaping (UnsafeMutableRawBufferPointer) async throws -> Int
  )

  public mutating func next() async throws -> UInt8?
}
```