#!/usr/bin/env Rscript

# Installation script for dawgtoolsr
# This script installs the package and its dependencies

cat("Installing dawgtoolsr package...\n")

# Install required dependencies
cat("Installing dependencies...\n")
deps <- c("DBI", "odbc", "jsonlite", "readr", "stringr", "glue", "R.utils")
for (dep in deps) {
  if (!require(dep, character.only = TRUE, quietly = TRUE)) {
    cat("Installing", dep, "...\n")
    install.packages(dep, repos = "https://cran.rstudio.com/")
  }
}

# Install the package
cat("Building and installing dawgtoolsr...\n")
system("R CMD build .")
pkg_file <- list.files(pattern = "dawgtoolsr_.*\\.tar\\.gz")[1]
system(paste("R CMD INSTALL", pkg_file))

cat("Installation complete!\n")
cat("You can now use: library(dawgtoolsr)\n")
cat("Or run from command line: dawgtoolsr --help\n")