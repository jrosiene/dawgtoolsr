test_that("list_queries returns available queries", {
  queries <- list_queries()
  expect_type(queries, "character")
  expect_true("example" %in% queries)
})

test_that("get_query retrieves query content", {
  query <- get_query("example")
  expect_type(query, "character")
  expect_true(nchar(query) > 0)
  expect_true(grepl("SELECT", query))
})

test_that("get_query throws error for non-existent query", {
  expect_error(get_query("non_existent_query"), "Query 'non_existent_query' not found")
})

test_that("render_template handles simple substitution", {
  template <- "SELECT {name} as name, {value} as value"
  params <- list(name = "test", value = 123)
  result <- render_template(template, params)
  
  expect_equal(result$sql, "SELECT test as name, 123 as value")
  expect_equal(result$params, list())
})

test_that("render_template handles positional parameters", {
  template <- "SELECT %(name)s as name, %(value)s as value"
  params <- list(name = "test", value = 123)
  result <- render_template(template, params)
  
  expect_equal(result$sql, "SELECT ? as name, ? as value")
  expect_equal(result$params, list("test", 123))
})

test_that("as_dicts converts rows to dictionaries", {
  headers <- c("col1", "col2")
  rows <- list(c("a", 1), c("b", 2))
  dicts <- as_dicts(headers, rows)
  
  expect_length(dicts, 2)
  expect_equal(dicts[[1]], list(col1 = "a", col2 = 1))
  expect_equal(dicts[[2]], list(col1 = "b", col2 = 2))
})