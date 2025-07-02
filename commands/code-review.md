# Comprehensive Code Review Command

**Command**: `/project:code-review`

## Purpose
Systematic code quality assessment covering architecture, performance, security, and maintainability standards for production-ready code.

## Workflow

Please conduct a comprehensive code review following these systematic checks:

1. **Architecture and Design Review**
   - Evaluate overall code architecture and design patterns
   - Check for proper separation of concerns and modularity
   - Verify adherence to established architectural principles (MVVM, etc.)
   - Assess code organization and file structure
   - Review API design and interface consistency

2. **Code Quality Assessment**
   - Scan for TODO comments, placeholders, and incomplete implementations
   - Check for proper error handling throughout the codebase
   - Verify consistent coding style and naming conventions
   - Review comment quality and documentation coverage
   - Assess code readability and maintainability

3. **Performance Analysis**
   - Identify potential performance bottlenecks
   - Review memory management and resource usage patterns
   - Check for inefficient algorithms or data structures
   - Assess async/await usage and concurrency patterns
   - Verify proper caching and optimization strategies

4. **Security and Best Practices**
   - Scan for potential security vulnerabilities
   - Check for proper input validation and sanitization
   - Review error messages for information leakage
   - Verify secure handling of sensitive data
   - Assess dependency security and update status

5. **Testing and Reliability**
   - Review test coverage and test quality
   - Check for proper edge case handling
   - Verify error scenarios are properly tested
   - Assess debugging and logging implementation
   - Review configuration management and environment handling

6. **Platform-Specific Considerations**
   - **For Swift/iOS**: Check HIG compliance, Apple Silicon optimization, accessibility
   - **For Python**: Verify PEP compliance, type hints, virtual environment usage
   - **For Financial Code**: Validate calculation accuracy, risk management, compliance

7. **Documentation and Maintainability**
   - Review inline documentation quality and coverage
   - Check for architectural decision documentation
   - Verify API documentation completeness
   - Assess onboarding and setup documentation
   - Review change management and version control practices

8. **Optimization Recommendations**
   - Remove any debug code and development artifacts
   - Optimize imports and dependencies
   - Identify opportunities for code reuse and refactoring
   - Suggest performance improvements and optimizations
   - Recommend architectural improvements for scalability

**Review Categories and Priorities**:
- **Critical**: Security issues, data corruption risks, crashes
- **High**: Performance problems, architectural violations, missing error handling
- **Medium**: Code style issues, missing documentation, optimization opportunities
- **Low**: Minor improvements, style inconsistencies, enhancement suggestions

**Deliverable Format**:
- **Executive Summary**: Overall code quality assessment and main recommendations
- **Critical Issues**: Must-fix items before production deployment
- **Improvement Recommendations**: Prioritized list of enhancements
- **Best Practices**: Suggestions for maintaining code quality
- **Implementation Plan**: Roadmap for addressing identified issues

**Success Criteria**:
- All critical and high-priority issues identified and documented
- Clear prioritization of improvements with impact assessment
- Actionable recommendations with specific implementation guidance
- Code quality metrics and baseline establishment
- Production readiness assessment with go/no-go recommendation