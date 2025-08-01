#' Execute SQL queries with parameter substitution
#' 
#' @description Execute SQL queries with template rendering and multiple output formats
#' @param query SQL query string
#' @param infile Input file containing SQL query
#' @param query_name Name of a predefined query
#' @param params Named list of parameters
#' @param params_file JSON file containing parameters
#' @param outfile Output file path
#' @param format Output format: 'lines', 'dicts', or 'lists'
#' @param dry_run Print the rendered query and exit
#' @return Query results in the specified format
#' @export
execute_query <- function(query = NULL, infile = NULL, query_name = NULL,
                        params = list(), params_file = NULL, outfile = NULL,
                        format = c("lines", "dicts", "lists"), dry_run = FALSE) {
  
  format <- match.arg(format)
  
  # Load parameters from file if specified
  if (!is.null(params_file)) {
    if (!file.exists(params_file)) {
      stop("Parameters file '", params_file, "' not found")
    }
    file_params <- jsonlite::fromJSON(params_file)
    params <- c(params, file_params)
  }
  
  # Get query from various sources
  if (!is.null(query)) {
    query_text <- query
  } else if (!is.null(infile)) {
    if (!file.exists(infile)) {
      stop("Input file '", infile, "' not found")
    }
    query_text <- paste(readLines(infile, warn = FALSE), collapse = "\n")
  } else if (!is.null(query_name)) {
    query_text <- get_query(query_name)
  } else {
    stop("Must provide either a query, input file, or query name")
  }
  
  # Dry run - just print the rendered query
  if (dry_run) {
    rendered <- render_template(query_text, params)
    cat("Rendered SQL:\n", rendered$sql, "\n")
    cat("Parameters:", jsonlite::toJSON(rendered$params, auto_unbox = TRUE), "\n")
    return(invisible())
  }
  
  # Execute query
  result <- sql_query(query_text, params)
  headers <- result$headers
  rows <- result$rows
  
  # Format output
  if (format == "lines") {
    dicts <- as_dicts(headers, rows)
    output <- sapply(dicts, function(dict) {
      my_json_encode(dict)
    })
    output <- paste(output, collapse = "\n")
  } else if (format == "dicts") {
    dicts <- as_dicts(headers, rows)
    output <- my_json_encode(dicts)
  } else if (format == "lists") {
    output <- my_json_encode(list(
      fieldnames = headers,
      data = rows
    ))
  }
  
  # Write output
  if (!is.null(outfile)) {
    # Apply parameter substitution to filename
    for (param_name in names(params)) {
      pattern <- paste0("\\{", param_name, "\\}")
      outfile <- stringr::str_replace_all(outfile, pattern, as.character(params[[param_name]]))
    }
    
    compress <- stringr::str_ends(outfile, "\\.gz$")
    write_output(output, outfile, compress)
  } else {
    write_output(output)
  }
  
  return(invisible())
}

#' Command-line interface for query execution
#' 
#' @param args Command line arguments
#' @export
query_cli <- function(args = commandArgs(trailingOnly = TRUE)) {
  # Simple argument parsing for R
  # This is a basic implementation - in practice you might want to use optparse or argparse
  
  # Parse arguments
  query <- NULL
  infile <- NULL
  query_name <- NULL
  params <- list()
  params_file <- NULL
  outfile <- NULL
  format <- "lines"
  dry_run <- FALSE
  
  i <- 1
  while (i <= length(args)) {
    arg <- args[i]
    
    if (arg == "-q" || arg == "--query") {
      i <- i + 1
      query <- args[i]
    } else if (arg == "-i" || arg == "--infile") {
      i <- i + 1
      infile <- args[i]
    } else if (arg == "-n" || arg == "--query-name") {
      i <- i + 1
      query_name <- args[i]
    } else if (arg == "-p" || arg == "--params") {
      i <- i + 1
      param_str <- args[i]
      parts <- strsplit(param_str, "=")[[1]]
      if (length(parts) == 2) {
        params[[parts[1]]] <- parts[2]
      }
    } else if (arg == "-P" || arg == "--params-file") {
      i <- i + 1
      params_file <- args[i]
    } else if (arg == "-o" || arg == "--outfile") {
      i <- i + 1
      outfile <- args[i]
    } else if (arg == "-f" || arg == "--format") {
      i <- i + 1
      format <- args[i]
    } else if (arg == "-x" || arg == "--dry-run") {
      dry_run <- TRUE
    }
    
    i <- i + 1
  }
  
  # Execute query
  execute_query(
    query = query,
    infile = infile,
    query_name = query_name,
    params = params,
    params_file = params_file,
    outfile = outfile,
    format = format,
    dry_run = dry_run
  )
}