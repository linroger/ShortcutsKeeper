TITLE: Using Deque from Collections Module (Swift)
DESCRIPTION: This snippet demonstrates how to import the top-level 'Collections' module to access all data structures and provides an example of initializing and manipulating a 'Deque' (double-ended queue) with string elements.
SOURCE: https://github.com/apple/swift-collections/blob/main/README.md#_snippet_0

LANGUAGE: swift
CODE:
```
import Collections

var deque: Deque<String> = ["Ted", "Rebecca"]
deques.prepend("Keeley")
deques.append("Nathan")
print(deque) // ["Keeley", "Ted", "Rebecca", "Nathan"]
```

----------------------------------------

TITLE: Adding Swift Collections as a SwiftPM Dependency
DESCRIPTION: This snippet demonstrates how to configure a Swift Package Manager Package.swift file to include the swift-collections library as a dependency, specifying the package URL and version requirement, and linking the product to a target.
SOURCE: https://github.com/apple/swift-collections/blob/main/README.md#_snippet_1

LANGUAGE: Swift
CODE:
```
// swift-tools-version:6.1
import PackageDescription

let package = Package(
  name: "MyPackage",
  dependencies: [
    .package(
      url: "https://github.com/apple/swift-collections.git",
      .upToNextMinor(from: "1.2.0") // or `.upToNextMajor
    )
  ],
  targets: [
    .target(
      name: "MyTarget",
      dependencies: [
        .product(name: "Collections", package: "swift-collections")
      ]
    )
  ]
)
```

----------------------------------------

TITLE: Using Queue Operations on a Swift Deque
DESCRIPTION: Demonstrates common queue-like operations such as appending elements (`append`), prepending single elements (`prepend`), removing from the ends (`popLast`, `popFirst`), and prepending a sequence of elements (`prepend(contentsOf:)`).
SOURCE: https://github.com/apple/swift-collections/blob/main/Documentation/Deque.md#_snippet_4

LANGUAGE: Swift
CODE:
```
colors.append("green")
colors.prepend("orange")
// colors: ["orange", "red", "blue", "yellow", "green"]

colors.popLast() // "green"
colors.popFirst() // "orange"
// colors: ["red", "blue", "yellow"]

colors.prepend(contentsOf: ["purple", "teal"])
// colors: ["purple", "teal", "red", "blue", "yellow"]
```

----------------------------------------

TITLE: Using Key-Based Subscript for Insertion and Access in OrderedDictionary in Swift
DESCRIPTION: Shows how to add new key-value pairs (which are appended) and access existing values using the key-based subscript, returning an optional.
SOURCE: https://github.com/apple/swift-collections/blob/main/Documentation/OrderedDictionary.md#_snippet_3

LANGUAGE: Swift
CODE:
```
var dictionary: OrderedDictionary<String, Int> = [:]
dictionary["one"] = 1
dictionary["two"] = 2
dictionary["three"] // nil
// dictionary is now ["one": 1, "two": 2]
```

----------------------------------------

TITLE: Removing Min/Max from Swift Heap
DESCRIPTION: Demonstrates removing and returning the smallest element using `popMin()` and the largest element using `popMax()` from a `Heap`.
SOURCE: https://github.com/apple/swift-collections/blob/main/Documentation/Heap.md#_snippet_8

LANGUAGE: swift
CODE:
```
var heap = Heap((1...20).shuffled())
var heap2 = heap

while let min = heap.popMin() {
    print("Next smallest element:", min)
}

while let max = heap2.popMax() {
    print("Next largest element:", max)
}
```

----------------------------------------

TITLE: Combining ShareableSet Instances - Swift
DESCRIPTION: Provides function signatures for non-mutating and mutating set algebra operations on `ShareableSet`, including intersection, union, subtraction, and symmetric difference. These operations support combining with other `ShareableSet` instances, `ShareableDictionary.Keys`, and arbitrary sequences.
SOURCE: https://github.com/apple/swift-collections/blob/main/Documentation/Reviews/2022-10-31.ShareableHashedCollections/ShareableHashedCollections.md#_snippet_7

LANGUAGE: Swift
CODE:
```
func intersection(`Self`) -> ShareableSet<Element>
func intersection<Value>(ShareableDictionary<Element, Value>.Keys) -> ShareableSet<Element>
func intersection<S>(S) -> ShareableSet<Element>

func union(`Self`) -> ShareableSet<Element>
func union<Value>(ShareableDictionary<Element, Value>.Keys) -> ShareableSet<Element>
func union<S>(S) -> ShareableSet<Element>

func subtracting(`Self`) -> ShareableSet<Element>
func subtracting<V>(ShareableDictionary<Element, V>.Keys) -> ShareableSet<Element>
func subtracting<S>(S) -> ShareableSet<Element>

func symmetricDifference(`Self`) -> ShareableSet<Element>
func symmetricDifference<Value>(ShareableDictionary<Element, Value>.Keys) -> ShareableSet<Element>
func symmetricDifference<S>(S) -> ShareableSet<Element>

mutating func formIntersection(`Self`)
mutating func formIntersection<Value>(ShareableDictionary<Element, Value>.Keys)
mutating func formIntersection<S>(S)

mutating func formUnion(`Self`)
mutating func formUnion<Value>(ShareableDictionary<Element, Value>.Keys)
mutating func formUnion<S>(S)

mutating func subtract(`Self`)
mutating func subtract<Value>(ShareableDictionary<Element, Value>.Keys)
mutating func subtract<S>(S)

mutating func formSymmetricDifference(`Self`)
mutating func formSymmetricDifference<Value>(ShareableDictionary<Element, Value>.Keys)
mutating func formSymmetricDifference<S>(S)
```

----------------------------------------

TITLE: Looking Up Min/Max in Swift Heap
DESCRIPTION: Retrieves the minimum and maximum elements from a `Heap` instance in constant time using the `min` and `max` properties.
SOURCE: https://github.com/apple/swift-collections/blob/main/Documentation/Heap.md#_snippet_6

LANGUAGE: swift
CODE:
```
var heap = Heap(1 ... 20)
let min = heap.min  // 1
let max = heap.max  // 20
```

----------------------------------------

TITLE: Accessing and Modifying Swift Deque Elements by Index
DESCRIPTION: Illustrates accessing elements using integer indices, demonstrates potential runtime errors for out-of-range access, and shows how to insert and remove elements at specific indices using `insert(at:)` and `remove(at:)`.
SOURCE: https://github.com/apple/swift-collections/blob/main/Documentation/Deque.md#_snippet_2

LANGUAGE: Swift
CODE:
```
print(colors[1]) // "yellow"
print(colors[3]) // Runtime error: Index out of range

colors.insert("green", at: 1)
// ["red", "green", "yellow", "blue"]

colors.remove(at: 2) // "yellow"
// ["red", "green", "blue"]
```

----------------------------------------

TITLE: Adding and Updating ShareableDictionary Values in Swift
DESCRIPTION: Presents methods for adding new key-value pairs or updating existing ones in a `ShareableDictionary`. This includes standard `updateValue` methods and variants that accept closures for in-place mutation, as well as `merge` operations.
SOURCE: https://github.com/apple/swift-collections/blob/main/Documentation/Reviews/2022-10-31.ShareableHashedCollections/ShareableHashedCollections.md#_snippet_14

LANGUAGE: Swift
CODE:
```
mutating func updateValue(Value, forKey: Key) -> Value?
mutating func updateValue<R>(forKey: Key, with: (inout Value?) throws -> R) rethrows -> R
mutating func updateValue<R>(forKey: Key, default: () -> Value, with: (inout Value) throws -> R) rethrows -> R

mutating func merge(`Self`, uniquingKeysWith: (Value, Value) throws -> Value) rethrows
mutating func merge<S>(S, uniquingKeysWith: (Value, Value) throws -> Value) rethrows

func merging(`Self`, uniquingKeysWith: (Value, Value) throws -> Value) rethrows -> ShareableDictionary<Key, Value>
func merging<S>(S, uniquingKeysWith: (Value, Value) throws -> Value) rethrows -> ShareableDictionary<Key, Value>
```

----------------------------------------

TITLE: Removing Elements from ShareableSet (Swift)
DESCRIPTION: This code block lists the methods available for removing elements from a `ShareableSet`. It includes methods to remove a specific element by value (`remove(_:)`), remove an element at a given index (`remove(at:)`), filter elements based on a condition (`filter(_:)`), and remove all elements matching a condition (`removeAll(where:)`).
SOURCE: https://github.com/apple/swift-collections/blob/main/Documentation/Reviews/2022-10-31.ShareableHashedCollections/ShareableHashedCollections.md#_snippet_6

LANGUAGE: swift
CODE:
```
mutating func remove(Element) -> Element?
mutating func remove(at: Index) -> Element
func filter((Element) throws -> Bool) rethrows -> ShareableSet<Element>
mutating func removeAll(where shouldBeRemoved: (Element) throws -> Bool) rethrows
```

----------------------------------------

TITLE: Removing ShareableDictionary Elements in Swift
DESCRIPTION: Outlines methods for removing key-value pairs from a `ShareableDictionary`. This includes removing by key, removing by index, filtering elements into a new dictionary, and removing elements based on a condition.
SOURCE: https://github.com/apple/swift-collections/blob/main/Documentation/Reviews/2022-10-31.ShareableHashedCollections/ShareableHashedCollections.md#_snippet_15

LANGUAGE: Swift
CODE:
```
mutating func removeValue(forKey: Key) -> Value?
mutating func remove(at: Index) -> Element
func filter((Element) throws -> Bool) rethrows -> ShareableDictionary<Key, Value>
mutating func removeAll(where shouldBeRemoved: (Element) throws -> Bool) rethrows
```

----------------------------------------

TITLE: Demonstrating Swift Deque Value Semantics (Copy-on-Write)
DESCRIPTION: Shows how modifying a copy of a deque does not affect the original deque instance, illustrating the value semantics and copy-on-write behavior.
SOURCE: https://github.com/apple/swift-collections/blob/main/Documentation/Deque.md#_snippet_3

LANGUAGE: Swift
CODE:
```
var copy = deque
copy[1] = "violet"
print(copy)  // ["red", "violet", "blue"]
print(deque) // ["red", "green", "blue"]
```

----------------------------------------

TITLE: Inserting Sequence of Elements into Swift Heap
DESCRIPTION: Inserts multiple elements from different sequences into an existing `Heap` using the `insert(contentsOf:)` method.
SOURCE: https://github.com/apple/swift-collections/blob/main/Documentation/Heap.md#_snippet_5

LANGUAGE: swift
CODE:
```
var heap = Heap(0 ..< 10)
heap.insert(contentsOf: (20 ... 100).shuffled())
heap.insert(contentsOf: [-5, -6, -8, -12, -3])
```

----------------------------------------

TITLE: Performing Set Operations on OrderedSet in Swift
DESCRIPTION: Shows examples of common set operations on an `OrderedSet` in Swift, including checking for element membership (`contains`) and finding the intersection with another collection, preserving the original order.
SOURCE: https://github.com/apple/swift-collections/blob/main/Documentation/OrderedSet.md#_snippet_3

LANGUAGE: swift
CODE:
```
buildingMaterials.contains("glass") // false
buildingMaterials.intersection(["bricks", "straw"]) // ["straw", "bricks"]
```

----------------------------------------

TITLE: Accessing Elements OrderedSet Swift
DESCRIPTION: This snippet demonstrates how to create an OrderedSet, access elements by index, find the index of an element, and iterate over the set using a standard for loop with indices. It highlights that OrderedSet is a random-access collection.
SOURCE: https://github.com/apple/swift-collections/blob/main/Documentation/OrderedSet.md#_snippet_7

LANGUAGE: swift
CODE:
```
let buildingMaterials: OrderedSet = ["straw", "sticks", "bricks"]
buildingMaterials[1] // "sticks"
buildingMaterials.firstIndex(of: "bricks") // 2

for i in 0 ..< buildingMaterials.count {
  print("Little piggie #\(i) built a house of \(buildingMaterials[i])")
}
// Little piggie #0 built a house of straw
// Little piggie #1 built a house of sticks
// Little piggie #2 built a house of bricks
```

----------------------------------------

TITLE: Inserting Single Element into Swift Heap
DESCRIPTION: Demonstrates inserting individual elements into an empty `Heap<Int>` using the `insert(_:)` method.
SOURCE: https://github.com/apple/swift-collections/blob/main/Documentation/Heap.md#_snippet_4

LANGUAGE: swift
CODE:
```
var heap = Heap<Int>()
heap.insert(6)
heap.insert(2)
```

----------------------------------------

TITLE: Accessing ShareableDictionary Elements in Swift
DESCRIPTION: Details methods for accessing values in a `ShareableDictionary` using keys, including the optional subscript, a subscript with a default value provider, and a method to find the index for a given key.
SOURCE: https://github.com/apple/swift-collections/blob/main/Documentation/Reviews/2022-10-31.ShareableHashedCollections/ShareableHashedCollections.md#_snippet_13

LANGUAGE: Swift
CODE:
```
subscript(Key) -> Value?
subscript(Key, default _: () -> Value) -> Value
func index(forKey: Key) -> Index?
```

----------------------------------------

TITLE: Finding Elements in ShareableSet (Swift)
DESCRIPTION: This code block presents methods for checking the presence of elements within a `ShareableSet` and finding their indices. It includes `contains(_:)` to check for membership and `firstIndex(of:)` and `lastIndex(of:)` to locate elements by value, noting that indices in `ShareableSet` are invalidated on mutation.
SOURCE: https://github.com/apple/swift-collections/blob/main/Documentation/Reviews/2022-10-31.ShareableHashedCollections/ShareableHashedCollections.md#_snippet_4

LANGUAGE: swift
CODE:
```
func contains(Element) -> Bool
func firstIndex(of: Element) -> Index?
func lastIndex(of: Element) -> Index?
```

----------------------------------------

TITLE: Accessing ShareableDictionary Views in Swift
DESCRIPTION: Documents the `Keys` and `Values` views provided by `ShareableDictionary`, which offer projections of the dictionary's keys and values. It also shows extensions on `Keys` for set-like operations such as intersection and subtraction.
SOURCE: https://github.com/apple/swift-collections/blob/main/Documentation/Reviews/2022-10-31.ShareableHashedCollections/ShareableHashedCollections.md#_snippet_10

LANGUAGE: Swift
CODE:
```
ShareableDictionary.Keys
ShareableDictionary.Values

var keys: Keys
var values: Values

extension ShareableDictionary.Keys {
  func contains(Element) -> Bool

  func intersection(ShareableSet<Key>) -> Self
  func intersection<Value2>(ShareableDictionary<Key, Value2>.Keys) -> Self

  func subtracting(ShareableSet<Key>) -> Self
  func subtracting<Value2>(ShareableDictionary<Key, Value2>.Keys) -> Self
}
```

----------------------------------------

TITLE: Initializing Swift Heap from Array Literal
DESCRIPTION: Creates a `Heap` instance with `Double` elements directly from an array literal.
SOURCE: https://github.com/apple/swift-collections/blob/main/Documentation/Heap.md#_snippet_3

LANGUAGE: swift
CODE:
```
var heap: Heap<Double> = [0.1, 0.6, 1.0, 0.15, 0.42]
```

----------------------------------------

TITLE: Accessing OrderedDictionary Elements (Swift)
DESCRIPTION: Demonstrates the difference between key-based subscript access (which returns nil for non-existent keys) and index-based access using the `.elements` collection view.
SOURCE: https://github.com/apple/swift-collections/blob/main/Documentation/OrderedDictionary.md#_snippet_6

LANGUAGE: Swift
CODE:
```
responses[0] // `nil` (key-based subscript)
responses.elements[0] // `(200, "OK")` (index-based subscript)
```

----------------------------------------

TITLE: Initializing ShareableDictionary in Swift
DESCRIPTION: Provides various initializers for creating instances of `ShareableDictionary`, including empty initialization, copying from other dictionaries or sequences, and initializing with unique keys or by grouping elements.
SOURCE: https://github.com/apple/swift-collections/blob/main/Documentation/Reviews/2022-10-31.ShareableHashedCollections/ShareableHashedCollections.md#_snippet_11

LANGUAGE: Swift
CODE:
```
init()
init(ShareableDictionary<Key, Value>)
init(Dictionary<Key, Value>)
init<S>(uniqueKeysWithValues: S)
init<S>(S, uniquingKeysWith: (Value, Value) throws -> Value) rethrows
init<S>(grouping: S, by: (S.Element) throws -> Key) rethrows
init(keys: ShareableSet<Key>, valueGenerator: (Key) throws -> Value) rethrows
```

----------------------------------------

TITLE: Initializing a Swift Deque
DESCRIPTION: Demonstrates how to initialize a `Deque` with an array literal, creating a mutable deque instance named `colors`.
SOURCE: https://github.com/apple/swift-collections/blob/main/Documentation/Deque.md#_snippet_1

LANGUAGE: Swift
CODE:
```
var colors: Deque = ["red", "yellow", "blue"]
```

----------------------------------------

TITLE: Converting OrderedSet to Array Swift
DESCRIPTION: This snippet demonstrates how to access the contents of an OrderedSet as a standard Array using the .elements property. This is useful for passing the set's contents to functions or APIs that specifically require an Array or a type conforming to RangeReplaceableCollection or MutableCollection.
SOURCE: https://github.com/apple/swift-collections/blob/main/Documentation/OrderedSet.md#_snippet_9

LANGUAGE: swift
CODE:
```
func pickyFunction(_ items: Array<Int>)

var set: OrderedSet = [0, 1, 2, 3]
pickyFunction(set) // error
pickyFunction(set.elements) // OK
```

----------------------------------------

TITLE: Accessing OrderedDictionary Keys View (Swift)
DESCRIPTION: Shows how to access the `keys` property of an OrderedDictionary, which provides a read-only view as an OrderedSet<Key>.
SOURCE: https://github.com/apple/swift-collections/blob/main/Documentation/OrderedDictionary.md#_snippet_8

LANGUAGE: Swift
CODE:
```
let d: OrderedDictionary = [2: "two", 1: "one", 0: "zero"]
d.keys // [2, 1, 0] as OrderedSet<Int>
```

----------------------------------------

TITLE: ShareableSet Initializers (Swift)
DESCRIPTION: This snippet lists the primary initializers available for creating instances of `ShareableSet`, including default initialization, initialization from a sequence, copy initialization, and initialization from the keys of a `ShareableDictionary`.
SOURCE: https://github.com/apple/swift-collections/blob/main/Documentation/Reviews/2022-10-31.ShareableHashedCollections/ShareableHashedCollections.md#_snippet_3

LANGUAGE: swift
CODE:
```
init()
init<S: Sequence>(S)
init(`Self`)
init<Value>(ShareableDictionary<Element, Value>.Keys)
```

----------------------------------------

TITLE: Demonstrating Swift Set Copy-on-Write Performance Issue
DESCRIPTION: This Swift code snippet illustrates a potential performance issue with the standard `Set` type when it is frequently copied and modified, and differences between versions are calculated. It defines a simple state update function that takes a new model (Set), calculates insertions and removals by diffing against the previous state, updates the state, and returns the changes. The loop simulates repeated insertions into a growing set, calling the update function after each insertion, highlighting the cost of copying and diffing a large set repeatedly.
SOURCE: https://github.com/apple/swift-collections/blob/main/Documentation/Reviews/2022-10-31.ShareableHashedCollections/ShareableHashedCollections.md#_snippet_0

LANGUAGE: swift
CODE:
```
typealias Model = Set<Int>

var _state: Model // Private
func updateState(
  with model: Model
) -> (insertions: Set<Int>, removals: Set<Int>) {
  let insertions = model.subtracting(_state)
  let removals = _state.subtracting(model)
  _state = model
  return (insertions, removals)
}

let c = 1_000_000
var model: Model = []
for i in 0 ..< c {
  model.insert(i)
  let r = updateState(with: model)
  precondition(r.insertions.count == 1 && r.removals.count = 0)
}
```

----------------------------------------

TITLE: Accessing and Mutating OrderedDictionary Values View (Swift)
DESCRIPTION: Demonstrates accessing the `values` property, which is a mutable random-access collection, and shows examples of modifying elements and sorting the values view.
SOURCE: https://github.com/apple/swift-collections/blob/main/Documentation/OrderedDictionary.md#_snippet_9

LANGUAGE: Swift
CODE:
```
d.values // "two", "one", "zero"
d.values[2] = "nada"
// `d` is now [2: "two", 1: "one", 0: "nada"]
d.values.sort()
// `d` is now [2: "nada", 1: "one", 0: "two"]
```

----------------------------------------

TITLE: Using ShareableSet as a Model Type (Swift)
DESCRIPTION: This snippet demonstrates how `ShareableSet` can be used as a drop-in replacement for `Set<Int>` in a performance test, highlighting the significant algorithmic improvement achieved by using the shareable collection type for operations involving copies or comparisons.
SOURCE: https://github.com/apple/swift-collections/blob/main/Documentation/Reviews/2022-10-31.ShareableHashedCollections/ShareableHashedCollections.md#_snippet_1

LANGUAGE: swift
CODE:
```
typealias Model = ShareableSet<Int>

... // Same code as before
```

----------------------------------------

TITLE: Comparing and Swapping Elements in OrderedDictionary in Swift
DESCRIPTION: Illustrates how equality in `OrderedDictionary` depends on both content and order, and shows how to change order using `swapAt`.
SOURCE: https://github.com/apple/swift-collections/blob/main/Documentation/OrderedDictionary.md#_snippet_2

LANGUAGE: Swift
CODE:
```
let a: OrderedDictionary = [1: "one", 2: "two"]
let b: OrderedDictionary = [2: "two", 1: "one"]
a == b // false
b.swapAt(0, 1) // `b` now has value [1: "one", 2: "two"]
a == b // true
```

----------------------------------------

TITLE: Using the Unordered View of OrderedSet in Swift
DESCRIPTION: Demonstrates how to access the `unordered` view of an `OrderedSet` in Swift, showing that this view ignores element order for equality checks and conforms to `SetAlgebra`, allowing it to be used in generic functions requiring that protocol.
SOURCE: https://github.com/apple/swift-collections/blob/main/Documentation/OrderedSet.md#_snippet_5

LANGUAGE: swift
CODE:
```
var a: OrderedSet = [0, 1, 2, 3]
let b: OrderedSet = [3, 2, 1, 0]
a == b // false
a.unordered == b.unordered // true

func frobnicate<S: SetAlgebra>(_ set: S) { ... }
frobnicate(a) // error: `OrderedSet<String>` does not conform to `SetAlgebra`
frobnicate(a.unordered) // OK
```

----------------------------------------

TITLE: Using updateValue(forKey:default:with:) Method in OrderedDictionary in Swift
DESCRIPTION: Shows an alternative method for updating values in place using a closure, which can be more convenient for complex mutations or reference types.
SOURCE: https://github.com/apple/swift-collections/blob/main/Documentation/OrderedDictionary.md#_snippet_5

LANGUAGE: Swift
CODE:
```
let text = "short string"
var counts: OrderedDictionary<Character, Int> = [:]
for character in text {
  counts.updateValue(forKey: character, default: 0) { value in
    value += 1
  }
}
// Same result as before
```

----------------------------------------

TITLE: Comparing OrderedSet Equality in Swift
DESCRIPTION: Illustrates that `OrderedSet` equality in Swift is order-sensitive, showing that two sets with the same elements but different orders are not equal, while sorting one makes them equal.
SOURCE: https://github.com/apple/swift-collections/blob/main/Documentation/OrderedSet.md#_snippet_2

LANGUAGE: swift
CODE:
```
let a: OrderedSet = [1, 2, 3, 4]
let b: OrderedSet = [4, 3, 2, 1]
a == b // false
b.sort() // `b` now has value [1, 2, 3, 4]
a == b // true
```

----------------------------------------

TITLE: Transforming ShareableDictionary Values in Swift
DESCRIPTION: Provides methods for creating a new `ShareableDictionary` by transforming the values of the original dictionary. `mapValues` applies a transformation to each value, while `compactMapValues` applies a transformation and discards nil results.
SOURCE: https://github.com/apple/swift-collections/blob/main/Documentation/Reviews/2022-10-31.ShareableHashedCollections/ShareableHashedCollections.md#_snippet_17

LANGUAGE: Swift
CODE:
```
func mapValues<T>((Value) throws -> T) rethrows -> ShareableDictionary<Key, T>
func compactMapValues<T>((Value) throws -> T?) rethrows -> ShareableDictionary<Key, T>
```

----------------------------------------

TITLE: OrderedSet Insertion and Update Methods in Swift
DESCRIPTION: Lists the specific methods provided by `OrderedSet` in Swift for inserting and updating elements, highlighting that it uses custom methods instead of the standard `SetAlgebra` ones to manage element order explicitly.
SOURCE: https://github.com/apple/swift-collections/blob/main/Documentation/OrderedSet.md#_snippet_4

LANGUAGE: swift
CODE:
```
func insert(_ item: Element, at index: Index) -> (inserted: Bool, index: Int)
func append(_ item: Element) -> (inserted: Bool, index: Int)
func update(at index: Int, with item: Element) -> Element
func updateOrAppend(_ item: Element) -> Element?
```

----------------------------------------

TITLE: Comparing ShareableDictionary Instances in Swift
DESCRIPTION: Shows the static equality operator (`==`) for comparing two instances of `ShareableDictionary` to determine if they contain the same key-value pairs.
SOURCE: https://github.com/apple/swift-collections/blob/main/Documentation/Reviews/2022-10-31.ShareableHashedCollections/ShareableHashedCollections.md#_snippet_16

LANGUAGE: Swift
CODE:
```
static func == (`Self`, `Self`) -> Bool
```

----------------------------------------

TITLE: Mutating OrderedSet via Unordered View in Swift
DESCRIPTION: Shows how inserting an element into the `unordered` view of an `OrderedSet` in Swift implicitly appends the new element to the end of the original ordered set.
SOURCE: https://github.com/apple/swift-collections/blob/main/Documentation/OrderedSet.md#_snippet_6

LANGUAGE: swift
CODE:
```
buildingMaterials.unordered.insert("glass") // => inserted: true
// buildingMaterials is now ["straw", "sticks", "bricks", "glass"]
```

----------------------------------------

TITLE: Mutable Operations on OrderedDictionary (Swift)
DESCRIPTION: Lists the permutation and removal operations supported by OrderedDictionary and its elements view, highlighting partial conformance to MutableCollection and RangeReplaceableCollection protocols.
SOURCE: https://github.com/apple/swift-collections/blob/main/Documentation/OrderedDictionary.md#_snippet_7

LANGUAGE: Swift
CODE:
```
// Permutation operations from MutableCollection:
func swapAt(_ i: Index, _ j: Index)
func partition(by predicate: (Element) throws -> Bool) rethrows -> Index
func sort() where Element: Comparable
func sort(by predicate: (Element, Element) throws -> Bool) rethrows
func shuffle()
func shuffle<T: RandomNumberGenerator>(using generator: inout T)

// Removal operations from RangeReplaceableCollection:
func removeAll(keepingCapacity: Bool = false)
func remove(at index: Index) -> Element
func removeSubrange(_ bounds: Range<Int>)
func removeLast() -> Element
func removeLast(_ n: Int)
func removeFirst() -> Element
func removeFirst(_ n: Int)
func removeAll(where shouldBeRemoved: (Element) throws -> Bool) rethrows
```

----------------------------------------

TITLE: Defining ShareableDictionary Struct - Swift
DESCRIPTION: Defines the `ShareableDictionary` struct with `Key` (Hashable) and `Value` generic parameters. It conforms to standard collection and description protocols and conditionally conforms to `Sendable`, `Equatable`, `Hashable`, `Decodable`, and `Encodable` based on its generic types.
SOURCE: https://github.com/apple/swift-collections/blob/main/Documentation/Reviews/2022-10-31.ShareableHashedCollections/ShareableHashedCollections.md#_snippet_9

LANGUAGE: Swift
CODE:
```
struct ShareableDictionary<Key: Hashable, Value>
  : Sequence, Collection,
    CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable,
    ExpressibleByDictionaryLiteral
{}

extension ShareableDictionary: Sendable where Key: Sendable, Value: Sendable {}
extension ShareableDictionary: Equatable where Value: Equatable {}
extension ShareableDictionary: Hashable where Value: Hashable {}
extension ShareableDictionary: Decodable where Key: Decodable, Value: Decodable {}
extension ShareableDictionary: Encodable where Key: Encodable, Value: Encodable {}
```

----------------------------------------

TITLE: Defining ShareableSet Struct and Conformances (Swift)
DESCRIPTION: This code block defines the basic structure of the `ShareableSet` type, specifying its generic `Element` requirement (`Hashable`) and listing the various protocols it conforms to, including `Sequence`, `Collection`, `SetAlgebra`, `Equatable`, `Hashable`, and conditional conformances for `Sendable`, `Decodable`, and `Encodable`.
SOURCE: https://github.com/apple/swift-collections/blob/main/Documentation/Reviews/2022-10-31.ShareableHashedCollections/ShareableHashedCollections.md#_snippet_2

LANGUAGE: swift
CODE:
```
struct ShareableSet<Element: Hashable>
 : Sequence, Collection,
   SetAlgebra,
   Equatable, Hashable,
   CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable,
   ExpressibleByArrayLiteral
{}

extension ShareableSet: Sendable where Element: Sendable {}
extension ShareableSet: Decodable where Element: Decodable {}
extension ShareableSet: Encodable where Element: Encodable {}
```

----------------------------------------

TITLE: Accessing Unordered View of Swift Heap
DESCRIPTION: Provides a read-only view of the underlying array storage of the `Heap` for iteration, without guaranteeing any specific order.
SOURCE: https://github.com/apple/swift-collections/blob/main/Documentation/Heap.md#_snippet_7

LANGUAGE: swift
CODE:
```
let heap = Heap((1...100).shuffled())
for val in heap.unordered {
   ...
}
```

TITLE: Configuring SwiftPM Executable Benchmark Target
DESCRIPTION: This Swift Package Manager configuration snippet demonstrates how to set up a dedicated executable target for running benchmarks. It defines an executable product and links it to a target that depends on the 'CollectionsBenchmark' product.
SOURCE: https://github.com/apple/swift-collections-benchmark/blob/main/README.md#_snippet_3

LANGUAGE: Swift
CODE:
```
// swift-tools-version:5.3
import PackageDescription

let package = Package(
  name: "MyPackage",
  products: [
    .executable(name: "my-benchmark", targets: ["MyBenchmark"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-collections-benchmark", from: "0.0.1"),
    // ... other dependencies ...
  ],
  targets: [
    // ... other targets ...
    .target(
      name: "MyBenchmark",
      dependencies: [
        .product(name: "CollectionsBenchmark", package: "swift-collections-benchmark"),
      ]),
  ]
)
```

----------------------------------------

TITLE: Adding Swift Collections Benchmark Dependency
DESCRIPTION: This line shows the required entry to add the Swift Collections Benchmark package as a dependency within a Swift Package Manager's Package.swift file, specifying the GitHub URL and a minimum version.
SOURCE: https://github.com/apple/swift-collections-benchmark/blob/main/README.md#_snippet_2

LANGUAGE: Swift
CODE:
```
.package(url: "https://github.com/apple/swift-collections-benchmark", from: "0.0.1"),
```

----------------------------------------

TITLE: Defining a Swift Benchmark
DESCRIPTION: This Swift code snippet demonstrates how to define performance benchmarks using the CollectionsBenchmark library. It initializes a benchmark suite and adds two tasks: one for sorting an array and another for checking set containment, showcasing both simple and more complex task definitions.
SOURCE: https://github.com/apple/swift-collections-benchmark/blob/main/README.md#_snippet_0

LANGUAGE: Swift
CODE:
```
import CollectionsBenchmark

var benchmark = Benchmark(title: "Demo Benchmark")

benchmark.addSimple(
  title: "Array<Int> sorted",
  input: [Int].self
) { input in
  blackHole(input.sorted())
}

benchmark.add(
  title: "Set<Int> contains",
  input: ([Int], [Int]).self
) { input, lookups in
  let set = Set(input)
  return { timer in
    for value in lookups {
      precondition(set.contains(value))
    }
  }
}

benchmark.main()
```

----------------------------------------

TITLE: Defining a Benchmark with CollectionsBenchmark (Swift)
DESCRIPTION: This Swift code demonstrates how to set up a benchmark using the `CollectionsBenchmark` library. It creates a `Benchmark` instance, adds a simple benchmark named `kalimbaOrdered` for an array of integers, and uses `blackHole` to consume the result without allowing the compiler to optimize away the computation.
SOURCE: https://github.com/apple/swift-collections-benchmark/blob/main/Documentation/01 Getting Started.md#_snippet_1

LANGUAGE: Swift
CODE:
```
import CollectionsBenchmark

// Create a new benchmark instance.
var benchmark = Benchmark(title: "Kalimba")

// Define a very simple benchmark called `kalimbaOrdered`.
benchmark.addSimple(
  title: "kalimbaOrdered",
  input: [Int].self
) { input in
  blackHole(input.kalimbaOrdered())
}

// Execute the benchmark tool with the above definitions.
benchmark.main()
```

----------------------------------------

TITLE: Optimizing Sequence Transformation with Deque in Swift
DESCRIPTION: This Swift extension demonstrates optimizing a sequence transformation function (`kalimbaOrdered`) by replacing `Array` with `Deque` from the Swift Collections package. It alternates between prepending and appending elements to build the resulting collection.
SOURCE: https://github.com/apple/swift-collections-benchmark/blob/main/Documentation/01 Getting Started.md#_snippet_3

LANGUAGE: swift
CODE:
```
import Collections

extension Sequence {
  func kalimbaOrdered() -> Deque<Element> {
    var kalimba: Deque<Element> = []
    kalimba.reserveCapacity(underestimatedCount)
    var insertAtStart = false
    for element in self {
      if insertAtStart {
        kalimba.prepend(element)
      } else {
        kalimba.append(element)
      }
      insertAtStart.toggle()
    }
    return kalimba
  }
}
```

----------------------------------------

TITLE: Running and Rendering Benchmarks using SwiftPM
DESCRIPTION: This shell session demonstrates the command-line workflow for executing a defined benchmark using Swift Package Manager. It shows how to run the benchmark, save the results to a file, and then render the collected data into a chart image.
SOURCE: https://github.com/apple/swift-collections-benchmark/blob/main/README.md#_snippet_1

LANGUAGE: Shell
CODE:
```
$ swift run -c release benchmark run results --cycles 5
Running 2 tasks on 76 sizes from 1 to 1M:
  Array<Int> sorted
  Set<Int> contains
Output file: /Users/klorentey/Projects/swift-collections-benchmark-demo/Demo/results
Appending to existing data (if any) for these tasks/sizes.

Collecting data:
  1.2.4...8...16...32...64...128...256...512...1k...2k...4k...8k...16k...32k...64k...128k...256k...512k...1M -- 5.31s
  1.2.4...8...16...32...64...128...256...512...1k...2k...4k...8k...16k...32k...64k...128k...256k...512k...1M -- 5.35s
  1.2.4...8...16...32...64...128...256...512...1k...2k...4k...8k...16k...32k...64k...128k...256k...512k...1M -- 5.29s
  1.2.4...8...16...32...64...128...256...512...1k...2k...4k...8k...16k...32k...64k...128k...256k...512k...1M -- 5.3s
  1.2.4...8...16...32...64...128...256...512...1k...2k...4k...8k...16k...32k...64k...128k...256k...512k...1M -- 5.34s
Finished in 26.6s
$ swift run -c release benchmark render results chart.png
$ open chart.png
```

----------------------------------------

TITLE: Running a CollectionsBenchmark from the Command Line (Shell)
DESCRIPTION: This shell command executes the benchmark defined in the Swift code using `swift run`. It specifies the release configuration (`-c release`), the benchmark target (`kalimba-benchmark`), the `run` command, the number of cycles (`--cycles 3`), and the output file name (`results`). The output shows the progress and completion time.
SOURCE: https://github.com/apple/swift-collections-benchmark/blob/main/Documentation/01 Getting Started.md#_snippet_2

LANGUAGE: Shell
CODE:
```
$ swift run -c release kalimba-benchmark run --cycles 3 results
Running 1 tasks on 76 sizes from 1 to 1M:
  kalimbaOrdered
Output file: /Users/klorentey/Projects/swift-collections-benchmark-demo/results
Appending to existing data (if any) for these tasks/sizes.

Collecting data:
  1.2.4...8...16...32...64...128...256...512...1k...2k...4k...8k...16k...32k...64k...128k...256k...512k...1M -- 21.7s
  1.2.4...8...16...32...64...128...256...512...1k...2k...4k...8k...16k...32k...64k...128k...256k...512k...1M -- 21.7s
  1.2.4...8...16...32...64...128...256...512...1k...2k...4k...8k...16k...32k...64k...128k...256k...512k...1M -- 21.8s
Finished in 65.2s
$
```

----------------------------------------

TITLE: Running Benchmarks with Swift Collections Benchmarks
DESCRIPTION: This shell command executes a specific benchmark task (`kalimbaOrdered`) using the Swift Collections Benchmarks tool. It runs the benchmark for 3 cycles across various sizes and saves the results to a specified output file (`results-deque`).
SOURCE: https://github.com/apple/swift-collections-benchmark/blob/main/Documentation/01 Getting Started.md#_snippet_4

LANGUAGE: shell
CODE:
```
$ swift run -c release kalimba-benchmark run --cycles 3 results-deque
Running 1 tasks on 76 sizes from 1 to 1M:
  kalimbaOrdered
Output file: /Users/klorentey/Projects/swift-collections-benchmark-demo/results-deque
Appending to existing data (if any) for these tasks/sizes.

Collecting data:
  1.2.4...8...16...32...64...128...256...512...1k...2k...4k...8k...16k...32k...64k...128k...256k...512k...1M -- 1.37s
  1.2.4...8...16...32...64...128...256...512...1k...2k...4k...8k...16k...32k...64k...128k...256k...512k...1M -- 1.38s
  1.2.4...8...16...32...64...128...256...512...1k...2k...4k...8k...16k...32k...64k...128k...256k...512k...1M -- 1.37s
Finished in 4.12s
```

----------------------------------------

TITLE: Rendering Benchmark Results from a Library
DESCRIPTION: This shell command renders the benchmark data stored in `results.json` according to the charts defined in `Library.json`. It generates output files (e.g., Markdown or HTML) and allows customization of time scales, percentiles, and themes.
SOURCE: https://github.com/apple/swift-collections-benchmark/blob/main/Documentation/01 Getting Started.md#_snippet_9

LANGUAGE: shell
CODE:
```
$ swift-collections-benchmark library render results.json --library Library.json --max-time 10us --min-time 1ns --theme-file Theme.json --percentile 90 --output .
```

----------------------------------------

TITLE: Running Benchmarks Defined in a Library
DESCRIPTION: This shell command executes all benchmark tasks specified within a benchmark library file (`Library.json`). It saves the collected data to a specified output file (`results.json`) and allows setting parameters like maximum size and cycles.
SOURCE: https://github.com/apple/swift-collections-benchmark/blob/main/Documentation/01 Getting Started.md#_snippet_8

LANGUAGE: shell
CODE:
```
$ swift-collections-benchmark library run results.json --library Library.json --max-size 16M --cycles 20
```