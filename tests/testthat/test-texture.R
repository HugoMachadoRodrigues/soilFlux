test_that("classify_texture returns expected USDA classes", {
  # Known examples from USDA texture triangle
  expect_equal(classify_texture(sand = 90, silt =  5, clay =  5), "Sand")
  expect_equal(classify_texture(sand = 75, silt = 10, clay = 15), "Sandy Loam")
  expect_equal(classify_texture(sand = 10, silt = 80, clay = 10), "Silt Loam")
  expect_equal(classify_texture(sand = 20, silt = 20, clay = 60), "Clay")
  expect_equal(classify_texture(sand =  5, silt = 50, clay = 45), "Silty Clay")
})

test_that("classify_texture returns NA for missing inputs", {
  expect_true(is.na(classify_texture(NA, 50, 30)))
})

test_that("classify_texture returns NA when fractions do not sum to 100", {
  expect_true(is.na(classify_texture(50, 50, 50)))   # sums to 150
})

test_that("classify_texture is vectorised", {
  sand <- c(90, 10, 40)
  silt <- c(5,  80, 40)
  clay <- c(5,  10, 20)
  res  <- classify_texture(sand, silt, clay)
  expect_length(res, 3L)
  expect_type(res, "character")
})

test_that("add_texture appends Texture column", {
  df  <- data.frame(sand_total = 90, silt = 5, clay = 5)
  out <- add_texture(df)
  expect_true("Texture" %in% names(out))
  expect_equal(out$Texture, "Sand")
})

test_that("add_texture errors on missing columns", {
  df <- data.frame(sand_total = 90, clay = 5)   # silt missing
  expect_error(add_texture(df), "Column not found")
})
