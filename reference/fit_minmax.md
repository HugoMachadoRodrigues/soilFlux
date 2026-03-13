# Fit a min-max scaler from a training data frame

Computes per-column minimum and range from `df[, cols]`. Constant
columns (range == 0) are assigned a range of 1 to avoid division by
zero.

## Usage

``` r
fit_minmax(df, cols)
```

## Arguments

- df:

  A data frame or tibble.

- cols:

  Character vector of column names to include.

## Value

A list with elements:

- `min`:

  Named numeric vector of per-column minima.

- `rng`:

  Named numeric vector of per-column ranges.

- `cols`:

  The character vector `cols` (stored for later use).

## Examples

``` r
df <- data.frame(sand = c(20, 40, 60), clay = c(30, 20, 10))
sc <- fit_minmax(df, c("sand", "clay"))
sc
#> $min
#> sand clay 
#>   20   10 
#> 
#> $rng
#> sand clay 
#>   40   20 
#> 
#> $cols
#> [1] "sand" "clay"
#> 
```
