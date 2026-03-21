# Plot predicted vs. observed water content

Creates a scatter plot of predicted vs. observed theta with a 1:1 line
and optional regression line, optionally faceted by a grouping variable.

## Usage

``` r
plot_pred_obs(
  df,
  obs_col = "theta_n",
  pred_col = "theta_predicted",
  group_col = NULL,
  show_lm = TRUE,
  show_stats = TRUE,
  ncol = 5L,
  base_size = 12,
  point_alpha = 0.25,
  title = NULL
)
```

## Arguments

- df:

  Data frame containing observed and predicted columns.

- obs_col:

  Column name for observed theta (default `"theta_n"`).

- pred_col:

  Column name for predicted theta (default `"theta_predicted"`).

- group_col:

  Column name for facet grouping (default `NULL`).

- show_lm:

  Logical; add a linear regression line (default `TRUE`).

- show_stats:

  Logical; add R², RMSE, MAE text annotations (default `TRUE`).

- ncol:

  Number of facet columns when `group_col` is supplied (default `5`).

- base_size:

  Base font size (default `12`).

- point_alpha:

  Point transparency (default `0.25`).

- title:

  Plot title (default `NULL`).

## Value

A `ggplot` object.

## Examples

``` r
# \donttest{
df_plot <- data.frame(
  theta_n         = c(0.30, 0.25, 0.20, 0.15, 0.10),
  theta_predicted = c(0.28, 0.26, 0.22, 0.14, 0.11)
)
plot_pred_obs(df_plot)

# }
```
