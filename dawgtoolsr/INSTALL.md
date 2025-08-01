# Installation and Usage Guide

## Prerequisites

Before installing dawgtoolsr, make sure you have:

1. **R** (version 3.5.0 or higher)
2. **ODBC Driver 17 for SQL Server** installed and configured
3. **Database access** to the DAWG database

## Installation

### Method 1: Using the installation script

```bash
# Clone or download the package
cd dawgtoolsr

# Run the installation script
Rscript install.R
```

### Method 2: Manual installation

```r
# Install dependencies
install.packages(c("DBI", "odbc", "jsonlite", "readr", "stringr", "glue", "R.utils"))

# Build and install the package
system("R CMD build .")
system("R CMD INSTALL dawgtoolsr_0.1.0.tar.gz")
```

### Method 3: Development installation

```r
# Install devtools if not already installed
install.packages("devtools")

# Install from local directory
devtools::install(".")
```

## Configuration

### Database Connection

The package connects to the DAWG database using the following connection string:
```
Driver={ODBC Driver 17 for SQL Server};Server=am-dawg-sql-trt;Trusted_Connection=yes
```

Make sure your ODBC driver is properly configured and you have access to the database.

### Environment Setup

You may need to set up environment variables for database access:

```bash
# Example environment setup (adjust as needed)
export SQLCMDCONNECTION="am-dawg-sql-trt"
```

## Usage Examples

### R Functions

```r
library(dawgtoolsr)

# Basic query execution
result <- sql_query("SELECT 1 as col1, 2 as col2")
print(result$headers)  # ["col1", "col2"]
print(result$rows)     # [[1, 2]]

# Query with parameters
result <- sql_query(
  "SELECT %(name)s as name, %(value)s as value",
  params = list(name = "test", value = 123)
)

# Template substitution
result <- sql_query(
  "SELECT {table_name} as table_name FROM {schema}.{table}",
  params = list(table_name = "users", schema = "dbo", table = "user_table")
)

# List available queries
queries <- list_queries()
print(queries)  # ["example", "notes", "path_reports"]

# Execute a predefined query
query_text <- get_query("example")
result <- sql_query(query_text, params = list(test_value = 456, date = "2023-01-01"))

# Convert to CSV
write_csv(result$headers, result$rows, "output.csv")

# JSON output
dicts <- as_dicts(result$headers, result$rows)
json_output <- my_json_encode(dicts)
```

### Command Line Interface

```bash
# Basic query execution
dawgtoolsr query -q "SELECT 1 as col1, 2 as col2"

# Query with parameters
dawgtoolsr query -q "SELECT %(name)s as name" -p name=test

# Output to file
dawgtoolsr query -q "SELECT 1 as col1" -o output.json

# Different output formats
dawgtoolsr query -q "SELECT 1 as col1" -f dicts
dawgtoolsr query -q "SELECT 1 as col1" -f lists

# Use predefined query
dawgtoolsr query -n example -p test_value=123 -p date=2023-01-01

# Dry run to see rendered query
dawgtoolsr query -q "SELECT %(date)s as date" -p date=2023-01-01 -x

# CSV output
dawgtoolsr sql2csv -q "SELECT 1 as col1, 2 as col2" -o output.csv

# Compressed output
dawgtoolsr sql2csv -q "SELECT 1 as col1" -o output.csv.gz

# Template substitution in filename
dawgtoolsr sql2csv -q "SELECT 1 as col1" -o "output-{date}.csv" -e date=2023-01-01
```

## Template Substitution

The package supports two types of parameter substitution:

### 1. Simple Substitution
Use `{param_name}` in your SQL templates:

```sql
SELECT {table_name} as table_name
FROM {schema}.{table}
WHERE id = {id}
```

### 2. Positional Parameters
Use `%(param_name)s` for prepared statements:

```sql
SELECT %(name)s as name, %(value)s as value
FROM users
WHERE id = %(user_id)s
```

## Output Formats

### JSON Lines (default)
Each row as a separate JSON object:
```json
{"col1": 1, "col2": 2}
{"col1": 3, "col2": 4}
```

### JSON Dictionaries
Array of objects:
```json
[
  {"col1": 1, "col2": 2},
  {"col1": 3, "col2": 4}
]
```

### JSON Lists
Structured format with headers and data:
```json
{
  "fieldnames": ["col1", "col2"],
  "data": [[1, 2], [3, 4]]
}
```

## Troubleshooting

### Common Issues

1. **ODBC Driver not found**
   - Install ODBC Driver 17 for SQL Server
   - Verify driver installation: `odbcinst -j`

2. **Database connection failed**
   - Check network connectivity to `am-dawg-sql-trt`
   - Verify Windows authentication is working
   - Test connection with `sqlcmd -S am-dawg-sql-trt`

3. **Package dependencies missing**
   - Run: `install.packages(c("DBI", "odbc", "jsonlite", "readr", "stringr", "glue", "R.utils"))`

4. **Permission denied for command line script**
   - Make executable: `chmod +x inst/bin/dawgtoolsr`

### Debug Mode

Enable verbose output for debugging:

```r
# Set logging level
options(dawgtoolsr.verbose = TRUE)

# Or use command line
dawgtoolsr query -q "SELECT 1" --verbose
```

## Development

### Running Tests

```r
# Run all tests
devtools::test()

# Run specific test file
devtools::test_file("tests/testthat/test-db.R")
```

### Building Documentation

```r
# Generate documentation
devtools::document()

# Build vignettes
devtools::build_vignettes()
```

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This package is licensed under the MIT License. See the LICENSE file for details.