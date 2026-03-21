# Build physics residual point sets (S1 – S4)

Generates four sets of collocation points (random soil-property vectors
and associated pF values) used to evaluate the physics constraints
during training.

## Usage

``` r
build_residual_sets(
  df_raw,
  x_inputs,
  S1 = 1500L,
  S2 = 500L,
  S3 = 500L,
  S4 = 1500L,
  pF_lin_min = 5,
  pF_lin_max = 7.6,
  pF0_pos = 6.2,
  pF1_neg = 7.6,
  pF_sat_min = -2,
  pF_sat_max = -0.3,
  seed = 123L
)
```

## Arguments

- df_raw:

  Data frame with covariate columns (training split).

- x_inputs:

  Character vector of covariate column names.

- S1:

  Number of S1 points — dry-end linearity (default 1500).

- S2:

  Number of S2 points — non-negativity at pF0 (default 500).

- S3:

  Number of S3 points — non-positivity at pF1 (default 500).

- S4:

  Number of S4 points — saturated plateau (default 1500).

- pF_lin_min:

  Lower pF for the S1 linearity constraint (default 5.0).

- pF_lin_max:

  Upper pF for the S1 linearity constraint (default 7.6).

- pF0_pos:

  pF at which theta must be \>= 0 — S2 (default 6.2).

- pF1_neg:

  pF at which theta must be \<= 0 — S3 (default 7.6).

- pF_sat_min:

  Lower pF for the S4 plateau constraint (default -2.0).

- pF_sat_max:

  Upper pF for the S4 plateau constraint (default -0.3).

- seed:

  Integer random seed (default 123).

## Value

A named list with four data frames: `set1`, `set2`, `set3`, `set4`. Each
data frame has one row per collocation point, with columns corresponding
to `x_inputs` (sampled uniformly within training range) and a `pF`
column.

## Examples

``` r
# \donttest{
df <- data.frame(
  clay       = c(20, 30, 10),
  silt       = c(30, 40, 20),
  sand_total = c(50, 30, 70),
  Depth_num  = c(15, 30, 60)
)
sets <- build_residual_sets(df, c("clay", "silt", "sand_total", "Depth_num"),
                            S1 = 50L, S2 = 20L, S3 = 20L, S4 = 50L)
# }
```
