# Invert a min-max scaling transformation

Converts scaled values back to original units.

## Usage

``` r
invert_minmax(X_scaled, scaler)
```

## Arguments

- X_scaled:

  Numeric matrix (or vector) of scaled values.

- scaler:

  A scaler object returned by
  [`fit_minmax()`](https://hugomachadorodrigues.github.io/soilFlux/reference/fit_minmax.md).

## Value

Numeric matrix in the original (unscaled) units.

## Examples

``` r
df <- data.frame(sand = c(20, 40, 60), clay = c(30, 20, 10))
sc <- fit_minmax(df, c("sand", "clay"))
Xs <- apply_minmax(df, sc)
invert_minmax(Xs, sc)
#>      sand clay
#> [1,]   20   30
#> [2,]   40   20
#> [3,]   60   10
```
