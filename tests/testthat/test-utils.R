test_that("pf_from_head returns correct values", {
  expect_equal(pf_from_head(1),    0,   tolerance = 1e-6)
  expect_equal(pf_from_head(10),   1,   tolerance = 1e-6)
  expect_equal(pf_from_head(100),  2,   tolerance = 1e-6)
  expect_equal(pf_from_head(1000), 3,   tolerance = 1e-6)
})

test_that("pf_from_head clamps near-zero heads", {
  expect_true(is.finite(pf_from_head(0)))
  expect_true(is.finite(pf_from_head(1e-10)))
})

test_that("head_from_pf inverts pf_from_head", {
  heads <- c(1, 10, 100, 1000, 15849)
  expect_equal(head_from_pf(pf_from_head(heads)), heads, tolerance = 1e-6)
})

test_that("pf_normalize maps domain to [0,1]", {
  expect_equal(pf_normalize(-2, -2, 7.6), 0, tolerance = 1e-6)
  expect_equal(pf_normalize(7.6, -2, 7.6), 1, tolerance = 1e-6)
  expect_equal(pf_normalize(2.8, -2, 7.6), (2.8 + 2) / 9.6, tolerance = 1e-6)
})

test_that("parse_depth handles range strings", {
  res <- parse_depth("0-5")
  expect_equal(res$mid,   2.5)
  expect_equal(res$label, "0-5 cm")
})

test_that("parse_depth handles single depth", {
  res <- parse_depth("30")
  expect_equal(res$mid,   30)
  expect_equal(res$label, "30 cm")
})

test_that("parse_depth returns NA for unrecognised input", {
  res <- parse_depth("abc")
  expect_true(is.na(res$mid))
  expect_true(is.na(res$label))
})

test_that("parse_depth_column adds Depth_num and Depth_label", {
  df <- data.frame(depth = c("0-5", "5-15", "15-30"), x = 1:3)
  out <- parse_depth_column(df, "depth")
  expect_true("Depth_num"   %in% names(out))
  expect_true("Depth_label" %in% names(out))
  expect_equal(out$Depth_num, c(2.5, 10, 22.5))
  expect_s3_class(out$Depth_label, "factor")
})

test_that("fix_bd_units converts kg/m3 to g/cm3", {
  expect_equal(fix_bd_units(c(120, 145, 130)), c(1.2, 1.45, 1.3),
               tolerance = 1e-6)
})

test_that("fix_bd_units leaves g/cm3 unchanged", {
  vals <- c(1.2, 1.45, 1.3)
  expect_equal(fix_bd_units(vals), vals, tolerance = 1e-6)
})

test_that("theta_unit_factor detects percentage vs fraction", {
  expect_equal(theta_unit_factor(c(10, 35, 50)), 100)
  expect_equal(theta_unit_factor(c(0.10, 0.35, 0.50)), 1)
})
