---
description: Deploy multiple specialized agents for complex tasks with parallel execution
---

# Multi-Agent Deployment Command

## Usage
`/project:agent-deploy [TASK_DESCRIPTION]`

## Purpose
Deploy multiple specialized agents to work on complex tasks in parallel, then integrate their outputs for comprehensive solutions.

## Agent Deployment Strategy

**Step 1: Task Analysis**
Analyze the task: $ARGUMENTS

Break down into parallel components suitable for:
- Research Agent
- Architecture Agent  
- Implementation Agent
- Testing Agent
- Integration Agent

**Step 2: Deploy Specialized Agents**

**Research Agent Task:**
```
AGENT ROLE: Research and Analysis Specialist
TASK: Research best practices, existing solutions, and technical approaches for: $ARGUMENTS
CONTEXT: This is part of a multi-agent effort to solve a complex technical challenge
REQUIREMENTS: Provide comprehensive research with citations, code examples, and recommendations
OUTPUT FORMAT: Structured research report with technical recommendations
SUCCESS CRITERIA: Research covers all viable approaches with pros/cons analysis
COORDINATION: Will inform architecture and implementation agents
```

**Architecture Agent Task:**  
```
AGENT ROLE: System Architecture Designer
TASK: Design the technical architecture and implementation approach for: $ARGUMENTS
CONTEXT: Working with research findings to create optimal system design
REQUIREMENTS: Must be production-ready, scalable, and follow established patterns
OUTPUT FORMAT: Detailed architecture documentation with diagrams and specifications  
SUCCESS CRITERIA: Architecture is implementable, testable, and maintainable
COORDINATION: Will guide implementation and testing agents
```

**Implementation Agent Task:**
```
AGENT ROLE: Code Implementation Specialist  
TASK: Implement the solution for: $ARGUMENTS
CONTEXT: Following architectural specifications and research recommendations
REQUIREMENTS: Production-quality code with proper error handling and documentation
OUTPUT FORMAT: Complete, working code implementation with comments
SUCCESS CRITERIA: Code compiles, follows best practices, and meets requirements
COORDINATION: Will work with testing agent for verification
```

**Testing Agent Task:**
```
AGENT ROLE: Quality Assurance and Testing Specialist
TASK: Create comprehensive test strategy and implementation for: $ARGUMENTS
CONTEXT: Ensuring the implemented solution is robust and reliable
REQUIREMENTS: Cover unit tests, integration tests, and edge cases
OUTPUT FORMAT: Complete test suite with coverage analysis
SUCCESS CRITERIA: All tests pass and provide adequate coverage
COORDINATION: Will validate implementation agent's work
```

**Integration Agent Task:**
```
AGENT ROLE: Solution Integration Coordinator
TASK: Integrate all agent outputs into final solution for: $ARGUMENTS  
CONTEXT: Combining research, architecture, implementation, and testing
REQUIREMENTS: Ensure all components work together seamlessly
OUTPUT FORMAT: Integrated final solution with documentation
SUCCESS CRITERIA: Complete, tested, documented solution ready for deployment
COORDINATION: Final coordinator of all agent outputs
```

**Step 3: Agent Coordination**
1. Deploy all agents simultaneously using Task tool
2. Collect and analyze all agent outputs
3. Identify conflicts or gaps between agent recommendations
4. Synthesize best elements from each agent's work
5. Create unified final solution

**Step 4: Quality Integration**
1. Validate that all agent outputs are compatible
2. Ensure no contradictions between approaches
3. Verify completeness of the integrated solution
4. Test the final integrated solution
5. Document the complete implementation

## Agent Specialization Guidelines

**Research Agent Focus:**
- Industry best practices
- Existing solutions and libraries
- Performance benchmarks
- Security considerations
- Scalability patterns

**Architecture Agent Focus:**
- System design patterns
- Data flow architecture
- Interface design
- Dependency management
- Deployment considerations

**Implementation Agent Focus:**
- Clean, readable code
- Error handling
- Performance optimization
- Security implementation
- Code documentation

**Testing Agent Focus:**
- Test strategy design
- Unit and integration tests
- Edge case coverage
- Performance testing
- Security testing

**Integration Agent Focus:**
- Component compatibility
- End-to-end validation
- Documentation completeness
- Deployment readiness
- Maintenance procedures

## Success Criteria
- All agents complete their specialized tasks
- Outputs are successfully integrated
- Final solution is production-ready
- No conflicts between agent recommendations
- Complete documentation and testing
- Ready for immediate implementation

This command orchestrates multiple specialized agents to tackle complex technical challenges through parallel execution and systematic integration.