# Audit & Fix macOS App - Complete Autonomous Workflow

**Command**: `/project:audit-fix-macos-app`

## Purpose
Comprehensive autonomous audit of existing macOS app codebase, identifying and fixing all issues, bugs, UI problems, and incomplete implementations to achieve production-ready quality.

## Arguments
**Usage**: `/project:audit-fix-macos-app [APP_PATH]`

Where `[APP_PATH]` is the path to the Xcode project or workspace to audit and fix

## Complete Autonomous Workflow

### **PHASE 1: COMPREHENSIVE CODEBASE ANALYSIS (Autonomous)**

1. **Project Structure Assessment**
   - Read through entire Xcode project structure systematically
   - Analyze project settings, build configurations, and dependencies
   - Review package dependencies and version compatibility
   - Assess code organization and architectural patterns
   - Identify any missing files, broken references, or configuration issues

2. **Complete Code Review**
   - Read through every Swift file from start to finish:
     - Models: Check data structures, relationships, validation
     - ViewModels: Verify business logic, state management, error handling
     - Views: Analyze UI implementation, layout, and user interactions
     - Services: Review networking, persistence, and external integrations
     - Extensions/Utilities: Check helper functions and code reuse

3. **Issue Identification & Cataloging**
   - Create comprehensive list of all identified issues:
     - Compilation errors and warnings
     - Runtime bugs and crash scenarios
     - Logic errors and incorrect implementations
     - TODO comments and placeholder code
     - Performance issues and memory leaks
     - UI/UX problems and inconsistencies
     - Missing error handling and edge cases

### **PHASE 2: BUILD & RUNTIME ANALYSIS (Autonomous)**

4. **Build System Analysis**
   - Attempt to build the project and catalog all errors/warnings
   - Fix compilation errors systematically
   - Address all build warnings and deprecated API usage
   - Verify all dependencies are properly linked and configured
   - Ensure build settings are optimized for production

5. **Runtime Testing & Bug Discovery**
   - Run the app and test every feature systematically
   - Identify crashes, hangs, and unexpected behaviors
   - Test all user workflows and interaction patterns
   - Check error scenarios and edge cases
   - Verify data persistence and app state management
   - Test app across different window sizes and configurations

6. **Performance & Memory Analysis**
   - Use Instruments to profile app performance
   - Identify memory leaks and retain cycles
   - Check for performance bottlenecks and optimization opportunities
   - Analyze app launch time and responsiveness
   - Review efficient use of system resources

### **PHASE 3: CODE QUALITY & ARCHITECTURE FIXES (Autonomous)**

7. **Code Quality Remediation**
   - Remove all TODO comments by implementing proper solutions
   - Replace all placeholder code with full implementations
   - Fix all logic errors and incorrect calculations
   - Implement proper error handling throughout the codebase
   - Add comprehensive input validation and sanitization

8. **Architecture & Design Pattern Fixes**
   - Ensure proper MVVM implementation with @Observable ViewModels
   - Fix any architectural violations or anti-patterns
   - Implement proper separation of concerns
   - Refactor code to eliminate duplication and improve maintainability
   - Ensure consistent coding patterns throughout the project

9. **Dependency & Integration Fixes**
   - Update outdated dependencies to latest stable versions
   - Fix any integration issues with external services or APIs
   - Ensure proper SwiftData model implementation and relationships
   - Fix any Core Data to SwiftData migration issues (if applicable)
   - Verify all package imports and module structure

### **PHASE 4: COMPREHENSIVE UI/UX AUDIT & FIXES (Autonomous)**

10. **Systematic UI Element Review**
    - Go through every UI element in every view:
      
      **Buttons & Controls:**
      - Proper styling with consistent appearance
      - Correct hover and pressed states
      - Appropriate disabled states and visual feedback
      - Proper accessibility labels and actions
      - Consistent sizing and spacing

      **Text Fields & Input Elements:**
      - Proper validation and error state display
      - Appropriate placeholder text and formatting
      - Correct keyboard shortcuts and focus management
      - Input sanitization and character limits
      - Clear error messaging and user guidance

      **Lists, Tables & Data Display:**
      - Proper selection states and multi-selection support
      - Sorting, filtering, and search functionality
      - Empty states with helpful messaging
      - Loading states and progress indicators
      - Proper data refresh and update mechanisms

      **Navigation & Layout:**
      - Consistent navigation patterns throughout app
      - Proper back button functionality and breadcrumbs
      - Responsive layout for different window sizes
      - Correct sidebar and toolbar implementation
      - Proper modal and sheet presentation/dismissal

11. **Visual Design & Consistency Fixes**
    - Implement consistent color scheme throughout app
    - Ensure proper typography hierarchy and readability
    - Fix spacing and alignment issues across all views
    - Implement proper light/dark mode support
    - Add smooth animations and transitions where appropriate
    - Ensure consistent icon usage (SF Symbols preferred)

12. **Native macOS Integration Improvements**
    - Implement proper window management and sizing constraints
    - Add appropriate keyboard shortcuts for all major actions
    - Integrate with macOS services (sharing, printing, Spotlight)
    - Implement proper context menus and right-click functionality
    - Add menu bar integration where appropriate
    - Ensure proper focus management and tab ordering

### **PHASE 5: FEATURE COMPLETION & ENHANCEMENT (Autonomous)**

13. **Feature Implementation Completion**
    - Identify and complete any partially implemented features
    - Remove any features that are non-functional or incomplete
    - Implement missing core functionality based on app purpose
    - Add proper data validation and business logic
    - Ensure all features work cohesively together

14. **User Experience Enhancements**
    - Add loading states and progress indicators for long operations
    - Implement proper onboarding and first-run experience
    - Add helpful tooltips and user guidance where needed
    - Implement undo/redo functionality where appropriate
    - Add keyboard shortcuts and power-user features
    - Implement proper search and filtering capabilities

15. **Data Management & Persistence Fixes**
    - Ensure robust data persistence with proper error handling
    - Implement data migration and version management
    - Add data backup and recovery mechanisms
    - Optimize database queries and data loading performance
    - Implement proper data validation and integrity checks

### **PHASE 6: ITERATIVE IMPROVEMENT & OPTIMIZATION (Autonomous)**

16. **Performance Optimization Implementation**
    - Optimize memory usage and reduce unnecessary allocations
    - Improve app launch time and initial load performance
    - Implement efficient caching strategies
    - Optimize image loading and processing
    - Reduce CPU usage for background operations

17. **Accessibility & Inclusivity Improvements**
    - Add comprehensive VoiceOver support throughout app
    - Implement proper keyboard navigation for all features
    - Support high contrast and reduced motion preferences
    - Add appropriate accessibility labels and descriptions
    - Test and verify accessibility with macOS accessibility tools

18. **Security & Privacy Enhancements**
    - Review and secure all data handling practices
    - Implement proper input validation and sanitization
    - Add appropriate privacy controls and user consent
    - Secure any API keys or sensitive configuration
    - Implement proper error handling that doesn't leak information

### **PHASE 7: COMPREHENSIVE TESTING & VALIDATION (Autonomous)**

19. **End-to-End Feature Testing**
    - Test every feature thoroughly with real-world usage scenarios
    - Verify all user workflows from start to finish
    - Test error conditions and recovery scenarios
    - Validate data integrity across app operations
    - Ensure proper app state management and persistence

20. **Cross-Platform & Compatibility Testing**
    - Test app on different macOS versions (if supporting multiple)
    - Verify functionality across different Mac hardware configurations
    - Test with various screen sizes and resolutions
    - Validate performance on both Intel and Apple Silicon Macs
    - Ensure compatibility with different user system configurations

21. **Final Quality Assurance**
    - Build final version and verify zero errors/warnings
    - Run comprehensive test suite covering all functionality
    - Verify app meets original design and requirement specifications
    - Ensure app is ready for distribution or App Store submission
    - Document all changes made and improvements implemented

### **CONTINUOUS BUILD-TEST-FIX CYCLES**

**After Every Fix:**
- Build in Xcode and address any new compilation issues
- Test the specific area that was modified
- Verify no regressions were introduced in other features
- Check performance impact of changes

**Quality Gates:**
- Zero compilation errors or warnings in Xcode
- All features functional with no placeholder or TODO code
- UI is polished and follows macOS Human Interface Guidelines
- App performs well with responsive interactions
- No memory leaks or performance issues detected

**Success Criteria for Completion:**
- App builds successfully with zero errors/warnings
- All identified bugs and issues are completely resolved
- Every UI element is properly styled and functional
- All features work as intended with comprehensive error handling
- Code is clean, well-documented, and production-ready
- App follows macOS design guidelines and best practices
- Performance is optimized for target hardware
- App is ready for production deployment or App Store submission

**Autonomous Decision Making:**
- Prioritize critical bugs and crashes over minor UI improvements
- Choose appropriate design patterns based on existing app architecture
- Make UX improvements that align with macOS conventions
- Implement performance optimizations using established best practices
- Follow your established code organization and style preferences

This workflow ensures comprehensive autonomous audit and improvement of existing macOS applications to production-ready standards.