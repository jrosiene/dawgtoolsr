# dawgtoolsr

R package providing tools for database operations, SQL query execution, and CSV output formatting. This is a port of the Python [dawgtools](https://github.com/nhoffman/dawgtools) package functionality to R.

## Installation

```r
# Install from GitHub (when available)
remotes::install_github("your-username/dawgtoolsr")

# Or install from local source
install.packages("dawgtoolsr", repos = NULL, type = "source")
```

## Features

- **SQL Query Execution**: Execute SQL queries with parameter substitution
- **CSV Output**: Convert SQL query results to CSV format
- **Template Rendering**: Support for parameter substitution in SQL templates
- **Multiple Output Formats**: JSON lines, dictionaries, or lists
- **Database Connection**: Direct connection to DAWG database
- **Command Line Interface**: CLI tools for batch processing

## Usage

### R Functions

```r
library(dawgtoolsr)

# Execute a simple query
result <- sql_query("SELECT 1 as col1, 2 as col2")
print(result$headers)
print(result$rows)

# Execute query with parameters
result <- sql_query("SELECT %(name)s as name, %(value)s as value", 
                   params = list(name = "test", value = 123))

# Convert to CSV
write_csv(result$headers, result$rows, "output.csv")

# List available predefined queries
list_queries()

# Execute a predefined query
query_text <- get_query("notes")
result <- sql_query(query_text)
```

### Command Line Interface

```bash
# Execute a query and output JSON lines
dawgtoolsr query -q "SELECT 1 as col1, 2 as col2"

# Execute query with parameters
dawgtoolsr query -q "SELECT %(name)s as name" -p name=test

# Output to CSV
dawgtoolsr sql2csv -q "SELECT 1 as col1, 2 as col2" -o output.csv

# Use a predefined query
dawgtoolsr query -n notes

# Dry run to see rendered query
dawgtoolsr query -q "SELECT %(date)s as date" -p date=2023-01-01 -x
```

## Available Commands

### query

Execute SQL queries with parameter substitution and multiple output formats.

**Options:**
- `-q, --query TEXT`: SQL command
- `-i, --infile FILE`: Input file containing SQL command
- `-n, --query-name NAME`: Name of a predefined query
- `-p, --params VAR=VAL`: Parameter values (can be specified multiple times)
- `-P, --params-file FILE`: JSON file containing parameter values
- `-o, --outfile FILE`: Output file
- `-f, --format FORMAT`: Output format: lines, dicts, or lists [default: lines]
- `-x, --dry-run`: Print the rendered query and exit

### sql2csv

Convert SQL query output to CSV format.

**Options:**
- `-q, --query TEXT`: SQL command
- `-i, --infile FILE`: Input file containing SQL command
- `-o, --outfile FILE`: Output file (uses gzip if ends with .gz)
- `-p, --print-query`: Print the query before executing
- `-n, --dry-run`: Read the query file and exit
- `-e, --environment VAR=VAL`: Environment variables for template substitution

## Template Substitution

The package supports two types of parameter substitution:

1. **Simple substitution**: `{param_name}` in SQL templates
2. **Positional parameters**: `%(param_name)s` for prepared statements

Example:
```sql
SELECT {table_name} as table_name, %(value)s as value
FROM {schema}.{table}
WHERE id = %(id)s
```

## Database Connection

The package connects to the DAWG database using ODBC. Make sure you have the appropriate ODBC driver installed and configured.

## Dependencies

- DBI: Database interface
- odbc: ODBC database driver
- jsonlite: JSON handling
- readr: CSV reading/writing
- stringr: String manipulation
- glue: String interpolation
- R.utils: Utility functions

## Development

To contribute to the package:

1. Clone the repository
2. Install dependencies: `install.packages(c("DBI", "odbc", "jsonlite", "readr", "stringr", "glue", "R.utils"))`
3. Build and install: `R CMD build . && R CMD INSTALL dawgtoolsr_0.1.0.tar.gz`

## License

MIT License - see LICENSE file for details.

## Acknowledgments

This package is a port of the Python [dawgtools](https://github.com/nhoffman/dawgtools) package by nhoffman.
