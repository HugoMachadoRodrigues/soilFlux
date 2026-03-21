# Predict dense SWRC curves for a set of soil profiles

For each unique (PEDON_ID × depth) profile in `newdata`, predicts theta
across a dense grid of pF values and returns a tidy long-format tibble.

## Usage

``` r
predict_swrc_dense(
  object,
  newdata,
  n_points = 1000L,
  pf_range = NULL,
  id_cols = c("PEDON_ID", "Depth_num", "Depth_label", "Texture")
)
```

## Arguments

- object:

  A `swrc_fit` object.

- newdata:

  A data frame with covariate columns plus (optionally) `PEDON_ID`,
  `Depth_num`, `Depth_label`, and `Texture`.

- n_points:

  Number of equally spaced pF points (default `1000`).

- pf_range:

  Numeric vector of length 2: min and max pF values for the output grid
  (default `c(-2, 7.6)`).

- id_cols:

  Character vector of columns used to identify profiles (default
  `c("PEDON_ID","Depth_num","Depth_label","Texture")`).

## Value

A tibble with columns: all `id_cols` present in `newdata`, `pF`,
`matric_head`, and `theta` (predicted volumetric water content in
m3/m3).

## Examples

``` r
# \donttest{
dense <- predict_swrc_dense(fit, newdata = test_df, n_points = 500)
#> Error: object 'fit' not found
# }
```
