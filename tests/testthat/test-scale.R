test_that("fit_minmax returns correct min and range", {
  df <- data.frame(sand = c(0, 50, 100), clay = c(10, 30, 50))
  sc <- fit_minmax(df, c("sand", "clay"))

  expect_equal(sc$min[["sand"]], 0,   tolerance = 1e-6)
  expect_equal(sc$min[["clay"]], 10,  tolerance = 1e-6)
  expect_equal(sc$rng[["sand"]], 100, tolerance = 1e-6)
  expect_equal(sc$rng[["clay"]], 40,  tolerance = 1e-6)
})

test_that("apply_minmax maps training data to [0,1]", {
  df <- data.frame(sand = c(20, 40, 60), clay = c(10, 20, 30))
  sc <- fit_minmax(df, c("sand", "clay"))
  Xs <- apply_minmax(df, sc)

  expect_equal(range(Xs[, "sand"]), c(0, 1), tolerance = 1e-6)
  expect_equal(range(Xs[, "clay"]), c(0, 1), tolerance = 1e-6)
})

test_that("apply_minmax extrapolates for out-of-range values", {
  df_tr  <- data.frame(sand = c(20, 60), clay = c(10, 30))
  sc     <- fit_minmax(df_tr, c("sand", "clay"))
  df_new <- data.frame(sand = 80, clay = 5)
  Xs     <- apply_minmax(df_new, sc)

  # sand = (80-20)/(60-20) = 1.5
  expect_equal(as.numeric(Xs[1, "sand"]), 1.5, tolerance = 1e-6)
  # clay = (5-10)/(30-10) = -0.25
  expect_equal(as.numeric(Xs[1, "clay"]), -0.25, tolerance = 1e-6)
})

test_that("invert_minmax recovers original data", {
  df <- data.frame(sand = c(20, 40, 60), clay = c(10, 20, 30))
  sc <- fit_minmax(df, c("sand", "clay"))
  Xs <- apply_minmax(df, sc)
  recovered <- invert_minmax(Xs, sc)

  expect_equal(recovered[, "sand"], as.numeric(df$sand), tolerance = 1e-6)
  expect_equal(recovered[, "clay"], as.numeric(df$clay), tolerance = 1e-6)
})

test_that("fit_minmax handles constant columns without error", {
  df <- data.frame(sand = c(50, 50, 50), clay = c(10, 20, 30))
  sc <- expect_no_error(fit_minmax(df, c("sand", "clay")))
  # Constant column gets rng = 1 to avoid division by zero
  expect_equal(sc$rng[["sand"]], 1)
})

test_that("fit_minmax errors on missing columns", {
  df <- data.frame(sand = c(20, 40))
  expect_error(fit_minmax(df, c("sand", "clay")), "not found")
})
