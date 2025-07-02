# Swift App Setup Command

**Command**: `/project:swift-app-setup`

## Purpose
Comprehensive native macOS/iOS app development setup following your established patterns and quality standards.

## Workflow

Please set up a complete Swift application development environment:

1. **Project Structure Analysis**
   - Examine existing project structure and organization
   - Identify main app targets and dependencies
   - Review current build configuration and schemes
   - Assess package dependencies and version requirements

2. **Architecture Setup**
   - Implement MVVM architecture with @Observable ViewModels
   - Set up SwiftData models for data persistence (not Core Data)
   - Create proper separation of concerns: Models/, ViewModels/, Views/, Services/
   - Establish navigation architecture using NavigationSplitView for macOS

3. **Development Environment**
   - Configure Xcode project settings for Swift 6 and latest macOS/iOS targets
   - Set up proper build configurations (Debug/Release)
   - Configure package dependencies and Swift Package Manager
   - Establish code signing and development team settings

4. **UI Foundation**
   - Implement native macOS design patterns using SwiftUI
   - Set up proper color schemes supporting light/dark mode
   - Configure SF Symbols and system fonts
   - Establish responsive layout patterns for different screen sizes

5. **Core Infrastructure**
   - Set up comprehensive error handling with user-friendly feedback
   - Implement proper async/await patterns for Swift concurrency
   - Create reusable UI components and view modifiers
   - Set up data validation and input sanitization

6. **Build Verification**
   - Ensure clean build with zero errors and minimal warnings
   - Test app launch and basic navigation functionality
   - Verify all dependencies are properly linked and functional
   - Check memory usage and performance characteristics

7. **Development Workflow**
   - Set up automatic build-test-fix cycle procedures
   - Configure debugging and logging systems
   - Establish version control practices and commit standards
   - Create development documentation and coding standards

**Apple-Specific Requirements**:
- Follow Human Interface Guidelines for native macOS/iOS design
- Optimize for Apple Silicon (M-series chips) performance
- Use platform-specific features (sidebar, toolbar, context menus)
- Implement proper accessibility support (VoiceOver, keyboard navigation)

**Success Criteria**:
- Clean Xcode build with professional architecture
- Native macOS/iOS UI with proper design patterns
- Responsive layout supporting multiple screen sizes
- Comprehensive error handling and user feedback
- Performance optimized for Apple Silicon
- Ready for iterative development and testing