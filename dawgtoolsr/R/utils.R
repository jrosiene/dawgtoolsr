#' Utility functions for dawgtoolsr
#' 
#' @description Helper functions for JSON encoding and output handling
#' @keywords internal

#' Custom JSON encoder for R objects
#' 
#' @param obj Object to encode
#' @return JSON string
#' @export
my_json_encode <- function(obj) {
  # Handle special cases like Python's MyJSONEncoder
  if (inherits(obj, "POSIXt")) {
    return(format(obj, "%Y-%m-%dT%H:%M:%S"))
  }
  
  if (inherits(obj, "numeric") && is.integer(obj)) {
    return(as.integer(obj))
  }
  
  # Use jsonlite for standard encoding
  jsonlite::toJSON(obj, auto_unbox = TRUE, null = "null")
}

#' Write data to stdout or file
#' 
#' @param data Data to write
#' @param file File path (NULL for stdout)
#' @param compress Whether to compress with gzip
#' @export
write_output <- function(data, file = NULL, compress = FALSE) {
  if (is.null(file)) {
    # Write to stdout
    cat(data, sep = "")
    return(invisible())
  }
  
  if (compress || stringr::str_ends(file, "\\.gz$")) {
    # Use gzip compression
    con <- gzfile(file, "w")
    on.exit(close(con))
    cat(data, file = con, sep = "")
  } else {
    # Write to regular file
    cat(data, file = file, sep = "")
  }
}

#' Replace NULL values with empty strings
#' 
#' @param row Row data
#' @param maxchars Maximum characters per field
#' @return Row with NULL values replaced
#' @export
nonull <- function(row, maxchars = 1000) {
  lapply(row, function(x) {
    if (is.null(x) || (is.character(x) && x == "NULL")) {
      return("")
    }
    if (is.character(x) && nchar(x) > maxchars) {
      return(substr(x, 1, maxchars))
    }
    return(x)
  })
}

#' Format data as CSV
#' 
#' @param headers Column headers
#' @param rows List of row data
#' @param file Output file (NULL for stdout)
#' @param compress Whether to compress output
#' @export
write_csv <- function(headers, rows, file = NULL, compress = FALSE) {
  # Convert to data frame
  df <- as.data.frame(do.call(rbind, rows), stringsAsFactors = FALSE)
  names(df) <- headers
  
  # Apply nonull function to each row
  df <- as.data.frame(lapply(df, function(col) {
    sapply(col, function(x) nonull(list(x))[[1]])
  }), stringsAsFactors = FALSE)
  
  # Write CSV
  if (is.null(file)) {
    readr::write_csv(df, stdout())
  } else {
    if (compress || stringr::str_ends(file, "\\.gz$")) {
      con <- gzfile(file, "w")
      on.exit(close(con))
      readr::write_csv(df, con)
    } else {
      readr::write_csv(df, file)
    }
  }
}