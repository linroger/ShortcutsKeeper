---
allowed-tools: Bash(find:*), Grep, Bash(npm test:*), Bash(swift test:*), Bash(pytest:*), Bash(xcodebuild test:*)
description: Add comprehensive tests for uncovered code with scaffolding and verification
---

# Add Tests for Uncovered Code - Complete Workflow

## Context
- Project structure: !`find . -name "*.swift" -o -name "*.py" -o -name "*.js" -o -name "*.ts" | grep -E "(test|spec)" | head -10`
- Current test files: !`find . -path "*/test*" -o -path "*/*test*" -o -name "*test*" -o -name "*spec*" | head -20`
- Available test commands: !`grep -r "test" package.json 2>/dev/null || echo "No package.json found"`

## Your Task

**Phase 1: Identify Untested Code**
1. Analyze the codebase to find functions, classes, or modules without test coverage
2. Look for:
   - Functions without corresponding test files
   - Complex business logic that lacks tests
   - Error handling paths that aren't tested
   - Edge cases and boundary conditions
3. Prioritize based on:
   - Code complexity and criticality
   - Public APIs and interfaces
   - Business logic and algorithms

**Phase 2: Generate Test Scaffolding**
1. Create appropriate test file structure following project conventions
2. Set up test imports and basic framework
3. Create test class/describe blocks with proper naming
4. Add setup and teardown methods if needed
5. Ensure test files follow existing patterns in the codebase

**Phase 3: Add Meaningful Test Cases**
1. **Happy Path Tests**: Normal operation scenarios
2. **Edge Case Tests**: Boundary conditions and limits
3. **Error Handling Tests**: Invalid inputs and error conditions
4. **Integration Tests**: Component interaction scenarios
5. **Performance Tests**: If applicable for critical paths

For each test case:
- Use descriptive test names that explain the scenario
- Follow AAA pattern (Arrange, Act, Assert)
- Include both positive and negative test cases
- Add comments explaining complex test scenarios

**Phase 4: Run and Verify Tests**
1. Execute the new tests to ensure they pass
2. Verify that tests fail when they should (test the tests)
3. Check test coverage if tools are available
4. Fix any failing tests or implementation issues
5. Ensure tests are properly integrated into CI/CD pipeline

## Testing Patterns by Language

**Swift/iOS Projects:**
- Use XCTest framework
- Test ViewModels, Services, and Data Models
- Mock external dependencies
- Test UI components where appropriate

**Python Projects:**
- Use pytest or unittest
- Test functions, classes, and modules
- Mock external APIs and dependencies
- Include doctests for examples

**JavaScript/TypeScript:**
- Use Jest, Mocha, or project's testing framework
- Test functions, classes, and React components
- Mock modules and API calls
- Include snapshot tests for UI components

## Success Criteria
- All identified untested code has corresponding tests
- Tests cover happy path, edge cases, and error conditions
- All new tests pass successfully
- Test coverage has measurably improved
- Tests follow project conventions and best practices
- Tests are maintainable and well-documented