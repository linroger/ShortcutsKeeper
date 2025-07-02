TITLE: Implementing a Generic Sigmoid Activation Function in Swift
DESCRIPTION: This Swift code snippet demonstrates how to implement a generic sigmoid activation function using the 'Real' protocol from RealModule. The function `sigmoid<T: Real>(_ x: T) -> T` calculates `1 / (1 + .exp(-x))`, allowing it to work seamlessly with any type conforming to 'Real', such as Float, Double, or Float80, making it highly adaptable for machine learning applications.
SOURCE: https://github.com/apple/swift-numerics/blob/main/Sources/RealModule/README.md#_snippet_1

LANGUAGE: Swift
CODE:
```
import Numerics

func sigmoid<T: Real>(_ x: T) -> T {
  1 / (1 + .exp(-x))
}
```

----------------------------------------

TITLE: Adding Swift Numerics package dependency in Package.swift
DESCRIPTION: To integrate Swift Numerics into a Swift Package Manager project, add this line to the `dependencies` array within your `Package.swift` file. This specifies the GitHub repository URL and the minimum version requirement for the package.
SOURCE: https://github.com/apple/swift-numerics/blob/main/README.md#_snippet_2

LANGUAGE: swift
CODE:
```
.package(url: "https://github.com/apple/swift-numerics", from: "1.0.0"),
```

----------------------------------------

TITLE: Adding Numerics as a target dependency in Package.swift
DESCRIPTION: After declaring the package dependency, you must add `Numerics` as a product dependency for your specific target within your `Package.swift` file. This ensures your target can access the APIs provided by the Swift Numerics package.
SOURCE: https://github.com/apple/swift-numerics/blob/main/README.md#_snippet_3

LANGUAGE: swift
CODE:
```
.target(name: "MyTarget", dependencies: [
  .product(name: "Numerics", package: "swift-numerics"),
  "AnotherModule"
]),
```

----------------------------------------

TITLE: Initialize a Complex Number in Swift
DESCRIPTION: Demonstrates how to import the `Numerics` module and create an instance of the `Complex` type by providing its real and imaginary components.
SOURCE: https://github.com/apple/swift-numerics/blob/main/Sources/ComplexModule/README.md#_snippet_0

LANGUAGE: swift
CODE:
```
import Numerics
let z = Complex(1,1) // z = 1 + i
```

----------------------------------------

TITLE: Importing the top-level Numerics module in Swift
DESCRIPTION: This example illustrates how to import the main `Numerics` module, which re-exports the complete public interface of the Swift Numerics package. Importing this module makes all Swift Numerics APIs available in your source code.
SOURCE: https://github.com/apple/swift-numerics/blob/main/README.md#_snippet_1

LANGUAGE: swift
CODE:
```
import Numerics

// The entire Swift Numerics API is now available
```

----------------------------------------

TITLE: Importing Swift Numerics Module
DESCRIPTION: This snippet demonstrates how to import the Numerics umbrella module in Swift, providing access to all its functionalities with a single statement.
SOURCE: https://github.com/apple/swift-numerics/blob/main/Sources/Numerics/README.md#_snippet_0

LANGUAGE: Swift
CODE:
```
import Numerics
```

----------------------------------------

TITLE: Importing ComplexModule in Swift
DESCRIPTION: This snippet demonstrates how to import the `ComplexModule` to use complex number types. It shows the basic syntax for importing the module and initializing a complex number representing the imaginary unit 'i'.
SOURCE: https://github.com/apple/swift-numerics/blob/main/README.md#_snippet_0

LANGUAGE: swift
CODE:
```
import ComplexModule

let z = Complex<Double>.i
```

----------------------------------------

TITLE: Demonstrate Saturating Arithmetic for FixedWidthInteger in Swift
DESCRIPTION: Compares standard addition (`+`), wrapping addition (`&+`), and saturating addition (`addingWithSaturation`) for `FixedWidthInteger` types. Saturating arithmetic clamps the result to the representable range of the type, unlike standard operators which trap on overflow or wrapping operators which wrap results modulo 2ⁿ.
SOURCE: https://github.com/apple/swift-numerics/blob/main/Sources/IntegerUtilities/README.md#_snippet_4

LANGUAGE: Swift
CODE:
```
let x: Int8 = 84
let y: Int8 = 100
let a = x + y                     // traps due to overflow
let b = x &+ y                    // wraps to -72
let c = x.addingWithSaturation(y) // saturates to 127
```

----------------------------------------

TITLE: RealModule Protocols and Methods Overview
DESCRIPTION: This section details the four core protocols defined in RealModule: ElementaryFunctions, RealFunctions, Real, and AlgebraicField. It outlines the specific mathematical functions and operations each protocol provides, enabling generic numeric programming in Swift.
SOURCE: https://github.com/apple/swift-numerics/blob/main/Sources/RealModule/README.md#_snippet_0

LANGUAGE: APIDOC
CODE:
```
Protocol: ElementaryFunctions
  Refines: AdditiveArithmetic
  Description: Provides basic mathematical functions.
  Functions:
    - exp()
    - expMinusOne()
    - log()
    - log(onePlus:)
    - cos()
    - sin()
    - tan()
    - acos()
    - asin()
    - atan()
    - cosh()
    - sinh()
    - tanh()
    - acosh()
    - asinh()
    - atanh()
    - pow()
    - sqrt()
    - root()
  Inherited from AdditiveArithmetic:
    - Addition (+)
    - Subtraction (-)
    - .zero property

Protocol: RealFunctions
  Refines: ElementaryFunctions
  Description: Adds operations difficult to define or implement over fields more general than real numbers.
  Functions:
    - atan2(y:x:): Computes atan(y/x) with sign chosen by the quadrant of (x,y).
    - hypot(): Computes sqrt(x*x + y*y) without intermediate overflow or underflow.
    - erf(): The error function.
    - erfc(): The complement of the error function.
    - exp2()
    - exp10()
    - log2()
    - log10()
    - gamma(): Evaluates the gamma function.
    - logGamma(): Evaluates the logarithm of the gamma function.
    - signGamma(): Evaluates the sign of the gamma function.

Protocol: Real
  Refines: ElementaryFunctions, AlgebraicField
  Description: Describes a floating-point type equipped with the full set of basic math functions. Ideal for writing generic numeric code.

Protocol: AlgebraicField
  Refines: SignedNumeric
  Description: A small refinement of SignedNumeric, adding division operators and a reciprocal property. Primarily for writing code generic over real and complex types.
  Operators:
    - / (division)
    - /= (in-place division)
  Properties:
    - reciprocal
```

----------------------------------------

TITLE: Complex Type Features and Protocol Conformances
DESCRIPTION: Documentation for the `Complex` number type in Swift Numerics, detailing its generic nature, standard arithmetic operations, conversion capabilities, and its extensive list of protocol conformances including `Equatable`, `Hashable`, `Codable`, `AlgebraicField`, and `ElementaryFunctions`.
SOURCE: https://github.com/apple/swift-numerics/blob/main/Sources/ComplexModule/README.md#_snippet_2

LANGUAGE: APIDOC
CODE:
```
Complex<RealType>:
  Description: A generic complex number type over an underlying RealType.
  Features:
    - Usual arithmetic operators (+, -, *, /)
    - Conversion to and from polar coordinates
    - Many useful properties
  Protocol Conformances:
    - Equatable (if RealType is Equatable)
    - Hashable (if RealType is Hashable)
    - Codable (if RealType is Codable)
    - AlgebraicField (implies AdditiveArithmetic, SignedNumeric)
    - ElementaryFunctions (provides log, pow, sin, etc.)
  Dependencies:
    - RealModule
```

----------------------------------------

TITLE: Precomputing DFT Weights with RealModule in Swift
DESCRIPTION: This Swift extension for the 'Real' protocol provides a static method `dftWeight(k: Int, n: Int)` to compute the real and imaginary parts of Discrete Fourier Transform (DFT) weights. It calculates `e^(-2πik/n)` using the `.cos` and `.sin` functions from RealModule, ensuring accurate results and generic applicability across various floating-point types like Float, Double, and future types such as Float16 or Float128.
SOURCE: https://github.com/apple/swift-numerics/blob/main/Sources/RealModule/README.md#_snippet_2

LANGUAGE: Swift
CODE:
```
import Numerics

extension Real {
  // The real and imaginary parts of e^{-2πik/n}
  static func dftWeight(k: Int, n: Int) -> (r: Self, i: Self) {
    precondition(0 <= k && k < n, "k is out of range")
    guard let N = Self(exactly: n) else {
      preconditionFailure("n cannot be represented exactly.")
    }
    let theta = -2 * .pi * (Self(k) / N)
    return (r: .cos(theta), i: .sin(theta))
  }
}
```

----------------------------------------

TITLE: API for BinaryInteger Utilities in Swift Numerics
DESCRIPTION: Defines core utility functions and methods applicable to all `BinaryInteger` types, including Greatest Common Divisor (GCD), bitwise shifts with rounding, and division with specified rounding.
SOURCE: https://github.com/apple/swift-numerics/blob/main/Sources/IntegerUtilities/README.md#_snippet_0

LANGUAGE: APIDOC
CODE:
```
BinaryInteger:
  Methods:
    gcd(_:_:):
      Description: Implements the Greatest Common Divisor operation for two BinaryInteger values.
      Parameters:
        lhs: The first BinaryInteger value.
        rhs: The second BinaryInteger value.
      Returns: The greatest common divisor of lhs and rhs.
    shifted(rightBy:rounding:):
      Description: Implements bitwise right shift with specified rounding.
      Parameters:
        rightBy: The number of bits to shift right (BinaryInteger).
        rounding: The RoundingRule to apply.
      Returns: The shifted value.
    divided(by:rounding:):
      Description: Implements division with specified rounding.
      Parameters:
        by: The divisor (Self).
        rounding: The RoundingRule to apply.
      Returns: The quotient (Self).
```

----------------------------------------

TITLE: Complex Number Infinity and NaN Semantics
DESCRIPTION: Explains how the Swift Numerics `Complex` type handles special floating-point values like zero, infinity, and NaN. It clarifies that the sign of zero and infinity has no semantic meaning, and non-finite complex numbers are treated as a single exceptional value with `real` and `imaginary` components returning `.nan`.
SOURCE: https://github.com/apple/swift-numerics/blob/main/Sources/ComplexModule/README.md#_snippet_3

LANGUAGE: APIDOC
CODE:
```
Complex Number Semantics for Infinity and NaN:
  Zero Representation:
    - (±0, ±0) are all considered encodings of the value zero.
    - No semantic meaning assigned to the sign of zero.
  Non-Finite Values (Infinity/NaN):
    - (±inf, y), (x, ±inf), (nan, y), (x, nan) are all considered encodings of a single exceptional value.
    - This exceptional value has infinite magnitude and undefined phase.
  Property Behavior for Non-Finite Values:
    - real: Returns .nan
    - imaginary: Returns .nan
  Rationale:
    - Simplifies implementation of some operations.
    - Decision might be revisited based on user experience.
```

----------------------------------------

TITLE: Understanding Swift Numerics Module Naming for Type Aliases
DESCRIPTION: This snippet illustrates the reason behind the 'Module' suffix in Swift Numerics module names like 'ComplexModule'. It demonstrates how direct imports of modules with ambiguous type names can lead to name lookup failures when creating type aliases, and how the 'Module' suffix resolves this by allowing explicit qualification.
SOURCE: https://github.com/apple/swift-numerics/blob/main/README.md#_snippet_4

LANGUAGE: Swift
CODE:
```
import Complex
// I know I only ever want Complex<Double>, so I shouldn't need the generic parameter.
typealias Complex = Complex.Complex<Double> // This doesn't work, because name lookup fails.
```

LANGUAGE: Swift
CODE:
```
import ComplexModule
// I know I only ever want Complex<Double>, so I shouldn't need the generic parameter.
typealias Complex = ComplexModule.Complex<Double>
// But I can still refer to the generic type by qualifying the name if I need it occasionally:
let a = ComplexModule.Complex<Float>
```

----------------------------------------

TITLE: Illustrating Type Inference Ambiguity with Mixed Real-Complex Arithmetic
DESCRIPTION: These Swift code examples demonstrate the challenges of type inference when attempting heterogeneous arithmetic operations between `RealType` and literal numbers. The first snippet shows ambiguity without context, while the second illustrates an unexpected `Complex` type inference within a `Complex` extension, highlighting why direct heterogeneous operators are avoided.
SOURCE: https://github.com/apple/swift-numerics/blob/main/Sources/ComplexModule/README.md#_snippet_1

LANGUAGE: swift
CODE:
```
let a: RealType = 1
let b = 2*a
```

LANGUAGE: swift
CODE:
```
extension Complex {
  static func doSomething() {
    let a: RealType = 1
    let b = 2*a // type is inferred as Complex 🤪
  }
}
```

----------------------------------------

TITLE: Complex.magnitude Property Design and Norms
DESCRIPTION: Details the design rationale behind the `Complex.magnitude` property, which deviates from the intuitive Euclidean 2-norm by using the ∞-norm (sup norm). This choice is made to enhance robustness against overflow/underflow and simplify computation, while the 2-norm is still accessible via `.length` and `.lengthSquared` properties.
SOURCE: https://github.com/apple/swift-numerics/blob/main/Sources/ComplexModule/README.md#_snippet_4

LANGUAGE: APIDOC
CODE:
```
Complex.magnitude Property:
  Description: The magnitude property for Complex numbers.
  Implementation:
    - Uses the ∞-norm (sup norm) for robustness.
  Rationale for ∞-norm:
    - Avoids spurious overflow/underflow issues common with 2-norm (Euclidean norm).
    - Naive 1-norm and ∞-norm expressions are always correct.
    - ∞-norm is guaranteed representable even when 2-norm overflows (e.g., Complex(Double.greatestFiniteMagnitude, Double.greatestFiniteMagnitude)).
    - Easier to compute for exotic types (O(n) vs O(n^3)).
    - Heavily used in other computational libraries (e.g., BLAS izamax/icamax).
  Related Properties for 2-norm:
    - length: Provides the Euclidean 2-norm (sqrt(real*real + imaginary*imaginary)).
    - lengthSquared: Provides the square of the Euclidean 2-norm.
```

----------------------------------------

TITLE: API for FixedWidthInteger Utilities in Swift Numerics
DESCRIPTION: Defines utility methods for `FixedWidthInteger` types, including bitwise rotation and a suite of saturating arithmetic operations.
SOURCE: https://github.com/apple/swift-numerics/blob/main/Sources/IntegerUtilities/README.md#_snippet_3

LANGUAGE: APIDOC
CODE:
```
FixedWidthInteger:
  Methods:
    rotated(right:):
      Description: Implements bitwise right rotation.
      Parameters:
        right: The count parameter (any BinaryInteger type).
      Returns: The rotated value (Self).
    rotated(left:):
      Description: Implements bitwise left rotation.
      Parameters:
        left: The count parameter (any BinaryInteger type).
      Returns: The rotated value (Self).
    addingWithSaturation(_:):
      Description: Performs addition with saturation. Clamps the result to the representable range of the type.
      Parameters:
        other: The value to add (Self).
      Returns: The saturated sum (Self).
    subtractingWithSaturation(_:):
      Description: Performs subtraction with saturation. Clamps the result to the representable range of the type.
      Parameters:
        other: The value to subtract (Self).
      Returns: The saturated difference (Self).
    negatedWithSaturation():
      Description: Performs negation with saturation. Clamps the result to the representable range of the type.
      Returns: The saturated negated value (Self).
    multipliedWithSaturation(by:):
      Description: Performs multiplication with saturation. Clamps the result to the representable range of the type.
      Parameters:
        other: The value to multiply by (Self).
      Returns: The saturated product (Self).
    shiftedWithSaturation(leftBy:rounding:):
      Description: Performs bitwise left shift with saturation and rounding. Clamps the result to the representable range of the type.
      Parameters:
        leftBy: The number of bits to shift left (BinaryInteger).
        rounding: The RoundingRule to apply.
      Returns: The saturated shifted value (Self).
```

----------------------------------------

TITLE: API for SignedInteger Utilities in Swift Numerics
DESCRIPTION: Defines utility methods specifically for `SignedInteger` types, including division with quotient and remainder, remainder operation with quotient rounding, and Euclidean division.
SOURCE: https://github.com/apple/swift-numerics/blob/main/Sources/IntegerUtilities/README.md#_snippet_2

LANGUAGE: APIDOC
CODE:
```
SignedInteger:
  Methods:
    divided(by:rounding:):
      Description: Implements division with specified rounding, returning both quotient and remainder. This overload requires a signed type because the remainder is not generally representable for unsigned types.
      Parameters:
        by: The divisor (Self).
        rounding: The RoundingRule to apply for the quotient.
      Returns: A tuple (quotient: Self, remainder: Self).
    remainder(dividingBy:rounding:):
      Description: Implements the remainder operation. The 'rounding' argument describes how to round the quotient, which is not returned. The remainder is always exact.
      Parameters:
        dividingBy: The divisor (Self).
        rounding: The RoundingRule to apply for the quotient.
      Returns: The remainder (Self).
  Free Functions:
    euclideanDivision(_:_:):
      Description: Implements Euclidean division, where the remainder is chosen to always be non-negative. This does not correspond to any rounding rule on the quotient.
      Parameters:
        dividend: The number to be divided (Self).
        divisor: The number to divide by (Self).
      Returns: A tuple (quotient: Self, remainder: Self).
```

----------------------------------------

TITLE: API for RoundingRule Enum in Swift Numerics
DESCRIPTION: Defines the `RoundingRule` enumeration, used to specify how to round results of shift, division, and other rounding operations to a representable value.
SOURCE: https://github.com/apple/swift-numerics/blob/main/Sources/IntegerUtilities/README.md#_snippet_5

LANGUAGE: APIDOC
CODE:
```
RoundingRule:
  Type: Enum
  Description: An enumeration used with shift, division, and round operations to specify how to round their results to a representable value.
```

----------------------------------------

TITLE: Perform Division with Rounding for Signed Integers in Swift
DESCRIPTION: Implements division with specified rounding for signed integer types, returning both quotient and remainder. The remainder is not generally representable for unsigned types. This is a disfavored overload; by default, only the quotient is returned.
SOURCE: https://github.com/apple/swift-numerics/blob/main/Sources/IntegerUtilities/README.md#_snippet_1

LANGUAGE: Swift
CODE:
```
let p = 5.divided(by: 3, rounding: .up)      // p = 2
let (q, r) = 5.divided(by: 3, rounding: .up) // q = 2, r = -1
```

----------------------------------------

TITLE: Configure Swift Numerics Project Build with CMake
DESCRIPTION: This CMake script defines the build system for the Swift Numerics project. It sets the minimum required CMake version, declares the project name and language, configures output directories for libraries, executables, and Swift modules, includes essential CMake modules like CTest and SwiftSupport, adds source subdirectories, and exports the project's build targets for external use.
SOURCE: https://github.com/apple/swift-numerics/blob/main/CMakeLists.txt#_snippet_0

LANGUAGE: CMake
CODE:
```
cmake_minimum_required(VERSION 3.16)
project(swift-numerics
  LANGUAGES Swift)

list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake/modules)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_Swift_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/swift)

include(CTest)
include(SwiftSupport)

add_subdirectory(Sources)

get_property(SWIFT_NUMERICS_EXPORTS GLOBAL PROPERTY SWIFT_NUMERICS_EXPORTS)
export(TARGETS ${SWIFT_NUMERICS_EXPORTS}
  NAMESPACE SwiftNumerics::
  FILE swift-numerics-config.cmake
  EXPORT_LINK_INTERFACE_LIBRARIES)
```

----------------------------------------

TITLE: Configure Swift Numerics Project with CMake
DESCRIPTION: This CMake script configures the Swift Numerics project by adding various subdirectories as modules, such as _NumericsShims, ComplexModule, IntegerUtilities, Numerics, and RealModule. It also conditionally includes a testing support directory (_TestSupport) if the BUILD_TESTING flag is enabled during compilation.
SOURCE: https://github.com/apple/swift-numerics/blob/main/Sources/CMakeLists.txt#_snippet_0

LANGUAGE: CMake
CODE:
```
add_subdirectory(_NumericsShims)
add_subdirectory(ComplexModule)
add_subdirectory(IntegerUtilities)
add_subdirectory(Numerics)
add_subdirectory(RealModule)
if(BUILD_TESTING)
  add_subdirectory(_TestSupport)
endif()
```

----------------------------------------

TITLE: Configure Swift Numerics IntegerUtilities Library with CMake
DESCRIPTION: This CMake script defines the `IntegerUtilities` library, specifying its Swift source files (DivideWithRounding.swift, GCD.swift, Rotate.swift, RoundingRule.swift, SaturatingArithmetic.swift, ShiftWithRounding.swift), setting include directories, and configuring it for installation and export within the Swift Numerics project.
SOURCE: https://github.com/apple/swift-numerics/blob/main/Sources/IntegerUtilities/CMakeLists.txt#_snippet_0

LANGUAGE: CMake
CODE:
```
add_library(IntegerUtilities
  DivideWithRounding.swift
  GCD.swift
  Rotate.swift
  RoundingRule.swift
  SaturatingArithmetic.swift
  ShiftWithRounding.swift)
set_target_properties(IntegerUtilities PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_Swift_MODULE_DIRECTORY})

_install_target(IntegerUtilities)
set_property(GLOBAL APPEND PROPERTY SWIFT_NUMERICS_EXPORTS IntegerUtilities)
```