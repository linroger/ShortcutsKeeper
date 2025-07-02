# Build Check Command

**Command**: `/project:build-check`

## Purpose
Comprehensive build verification workflow that ensures code quality and successful compilation before proceeding with development.

## Workflow

Please perform the following build verification sequence:

1. **Initial Build Assessment**
   - Run initial build to identify any immediate compilation errors
   - Check project configuration and dependencies
   - Verify all required packages/frameworks are properly linked

2. **Error Resolution**
   - Fix all compilation errors systematically
   - Address any missing imports or dependency issues
   - Resolve circular dependency problems in module structure
   - Fix syntax errors and type mismatches

3. **Code Quality Scan**
   - Scan entire codebase for TODO comments and placeholders
   - Identify incomplete implementations that need attention
   - Check for debug code that should be removed
   - Review for any hardcoded values that should be constants

4. **Build Optimization**
   - Ensure all warnings are addressed or documented as acceptable
   - Verify proper error handling is implemented throughout
   - Check that performance-critical code is optimized
   - Confirm memory management patterns are correct

5. **Final Verification**
   - Run complete build to ensure zero errors and minimal warnings
   - Test basic app functionality to verify successful compilation
   - Document any remaining issues that need future attention
   - Update build documentation if configuration changes were made

**Success Criteria**: 
- Clean build with zero errors
- All TODOs addressed or documented for future work
- App launches successfully without crashes
- Performance and memory usage are within acceptable ranges

**For Swift/Xcode Projects**: Use `xcodebuild` commands and verify iOS/macOS specific requirements
**For Python Projects**: Use appropriate package managers (pip, uv, conda) and verify imports
**For Other Languages**: Use language-specific build tools and verification methods