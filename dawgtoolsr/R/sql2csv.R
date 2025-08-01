#' Convert SQL query output to CSV format
#' 
#' @description Execute SQL queries and format output as CSV, similar to sqlcmd
#' @param query SQL query string
#' @param infile Input file containing SQL query
#' @param outfile Output file path
#' @param print_query Print the query before executing
#' @param dry_run Read the query file and exit
#' @param environment Named list of environment variables for template substitution
#' @export
sql2csv <- function(query = NULL, infile = NULL, outfile = NULL,
                   print_query = FALSE, dry_run = FALSE, environment = list()) {
  
  # Get query from various sources
  if (!is.null(query)) {
    query_text <- query
  } else if (!is.null(infile)) {
    if (!file.exists(infile)) {
      stop("Input file '", infile, "' not found")
    }
    query_text <- paste(readLines(infile, warn = FALSE), collapse = "\n")
  } else {
    stop("Must provide either -q/--query or -i/--infile")
  }
  
  # Apply environment variable substitution
  if (length(environment) > 0) {
    for (env_name in names(environment)) {
      pattern <- paste0("\\{", env_name, "\\}")
      query_text <- stringr::str_replace_all(query_text, pattern, as.character(environment[[env_name]]))
    }
  }
  
  # Print query if requested
  if (print_query) {
    cat(query_text, "\n")
  }
  
  # Dry run - just exit
  if (dry_run) {
    return(invisible())
  }
  
  # Execute query using database connection
  result <- sql_query(query_text, list())
  headers <- result$headers
  rows <- result$rows
  
  # Write CSV output
  if (!is.null(outfile)) {
    # Apply environment variable substitution to filename
    for (env_name in names(environment)) {
      pattern <- paste0("\\{", env_name, "\\}")
      outfile <- stringr::str_replace_all(outfile, pattern, as.character(environment[[env_name]]))
    }
    
    compress <- stringr::str_ends(outfile, "\\.gz$")
    write_csv(headers, rows, outfile, compress)
  } else {
    write_csv(headers, rows)
  }
  
  return(invisible())
}

#' Command-line interface for sql2csv
#' 
#' @param args Command line arguments
#' @export
sql2csv_cli <- function(args = commandArgs(trailingOnly = TRUE)) {
  # Parse arguments
  query <- NULL
  infile <- NULL
  outfile <- NULL
  print_query <- FALSE
  dry_run <- FALSE
  environment <- list()
  
  i <- 1
  while (i <= length(args)) {
    arg <- args[i]
    
    if (arg == "-q" || arg == "--query") {
      i <- i + 1
      query <- args[i]
    } else if (arg == "-i" || arg == "--infile") {
      i <- i + 1
      infile <- args[i]
    } else if (arg == "-o" || arg == "--outfile") {
      i <- i + 1
      outfile <- args[i]
    } else if (arg == "-p" || arg == "--print-query") {
      print_query <- TRUE
    } else if (arg == "-n" || arg == "--dry-run") {
      dry_run <- TRUE
    } else if (arg == "-e" || arg == "--environment") {
      i <- i + 1
      env_str <- args[i]
      parts <- strsplit(env_str, "=")[[1]]
      if (length(parts) == 2) {
        environment[[parts[1]]] <- parts[2]
      }
    }
    
    i <- i + 1
  }
  
  # Execute sql2csv
  sql2csv(
    query = query,
    infile = infile,
    outfile = outfile,
    print_query = print_query,
    dry_run = dry_run,
    environment = environment
  )
}