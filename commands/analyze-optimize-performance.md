# Analyze & Optimize Performance - Complete Autonomous Workflow

**Command**: `/project:analyze-optimize-performance`

## Purpose
Comprehensive autonomous performance analysis and optimization of applications, focusing on speed, memory usage, efficiency, and user experience improvements.

## Arguments
**Usage**: `/project:analyze-optimize-performance [PROJECT_TYPE] [TARGET_PATH]`

Where `[PROJECT_TYPE]` is "swift-app", "python-notebook", or "general", and `[TARGET_PATH]` is the project directory or file to optimize

## Complete Autonomous Workflow

### **PHASE 1: COMPREHENSIVE PERFORMANCE BASELINE (Autonomous)**

1. **Current Performance Assessment**
   - Profile application using appropriate tools:
     - **Swift/macOS**: Instruments (Time Profiler, Allocations, Leaks)
     - **Python**: cProfile, memory_profiler, line_profiler
     - **General**: System monitoring and benchmarking tools
   - Establish baseline metrics for all critical operations
   - Identify performance-critical code paths and bottlenecks
   - Measure memory usage patterns and allocation behavior
   - Document current user experience and responsiveness

2. **Performance Requirements Definition**
   - Define target performance metrics based on application type:
     - **UI Applications**: < 16ms frame time, < 1s launch time
     - **Data Analysis**: Efficient memory usage, reasonable processing time
     - **Financial Calculations**: Sub-millisecond precision operations
   - Establish memory usage limits and efficiency targets
   - Define user experience responsiveness requirements
   - Set performance regression prevention criteria

3. **Performance Issue Identification**
   - Catalog all identified performance problems:
     - Slow algorithms and inefficient data structures
     - Memory leaks and excessive allocations
     - UI blocking operations and responsiveness issues
     - Database query inefficiencies
     - Network and I/O bottlenecks
     - Unnecessary computations and redundant operations

### **PHASE 2: ALGORITHMIC & DATA STRUCTURE OPTIMIZATION (Autonomous)**

4. **Algorithm Analysis & Improvement**
   - Review all algorithms for time complexity optimization:
     - Replace O(n²) operations with O(n log n) or O(n) alternatives
     - Implement efficient sorting and searching algorithms
     - Optimize recursive operations with memoization or iteration
     - Use appropriate data structures for specific use cases
     - Implement efficient caching and memoization strategies

5. **Data Structure Optimization**
   - Analyze and optimize data structure choices:
     - Use arrays vs dictionaries vs sets based on access patterns
     - Implement efficient data indexing and lookup mechanisms
     - Optimize data serialization and deserialization
     - Reduce data copying and implement copy-on-write patterns
     - Use memory-efficient data representations

6. **Mathematical & Computational Optimization**
   - Optimize numerical computations:
     - Use vectorized operations (NumPy, Swift Accelerate)
     - Implement SIMD optimizations for parallel calculations
     - Optimize floating-point operations and precision
     - Use efficient mathematical libraries (BLAS, LAPACK)
     - Implement numerical stability improvements

### **PHASE 3: MEMORY MANAGEMENT OPTIMIZATION (Autonomous)**

7. **Memory Usage Analysis & Reduction**
   - Identify and fix memory leaks and retain cycles
   - Optimize memory allocation patterns:
     - Reduce temporary object creation
     - Implement object pooling for frequently used objects
     - Use weak references to break retain cycles
     - Optimize collection usage and autorelease pools
     - Implement efficient memory pre-allocation strategies

8. **Memory Access Pattern Optimization**
   - Optimize memory access for cache efficiency:
     - Improve data locality and reduce cache misses
     - Align data structures for optimal memory access
     - Reduce memory fragmentation
     - Implement memory-mapped file access for large datasets
     - Use streaming processing for large data operations

9. **Garbage Collection & Resource Management**
   - Optimize automatic memory management:
     - Reduce GC pressure through efficient object lifecycle management
     - Implement proper resource disposal and cleanup
     - Optimize collection resizing and capacity management
     - Use appropriate collection types for specific scenarios
     - Implement efficient string handling and manipulation

### **PHASE 4: APPLICATION-SPECIFIC OPTIMIZATIONS (Autonomous)**

10. **Swift/macOS Application Optimizations**
    - Optimize SwiftUI performance:
      - Implement efficient view updates and state management
      - Use LazyVStack/LazyHStack for large collections
      - Optimize image loading and caching
      - Implement efficient animation and transition performance
      - Use proper SwiftData optimizations and batch operations
    
    - Apple Silicon specific optimizations:
      - Utilize unified memory architecture efficiently
      - Implement Metal compute shaders for parallel operations
      - Use Core ML for machine learning optimizations
      - Optimize for Neural Engine utilization
      - Implement efficient multithreading with Swift concurrency

11. **Python/Data Analysis Optimizations**
    - Optimize pandas and NumPy operations:
      - Use vectorized operations instead of loops
      - Implement efficient data filtering and selection
      - Optimize groupby and aggregation operations
      - Use appropriate data types to reduce memory usage
      - Implement chunked processing for large datasets
    
    - Visualization and I/O optimizations:
      - Optimize Plotly rendering and interactivity
      - Implement efficient data loading and parsing
      - Use appropriate file formats (Parquet vs CSV)
      - Optimize database query performance
      - Implement lazy loading and streaming for large datasets

12. **Concurrency & Parallelization Optimization**
    - Implement appropriate concurrency patterns:
      - Use async/await for I/O-bound operations
      - Implement CPU-bound parallel processing
      - Optimize thread pool usage and task scheduling
      - Use appropriate synchronization mechanisms
      - Implement lock-free data structures where possible

### **PHASE 5: USER EXPERIENCE OPTIMIZATION (Autonomous)**

13. **Responsiveness & Interaction Optimization**
    - Optimize user interface responsiveness:
      - Move blocking operations off main thread
      - Implement progressive loading and lazy evaluation
      - Add loading states and progress indicators
      - Optimize animation performance and smoothness
      - Implement efficient scroll performance and virtualization

14. **Startup & Load Time Optimization**
    - Optimize application startup performance:
      - Implement lazy initialization patterns
      - Optimize dependency loading and initialization
      - Use background preloading for non-critical resources
      - Implement efficient configuration and settings loading
      - Optimize initial view rendering and layout

15. **Runtime Performance Optimization**
    - Optimize ongoing operation performance:
      - Implement efficient background task management
      - Optimize periodic operations and timers
      - Use intelligent caching and invalidation strategies
      - Implement efficient search and filtering operations
      - Optimize real-time data updates and synchronization

### **PHASE 6: SYSTEMATIC TESTING & VALIDATION (Autonomous)**

16. **Performance Regression Testing**
    - Implement comprehensive performance test suite:
      - Create automated performance benchmarks
      - Set up performance regression detection
      - Implement memory leak detection tests
      - Create load testing and stress testing scenarios
      - Establish continuous performance monitoring

17. **Real-World Performance Validation**
    - Test optimizations under realistic conditions:
      - Test with representative datasets and usage patterns
      - Validate performance across different hardware configurations
      - Test performance with various system loads
      - Verify optimization effectiveness across different scenarios
      - Ensure optimizations don't negatively impact functionality

18. **Performance Monitoring Implementation**
    - Set up ongoing performance monitoring:
      - Implement performance metrics collection
      - Create performance dashboards and alerts
      - Set up automated performance analysis
      - Implement user experience monitoring
      - Create performance debugging and diagnostic tools

### **PHASE 7: OPTIMIZATION VALIDATION & DOCUMENTATION (Autonomous)**

19. **Optimization Impact Assessment**
    - Measure and document improvement results:
      - Compare before/after performance metrics
      - Document specific optimizations and their impact
      - Validate that all optimization goals are met
      - Assess user experience improvements
      - Document any trade-offs or limitations introduced

20. **Documentation & Knowledge Transfer**
    - Create comprehensive optimization documentation:
      - Document all implemented optimizations and rationale
      - Create performance best practices guide
      - Document performance monitoring and maintenance procedures
      - Create troubleshooting guide for performance issues
      - Document performance regression prevention strategies

21. **Future Performance Strategy**
    - Establish ongoing performance management:
      - Create performance review and optimization schedule
      - Implement performance-conscious development practices
      - Set up performance goal tracking and reporting
      - Plan future optimization opportunities and roadmap
      - Establish performance culture and processes

### **CONTINUOUS VALIDATION REQUIREMENTS**

**After Each Optimization:**
- Profile the specific optimization to measure impact
- Verify no functionality regressions are introduced
- Test performance across different scenarios and data sizes
- Validate user experience improvements

**Optimization Priorities:**
1. Fix critical performance issues affecting user experience
2. Optimize high-frequency operations and hot code paths
3. Reduce memory usage and improve resource efficiency
4. Improve startup time and initial loading performance
5. Optimize background operations and periodic tasks

**Success Criteria for Completion:**
- All identified performance issues addressed and resolved
- Target performance metrics achieved or exceeded
- Memory usage optimized and leaks eliminated
- User experience responsiveness significantly improved
- Comprehensive performance monitoring and testing in place
- Performance optimizations documented and maintainable
- No functionality regressions introduced by optimizations

**Autonomous Decision Making:**
- Prioritize optimizations based on user impact and frequency of use
- Choose appropriate optimization techniques based on performance profiling data
- Balance optimization complexity with maintenance burden
- Make trade-off decisions between different performance characteristics
- Implement optimizations that align with platform best practices

This workflow ensures comprehensive autonomous performance optimization across different application types and platforms.