# Financial Analysis Command

**Command**: `/project:financial-analysis`

## Purpose
Comprehensive financial analysis workflow with academic rigor, professional calculations, and institutional-grade validation suitable for quantitative finance projects.

## Arguments
**Usage**: `/project:financial-analysis [ANALYSIS_TYPE]`

Where `[ANALYSIS_TYPE]` can be: bond-analysis, risk-assessment, portfolio-optimization, derivatives-pricing, or credit-modeling

## Workflow

Please conduct professional-grade financial analysis following these standards:

1. **Data Setup and Validation**
   - Import and validate all financial datasets with proper error checking
   - Set up QuantLib environment with appropriate market calendars and conventions
   - Verify data integrity, check for missing values and outliers
   - Implement proper date handling and business day adjustments
   - Establish data lineage and source documentation

2. **Mathematical Framework Setup**
   - Import required libraries: QuantLib, numpy, pandas, scipy, plotly
   - Set up symbolic mathematics environment using SymPy for derivations
   - Configure numerical precision settings for financial calculations
   - Establish proper rounding and precision standards for monetary values
   - Create utility functions for common financial calculations

3. **Model Implementation and Validation**
   - Implement relevant financial models with academic rigor:
     - **Bond Analysis**: Nelson-Siegel, Svensson models for term structure
     - **Risk Assessment**: VaR, Expected Shortfall, stress testing
     - **Portfolio**: Mean-variance optimization, risk parity
     - **Derivatives**: Black-Scholes, Monte Carlo simulation
     - **Credit**: Merton structural model, hazard rate modeling
   - Validate all calculations against known benchmarks and literature
   - Cross-verify results using multiple methodologies where possible

4. **Risk Metrics and Analytics**
   - Calculate comprehensive risk metrics: duration, convexity, DV01, Greeks
   - Implement stress testing and scenario analysis
   - Generate risk attribution and decomposition analysis
   - Calculate performance metrics: Sharpe ratio, Information ratio, alpha/beta
   - Implement backtesting frameworks with proper statistical validation

5. **Professional Visualization**
   - Create publication-quality charts using Plotly with professional styling
   - Implement interactive visualizations with hover data and controls
   - Generate yield curve plots with proper interpolation
   - Create risk-return scatter plots and efficient frontier visualizations
   - Implement time series analysis with trend and volatility analysis

6. **Academic Documentation**
   - Document all mathematical derivations using LaTeX in markdown cells
   - Include proper academic citations and reference methodology
   - Provide comprehensive methodology explanations
   - Document all assumptions and limitations clearly
   - Create executive summary with key findings and business implications

7. **Quality Assurance and Validation**
   - Implement comprehensive input validation and error handling
   - Cross-validate results against industry-standard benchmarks
   - Perform sensitivity analysis on key parameters
   - Document confidence intervals and statistical significance
   - Create reproducibility framework with seed management

8. **Professional Reporting**
   - Generate executive summary suitable for institutional presentation
   - Create detailed technical appendix with all calculations
   - Implement comprehensive data export functionality (CSV, Excel, PDF)
   - Document methodology and provide implementation details
   - Include disclaimer and risk warnings appropriate for financial analysis

**Analysis-Specific Requirements**:
- **Bond Analysis**: Yield curve construction, duration/convexity, credit spreads
- **Risk Assessment**: VaR methodologies, stress testing, correlation analysis
- **Portfolio Optimization**: Mean-variance, Black-Litterman, risk budgeting
- **Derivatives Pricing**: Greeks calculation, implied volatility, model validation
- **Credit Modeling**: PD/LGD estimation, migration matrices, correlation modeling

**Academic Standards**:
- University of Chicago FINM-level quantitative rigor
- Proper literature citations and methodology references
- Mathematical derivations with step-by-step explanations
- Statistical validation with confidence intervals
- Professional presentation suitable for peer review

**Success Criteria**:
- All calculations validated against industry benchmarks
- Comprehensive risk analysis with multiple methodologies
- Professional visualization with publication-quality charts
- Academic-level documentation with proper citations
- Executive summary with clear business implications
- Reproducible results with proper seed and version management