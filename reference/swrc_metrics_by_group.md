# Compute regression metrics by group

Applies
[`swrc_metrics()`](https://hugomachadorodrigues.github.io/soilFlux/reference/swrc_metrics.md)
within each level of one or more grouping variables, returning a tidy
data frame.

## Usage

``` r
swrc_metrics_by_group(df, obs_col, pred_col, group_col, na.rm = TRUE)
```

## Arguments

- df:

  A data frame containing observed and predicted columns.

- obs_col:

  Name of the observed-values column (character string).

- pred_col:

  Name of the predicted-values column (character string).

- group_col:

  Character vector of grouping column names.

- na.rm:

  Logical; passed to
  [`swrc_metrics()`](https://hugomachadorodrigues.github.io/soilFlux/reference/swrc_metrics.md)
  (default `TRUE`).

## Value

A tibble with one row per group and columns: grouping variables, `R2`,
`RMSE`, `MAE`, `n`.

## Examples

``` r
df <- data.frame(
  obs  = c(0.30, 0.25, 0.20, 0.15, 0.10, 0.35, 0.28, 0.18),
  pred = c(0.28, 0.26, 0.22, 0.14, 0.11, 0.33, 0.27, 0.19),
  texture = c("Clay","Clay","Clay","Clay","Clay","Sand","Sand","Sand")
)
swrc_metrics_by_group(df, "obs", "pred", "texture")
#>   texture        R2       RMSE        MAE n
#> 1    Clay 0.9560000 0.01483240 0.01400000 5
#> 2    Sand 0.9589041 0.01414214 0.01333333 3
```
