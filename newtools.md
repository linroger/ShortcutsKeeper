# NEW TOOLS FOR CLAUDE CODE

This document defines additional tools that would enhance Claude Code's capabilities for advanced technical workflows, particularly for quantitative finance, macOS development, and AI/ML research.

---

## FILE SYSTEM & PROJECT MANAGEMENT TOOLS

### 1. **Watch**
Monitor file system changes in real-time for development workflows.

```json
{
  "name": "Watch",
  "description": "Monitor files/directories for changes and execute actions when modifications occur. Useful for auto-building projects, running tests, or triggering workflows when files change.",
  "parameters": {
    "$schema": "http://json-schema.org/draft-07/schema#",
    "type": "object",
    "properties": {
      "path": {
        "type": "string",
        "description": "Path to file or directory to monitor"
      },
      "patterns": {
        "type": "array",
        "items": {"type": "string"},
        "description": "File patterns to watch (e.g., ['*.swift', '*.py'])"
      },
      "command": {
        "type": "string",
        "description": "Command to execute when changes detected"
      },
      "debounce_ms": {
        "type": "number",
        "default": 500,
        "description": "Milliseconds to wait before triggering after last change"
      }
    },
    "required": ["path"]
  }
}
```

### 2. **Tree**
Generate visual directory structures for documentation and analysis.

```json
{
  "name": "Tree",
  "description": "Generate a tree-like visualization of directory structure with filtering options. Useful for understanding project layout and creating documentation.",
  "parameters": {
    "$schema": "http://json-schema.org/draft-07/schema#",
    "type": "object",
    "properties": {
      "path": {
        "type": "string",
        "description": "Root directory path"
      },
      "max_depth": {
        "type": "number",
        "default": 3,
        "description": "Maximum depth to traverse"
      },
      "include_patterns": {
        "type": "array",
        "items": {"type": "string"},
        "description": "Patterns to include (e.g., ['*.swift', '*.py'])"
      },
      "exclude_patterns": {
        "type": "array",
        "items": {"type": "string"},
        "description": "Patterns to exclude (e.g., ['node_modules', '.git'])"
      },
      "show_hidden": {
        "type": "boolean",
        "default": false,
        "description": "Include hidden files and directories"
      }
    },
    "required": ["path"]
  }
}
```

### 3. **Find**
Advanced file finding with complex search criteria.

```json
{
  "name": "Find",
  "description": "Advanced file search with multiple criteria including size, date, content, and metadata. More powerful than basic glob patterns.",
  "parameters": {
    "$schema": "http://json-schema.org/draft-07/schema#",
    "type": "object",
    "properties": {
      "path": {
        "type": "string",
        "description": "Search root directory"
      },
      "name_pattern": {
        "type": "string",
        "description": "File name pattern (supports regex)"
      },
      "content_pattern": {
        "type": "string",
        "description": "Content search pattern"
      },
      "file_type": {
        "type": "string",
        "enum": ["file", "directory", "symlink"],
        "description": "Type of filesystem object to find"
      },
      "size_min": {
        "type": "string",
        "description": "Minimum file size (e.g., '1MB', '500KB')"
      },
      "size_max": {
        "type": "string",
        "description": "Maximum file size"
      },
      "modified_after": {
        "type": "string",
        "description": "Modified after date (ISO format)"
      },
      "modified_before": {
        "type": "string",
        "description": "Modified before date (ISO format)"
      },
      "max_results": {
        "type": "number",
        "default": 100,
        "description": "Maximum number of results to return"
      }
    },
    "required": ["path"]
  }
}
```

---

## CODE ANALYSIS & DEVELOPMENT TOOLS

### 4. **AST**
Parse and analyze code structure using Abstract Syntax Trees.

```json
{
  "name": "AST",
  "description": "Parse source code into Abstract Syntax Tree for deep structural analysis. Supports multiple languages and can extract functions, classes, imports, and dependencies.",
  "parameters": {
    "$schema": "http://json-schema.org/draft-07/schema#",
    "type": "object",
    "properties": {
      "file_path": {
        "type": "string",
        "description": "Path to source code file"
      },
      "language": {
        "type": "string",
        "enum": ["python", "javascript", "swift", "rust", "go", "java"],
        "description": "Programming language for parsing"
      },
      "extract": {
        "type": "array",
        "items": {
          "type": "string",
          "enum": ["functions", "classes", "imports", "variables", "dependencies", "complexity"]
        },
        "description": "Elements to extract from AST"
      },
      "include_docstrings": {
        "type": "boolean",
        "default": true,
        "description": "Include documentation strings in output"
      }
    },
    "required": ["file_path", "language"]
  }
}
```

### 5. **Lint**
Run code quality analysis and style checking.

```json
{
  "name": "Lint",
  "description": "Run language-specific linting tools to check code quality, style, and potential issues. Supports multiple linters per language.",
  "parameters": {
    "$schema": "http://json-schema.org/draft-07/schema#",
    "type": "object",
    "properties": {
      "path": {
        "type": "string",
        "description": "File or directory path to lint"
      },
      "language": {
        "type": "string",
        "enum": ["python", "javascript", "swift", "rust", "go"],
        "description": "Programming language"
      },
      "linters": {
        "type": "array",
        "items": {"type": "string"},
        "description": "Specific linters to run (e.g., ['flake8', 'mypy'] for Python)"
      },
      "fix": {
        "type": "boolean",
        "default": false,
        "description": "Automatically fix issues where possible"
      },
      "config_file": {
        "type": "string",
        "description": "Path to linter configuration file"
      }
    },
    "required": ["path", "language"]
  }
}
```

### 6. **Format**
Format source code according to language conventions.

```json
{
  "name": "Format",
  "description": "Format source code using language-specific formatters (black, prettier, swiftformat, etc.). Can format individual files or entire directories.",
  "parameters": {
    "$schema": "http://json-schema.org/draft-07/schema#",
    "type": "object",
    "properties": {
      "path": {
        "type": "string",
        "description": "File or directory path to format"
      },
      "language": {
        "type": "string",
        "enum": ["python", "javascript", "swift", "rust", "go", "json", "yaml"],
        "description": "Programming language"
      },
      "formatter": {
        "type": "string",
        "description": "Specific formatter to use (auto-detected if not specified)"
      },
      "config_file": {
        "type": "string",
        "description": "Path to formatter configuration file"
      },
      "in_place": {
        "type": "boolean",
        "default": true,
        "description": "Modify files in place or return formatted content"
      }
    },
    "required": ["path", "language"]
  }
}
```

---

## BUILD & TESTING TOOLS

### 7. **Build**
Build projects using language-specific build systems.

```json
{
  "name": "Build",
  "description": "Build projects using appropriate build systems (xcodebuild, cargo, npm, pip, etc.). Provides unified interface for different build tools.",
  "parameters": {
    "$schema": "http://json-schema.org/draft-07/schema#",
    "type": "object",
    "properties": {
      "path": {
        "type": "string",
        "description": "Project root directory"
      },
      "target": {
        "type": "string",
        "description": "Build target or scheme name"
      },
      "configuration": {
        "type": "string",
        "enum": ["debug", "release"],
        "default": "debug",
        "description": "Build configuration"
      },
      "platform": {
        "type": "string",
        "description": "Target platform (e.g., 'macOS', 'iOS', 'linux')"
      },
      "clean": {
        "type": "boolean",
        "default": false,
        "description": "Clean before building"
      },
      "verbose": {
        "type": "boolean",
        "default": false,
        "description": "Enable verbose output"
      }
    },
    "required": ["path"]
  }
}
```

### 8. **Test**
Run automated tests using language-specific test frameworks.

```json
{
  "name": "Test",
  "description": "Run automated tests using appropriate test frameworks (XCTest, pytest, jest, etc.). Supports filtering, coverage, and parallel execution.",
  "parameters": {
    "$schema": "http://json-schema.org/draft-07/schema#",
    "type": "object",
    "properties": {
      "path": {
        "type": "string",
        "description": "Project or test directory path"
      },
      "test_pattern": {
        "type": "string",
        "description": "Pattern to match test files or test names"
      },
      "coverage": {
        "type": "boolean",
        "default": false,
        "description": "Generate code coverage report"
      },
      "parallel": {
        "type": "boolean",
        "default": true,
        "description": "Run tests in parallel"
      },
      "verbose": {
        "type": "boolean",
        "default": false,
        "description": "Verbose test output"
      },
      "stop_on_failure": {
        "type": "boolean",
        "default": false,
        "description": "Stop execution on first test failure"
      }
    },
    "required": ["path"]
  }
}
```

---

## DATA & ANALYSIS TOOLS

### 9. **DataProfile**
Generate comprehensive profiles of datasets for analysis.

```json
{
  "name": "DataProfile",
  "description": "Generate detailed statistical profiles of datasets including distributions, missing values, correlations, and data quality metrics. Supports CSV, JSON, Parquet, and database connections.",
  "parameters": {
    "$schema": "http://json-schema.org/draft-07/schema#",
    "type": "object",
    "properties": {
      "source": {
        "type": "string",
        "description": "Path to data file or database connection string"
      },
      "source_type": {
        "type": "string",
        "enum": ["csv", "json", "parquet", "excel", "database"],
        "description": "Type of data source"
      },
      "sample_size": {
        "type": "number",
        "description": "Number of rows to sample for large datasets"
      },
      "include_correlations": {
        "type": "boolean",
        "default": true,
        "description": "Calculate correlation matrix"
      },
      "include_distributions": {
        "type": "boolean",
        "default": true,
        "description": "Generate distribution plots"
      },
      "output_format": {
        "type": "string",
        "enum": ["json", "html", "markdown"],
        "default": "json",
        "description": "Output format for the profile report"
      }
    },
    "required": ["source", "source_type"]
  }
}
```

### 10. **Plot**
Generate statistical plots and visualizations.

```json
{
  "name": "Plot",
  "description": "Generate statistical plots and visualizations from data. Supports multiple chart types and export formats. Optimized for financial and scientific data.",
  "parameters": {
    "$schema": "http://json-schema.org/draft-07/schema#",
    "type": "object",
    "properties": {
      "data_source": {
        "type": "string",
        "description": "Path to data file or inline data"
      },
      "plot_type": {
        "type": "string",
        "enum": ["line", "scatter", "histogram", "box", "heatmap", "candlestick", "surface"],
        "description": "Type of plot to generate"
      },
      "x_column": {
        "type": "string",
        "description": "Column name for X-axis"
      },
      "y_column": {
        "type": "string",
        "description": "Column name for Y-axis"
      },
      "color_column": {
        "type": "string",
        "description": "Column name for color grouping"
      },
      "title": {
        "type": "string",
        "description": "Plot title"
      },
      "output_path": {
        "type": "string",
        "description": "Path to save the plot image"
      },
      "output_format": {
        "type": "string",
        "enum": ["png", "svg", "pdf", "html"],
        "default": "png",
        "description": "Output format"
      },
      "interactive": {
        "type": "boolean",
        "default": true,
        "description": "Generate interactive plot (when supported)"
      }
    },
    "required": ["data_source", "plot_type"]
  }
}
```

---

## NETWORK & API TOOLS

### 11. **API**
Make HTTP API requests with advanced features.

```json
{
  "name": "API",
  "description": "Make HTTP requests with support for authentication, retries, rate limiting, and response parsing. Ideal for testing APIs and data fetching.",
  "parameters": {
    "$schema": "http://json-schema.org/draft-07/schema#",
    "type": "object",
    "properties": {
      "url": {
        "type": "string",
        "description": "Request URL"
      },
      "method": {
        "type": "string",
        "enum": ["GET", "POST", "PUT", "DELETE", "PATCH"],
        "default": "GET",
        "description": "HTTP method"
      },
      "headers": {
        "type": "object",
        "description": "Request headers as key-value pairs"
      },
      "body": {
        "type": "string",
        "description": "Request body (JSON string or form data)"
      },
      "auth_type": {
        "type": "string",
        "enum": ["bearer", "basic", "api_key"],
        "description": "Authentication type"
      },
      "auth_value": {
        "type": "string",
        "description": "Authentication value (token, key, etc.)"
      },
      "timeout": {
        "type": "number",
        "default": 30,
        "description": "Request timeout in seconds"
      },
      "retries": {
        "type": "number",
        "default": 3,
        "description": "Number of retry attempts"
      },
      "parse_json": {
        "type": "boolean",
        "default": true,
        "description": "Automatically parse JSON responses"
      }
    },
    "required": ["url"]
  }
}
```

### 12. **Download**
Download files with progress tracking and resume capability.

```json
{
  "name": "Download",
  "description": "Download files from URLs with progress tracking, resume capability, and integrity verification. Supports large files and parallel downloads.",
  "parameters": {
    "$schema": "http://json-schema.org/draft-07/schema#",
    "type": "object",
    "properties": {
      "url": {
        "type": "string",
        "description": "URL to download from"
      },
      "output_path": {
        "type": "string",
        "description": "Local path to save the file"
      },
      "resume": {
        "type": "boolean",
        "default": true,
        "description": "Resume interrupted downloads"
      },
      "verify_checksum": {
        "type": "string",
        "description": "Expected checksum for verification (SHA256)"
      },
      "max_retries": {
        "type": "number",
        "default": 3,
        "description": "Maximum retry attempts"
      },
      "chunk_size": {
        "type": "number",
        "default": 8192,
        "description": "Download chunk size in bytes"
      },
      "show_progress": {
        "type": "boolean",
        "default": true,
        "description": "Show download progress"
      }
    },
    "required": ["url", "output_path"]
  }
}
```

---

## PRODUCTIVITY & AUTOMATION TOOLS

### 13. **Template**
Generate files from templates with variable substitution.

```json
{
  "name": "Template",
  "description": "Generate files from templates with variable substitution. Supports Jinja2 templating and multiple output formats. Useful for scaffolding projects.",
  "parameters": {
    "$schema": "http://json-schema.org/draft-07/schema#",
    "type": "object",
    "properties": {
      "template_path": {
        "type": "string",
        "description": "Path to template file"
      },
      "output_path": {
        "type": "string",
        "description": "Path for generated output file"
      },
      "variables": {
        "type": "object",
        "description": "Variables for template substitution"
      },
      "template_engine": {
        "type": "string",
        "enum": ["jinja2", "mustache", "simple"],
        "default": "jinja2",
        "description": "Template engine to use"
      }
    },
    "required": ["template_path", "output_path", "variables"]
  }
}
```

### 14. **Archive**
Create and extract archives in various formats.

```json
{
  "name": "Archive",
  "description": "Create and extract archives (zip, tar, tar.gz, etc.). Supports compression, filtering, and progress tracking for large archives.",
  "parameters": {
    "$schema": "http://json-schema.org/draft-07/schema#",
    "type": "object",
    "properties": {
      "operation": {
        "type": "string",
        "enum": ["create", "extract", "list"],
        "description": "Archive operation to perform"
      },
      "archive_path": {
        "type": "string",
        "description": "Path to archive file"
      },
      "source_path": {
        "type": "string",
        "description": "Source directory for creation"
      },
      "destination_path": {
        "type": "string",
        "description": "Destination directory for extraction"
      },
      "format": {
        "type": "string",
        "enum": ["zip", "tar", "tar.gz", "tar.bz2"],
        "description": "Archive format"
      },
      "compression_level": {
        "type": "number",
        "minimum": 0,
        "maximum": 9,
        "description": "Compression level (0-9)"
      },
      "exclude_patterns": {
        "type": "array",
        "items": {"type": "string"},
        "description": "Patterns to exclude from archive"
      }
    },
    "required": ["operation", "archive_path"]
  }
}
```

### 15. **Encrypt**
Encrypt and decrypt files and data.

```json
{
  "name": "Encrypt",
  "description": "Encrypt and decrypt files and data using various encryption algorithms. Supports both symmetric and asymmetric encryption.",
  "parameters": {
    "$schema": "http://json-schema.org/draft-07/schema#",
    "type": "object",
    "properties": {
      "operation": {
        "type": "string",
        "enum": ["encrypt", "decrypt"],
        "description": "Encryption operation"
      },
      "input_path": {
        "type": "string",
        "description": "Input file path"
      },
      "output_path": {
        "type": "string",
        "description": "Output file path"
      },
      "algorithm": {
        "type": "string",
        "enum": ["AES-256", "RSA", "ChaCha20"],
        "default": "AES-256",
        "description": "Encryption algorithm"
      },
      "key": {
        "type": "string",
        "description": "Encryption key (or path to key file)"
      },
      "key_derivation": {
        "type": "string",
        "enum": ["pbkdf2", "scrypt", "argon2"],
        "description": "Key derivation function for password-based encryption"
      }
    },
    "required": ["operation", "input_path", "output_path", "key"]
  }
}
```

---

## FINANCIAL & SCIENTIFIC TOOLS

### 16. **QuantLib**
Execute QuantLib financial calculations and modeling.

```json
{
  "name": "QuantLib",
  "description": "Execute QuantLib financial calculations including bond pricing, options valuation, risk metrics, and curve construction. Provides direct access to QuantLib functions.",
  "parameters": {
    "$schema": "http://json-schema.org/draft-07/schema#",
    "type": "object",
    "properties": {
      "calculation_type": {
        "type": "string",
        "enum": ["bond_price", "option_price", "curve_bootstrap", "risk_metrics", "custom"],
        "description": "Type of financial calculation"
      },
      "parameters": {
        "type": "object",
        "description": "Calculation-specific parameters"
      },
      "market_data": {
        "type": "object",
        "description": "Market data for calculations (rates, prices, volatilities)"
      },
      "calculation_date": {
        "type": "string",
        "description": "Valuation date (ISO format)"
      },
      "output_format": {
        "type": "string",
        "enum": ["json", "dataframe", "array"],
        "default": "json",
        "description": "Output format for results"
      }
    },
    "required": ["calculation_type", "parameters"]
  }
}
```

### 17. **MarketData**
Fetch real-time and historical financial market data.

```json
{
  "name": "MarketData",
  "description": "Fetch financial market data from multiple providers (Yahoo Finance, Alpha Vantage, Polygon, etc.). Supports stocks, bonds, options, currencies, and commodities.",
  "parameters": {
    "$schema": "http://json-schema.org/draft-07/schema#",
    "type": "object",
    "properties": {
      "symbols": {
        "type": "array",
        "items": {"type": "string"},
        "description": "Financial instrument symbols (e.g., ['AAPL', 'MSFT'])"
      },
      "data_type": {
        "type": "string",
        "enum": ["price", "historical", "options", "fundamentals", "news"],
        "description": "Type of market data to fetch"
      },
      "provider": {
        "type": "string",
        "enum": ["yahoo", "alpha_vantage", "polygon", "fred"],
        "description": "Data provider to use"
      },
      "start_date": {
        "type": "string",
        "description": "Start date for historical data (ISO format)"
      },
      "end_date": {
        "type": "string",
        "description": "End date for historical data (ISO format)"
      },
      "interval": {
        "type": "string",
        "enum": ["1m", "5m", "15m", "1h", "1d", "1wk", "1mo"],
        "default": "1d",
        "description": "Data interval for historical data"
      },
      "api_key": {
        "type": "string",
        "description": "API key for provider (if required)"
      }
    },
    "required": ["symbols", "data_type"]
  }
}
```

---

## USAGE RECOMMENDATIONS

### **High Priority Tools for Your Workflows:**
1. **Build** - Essential for Xcode/Swift development cycle
2. **Test** - Automated testing for all projects
3. **AST** - Code analysis for large Swift projects
4. **QuantLib** - Financial calculations and modeling
5. **MarketData** - Real-time data for financial applications

### **Medium Priority Tools:**
6. **Watch** - File monitoring for development automation
7. **Format** - Code formatting automation
8. **DataProfile** - Dataset analysis for Python notebooks
9. **Plot** - Advanced visualization capabilities
10. **API** - Enhanced HTTP request capabilities

### **Specialized Tools:**
11. **Template** - Project scaffolding and code generation
12. **Tree** - Project structure documentation
13. **Find** - Advanced file search capabilities
14. **Lint** - Code quality automation
15. **Archive** - Project packaging and deployment

These tools would significantly enhance Claude Code's capabilities for your specific workflows while maintaining focus on practical, high-value functionality.