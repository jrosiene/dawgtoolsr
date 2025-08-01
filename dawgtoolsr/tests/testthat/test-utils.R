test_that("nonull replaces NULL values", {
  row <- list("a", "NULL", "c", NULL)
  result <- nonull(row)
  
  expect_equal(result, list("a", "", "c", ""))
})

test_that("nonull limits string length", {
  long_string <- paste(rep("a", 2000), collapse = "")
  row <- list("short", long_string)
  result <- nonull(row, maxchars = 1000)
  
  expect_equal(nchar(result[[2]]), 1000)
})

test_that("my_json_encode handles special types", {
  # Test POSIXt
  dt <- as.POSIXct("2023-01-01 12:00:00")
  result <- my_json_encode(dt)
  expect_true(grepl("2023-01-01", result))
  
  # Test integer
  result <- my_json_encode(123L)
  expect_equal(result, "123")
})

test_that("write_output writes to stdout when file is NULL", {
  # Capture stdout
  output <- capture.output(write_output("test data"))
  expect_equal(output, "test data")
})