---
allowed-tools: Bash(xcodebuild:*), Bash(swift build:*), Bash(npm run:*), Bash(yarn:*), Bash(pip install:*)
description: Diagnose and fix build issues systematically
---

# Fix Build Issues - Systematic Approach

## Context
- Current build status: !`xcodebuild -scheme $ARGUMENTS build 2>&1 | tail -20 || swift build 2>&1 | tail -20 || npm run build 2>&1 | tail -20 || echo "No standard build command found"`
- Recent changes: !`git diff --name-only HEAD~3..HEAD`
- Build configuration: !`find . -name "*.xcodeproj" -o -name "package.json" -o -name "Package.swift" -o -name "requirements.txt" | head -5`

## Your Task

**Phase 1: Diagnose Build Issues**
1. **Analyze Error Messages**: Examine build output for specific errors
2. **Categorize Issues**:
   - Compilation errors (syntax, missing imports)
   - Linking errors (missing dependencies, symbols)
   - Configuration issues (build settings, paths)
   - Dependency problems (version conflicts, missing packages)
3. **Identify Root Causes**: Determine if issues are from recent changes or environmental

**Phase 2: Fix Compilation Errors**
1. **Syntax Errors**: Fix missing semicolons, brackets, typos
2. **Import Issues**: Add missing imports, fix import paths
3. **Type Errors**: Resolve type mismatches, add type annotations
4. **API Changes**: Update deprecated API usage

**Phase 3: Resolve Dependencies**
1. **Package Management**: Update package.json, Package.swift, or requirements.txt
2. **Version Conflicts**: Resolve incompatible dependency versions
3. **Missing Dependencies**: Install required packages
4. **Path Issues**: Fix include paths and search directories

**Phase 4: Build Configuration**
1. **Build Settings**: Check and update build configurations
2. **Target Settings**: Verify target dependencies and settings
3. **Environment**: Ensure proper SDK and tool versions
4. **Clean Build**: Perform clean build if necessary

**Phase 5: Verification**
1. **Full Build**: Run complete build process
2. **Tests**: Ensure tests still pass after fixes
3. **Regression Check**: Verify no new issues introduced
4. **Documentation**: Update any build instructions if needed

## Language-Specific Approaches

**Swift/Xcode Projects:**
- Check scheme and target configurations
- Verify Swift version compatibility
- Update deprecated API usage
- Fix import statements and module issues

**Node.js Projects:**
- Update package.json dependencies
- Clear node_modules and reinstall
- Fix TypeScript configuration issues
- Resolve module resolution problems

**Python Projects:**
- Update requirements.txt or setup.py
- Fix import statements and paths
- Resolve virtual environment issues
- Update Python version compatibility

## Success Criteria
- Build completes without errors or warnings
- All tests pass after build fixes
- Dependencies are properly resolved
- Build is reproducible across environments
- Any necessary documentation is updated