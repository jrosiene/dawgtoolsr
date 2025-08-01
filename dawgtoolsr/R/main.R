#' Main dawgtoolsr package functions
#' 
#' @description Main entry points for the dawgtoolsr package
#' @keywords internal

#' Main command-line interface
#' 
#' @param args Command line arguments
#' @export
main <- function(args = commandArgs(trailingOnly = TRUE)) {
  if (length(args) == 0) {
    cat("dawgtoolsr - R Tools for DAWG Database Operations\n")
    cat("Usage: dawgtoolsr <command> [options]\n")
    cat("\nAvailable commands:\n")
    cat("  query    - Execute SQL queries with parameter substitution\n")
    cat("  sql2csv  - Convert SQL query output to CSV format\n")
    cat("  help     - Show detailed help for a command\n")
    cat("\nUse 'dawgtoolsr help <command>' for detailed help\n")
    return(invisible())
  }
  
  command <- args[1]
  remaining_args <- args[-1]
  
  if (command == "help") {
    if (length(remaining_args) > 0) {
      help_command <- remaining_args[1]
      if (help_command == "query") {
        cat("dawgtoolsr query - Execute SQL queries with parameter substitution\n")
        cat("\nUsage: dawgtoolsr query [options]\n")
        cat("\nOptions:\n")
        cat("  -q, --query TEXT        SQL command\n")
        cat("  -i, --infile FILE       Input file containing SQL command\n")
        cat("  -n, --query-name NAME   Name of a predefined query\n")
        cat("  -p, --params VAR=VAL    Parameter values (can be specified multiple times)\n")
        cat("  -P, --params-file FILE  JSON file containing parameter values\n")
        cat("  -o, --outfile FILE      Output file\n")
        cat("  -f, --format FORMAT     Output format: lines, dicts, or lists [default: lines]\n")
        cat("  -x, --dry-run           Print the rendered query and exit\n")
      } else if (help_command == "sql2csv") {
        cat("dawgtoolsr sql2csv - Convert SQL query output to CSV format\n")
        cat("\nUsage: dawgtoolsr sql2csv [options]\n")
        cat("\nOptions:\n")
        cat("  -q, --query TEXT        SQL command\n")
        cat("  -i, --infile FILE       Input file containing SQL command\n")
        cat("  -o, --outfile FILE      Output file (uses gzip if ends with .gz)\n")
        cat("  -p, --print-query       Print the query before executing\n")
        cat("  -n, --dry-run           Read the query file and exit\n")
        cat("  -e, --environment VAR=VAL Environment variables for template substitution\n")
      } else {
        cat("Unknown command '", help_command, "'\n")
        cat("Available commands: query, sql2csv\n")
      }
    } else {
      cat("dawgtoolsr help <command> - Show detailed help for a command\n")
    }
    return(invisible())
  }
  
  if (command == "query") {
    query_cli(remaining_args)
  } else if (command == "sql2csv") {
    sql2csv_cli(remaining_args)
  } else {
    cat("Unknown command '", command, "'\n")
    cat("Use 'dawgtoolsr help' for available commands\n")
  }
}

#' Package version
#' 
#' @return Package version string
#' @export
package_version <- function() {
  "0.1.0"
}

#' List available commands
#' 
#' @return Character vector of available commands
#' @export
list_commands <- function() {
  c("query", "sql2csv", "help")
}

#' Show package information
#' 
#' @export
package_info <- function() {
  cat("dawgtoolsr version", package_version(), "\n")
  cat("R Tools for DAWG Database Operations\n")
  cat("\nAvailable commands:\n")
  for (cmd in list_commands()) {
    cat("  ", cmd, "\n")
  }
  cat("\nFor help on a specific command, use: dawgtoolsr help <command>\n")
}