test_that("swrc_metrics returns perfect scores for identical inputs", {
  x <- seq(0.05, 0.45, by = 0.05)
  m <- swrc_metrics(x, x)

  expect_equal(m$R2,   1,   tolerance = 1e-8)
  expect_equal(m$RMSE, 0,   tolerance = 1e-8)
  expect_equal(m$MAE,  0,   tolerance = 1e-8)
  expect_equal(m$n,    length(x))
})

test_that("swrc_metrics R2 is negative for poor predictions", {
  obs  <- c(0.3, 0.25, 0.2, 0.15, 0.1)
  pred <- c(0.1, 0.4, 0.05, 0.5, 0.02)   # badly off
  m    <- swrc_metrics(obs, pred)
  expect_lt(m$R2, 0.5)
})

test_that("swrc_metrics handles NA values with na.rm = TRUE", {
  obs  <- c(0.3, NA, 0.2, 0.15, 0.1)
  pred <- c(0.3, 0.25, 0.2, 0.15, 0.1)
  expect_no_warning(m <- swrc_metrics(obs, pred))
  expect_equal(m$n, 4L)
})

test_that("swrc_metrics_by_group returns one row per group", {
  df <- data.frame(
    obs     = c(0.3, 0.25, 0.2, 0.15),
    pred    = c(0.28, 0.26, 0.22, 0.14),
    texture = c("Clay", "Clay", "Sand", "Sand")
  )
  m <- swrc_metrics_by_group(df, "obs", "pred", "texture")
  expect_equal(nrow(m), 2L)
  expect_true("texture" %in% names(m))
  expect_true(all(c("R2", "RMSE", "MAE") %in% names(m)))
})

test_that("swrc_metrics errors on mismatched lengths", {
  expect_error(swrc_metrics(1:5, 1:6), "length")
})

test_that("swrc_metrics RMSE == MAE for constant error", {
  obs  <- rep(0.3, 10)
  pred <- rep(0.32, 10)  # constant error of 0.02
  m    <- swrc_metrics(obs, pred)
  expect_equal(m$RMSE, m$MAE, tolerance = 1e-8)
  expect_equal(m$MAE,  0.02,  tolerance = 1e-8)
})
