#' Database connection and query functions for dawgtoolsr
#' 
#' @description Functions for connecting to the DAWG database and executing queries
#' @keywords internal

# Connection string for DAWG database
CONNECTION_STRING <- "Driver={ODBC Driver 17 for SQL Server};Server=am-dawg-sql-trt;Trusted_Connection=yes"

#' List available queries
#' 
#' @return A character vector of available query names
#' @export
list_queries <- function() {
  query_dir <- system.file("extdata", "queries", package = "dawgtoolsr")
  if (!dir.exists(query_dir)) {
    return(character(0))
  }
  sql_files <- list.files(query_dir, pattern = "\\.sql$", full.names = FALSE)
  tools::file_path_sans_ext(sql_files)
}

#' Get a query by name
#' 
#' @param name The name of the query (without .sql extension)
#' @return The SQL query as a character string
#' @export
get_query <- function(name) {
  query_file <- system.file("extdata", "queries", paste0(name, ".sql"), package = "dawgtoolsr")
  if (!file.exists(query_file)) {
    stop("Query '", name, "' not found")
  }
  readLines(query_file, warn = FALSE) %>% paste(collapse = "\n")
}

#' Render a template with parameters
#' 
#' @param template The SQL template string
#' @param params Named list of parameters
#' @return A list with 'sql' (the rendered SQL) and 'params' (positional parameters)
#' @export
render_template <- function(template, params = list()) {
  # Simple template rendering - replace {param} with values
  rendered <- template
  
  # Handle simple parameter substitution
  for (param_name in names(params)) {
    pattern <- paste0("\\{", param_name, "\\}")
    rendered <- stringr::str_replace_all(rendered, pattern, as.character(params[[param_name]]))
  }
  
  # Handle %(param)s style formatting (like Python's string formatting)
  format_pattern <- "%\\(([^)]+)\\)s"
  matches <- stringr::str_match_all(rendered, format_pattern)
  
  if (length(matches[[1]]) > 0) {
    param_names <- matches[[1]][, 2]
    positional_params <- params[param_names]
    
    # Replace with ? placeholders
    rendered <- stringr::str_replace_all(rendered, format_pattern, "?")
    
    return(list(
      sql = rendered,
      params = unname(positional_params)
    ))
  }
  
  return(list(
    sql = rendered,
    params = list()
  ))
}

#' Execute a SQL query
#' 
#' @param query The SQL query string
#' @param params Named list of parameters for the query
#' @return A list with 'headers' and 'rows'
#' @export
sql_query <- function(query, params = list()) {
  rendered <- render_template(query, params)
  
  # Connect to database
  conn <- DBI::dbConnect(odbc::odbc(), .connection_string = CONNECTION_STRING)
  on.exit(DBI::dbDisconnect(conn))
  
  # Execute query
  result <- DBI::dbGetQuery(conn, rendered$sql, params = rendered$params)
  
  if (nrow(result) == 0) {
    return(list(headers = names(result), rows = list()))
  }
  
  # Convert to list of rows
  rows <- split(result, seq_len(nrow(result)))
  rows <- lapply(rows, unlist, use.names = FALSE)
  
  # Handle JSON columns
  headers <- names(result)
  rows <- deserialize_json(headers, rows)
  headers <- stringr::str_replace(headers, "__json$", "")
  
  return(list(
    headers = headers,
    rows = rows
  ))
}

#' Deserialize JSON columns
#' 
#' @param headers Column headers
#' @param rows List of row data
#' @return Modified rows with JSON columns deserialized
#' @keywords internal
deserialize_json <- function(headers, rows) {
  json_cols <- which(stringr::str_ends(headers, "__json"))
  
  if (length(json_cols) == 0) {
    return(rows)
  }
  
  for (i in seq_along(rows)) {
    for (col_idx in json_cols) {
      if (!is.null(rows[[i]][[col_idx]]) && !is.na(rows[[i]][[col_idx]])) {
        tryCatch({
          json_str <- as.character(rows[[i]][[col_idx]])
          json_str <- stringr::str_replace_all(json_str, "\\\\n", "\n")
          rows[[i]][[col_idx]] <- jsonlite::fromJSON(json_str)
        }, error = function(e) {
          # If JSON parsing fails, keep original value
          warning("Failed to parse JSON in column ", headers[col_idx], ": ", e$message)
        })
      }
    }
  }
  
  return(rows)
}

#' Convert rows to list of dictionaries
#' 
#' @param headers Column headers
#' @param rows List of row data
#' @return List of named lists (dictionaries)
#' @export
as_dicts <- function(headers, rows) {
  lapply(rows, function(row) {
    setNames(row, headers)
  })
}