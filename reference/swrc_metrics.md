# Compute regression metrics for SWRC predictions

Returns R², RMSE, and MAE between observed and predicted volumetric
water content (or any continuous response).

## Usage

``` r
swrc_metrics(observed, predicted, na.rm = TRUE)
```

## Arguments

- observed:

  Numeric vector of observed values.

- predicted:

  Numeric vector of predicted values (same length).

- na.rm:

  Logical; remove `NA` pairs before computing (default `TRUE`).

## Value

A
[`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
with one row and columns `R2`, `RMSE`, `MAE`, `n` (number of non-missing
pairs).

## Examples

``` r
obs  <- c(0.30, 0.25, 0.20, 0.15, 0.10)
pred <- c(0.28, 0.26, 0.22, 0.14, 0.11)
swrc_metrics(obs, pred)
#> # A tibble: 1 × 4
#>      R2   RMSE    MAE     n
#>   <dbl>  <dbl>  <dbl> <int>
#> 1 0.956 0.0148 0.0140     5
```
