TITLE: Handling Tool Results and Continuing Conversation Loop in SwiftClaude
DESCRIPTION: This snippet illustrates a common pattern for managing conversations that involve tool use. It uses a `repeat-while` loop to continuously fetch the next message from Claude and append it to the conversation. The loop continues as long as `conversation.nextStep()` indicates that a tool use result is expected, ensuring that all tool interactions are processed before proceeding with the conversation.
SOURCE: https://github.com/georgelyon/swiftclaude/blob/main/Readme.md#_snippet_13

LANGUAGE: Swift
CODE:
```
repeat {
  let message = claude.nextMessage(
    in: conversation,
    tools: Tools { … }
  )
  conversation.append(message)
} while try await conversation.nextStep() == .toolUseResult
```

----------------------------------------

TITLE: Displaying SwiftClaude Content Blocks in SwiftUI
DESCRIPTION: This SwiftUI example shows how to render content blocks from an observable `assistant` object, which conforms to `Observation`. It uses a `ForEach` loop to iterate over `currentContentBlocks`, displaying text blocks as `Text` views and tool use blocks with their names and outputs (if available). This pattern simplifies integrating Claude's responses, including tool interactions, into a SwiftUI user interface.
SOURCE: https://github.com/georgelyon/swiftclaude/blob/main/Readme.md#_snippet_12

LANGUAGE: Swift
CODE:
```
ForEach(assistant.currentContentBlocks) { block in
  switch block {
  case .textBlock(let textBlock):
    Text(textBlock.currentText)
  case .toolUseBlock(let toolUseBlock):
    if let output = toolUseBlock.toolUse.currentOutput {
      Text("[Using \(toolUseBlock.toolUse.toolName): \(output)]")
    } else {
      Text("[Using \(toolUseBlock.toolUse.toolName)]")
    }
  }
}
```

----------------------------------------

TITLE: Defining a Claude Conversation in Swift
DESCRIPTION: This snippet defines a `Conversation` struct conforming to the `Claude.Conversation` protocol, which serves as the core abstraction for managing messages in a dialogue with Claude. It demonstrates initializing a conversation with an initial user message.
SOURCE: https://github.com/georgelyon/swiftclaude/blob/main/Readme.md#_snippet_0

LANGUAGE: Swift
CODE:
```
import SwiftClaude

struct Conversation: Claude.Conversation {
  var messages: [Message]
}

var conversation = Conversation(
  messages: [
    .user("Write me a haiku about a really well-made tool.")
  ]
)
```

----------------------------------------

TITLE: Requesting the Next Message from Claude in Swift
DESCRIPTION: This snippet demonstrates how to request the next message from Claude within an existing conversation. It assumes that a `claude` instance has been created and a `conversation` object has been properly initialized with previous messages.
SOURCE: https://github.com/georgelyon/swiftclaude/blob/main/Readme.md#_snippet_1

LANGUAGE: Swift
CODE:
```
let message = claude.nextMessage(in: conversation)
```

----------------------------------------

TITLE: Processing Message Content Blocks with Async API in SwiftClaude
DESCRIPTION: This snippet demonstrates how to asynchronously process different types of content blocks received from a Claude message, including text and tool use blocks. It iterates through `message.contentBlocks`, handling `textBlock` by printing its fragments and `toolUseBlock` by printing the tool name and its output. This is crucial for conversations involving tool interactions.
SOURCE: https://github.com/georgelyon/swiftclaude/blob/main/Readme.md#_snippet_11

LANGUAGE: Swift
CODE:
```
for try await block in message.contentBlocks {
  switch block {
  case .textBlock(let textBlock):
    for try await textFragment in textBlock.textFragments {
      print(textFragment, terminator: "")
      fflush(stdout)
    }
  case .toolUseBlock(let toolUseBlock):
    print("[Using \(toolUseBlock.toolName): \(try await toolUseBlock.output())"]")
  }
}
print()
```

----------------------------------------

TITLE: Integrating Custom @ToolInput into a SwiftClaude Tool
DESCRIPTION: This snippet illustrates how to use a custom `@ToolInput` type (like the `Command` enum) as a parameter in a tool's `invoke` function. The `Browser` tool accepts a `Command` object, enabling Claude to issue complex, structured commands to control a simulated browser. The `invoke` function would contain the logic to execute the given command.
SOURCE: https://github.com/georgelyon/swiftclaude/blob/main/Readme.md#_snippet_7

LANGUAGE: Swift
CODE:
```
@Tool
struct Browser {

  /// Controls a browser
  func invoke(
    _ command: Command
  ) -> String {
    /// Execute `command`
  }

}
```

----------------------------------------

TITLE: Appending Image to User Message in SwiftClaude
DESCRIPTION: Demonstrates how to include UIImage or NSImage directly in a user message within SwiftClaude for vision capabilities. This allows the model to process and describe the provided image.
SOURCE: https://github.com/georgelyon/swiftclaude/blob/main/Readme.md#_snippet_14

LANGUAGE: Swift
CODE:
```
conversation.messages.append(
  .user("Describe this image: \(image)")
)
```

----------------------------------------

TITLE: Defining Custom Tool Input with @ToolInput Macro in Swift
DESCRIPTION: This example shows how to define a more sophisticated input type for a tool using the `@ToolInput` macro. It creates an `enum` named `Command` that can represent different browser navigation actions, including navigating to a specific URL. This allows for structured and type-safe tool inputs.
SOURCE: https://github.com/georgelyon/swiftclaude/blob/main/Readme.md#_snippet_6

LANGUAGE: Swift
CODE:
```
@ToolInput
enum Command {
  case goBack
  case goForward
  case navigate(to: String)
}
```

----------------------------------------

TITLE: Continuing a Multi-Turn Claude Conversation in Swift
DESCRIPTION: This snippet demonstrates how to continue a conversation with Claude by appending the assistant's previous response and a new user message to the existing conversation. After updating the conversation, a new message is requested to facilitate multi-turn interactions.
SOURCE: https://github.com/georgelyon/swiftclaude/blob/main/Readme.md#_snippet_4

LANGUAGE: Swift
CODE:
```
conversation.messages += [
  .assistant(message),
  .user("That was great! Can you write me one more, this time about track saws?")
]
let nextMessage = claude.nextMessage(in: conversation)
```

----------------------------------------

TITLE: Providing Tools to Claude in SwiftClaude Conversation
DESCRIPTION: This snippet demonstrates how to provide a list of available tools to Claude when requesting the next message in a conversation. The `Tools` builder is used to register instances of `CatEmojiTool` and `EmojiTool`, making them accessible for Claude to invoke based on its understanding of the conversation and tool definitions.
SOURCE: https://github.com/georgelyon/swiftclaude/blob/main/Readme.md#_snippet_9

LANGUAGE: Swift
CODE:
```
let message = claude.nextMessage(
  in: conversation,
  tools: Tools {
    CatEmojiTool()
    EmojiTool()
  }
)
```

----------------------------------------

TITLE: Creating Claude Instance with Authenticator
DESCRIPTION: Illustrates how to instantiate the main Claude object by passing an initialized authenticator instance. This sets up the Claude API client for subsequent operations.
SOURCE: https://github.com/georgelyon/swiftclaude/blob/main/Readme.md#_snippet_16

LANGUAGE: Swift
CODE:
```
let claude = Claude(authenticator: authenticator)
```

----------------------------------------

TITLE: Processing Claude Message Text in Swift
DESCRIPTION: This snippet illustrates two methods for processing the text content of a message received from Claude: awaiting the full text or processing it asynchronously in segments as they arrive. The segmented approach is useful for real-time display or streaming interfaces.
SOURCE: https://github.com/georgelyon/swiftclaude/blob/main/Readme.md#_snippet_2

LANGUAGE: Swift
CODE:
```
/// Print the full text
print(try await message.text())

/// Print the text as segments come in
for try await segment in message.textSegments {
  print(segment, terminator: "")
  fflush(stdout)
}
print()
```

----------------------------------------

TITLE: Defining a Simple Tool with @Tool Macro in SwiftClaude
DESCRIPTION: This snippet demonstrates how to define a basic tool in SwiftClaude using the `@Tool` macro. The `invoke` method is the entry point for Claude to call the tool, and its comments are crucial for Claude's understanding of the tool's purpose and parameters. This tool simply returns the input emoji.
SOURCE: https://github.com/georgelyon/swiftclaude/blob/main/Readme.md#_snippet_5

LANGUAGE: Swift
CODE:
```
@Tool
struct EmojiTool {

  /// Displays an emoji
  /// Great for spicing up a haiku!
  func invoke(
    _ emoji: String
  ) -> String {
    emoji
  }

}
```

----------------------------------------

TITLE: Displaying Claude Message Text in SwiftUI
DESCRIPTION: This snippet shows how to directly use an `Observable` message's `currentText` property within a SwiftUI `Text` view. This allows for real-time updates of the displayed text as the message content streams in, leveraging SwiftUI's reactive capabilities.
SOURCE: https://github.com/georgelyon/swiftclaude/blob/main/Readme.md#_snippet_3

LANGUAGE: Swift
CODE:
```
Text(message.currentText)
```