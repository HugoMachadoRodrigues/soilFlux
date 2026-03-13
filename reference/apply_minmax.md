# Apply a fitted min-max scaler to a data frame

Scales `df[, scaler$cols]` using the precomputed min/range. Returns a
numeric matrix with the same column order as `scaler$cols`.

## Usage

``` r
apply_minmax(df, scaler)
```

## Arguments

- df:

  A data frame or tibble.

- scaler:

  A scaler object returned by
  [`fit_minmax()`](https://hugomachadorodrigues.github.io/soilFlux/reference/fit_minmax.md).

## Value

A numeric matrix scaled to approximately \[0, 1\] per column. Columns
correspond to `scaler$cols`.

## Examples

``` r
df_train <- data.frame(sand = c(20, 40, 60), clay = c(30, 20, 10))
sc       <- fit_minmax(df_train, c("sand", "clay"))
df_new   <- data.frame(sand = c(50, 25), clay = c(15, 28))
apply_minmax(df_new, sc)
#>       sand clay
#> [1,] 0.750 0.25
#> [2,] 0.125 0.90
```
