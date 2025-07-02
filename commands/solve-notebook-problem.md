# Solve Notebook Problem - Complete Autonomous Workflow

**Command**: `/project:solve-notebook-problem`

## Purpose
End-to-end autonomous solution of complex, multi-step problems in Python notebooks with comprehensive analysis, visualization, and validation.

## Arguments
**Usage**: `/project:solve-notebook-problem [PROBLEM_DESCRIPTION]`

Where `[PROBLEM_DESCRIPTION]` is the problem statement or notebook file path to analyze and solve

## Complete Autonomous Workflow

### **PHASE 1: PROBLEM ANALYSIS & SETUP (Autonomous)**

1. **Problem Decomposition**
   - Read and analyze the complete problem statement thoroughly
   - Break down complex problems into logical sub-problems
   - Identify data requirements, analysis methods, and expected outputs
   - Determine mathematical/statistical approaches needed
   - Plan the solution sequence and dependencies between steps

2. **Environment Setup**
   - Import all required libraries: pandas, numpy, plotly, scipy, QuantLib (if financial)
   - Set up professional notebook styling and output formatting
   - Configure Plotly themes for publication-quality visualizations
   - Initialize any domain-specific libraries and configurations
   - Set up proper error handling and logging framework

3. **Data Acquisition & Initial Assessment**
   - Load all provided datasets with proper error handling
   - Perform initial data shape, type, and structure analysis
   - Identify data quality issues, missing values, and outliers
   - Document data sources, definitions, and limitations
   - Create data dictionary and variable explanations

### **PHASE 2: DATA CLEANING & PREPARATION (Autonomous)**

4. **Comprehensive Data Cleaning**
   - Handle missing values using appropriate methods (imputation, deletion, etc.)
   - Identify and address outliers using statistical methods
   - Fix data type issues and format inconsistencies
   - Standardize column names and categorical variables
   - Validate data integrity and logical consistency

5. **Exploratory Data Analysis**
   - Generate comprehensive descriptive statistics
   - Create distribution plots for all numerical variables
   - Analyze correlations and relationships between variables
   - Identify patterns, trends, and anomalies in the data
   - Document key insights and implications for analysis

6. **Data Transformation & Feature Engineering**
   - Create derived variables and calculated fields as needed
   - Apply necessary transformations (log, normalization, etc.)
   - Handle categorical variables with proper encoding
   - Create time-based features if working with time series
   - Prepare data in optimal format for analysis requirements

### **PHASE 3: PROBLEM SOLVING & ANALYSIS (Autonomous)**

7. **Solution Implementation - Part by Part**
   - Solve each sub-problem systematically in logical order
   - For each step:
     - Restate the specific question being addressed
     - Implement the appropriate analytical method or calculation
     - Execute the code and capture intermediate results
     - Analyze outputs to inform next steps
     - Validate results using multiple approaches where possible

8. **Mathematical & Statistical Analysis**
   - Implement required calculations with proper formulas
   - Use appropriate statistical tests and significance levels
   - Apply domain-specific methods (financial models, ML algorithms, etc.)
   - Cross-validate results using alternative methodologies
   - Document assumptions and limitations of each approach

9. **Iterative Problem Solving**
   - Use results from each step to inform subsequent analysis
   - Adjust approaches based on intermediate findings
   - Implement feedback loops to refine solutions
   - Validate each step before proceeding to the next
   - Document decision points and rationale for chosen methods

### **PHASE 4: VISUALIZATION & INTERPRETATION (Autonomous)**

10. **Professional Data Visualization**
    - Create publication-quality plots using Plotly exclusively
    - Design interactive visualizations with hover data and controls
    - Implement consistent styling with professional color schemes
    - Create charts that effectively communicate findings:
      - Distribution plots for data exploration
      - Time series plots for temporal analysis
      - Correlation heatmaps for relationship analysis
      - Scatter plots for regression and clustering
      - Custom plots specific to domain requirements

11. **Results Interpretation & Analysis**
    - Provide clear, written analysis of all findings
    - Explain practical significance of statistical results
    - Connect findings back to original problem statement
    - Identify limitations and potential sources of error
    - Suggest areas for further investigation or improvement

### **PHASE 5: VALIDATION & QUALITY ASSURANCE (Autonomous)**

12. **Comprehensive Solution Validation**
    - Run the entire notebook from start to finish to verify execution
    - Check all intermediate outputs for reasonableness
    - Validate calculations using alternative methods or spot checks
    - Ensure all visualizations render correctly and are informative
    - Verify all code executes without errors or warnings

13. **Results Verification**
    - Cross-check calculations against known benchmarks (if available)
    - Verify statistical significance and practical relevance
    - Check units, scales, and order of magnitude for all results
    - Ensure conclusions are supported by the analysis
    - Validate that all original questions have been answered

14. **Error Checking & Debugging**
    - Review all code for logical errors and edge cases
    - Check data handling for potential issues (division by zero, etc.)
    - Verify proper handling of missing data and outliers
    - Ensure robust error handling throughout the notebook
    - Test with different data subsets to verify stability

### **PHASE 6: DOCUMENTATION & FINAL POLISH (Autonomous)**

15. **Comprehensive Documentation**
    - Add clear markdown explanations for each section
    - Document methodology and rationale for analytical choices
    - Provide executive summary of key findings
    - Include limitations, assumptions, and caveats
    - Add conclusions and business/academic implications

16. **Professional Presentation**
    - Format notebook with clear section headers and navigation
    - Ensure consistent code style and commenting
    - Remove any debug code or unnecessary outputs
    - Add table of contents and summary sections
    - Create polished, presentation-ready final product

### **CONTINUOUS VALIDATION REQUIREMENTS**

**After Each Code Cell:**
- Execute cell and verify output is reasonable
- Check for any errors, warnings, or unexpected results
- Validate intermediate results make sense in context
- Ensure data transformations are applied correctly

**Before Proceeding to Next Step:**
- Verify current step is completely solved
- Check that results inform the next analytical step
- Ensure no logical errors in reasoning or implementation
- Confirm data quality is maintained throughout

**Quality Gates:**
- All code executes successfully from start to finish
- All intermediate outputs are validated and reasonable
- Visualizations are professional and informative
- Written analysis clearly explains findings and methodology
- Conclusions are well-supported by the analysis

**Success Criteria for Completion:**
- Complete problem solution with all sub-questions answered
- Professional-quality code with proper documentation
- Publication-ready visualizations with clear insights
- Comprehensive written analysis and interpretation
- Notebook runs successfully from start to finish
- All calculations validated and cross-checked
- Executive summary with key findings and implications
- Ready for submission or presentation to stakeholders

**Autonomous Decision Making:**
- Choose appropriate analytical methods based on data characteristics
- Select optimal visualization types for different data patterns
- Determine statistical significance thresholds and test selection
- Make data cleaning decisions based on domain knowledge
- Prioritize analysis depth based on problem complexity and requirements

This workflow ensures comprehensive, autonomous problem-solving with academic/professional rigor and complete validation of results.