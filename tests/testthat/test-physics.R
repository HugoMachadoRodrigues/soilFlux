test_that("norouzi_lambdas returns correct defaults", {
  lam <- norouzi_lambdas("norouzi")
  expect_equal(lam$lambda_wet, 1.0)
  expect_equal(lam$lambda_dry, 10.0)
  expect_equal(lam$lambda3,    1.0)
  expect_equal(lam$lambda4,    1000.0)
  expect_equal(lam$lambda5,    1000.0)
  expect_equal(lam$lambda6,    1.0)
})

test_that("norouzi_lambdas smooth config increases lambda3", {
  lam_n <- norouzi_lambdas("norouzi")
  lam_s <- norouzi_lambdas("smooth")
  expect_gt(lam_s$lambda3, lam_n$lambda3)
})

test_that("build_residual_sets returns expected structure", {
  df <- data.frame(
    clay      = runif(50, 5, 60),
    silt      = runif(50, 5, 50),
    sand_total = runif(50, 10, 80),
    Depth_num = runif(50, 2.5, 50)
  )
  sets <- build_residual_sets(df, c("clay", "silt", "sand_total", "Depth_num"),
                              S1 = 10L, S2 = 5L, S3 = 5L, S4 = 10L)

  expect_named(sets, c("set1", "set2", "set3", "set4"))
  expect_equal(nrow(sets$set1), 10L)
  expect_equal(nrow(sets$set2), 5L)
  expect_true("pF" %in% names(sets$set1))

  # S2 all at pF0 = 6.2
  expect_true(all(sets$set2$pF == 6.2))

  # S1 pF values within [5, 7.6]
  expect_true(all(sets$set1$pF >= 5.0 & sets$set1$pF <= 7.6))
})

test_that("build_residual_sets is reproducible with same seed", {
  df <- data.frame(clay = runif(30, 5, 60), silt = runif(30, 5, 50),
                   sand_total = runif(30, 10, 80))
  s1 <- build_residual_sets(df, c("clay","silt","sand_total"), seed = 42L,
                             S1=10L, S2=5L, S3=5L, S4=10L)
  s2 <- build_residual_sets(df, c("clay","silt","sand_total"), seed = 42L,
                             S1=10L, S2=5L, S3=5L, S4=10L)
  expect_equal(s1$set1$pF, s2$set1$pF)
  expect_equal(s1$set1$clay, s2$set1$clay)
})
