# Create macOS App - Complete Autonomous Workflow

**Command**: `/project:create-macos-app`

## Purpose
End-to-end autonomous creation of a native macOS app from planning and architecture through polished production-ready implementation.

## Arguments
**Usage**: `/project:create-macos-app [APP_CONCEPT]`

Where `[APP_CONCEPT]` is a brief description of the app to build (e.g., "Financial Calculator", "Task Manager", "Data Visualizer")

## Complete Autonomous Workflow

### **PHASE 1: PLANNING & ARCHITECTURE (Autonomous)**

1. **Requirements Analysis**
   - Analyze the app concept and define comprehensive requirements
   - Identify core features, user workflows, and technical constraints
   - Define target user personas and use cases
   - Establish success criteria and acceptance requirements
   - Create feature prioritization matrix (MVP vs future enhancements)

2. **Technical Architecture Design**
   - Design MVVM architecture with SwiftUI and SwiftData
   - Plan data models, relationships, and persistence strategy
   - Design navigation structure using NavigationSplitView
   - Plan service layer architecture for external integrations
   - Design error handling and validation framework

3. **UI/UX Architecture Planning**
   - Design app flow and navigation hierarchy
   - Plan screen layouts and user interaction patterns
   - Design consistent visual system (colors, typography, spacing)
   - Plan accessibility features and keyboard navigation
   - Create responsive design strategy for different window sizes

### **PHASE 2: PROJECT SETUP & FOUNDATION (Autonomous)**

4. **Xcode Project Creation**
   - Create new Xcode project with proper naming and organization
   - Configure project settings for macOS target with latest SDK
   - Set up Swift Package dependencies (if needed)
   - Configure build settings and schemes for development/release
   - Set up proper folder structure: Models/, ViewModels/, Views/, Services/

5. **Core Architecture Implementation**
   - Create base SwiftData models with proper relationships
   - Implement core ViewModels with @Observable pattern
   - Set up navigation structure and app entry point
   - Create error handling framework and user feedback system
   - Implement basic app lifecycle and state management

### **PHASE 3: FEATURE IMPLEMENTATION (Autonomous)**

6. **Core Feature Development**
   - Implement each planned feature systematically
   - Create corresponding ViewModels for business logic
   - Build SwiftUI views with native macOS design patterns
   - Implement data persistence and CRUD operations
   - Add proper input validation and error handling

7. **Build-Test-Fix Cycles**
   - After each feature implementation, build in Xcode
   - Fix any compilation errors immediately
   - Test feature functionality and user interactions
   - Address any runtime issues or crashes
   - Verify memory usage and performance characteristics

### **PHASE 4: UI REFINEMENT & POLISH (Autonomous)**

8. **Comprehensive UI Review**
   - Go through every UI element systematically:
     - Buttons: Proper styling, hover states, disabled states
     - Text fields: Validation, error states, placeholder text
     - Lists/Tables: Selection, sorting, empty states
     - Navigation: Breadcrumbs, back buttons, deep linking
     - Modals/Sheets: Proper presentation and dismissal
     - Menus: Context menus, menu bar integration

9. **Visual Polish Implementation**
   - Implement consistent spacing and alignment throughout
   - Add smooth animations and transitions
   - Ensure proper SF Symbols usage and sizing
   - Implement proper light/dark mode support
   - Add visual feedback for user interactions (loading states, etc.)

10. **Native macOS Integration**
    - Implement proper window management and sizing
    - Add keyboard shortcuts for common actions
    - Integrate with macOS services (sharing, printing, etc.)
    - Implement proper focus management and tab ordering
    - Add context menus and right-click functionality

### **PHASE 5: FEATURE COMPLETION & TESTING (Autonomous)**

11. **Feature Verification**
    - Test every feature end-to-end with real data
    - Verify all CRUD operations work correctly
    - Test error scenarios and edge cases
    - Ensure all user workflows function properly
    - Verify data persistence across app restarts

12. **Performance Optimization**
    - Profile app performance with Instruments
    - Optimize memory usage and reduce allocations
    - Improve app launch time and responsiveness
    - Optimize database queries and data loading
    - Implement efficient caching where appropriate

### **PHASE 6: QUALITY ASSURANCE & FINAL POLISH (Autonomous)**

13. **Comprehensive Code Review**
    - Remove all TODO comments and placeholder code
    - Ensure no debug code or development artifacts remain
    - Verify proper error handling throughout
    - Check for memory leaks and retain cycles
    - Ensure all code follows Swift best practices

14. **Accessibility Implementation**
    - Add proper accessibility labels and hints
    - Test VoiceOver functionality throughout app
    - Ensure keyboard navigation works for all features
    - Support high contrast and reduced motion settings
    - Test with accessibility inspector

15. **Final Testing & Validation**
    - Test app on different macOS versions (if applicable)
    - Verify app works on different Mac screen sizes
    - Test all features with various data scenarios
    - Ensure app handles edge cases gracefully
    - Verify app meets original requirements and success criteria

### **CONTINUOUS VERIFICATION REQUIREMENTS**

**After Every Code Change:**
- Build in Xcode and fix any errors immediately
- Test the specific feature/change that was implemented
- Verify no regressions were introduced in existing features
- Check memory usage and performance impact

**Quality Gates:**
- Zero compilation errors or warnings
- All features work as designed with no placeholder code
- UI is polished and follows macOS design guidelines
- App performs well with responsive user interactions
- Accessibility requirements are met

**Success Criteria for Completion:**
- App builds successfully in Xcode with zero errors/warnings
- All planned features are fully implemented and functional
- UI is polished and professional with consistent design
- App follows macOS Human Interface Guidelines
- Performance is optimized for Apple Silicon
- No TODO comments, placeholders, or incomplete implementations
- App is ready for potential App Store submission

**Autonomous Decision Making:**
- Make architectural decisions based on macOS best practices
- Choose appropriate UI patterns from Apple's design system
- Implement features that align with user expectations
- Optimize performance using established patterns
- Follow your established preferences for code organization and style

This workflow ensures complete autonomous development from concept to production-ready macOS application.