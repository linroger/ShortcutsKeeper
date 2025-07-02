TITLE: Validating Code Result with Expect Macro in Swift
DESCRIPTION: This example demonstrates how to use the `expect` macro to validate that code produces an expected value. The macro captures the expression and provides detailed information when the code doesn't satisfy the expectation. The test continues running even if the expectation fails.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/Expectations.md#_snippet_0

LANGUAGE: Swift
CODE:
```
@Test func calculatingOrderTotal() {
  let calculator = OrderCalculator()
  #expect(calculator.total(of: [3, 3]) == 7)
  // Prints "Expectation failed: (calculator.total(of: [3, 3]) → 6) == 7"
}
```

----------------------------------------

TITLE: Validating Code Result with Require Macro in Swift
DESCRIPTION: This example demonstrates how to use the `require` macro to stop the test when the code doesn't satisfy a requirement. The `require` macro throws an `ExpectationFailedError` when the code fails to satisfy the requirement, halting the test execution.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/Expectations.md#_snippet_1

LANGUAGE: Swift
CODE:
```
@Test func returningCustomerRemembersUsualOrder() throws {
  let customer = try #require(Customer(id: 123))
  // The test runner doesn't reach this line if the customer is nil.
  #expect(customer.usualOrder.countOfItems == 2)
}
```

----------------------------------------

TITLE: Declaring a Test Function in Swift
DESCRIPTION: Declare a test function using the `@Test` attribute. Test functions should not take any arguments. The test logic is placed inside the function body.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/DefiningTests.md#_snippet_1

LANGUAGE: swift
CODE:
```
@Test func foodTruckExists() {
  // Test logic goes here.
}
```

----------------------------------------

TITLE: Validating Expected Error Throws in Swift
DESCRIPTION: This code snippet demonstrates how to validate that a specific error is thrown when calling a function. It uses `#expect(throws:)` to check if the `add(topping:toPizzasIn:)` method throws a `PizzaToppings.Error.outOfRange` error when attempting to add a topping to an invalid pizza index.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/testing-for-errors-in-swift-code.md#_snippet_0

LANGUAGE: swift
CODE:
```
@Test func cannotAddToppingToPizzaBeforeStartOfList() {
  var order = PizzaToppings(bases: [.calzone, .deepCrust])
  #expect(throws: PizzaToppings.Error.outOfRange) {
    try order.add(topping: .mozarella, toPizzasIn: -1..<0)
  }
}
```

----------------------------------------

TITLE: Handle optional values with require in Swift Testing
DESCRIPTION: This code snippet demonstrates how to handle optional values in the Swift Testing library using `#require` to unwrap them, replacing the `XCTUnwrap` function from XCTest.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/MigratingFromXCTest.md#_snippet_6

LANGUAGE: Swift
CODE:
```
// Before
func testEngineWorks() throws {
  let engine = FoodTruck.shared.engine
  let part = try XCTUnwrap(engine.parts.first)
  ...
}
```

LANGUAGE: Swift
CODE:
```
// After
@Test func engineWorks() throws {
  let engine = FoodTruck.shared.engine
  let part = try #require(engine.parts.first)
  ...
}
```

----------------------------------------

TITLE: Replace XCTAssert with expect and require in Swift Testing
DESCRIPTION: This code snippet illustrates how to replace `XCTAssert` assertions with `#expect` and `#require` in the Swift Testing library. `#require` throws an error if the condition is not met, while `#expect` continues execution.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/MigratingFromXCTest.md#_snippet_5

LANGUAGE: Swift
CODE:
```
// Before
func testEngineWorks() throws {
  let engine = FoodTruck.shared.engine
  XCTAssertNotNil(engine.parts.first)
  XCTAssertGreaterThan(engine.batteryLevel, 0)
  try engine.start()
  XCTAssertTrue(engine.isRunning)
}
```

LANGUAGE: Swift
CODE:
```
// After
@Test func engineWorks() throws {
  let engine = FoodTruck.shared.engine
  try #require(engine.parts.first != nil)
  #expect(engine.batteryLevel > 0)
  try engine.start()
  #expect(engine.isRunning)
}
```

----------------------------------------

TITLE: Validating Any Error Throws in Swift
DESCRIPTION: This code snippet demonstrates how to validate that any error is thrown when calling a function. It uses `#expect(throws:)` with `(any Error).self` to check if the `add(topping:toPizzasIn:)` method throws any error when attempting to add a topping to an invalid pizza index.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/testing-for-errors-in-swift-code.md#_snippet_1

LANGUAGE: swift
CODE:
```
@Test func cannotAddToppingToPizzaBeforeStartOfList() {
  var order = PizzaToppings(bases: [.calzone, .deepCrust])
  #expect(throws: (any Error).self) {
    try order.add(topping: .mozarella, toPizzasIn: -1..<0)
  }
}
```

----------------------------------------

TITLE: Writing Concurrent or Throwing Tests in Swift
DESCRIPTION: Test functions can be marked as `async` and `throws` to indicate concurrency or potential errors. Use `@MainActor` to ensure the test runs on the main actor's execution context.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/DefiningTests.md#_snippet_3

LANGUAGE: swift
CODE:
```
@Test @MainActor func foodTruckExists() async throws { ... }
```

----------------------------------------

TITLE: Convert XCTest test methods to Swift Testing
DESCRIPTION: This code snippet demonstrates how to convert a test method from XCTest to the Swift Testing library. It involves changing the test class to a struct and replacing the `test` prefix with the `@Test` attribute.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/MigratingFromXCTest.md#_snippet_4

LANGUAGE: Swift
CODE:
```
// Before
class FoodTruckTests: XCTestCase {
  func testEngineWorks() { ... }
  ...
}
```

LANGUAGE: Swift
CODE:
```
// After
struct FoodTruckTests {
  @Test func engineWorks() { ... }
  ...
}
```

----------------------------------------

TITLE: Replacing setUp() with init() in Swift
DESCRIPTION: Illustrates how to replace XCTest's setUp() function with Swift's init() for setting up test data.  The use of async and throws is optional.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/MigratingFromXCTest.md#_snippet_2

LANGUAGE: Swift
CODE:
```
// Before
class FoodTruckTests: XCTestCase {
  var batteryLevel: NSNumber!
  override func setUp() async throws {
    batteryLevel = 100
  }
  ...
}
```

LANGUAGE: Swift
CODE:
```
// After
struct FoodTruckTests {
  var batteryLevel: NSNumber
  init() async throws {
    batteryLevel = 100
  }
  ...
}
```

----------------------------------------

TITLE: Replacing XCTAssert with #expect in Swift
DESCRIPTION: This snippet shows how to replace various `XCTAssert()` functions from XCTest with their `#expect` equivalents in the Swift Testing Library for assertions.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/MigratingFromXCTest.md#_snippet_8

LANGUAGE: Swift
CODE:
```
#expect(x)
```

LANGUAGE: Swift
CODE:
```
#expect(!x)
```

LANGUAGE: Swift
CODE:
```
#expect(x == nil)
```

LANGUAGE: Swift
CODE:
```
#expect(x != nil)
```

LANGUAGE: Swift
CODE:
```
#expect(x == y)
```

LANGUAGE: Swift
CODE:
```
#expect(x != y)
```

LANGUAGE: Swift
CODE:
```
#expect(x === y)
```

LANGUAGE: Swift
CODE:
```
#expect(x !== y)
```

LANGUAGE: Swift
CODE:
```
#expect(x > y)
```

LANGUAGE: Swift
CODE:
```
#expect(x >= y)
```

LANGUAGE: Swift
CODE:
```
#expect(x <= y)
```

LANGUAGE: Swift
CODE:
```
#expect(x < y)
```

LANGUAGE: Swift
CODE:
```
#expect(throws: (any Error).self) { try f() }
```

LANGUAGE: Swift
CODE:
```
let error = #expect(throws: (any Error).self) { try f() }
```

LANGUAGE: Swift
CODE:
```
#expect(throws: Never.self) { try f() }
```

----------------------------------------

TITLE: Basic Expectation in a Test Function (Swift)
DESCRIPTION: This code snippet demonstrates a basic test function using the Swift Testing framework. It defines a string variable and uses the `#expect` macro to assert that the string equals "Hello". If the expectation fails, it captures the evaluated values for debugging.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/README.md#_snippet_0

LANGUAGE: Swift
CODE:
```
@Test func helloWorld() {
  let greeting = "Hello, world!"
  #expect(greeting == "Hello") // Expectation failed: (greeting → "Hello, world!") == "Hello"
}
```

----------------------------------------

TITLE: Replacing XCTUnwrap with #require in Swift
DESCRIPTION: This snippet illustrates how to replace `XCTUnwrap()` from XCTest with `#require()` in the Swift Testing Library for unwrapping optional values.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/MigratingFromXCTest.md#_snippet_9

LANGUAGE: Swift
CODE:
```
try #require(x)
```

----------------------------------------

TITLE: Parameterizing a test over an array of enum values in Swift
DESCRIPTION: This code shows how to parameterize a test function over an array of Food enum cases using the arguments parameter of the @Test attribute. This allows the testing library to pass each element in the collection to the test function as its first argument, making it easier to identify which inputs cause the test to fail.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/ParameterizedTesting.md#_snippet_1

LANGUAGE: swift
CODE:
```
enum Food {
  case burger, iceCream, burrito, noodleBowl, kebab
}

@Test("All foods available", arguments: [Food.burger, .iceCream, .burrito, .noodleBowl, .kebab])
func foodAvailable(_ food: Food) async throws {
  let foodTruck = FoodTruck(selling: food)
  #expect(await foodTruck.cook(food))
}
```

----------------------------------------

TITLE: Setting a Time Limit for a Test Function in Swift
DESCRIPTION: This code snippet demonstrates how to set a time limit for a test function using the .timeLimit trait. If the test function takes longer than the specified time (in this case, 60 minutes), the task is cancelled, and the test fails with a timeLimitExceeded issue.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/LimitingExecutionTime.md#_snippet_0

LANGUAGE: Swift
CODE:
```
@Test(.timeLimit(.minutes(60))
func serve100CustomersInOneHour() async {
  for _ in 0 ..< 100 {
    let customer = await Customer.next()
    await customer.order()
    ...
  }
}
```

----------------------------------------

TITLE: Inspecting Thrown Errors in Swift
DESCRIPTION: This code snippet demonstrates how to inspect an error thrown by a function using `#expect(throws:)`. It captures the thrown `PizzaToppings.InvalidToppingError` and validates its properties, such as the topping and the reason for the error.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/testing-for-errors-in-swift-code.md#_snippet_3

LANGUAGE: swift
CODE:
```
@Test func cannotAddMarshmallowsToPizza() throws {
  let error = #expect(throws: PizzaToppings.InvalidToppingError.self) {
    try Pizza.current.add(topping: .marshmallows)
  }
  #expect(error?.topping == .marshmallows)
  #expect(error?.reason == .dessertToppingOnly)
}
```

----------------------------------------

TITLE: Testing Asynchronous Function with Expected Value in Swift
DESCRIPTION: This code snippet demonstrates how to test an asynchronous function using the `async` keyword and `#expect` to validate the returned value. It defines a test function `priceLookupYieldsExpectedValue` that calls an asynchronous function `unitPrice` and asserts that the returned price matches the expected value.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/testing-asynchronous-code.md#_snippet_0

LANGUAGE: swift
CODE:
```
@Test func priceLookupYieldsExpectedValue() async {
  let mozarellaPrice = await unitPrice(for: .mozarella)
  #expect(mozarellaPrice == 3)
}
```

----------------------------------------

TITLE: Running Swift Tests
DESCRIPTION: This command executes the Swift test suite in the current directory.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/CONTRIBUTING.md#_snippet_12

LANGUAGE: bash
CODE:
```
$> swift test
```

----------------------------------------

TITLE: Importing Testing Module in Swift
DESCRIPTION: Shows how to replace the XCTest import with the Testing module import in Swift.  This is necessary to use the new Swift testing library.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/MigratingFromXCTest.md#_snippet_0

LANGUAGE: Swift
CODE:
```
// Before
import XCTest
```

LANGUAGE: Swift
CODE:
```
// After
import Testing
```

----------------------------------------

TITLE: Importing the Testing Library in Swift
DESCRIPTION: To use the Swift Testing library, import it into your test file. This allows you to use the @Test attribute and other testing functionalities.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/DefiningTests.md#_snippet_0

LANGUAGE: swift
CODE:
```
import Testing
```

----------------------------------------

TITLE: Adding Swift Testing Package Dependency
DESCRIPTION: This code snippet demonstrates how to add a package dependency on Swift Testing in your Package.swift file. It specifies the URL of the Swift Testing repository and the branch to use.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Documentation/ExpectationCapture.md#_snippet_4

LANGUAGE: Swift
CODE:
```
dependencies: [
  /* ... */
  .package(
    url: "https://github.com/swiftlang/swift-testing.git",
    branch: "jgrynspan/162-redesign-value-capture"
  ),
],
```

----------------------------------------

TITLE: Testing Asynchronous Events with Confirmation
DESCRIPTION: This code demonstrates how to use the Confirmation API to test asynchronous events. It uses the confirmation function to define a block that sets up an event handler. The handler confirms the event when it occurs, and the test waits for the confirmation to occur.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/MigratingFromXCTest.md#_snippet_13

LANGUAGE: Swift
CODE:
```
@Test func truckEvents() async {
  await confirmation("…") { soldFood in
    FoodTruck.shared.eventHandler = { event in
      if case .soldFood = event {
        soldFood()
      }
    }
    await Customer().buy(.soup)
  }
  ...
}
```

----------------------------------------

TITLE: Parameterized Test with Arguments (Swift)
DESCRIPTION: This code snippet demonstrates a parameterized test that runs the same test function over a sequence of values. The `arguments:` parameter of the `@Test` macro is used to provide an array of video names. The test asynchronously retrieves each video and asserts that the number of mentioned continents is less than or equal to 3.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/README.md#_snippet_3

LANGUAGE: Swift
CODE:
```
@Test("Continents mentioned in videos", arguments: [
    "A Beach",
    "By the Lake",
    "Camping in the Woods"
])
func mentionedContinents(videoName: String) async throws {
    let videoLibrary = try await VideoLibrary()
    let video = try #require(await videoLibrary.video(named: videoName))
    #expect(video.mentionedContinents.count <= 3)
}
```

----------------------------------------

TITLE: Parameterizing a test over enum cases using CaseIterable in Swift
DESCRIPTION: This code demonstrates how to parameterize a test function over all cases of an enumeration that conforms to the CaseIterable protocol. This ensures that any new cases added to the enumeration are automatically tested by the function.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/ParameterizedTesting.md#_snippet_2

LANGUAGE: swift
CODE:
```
enum Food: CaseIterable {
  case burger, iceCream, burrito, noodleBowl, kebab
}

@Test("All foods available", arguments: Food.allCases)
func foodAvailable(_ food: Food) async throws {
  let foodTruck = FoodTruck(selling: food)
  #expect(await foodTruck.cook(food))
}
```

----------------------------------------

TITLE: Replacing continueAfterFailure with #require in Swift
DESCRIPTION: This snippet shows how to replace `continueAfterFailure = false` and `XCTAssertTrue` from XCTest with `#require` in the Swift Testing Library to halt after a test failure.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/MigratingFromXCTest.md#_snippet_11

LANGUAGE: Swift
CODE:
```
// Before
func testTruck() async {
  continueAfterFailure = false
  XCTAssertTrue(FoodTruck.shared.isLicensed)
  ...
}
```

LANGUAGE: Swift
CODE:
```
// After
@Test func truck() throws {
  try #require(FoodTruck.shared.isLicensed)
  ...
}
```

----------------------------------------

TITLE: Confirming Event Occurrence in Asynchronous Test in Swift
DESCRIPTION: This code snippet demonstrates how to use `Confirmation` to verify that an event happens during an asynchronous test. It defines a test function `subtotalForNoPizzas` that creates a `Confirmation` and calls the code under test within the trailing closure. The `successHandler` is set to call the `Confirmation` when the expected event occurs.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/testing-asynchronous-code.md#_snippet_1

LANGUAGE: swift
CODE:
```
@Test("OrderCalculator successfully calculates subtotal for no pizzas")
func subtotalForNoPizzas() async {
  let calculator = OrderCalculator()
  await confirmation() { confirmation in
    calculator.successHandler = { _ in confirmation() }
    _ = await calculator.subtotal(for: PizzaToppings(bases: []))
  }
}
```

----------------------------------------

TITLE: Test with Enabled Trait (Swift)
DESCRIPTION: This code snippet demonstrates how to use traits to customize test behavior. The `.enabled(if:)` trait is used to conditionally enable the test based on the value of `AppFeatures.isCommentingEnabled`. The test asynchronously retrieves a video and asserts that its comments contain a specific string.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/README.md#_snippet_1

LANGUAGE: Swift
CODE:
```
@Test(.enabled(if: AppFeatures.isCommentingEnabled))
func videoCommenting() async throws {
    let video = try #require(await videoLibrary.video(named: "A Beach"))
    #expect(video.comments.contains("So picturesque!"))
}
```

----------------------------------------

TITLE: Using try within #expect argument list in Swift
DESCRIPTION: This example demonstrates the correct way to use the `try` keyword with the `#expect` macro to avoid compiler errors when dealing with throwing functions.  The `try` keyword should be placed within the argument list of `#expect()`. This ensures that the macro expansion correctly handles the throwing function.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Documentation/ExpectationCapture.md#_snippet_6

LANGUAGE: Swift
CODE:
```
#expect(try h())
```

----------------------------------------

TITLE: Confirming Event Absence in Asynchronous Test in Swift
DESCRIPTION: This code snippet demonstrates how to use `Confirmation` to verify that an event does not occur during an asynchronous test. It defines a test function `orderCalculatorEncountersNoErrors` that creates a `Confirmation` with an expected count of 0. The `errorHandler` is set to call the `Confirmation` when an error occurs, but the test expects no errors to happen.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/testing-asynchronous-code.md#_snippet_3

LANGUAGE: swift
CODE:
```
@Test func orderCalculatorEncountersNoErrors() async {
  let calculator = OrderCalculator()
  await confirmation(expectedCount: 0) { confirmation in
    calculator.errorHandler = { _ in confirmation() }
    calculator.subtotal(for: PizzaToppings(bases: []))
  }
}
```

----------------------------------------

TITLE: Test with Name and Tags (Swift)
DESCRIPTION: This code snippet shows how to add a descriptive name and tags to a test. The `@Test` macro is used to assign the name "Check video metadata" and the tag `.metadata` to the test function. The test creates a `Video` object and asserts that its metadata matches the expected metadata.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/README.md#_snippet_2

LANGUAGE: Swift
CODE:
```
@Test("Check video metadata",
      .tags(.metadata))
func videoMetadata() {
    let video = Video(fileName: "By the Lake.mov")
    let expectedMetadata = Metadata(duration: .seconds(90))
    #expect(video.metadata == expectedMetadata)
}
```

----------------------------------------

TITLE: Validating No Error Throws in Swift
DESCRIPTION: This code snippet demonstrates how to validate that no error is thrown when calling a function. It uses `#expect(throws:)` with `Never.self` to check if the `add(topping:toPizzasIn:)` method does not throw an error when adding a topping to a valid pizza index. It also checks if the toppings are added correctly.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/testing-for-errors-in-swift-code.md#_snippet_2

LANGUAGE: swift
CODE:
```
@Test func canAddToppingToPizzaInPositionZero() throws {
  var order = PizzaToppings(bases: [.thinCrust, .thinCrust])
  #expect(throws: Never.self) {
    try order.add(topping: .caper, toPizzasIn: 0..<1)
  }
  let toppings = try order.toppings(forPizzaAt: 0)
  #expect(toppings == [.caper])
}
```

----------------------------------------

TITLE: Confirming Event Occurrence within a Range in Swift
DESCRIPTION: This code snippet demonstrates how to use `Confirmation` with a range of expected occurrences in an asynchronous test. It defines a test function `boughtSandwiches` that creates a `Confirmation` with an expected count range of 0 to 999. The `orderHandler` is set to call the `Confirmation` when an order contains a sandwich.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/testing-asynchronous-code.md#_snippet_2

LANGUAGE: swift
CODE:
```
@Test("Customers bought sandwiches")
func boughtSandwiches() async {
  await confirmation(expectedCount: 0 ..< 1000) { boughtSandwich in
    var foodTruck = FoodTruck()
    foodTruck.orderHandler = { order in
      if order.contains(.sandwich) {
        boughtSandwich()
      }
    }
    await FoodTruck.operate()
  }
}
```

----------------------------------------

TITLE: Converting XCTestCase to a Swift struct
DESCRIPTION: Demonstrates how to convert an XCTestCase subclass to a Swift struct for use with the testing library.  This involves removing the inheritance from XCTestCase.  Using struct or actor is recommended for concurrency safety.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/MigratingFromXCTest.md#_snippet_1

LANGUAGE: Swift
CODE:
```
// Before
class FoodTruckTests: XCTestCase {
  ...
}
```

LANGUAGE: Swift
CODE:
```
// After
struct FoodTruckTests {
  ...
}
```

----------------------------------------

TITLE: Test Function with Expectation in Swift
DESCRIPTION: This test function demonstrates a failing expectation. If `foodTruck.grill.isHeating` is false, the `#expect` will record an issue, causing the test to fail.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/known-issues.md#_snippet_0

LANGUAGE: Swift
CODE:
```
@Test func grillHeating() throws {
  var foodTruck = FoodTruck()
  try foodTruck.startGrill()
  #expect(foodTruck.grill.isHeating) // ❌ Expectation failed
}
```

----------------------------------------

TITLE: Marking Expectation Failure as Known in Swift
DESCRIPTION: This example shows how to use `withKnownIssue()` to mark an expectation failure as known. The closure passed to `withKnownIssue()` contains the failing `#expect`. Any issues recorded within the closure will be considered known, preventing the test from failing.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/known-issues.md#_snippet_1

LANGUAGE: Swift
CODE:
```
@Test func grillHeating() throws {
  var foodTruck = FoodTruck()
  try foodTruck.startGrill()
  withKnownIssue("Propane tank is empty") {
    #expect(foodTruck.grill.isHeating) // Known issue
  }
}
```

----------------------------------------

TITLE: Testing Multiple Events with Confirmation and Range
DESCRIPTION: This code demonstrates how to use the Confirmation API with a range for expectedCount to test multiple occurrences of an event. It defines a confirmation with a range to indicate the minimum number of times the event should be confirmed.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/MigratingFromXCTest.md#_snippet_15

LANGUAGE: Swift
CODE:
```
@Test func regularCustomerOrders() async {
  await confirmation(
    "…",
    expectedCount: 10...
  ) { soldFood in
    FoodTruck.shared.eventHandler = { event in
      if case .soldFood = event {
        soldFood()
      }
    }
    for customer in regularCustomers() {
      await customer.buy(customer.regularOrder)
    }
  }
  ...
}
```

----------------------------------------

TITLE: Parameterizing a test over a range of integers in Swift
DESCRIPTION: This code shows how to parameterize a test function over a closed range of integers using the arguments parameter of the @Test attribute. This allows testing with a sequence of integer values.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/ParameterizedTesting.md#_snippet_3

LANGUAGE: swift
CODE:
```
@Test("Can make large orders", arguments: 1 ... 100)
func makeLargeOrder(count: Int) async throws {
  let foodTruck = FoodTruck(selling: .burger)
  #expect(await foodTruck.cook(.burger, quantity: count))
}
```

----------------------------------------

TITLE: Expectation with f() < g() in Swift Testing
DESCRIPTION: This code demonstrates a simple expectation using the #expect macro in Swift Testing. It checks if the result of function f() is less than the result of function g(). If the expectation fails, Swift Testing will provide the values of f() and g() in addition to the overall expression.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Documentation/ExpectationCapture.md#_snippet_0

LANGUAGE: Swift
CODE:
```
#expect(f() < g())
```

----------------------------------------

TITLE: Enabling/Disabling Tests with Traits
DESCRIPTION: Shows how to use the ConditionTrait to enable or disable tests and suites based on conditions. This provides a more declarative way to control test execution compared to XCTSkipIf/XCTSkipUnless.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/MigratingFromXCTest.md#_snippet_17

LANGUAGE: Swift
CODE:
```
// After
@Suite(.disabled(if: CashRegister.isEmpty))
struct FoodTruckTests {
  @Test(.enabled(if: FoodTruck.sells(.arepas)))
  func arepasAreTasty() {
    ...
  }
  ...
}
```

----------------------------------------

TITLE: Expanded expectation with boolean operators in Swift Testing
DESCRIPTION: This code demonstrates how the redesigned #expect macro can fully expand an expression with boolean operators, providing a detailed breakdown of the condition at runtime if it fails. This allows for more precise identification of the cause of the failure.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Documentation/ExpectationCapture.md#_snippet_3

LANGUAGE: Swift
CODE:
```
#expect(x && y && !z)
```

----------------------------------------

TITLE: Replacing XCTFail with Issue.record in Swift
DESCRIPTION: This snippet demonstrates how to replace `XCTFail("...")` from XCTest with `Issue.record("...")` in the Swift Testing Library for unconditionally failing a test.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/MigratingFromXCTest.md#_snippet_10

LANGUAGE: Swift
CODE:
```
Issue.record("...")
```

----------------------------------------

TITLE: Disabling Parallelization with .serialized Trait in Swift
DESCRIPTION: This code demonstrates how to disable test parallelization on a per-function and per-suite basis using the `.serialized` trait. When applied to a test function with arguments, each case will run serially. When applied to a test suite, all contained test functions and sub-suites will run serially.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/Parallelization.md#_snippet_0

LANGUAGE: Swift
CODE:
```
@Test(.serialized, arguments: Food.allCases) func prepare(food: Food) {
  // This function will be invoked serially, once per food, because it has the
  // .serialized trait.
}

@Suite(.serialized) struct FoodTruckTests {
  @Test(arguments: Condiment.allCases) func refill(condiment: Condiment) {
    // This function will be invoked serially, once per condiment, because the
    // containing suite has the .serialized trait.
  }

  @Test func startEngine() async throws {
    // This function will not run while refill(condiment:) is running. One test
    // must end before the other will start.
  }
}
```

----------------------------------------

TITLE: Creating a Unique Tag with Reverse-DNS Naming in Swift
DESCRIPTION: This code snippet demonstrates how to create a unique tag using reverse-DNS naming to avoid conflicts with similar tags declared elsewhere in a project or its dependencies. This ensures that the tag is uniquely identified by the testing library.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/AddingTags.md#_snippet_1

LANGUAGE: Swift
CODE:
```
extension Tag {
  enum com_example_foodtruck {}
}

extension Tag.com_example_foodtruck {
  @Tag static var extraSpecial: Tag
}

@Test(
  "Extra Special Sauce recipe is secret",
  .tags(.com_example_foodtruck.extraSpecial)
)
func secretSauce() { ... }
```

----------------------------------------

TITLE: Testing process exit with standard output observation in Swift
DESCRIPTION: This Swift test function demonstrates how to use the `#expect` macro to assert that a process exits with a failure status and to observe the standard output content. It sets up a scenario where a customer attempts to eat food that is not delicious, and then asserts that the standard output contains the letter 'L'.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/exit-testing.md#_snippet_4

LANGUAGE: Swift
CODE:
```
@Test func `Customer won't eat food unless it's delicious`() async {
  let result = await #expect(
    processExitsWith: .failure,
    observing: [\.standardOutputContent]
  ) {
    var food = ...
    food.isDelicious = false
    Customer.current.eat(food)
  }
  if let result {
    #expect(result.standardOutputContent.contains(UInt8(ascii: "L")))
  }
}
```

----------------------------------------

TITLE: Testing with Cartesian Product of Collections in Swift
DESCRIPTION: This code demonstrates how to use the Cartesian product of collections to generate test cases. The test function `makeLargeOrder` is invoked for every possible combination of `Food` and `Int` within the specified ranges.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/ParameterizedTesting.md#_snippet_4

LANGUAGE: Swift
CODE:
```
@Test("Can make large orders", arguments: Food.allCases, 1 ... 100)
func makeLargeOrder(of food: Food, count: Int) async throws {
  let foodTruck = FoodTruck(selling: food)
  #expect(await foodTruck.cook(food, quantity: count))
}
```

----------------------------------------

TITLE: Disabling a Test with a Comment in Swift
DESCRIPTION: This code snippet shows how to disable a test and include a comment that will be displayed in the runner's output when the test is skipped. This provides additional context for why the test was disabled.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/EnablingAndDisabling.md#_snippet_1

LANGUAGE: Swift
CODE:
```
@Test("Food truck sells burritos", .disabled("We only sell Thai cuisine"))
func sellsBurritos() async throws { ... }
```

----------------------------------------

TITLE: Testing with Zipped Collections in Swift
DESCRIPTION: This code demonstrates how to use zipped collections to generate test cases. The `zip()` function combines `Food.allCases` and `1 ... 100` into a sequence of tuples, which are then passed to the test function `makeLargeOrder`.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/ParameterizedTesting.md#_snippet_5

LANGUAGE: Swift
CODE:
```
@Test("Can make large orders", arguments: zip(Food.allCases, 1 ... 100))
func makeLargeOrder(of food: Food, count: Int) async throws {
  let foodTruck = FoodTruck(selling: food)
  #expect(await foodTruck.cook(food, quantity: count))
}
```

----------------------------------------

TITLE: Declaring a Named Constant Tag in Swift
DESCRIPTION: This code snippet demonstrates how to declare a named constant tag using the @Tag macro within an extension of the Tag type. This allows the tag to be applied to tests for categorization and filtering.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/AddingTags.md#_snippet_0

LANGUAGE: Swift
CODE:
```
extension Tag {
  @Tag static var legallyRequired: Self
}

@Test("Vendor's license is valid", .tags(.legallyRequired))
func licenseValid() { ... }
```

----------------------------------------

TITLE: Disabling a Test Unconditionally in Swift
DESCRIPTION: This code snippet demonstrates how to disable a test unconditionally using the `.disabled()` trait. The test will always be skipped when executed.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/EnablingAndDisabling.md#_snippet_0

LANGUAGE: Swift
CODE:
```
@Test("Food truck sells burritos")
func sellsBurritos() async throws { ... }
```

LANGUAGE: Swift
CODE:
```
@Test("Food truck sells burritos", .disabled())
func sellsBurritos() async throws { ... }
```

----------------------------------------

TITLE: Annotate Known Issue After
DESCRIPTION: This code snippet demonstrates how to annotate a known issue in a test using the testing library's withKnownIssue function. It wraps the code that might fail due to the known issue within the closure provided to withKnownIssue.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/MigratingFromXCTest.md#_snippet_19

LANGUAGE: Swift
CODE:
```
// After
@Test func grillWorks() async {
  withKnownIssue("Grill is out of fuel") {
    try FoodTruck.shared.grill.start()
  }
  ...
}
```

----------------------------------------

TITLE: Adding a title to an associated bug in Swift
DESCRIPTION: This code snippet demonstrates how to add a title to an associated bug. The title is included as a string after the bug's unique identifier within the `.bug()` trait. The test function `hasNapkins()` is a placeholder for the actual test logic.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/AssociatingBugs.md#_snippet_2

LANGUAGE: swift
CODE:
```
@Test(
  "Food truck has napkins",
  .bug(id: "12345", "Forgot to buy more napkins")
)
func hasNapkins() async {
  ...
}
```

----------------------------------------

TITLE: Linking a Test to a Bug Report in Swift
DESCRIPTION: This code snippet demonstrates how to link a test to a bug report using the `.bug(id:)` trait. This helps to track the relationship between failing tests and known issues.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/EnablingAndDisabling.md#_snippet_4

LANGUAGE: Swift
CODE:
```
@Test(
  "Ice cream is cold",
  .enabled(if: Season.current == .summer),
  .disabled("We ran out of sprinkles"),
  .bug(id: "12345")
)
func isCold() async throws { ... }
```

----------------------------------------

TITLE: Handling Complex Conditions with Helper Functions in Swift
DESCRIPTION: This code snippet shows how to use a helper function to encapsulate complex conditions, improving the readability of test definitions. The helper function returns a boolean value that determines whether the test should be enabled.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/EnablingAndDisabling.md#_snippet_5

LANGUAGE: Swift
CODE:
```
func allIngredientsAvailable(for food: Food) -> Bool { ... }

@Test(
  "Can make sundaes",
  .enabled(if: Season.current == .summer),
  .enabled(if: allIngredientsAvailable(for: .sundae))
)
func makeSundae() async throws { ... }
```

----------------------------------------

TITLE: Handling Intermittent Known Issue in Swift
DESCRIPTION: This code snippet demonstrates how to use `withKnownIssue()` with `isIntermittent: true` to indicate that the issue may not always occur. This prevents the testing library from recording an issue when zero known issues are recorded.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/known-issues.md#_snippet_5

LANGUAGE: swift
CODE:
```
@Test func grillHeating() throws {
  var foodTruck = FoodTruck()
  try foodTruck.startGrill()
  withKnownIssue(isIntermittent: true) {
    #expect(foodTruck.grill.isHeating)
  }
}
```

----------------------------------------

TITLE: Marking Thrown Error as Known in Swift
DESCRIPTION: This example demonstrates how to use `withKnownIssue()` to mark a thrown error as known. The `startGrill()` function, which may throw an error, is called within the closure passed to `withKnownIssue()`. Any errors thrown from the closure are caught and interpreted as known issues.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/known-issues.md#_snippet_2

LANGUAGE: Swift
CODE:
```
@Test func grillHeating() {
  var foodTruck = FoodTruck()
  withKnownIssue {
    try foodTruck.startGrill() // Known issue
    #expect(foodTruck.grill.isHeating)
  }
}
```

----------------------------------------

TITLE: Annotate Intermittent Failure After
DESCRIPTION: This code snippet demonstrates how to annotate an intermittent failure in a test using the testing library's withKnownIssue function with the isIntermittent parameter set to true. This indicates that the failure is not always expected.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/MigratingFromXCTest.md#_snippet_21

LANGUAGE: Swift
CODE:
```
// After
@Test func grillWorks() async {
  withKnownIssue(
    "Grill may need fuel",
    isIntermittent: true
  ) {
    try FoodTruck.shared.grill.start()
  }
  ...
}
```

----------------------------------------

TITLE: Equivalent Test Suite Structures in Swift
DESCRIPTION: This example shows two equivalent ways to define a test suite and a test function within it. The first uses an instance method, while the second explicitly creates an instance and calls the method from a static test function.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/OrganizingTests.md#_snippet_1

LANGUAGE: Swift
CODE:
```
@Suite struct FoodTruckTests {
  @Test func foodTruckExists() { ... }
}
```

LANGUAGE: Swift
CODE:
```
@Suite struct FoodTruckTests {
  func foodTruckExists() { ... }

  @Test static func staticFoodTruckExists() {
    let instance = FoodTruckTests()
    instance.foodTruckExists()
  }
}
```

----------------------------------------

TITLE: Swift Testing Sequential Test Execution
DESCRIPTION: Illustrates how to run tests sequentially in Swift Testing using the `@Suite(.serialized)` annotation. The example shows the equivalent `RefrigeratorTests` suite, now annotated to ensure serial execution, and uses `#expect` for assertions.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/MigratingFromXCTest.md#_snippet_25

LANGUAGE: swift
CODE:
```
// After
@Suite(.serialized)
class RefrigeratorTests {
  @Test func lightComesOn() throws {
    try FoodTruck.shared.refrigerator.openDoor()
    #expect(FoodTruck.shared.refrigerator.lightState == .on)
  }

  @Test func lightGoesOut() throws {
    try FoodTruck.shared.refrigerator.openDoor()
    try FoodTruck.shared.refrigerator.closeDoor()
    #expect(FoodTruck.shared.refrigerator.lightState == .off)
  }
}
```

----------------------------------------

TITLE: Valid Test Suite with Private Initializer in Swift
DESCRIPTION: This example demonstrates a valid test suite where the struct has a private initializer. The initializer is still callable, satisfying the requirement for a zero-argument initializer.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/OrganizingTests.md#_snippet_3

LANGUAGE: Swift
CODE:
```
@Suite struct CashRegisterTests {
  private init(cashOnHand: Decimal = 0.0) async throws { ... }

  @Test func calculateSalesTax() { ... } // ✅ OK: The type has a callable init().
}
```

----------------------------------------

TITLE: Valid Test Suite with Static Test Function in Swift
DESCRIPTION: This code shows a valid test suite because the test function is static, so it doesn't require an instance of the struct to be created.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/OrganizingTests.md#_snippet_4

LANGUAGE: Swift
CODE:
```
struct MenuTests {
  var foods: [Food]
  var prices: [Food: Decimal]

  @Test static func specialOfTheDay() { ... } // ✅ OK: The function is static.
  @Test func orderAllFoods() { ... } // ❌ ERROR: The suite type requires init().
}
```

----------------------------------------

TITLE: Valid Test Suite with Implicit Initializer in Swift
DESCRIPTION: This code shows a valid test suite because the struct has an implicit zero-argument initializer, even though it has a stored property.
SOURCE: https://github.com/swiftlang/swift-testing/blob/main/Sources/Testing/Testing.docc/OrganizingTests.md#_snippet_2

LANGUAGE: Swift
CODE:
```
@Suite struct FoodTruckTests {
  var batteryLevel = 100

  @Test func foodTruckExists() { ... } // ✅ OK: The type has an implicit init().
}
```