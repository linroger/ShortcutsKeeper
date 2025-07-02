TITLE: Creating a Markdown View with a String in SwiftUI
DESCRIPTION: This snippet demonstrates the simplest way to create a `Markdown` view in SwiftUI by passing a direct Markdown string to its initializer. It shows how to define a multi-line Markdown string and then use it within a `View`'s `body` property to render rich text.
SOURCE: https://github.com/gonzalezreal/swift-markdown-ui/blob/main/Sources/MarkdownUI/Documentation.docc/Articles/GettingStarted.md#_snippet_0

LANGUAGE: Swift
CODE:
```
let markdownString = """
  ## Try MarkdownUI

  **MarkdownUI** is a native Markdown renderer for SwiftUI
  compatible with the
  [GitHub Flavored Markdown Spec](https://github.github.com/gfm/).
  """

var body: some View {
  Markdown(markdownString)
}
```

----------------------------------------

TITLE: Creating a Basic Markdown View in SwiftUI
DESCRIPTION: This snippet demonstrates the simplest way to display Markdown content in a SwiftUI view using MarkdownUI. It initializes a `Markdown` view by passing a multi-line Markdown string directly to its initializer. This method is suitable for static or pre-defined Markdown content.
SOURCE: https://github.com/gonzalezreal/swift-markdown-ui/blob/main/README.md#_snippet_0

LANGUAGE: Swift
CODE:
```
let markdownString = """
  ## Try MarkdownUI

  **MarkdownUI** is a native Markdown renderer for SwiftUI
  compatible with the
  [GitHub Flavored Markdown Spec](https://github.github.com/gfm/).
  """

var body: some View {
  Markdown(markdownString)
}
```

----------------------------------------

TITLE: Declaring MarkdownUI Package Dependency in Swift
DESCRIPTION: This snippet shows how to declare MarkdownUI as a package dependency in a `Package.swift` file for Swift Package Manager. It specifies the GitHub URL of the library and the minimum version requirement, allowing SPM to fetch and manage the dependency.
SOURCE: https://github.com/gonzalezreal/swift-markdown-ui/blob/main/README.md#_snippet_8

LANGUAGE: Swift
CODE:
```
.package(url: "https://github.com/gonzalezreal/swift-markdown-ui", from: "2.0.2")
```

----------------------------------------

TITLE: Adding MarkdownUI as Target Dependency in Swift
DESCRIPTION: This snippet demonstrates how to add MarkdownUI as a product dependency to an executable target within a `Package.swift` file. It links the `MarkdownUI` product from the `swift-markdown-ui` package to the specified target, making its functionalities available for use.
SOURCE: https://github.com/gonzalezreal/swift-markdown-ui/blob/main/README.md#_snippet_9

LANGUAGE: Swift
CODE:
```
.target(name: "<target>", dependencies: [
  .product(name: "MarkdownUI", package: "swift-markdown-ui")
]),
```

----------------------------------------

TITLE: Creating a Custom Markdown Theme in Swift-Markdown-UI
DESCRIPTION: This snippet illustrates how to create a custom `Theme` by extending the `Theme` type. It shows chaining multiple text and block style customizations, such as for code, links, paragraphs, and list items, to define a reusable theme.
SOURCE: https://github.com/gonzalezreal/swift-markdown-ui/blob/main/Sources/MarkdownUI/Documentation.docc/Articles/GettingStarted.md#_snippet_7

LANGUAGE: Swift
CODE:
```
extension Theme {\n  static let fancy = Theme()\n    .code {\n      FontFamilyVariant(.monospaced)\n      FontSize(.em(0.85))\n    }\n    .link {\n      ForegroundColor(.purple)\n    }\n    // More text styles...\n    .paragraph { configuration in\n      configuration.label\n        .relativeLineSpacing(.em(0.25))\n        .markdownMargin(top: 0, bottom: 16)\n    }\n    .listItem { configuration in\n      configuration.label\n        .markdownMargin(top: .em(0.25))\n    }\n    // More block styles...\n}
```

----------------------------------------

TITLE: Creating a Custom Markdown Theme in Swift
DESCRIPTION: To create a custom theme, instantiate an empty `Theme` and chain together different text and block styles. This example demonstrates extending `Theme` to define a `fancy` theme with custom styles for code, links, paragraphs, and list items.
SOURCE: https://github.com/gonzalezreal/swift-markdown-ui/blob/main/README.md#_snippet_7

LANGUAGE: Swift
CODE:
```
extension Theme {
  static let fancy = Theme()
    .code {
      FontFamilyVariant(.monospaced)
      FontSize(.em(0.85))
    }
    .link {
      ForegroundColor(.purple)
    }
    // More text styles...
    .paragraph { configuration in
      configuration.label
        .relativeLineSpacing(.em(0.25))
        .markdownMargin(top: 0, bottom: 16)
    }
    .listItem { configuration in
      configuration.label
        .markdownMargin(top: .em(0.25))
    }
    // More block styles...
}
```

----------------------------------------

TITLE: Composing Markdown Content with a Builder in SwiftUI
DESCRIPTION: This example illustrates a more flexible approach to creating a `Markdown` view using a content builder. It allows for composing Markdown content using both raw Markdown strings and an expressive domain-specific language (DSL) for elements like headings, paragraphs, strong text, and links, providing structured content creation.
SOURCE: https://github.com/gonzalezreal/swift-markdown-ui/blob/main/Sources/MarkdownUI/Documentation.docc/Articles/GettingStarted.md#_snippet_1

LANGUAGE: Swift
CODE:
```
var body: some View {
  Markdown {
    """
    ## Using a Markdown Content Builder
    Use Markdown strings or an expressive domain-specific language
    to build the content.
    """
    Heading(.level2) {
      "Try MarkdownUI"
    }
    Paragraph {
      Strong("MarkdownUI")
      " is a native Markdown renderer for SwiftUI"
      " compatible with the "
      InlineLink(
        "GitHub Flavored Markdown Spec",
        destination: URL(string: "https://github.github.com/gfm/")!
      )
      "."
    }
  }
}
```

----------------------------------------

TITLE: Composing Markdown Content with a Builder in SwiftUI
DESCRIPTION: This example illustrates a more flexible approach to creating Markdown content using a content builder closure. It allows for combining raw Markdown strings with an expressive domain-specific language (DSL) to construct complex Markdown structures programmatically, offering fine-grained control over elements like headings, paragraphs, and links.
SOURCE: https://github.com/gonzalezreal/swift-markdown-ui/blob/main/README.md#_snippet_1

LANGUAGE: Swift
CODE:
```
var body: some View {
  Markdown {
    """
    ## Using a Markdown Content Builder
    Use Markdown strings or an expressive domain-specific language
    to build the content.
    """
    Heading(.level2) {
      "Try MarkdownUI"
    }
    Paragraph {
      Strong("MarkdownUI")
      " is a native Markdown renderer for SwiftUI"
      " compatible with the "
      InlineLink(
        "GitHub Flavored Markdown Spec",
        destination: URL(string: "https://github.github.com/gfm/")!
      )
      "."
    }
  }
}
```

----------------------------------------

TITLE: Configuring Asset Image Provider in MarkdownUI 2 (Swift)
DESCRIPTION: This snippet demonstrates how to configure MarkdownUI 2 to load images from the main bundle using the `markdownImageProvider(.asset)` modifier. It shows a `Markdown` view containing an image reference and a text, with the image provider set to load assets.
SOURCE: https://github.com/gonzalezreal/swift-markdown-ui/blob/main/Sources/MarkdownUI/Documentation.docc/Articles/MigratingToVersion2.md#_snippet_0

LANGUAGE: Swift
CODE:
```
Markdown {
  "![A dog](dog)"
  "― Photo by André Spieker"
}
.markdownImageProvider(.asset)
```

----------------------------------------

TITLE: Using Pre-parsed MarkdownContent in SwiftUI
DESCRIPTION: This snippet demonstrates how to use a pre-parsed `MarkdownContent` value, typically created in the model layer, to initialize a `Markdown` view. This approach optimizes performance by preventing the view from re-parsing the Markdown string, making it suitable for scenarios where content is static or frequently reused.
SOURCE: https://github.com/gonzalezreal/swift-markdown-ui/blob/main/Sources/MarkdownUI/Documentation.docc/Articles/GettingStarted.md#_snippet_2

LANGUAGE: Swift
CODE:
```
// Somewhere in the model layer
let content = MarkdownContent("You can try **CommonMark** [here](https://spec.commonmark.org/dingus/).")

// Later in the view layer
var body: some View {
  Markdown(self.model.content)
}
```

----------------------------------------

TITLE: Pre-parsing Markdown Content for Performance in SwiftUI
DESCRIPTION: This snippet demonstrates how to pre-parse Markdown content into a `MarkdownContent` value in the model layer, improving performance by preventing the view from repeatedly parsing the string. The pre-parsed `MarkdownContent` object can then be passed to the `Markdown` view's initializer, separating content preparation from view rendering.
SOURCE: https://github.com/gonzalezreal/swift-markdown-ui/blob/main/README.md#_snippet_2

LANGUAGE: Swift
CODE:
```
// Somewhere in the model layer
let content = MarkdownContent("You can try **CommonMark** [here](https://spec.commonmark.org/dingus/).")

// Later in the view layer
var body: some View {
  Markdown(self.model.content)
}
```

----------------------------------------

TITLE: Customizing Blockquote Style in Swift-Markdown-UI
DESCRIPTION: This example demonstrates overriding the default blockquote style using the `markdownBlockStyle(_:body:)` modifier. It applies custom padding, text styling (lowercase small caps, semibold font), a teal leading border, and a semi-transparent teal background to blockquotes.
SOURCE: https://github.com/gonzalezreal/swift-markdown-ui/blob/main/Sources/MarkdownUI/Documentation.docc/Articles/GettingStarted.md#_snippet_6

LANGUAGE: Swift
CODE:
```
Markdown {\n  """\n  You can quote text with a `>`.\n\n  > Outside of a dog, a book is man's best friend. Inside of a\n  > dog it's too dark to read.\n\n  – Groucho Marx\n  """\n}\n.markdownBlockStyle(\.blockquote) { configuration in\n  configuration.label\n    .padding()\n    .markdownTextStyle {\n      FontCapsVariant(.lowercaseSmallCaps)\n      FontWeight(.semibold)\n      BackgroundColor(nil)\n    }\n    .overlay(alignment: .leading) {\n      Rectangle()\n        .fill(Color.teal)\n        .frame(width: 4)\n    }\n    .background(Color.teal.opacity(0.5))\n}
```

----------------------------------------

TITLE: Applying GitHub Theme to Markdown Blockquote in Swift-Markdown-UI
DESCRIPTION: This example illustrates how to apply the built-in `.gitHub` theme to a Markdown view using the `markdownTheme(_:)` modifier. It changes the appearance of the blockquote to match the GitHub theme's styling.
SOURCE: https://github.com/gonzalezreal/swift-markdown-ui/blob/main/Sources/MarkdownUI/Documentation.docc/Articles/GettingStarted.md#_snippet_4

LANGUAGE: Swift
CODE:
```
Markdown {\n  """\n  You can quote text with a `>`.\n\n  > Outside of a dog, a book is man's best friend. Inside of a\n  > dog it's too dark to read.\n\n  – Groucho Marx\n  """\n}\n.markdownTheme(.gitHub)
```

----------------------------------------

TITLE: Applying Built-in GitHub Theme to Markdown in Swift
DESCRIPTION: You can customize the appearance of Markdown content by applying different themes using the `markdownTheme(_:)` modifier. This example shows how to apply one of the built-in themes, like `gitHub`, to a Markdown view.
SOURCE: https://github.com/gonzalezreal/swift-markdown-ui/blob/main/README.md#_snippet_4

LANGUAGE: Swift
CODE:
```
Markdown {
  """
You can quote text with a `>`.

> Outside of a dog, a book is man's best friend. Inside of a
> dog it's too dark to read.

– Groucho Marx
"""
}
.markdownTheme(.gitHub)
```