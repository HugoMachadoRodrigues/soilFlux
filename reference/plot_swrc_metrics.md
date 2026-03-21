# Plot model performance metric comparison

Creates a bar chart comparing R², RMSE, and MAE across multiple models
or configurations.

## Usage

``` r
plot_swrc_metrics(
  metrics_df,
  model_col = "model",
  palette = "Blues",
  base_size = 12,
  title = NULL
)
```

## Arguments

- metrics_df:

  A data frame with columns `model` (character/factor), `R2`, `RMSE`,
  `MAE`. Typically produced by stacking the output of
  [`swrc_metrics()`](https://hugomachadorodrigues.github.io/soilFlux/reference/swrc_metrics.md).

- model_col:

  Column name for the model identifier (default `"model"`).

- palette:

  RColorBrewer palette (default `"Blues"`).

- base_size:

  Base font size (default `12`).

- title:

  Plot title (default `NULL`).

## Value

A `ggplot` object.

## Examples

``` r
# \donttest{
m1 <- swrc_metrics(c(0.30, 0.25, 0.20), c(0.28, 0.26, 0.22)) |>
  dplyr::mutate(model = "Model 1")
m2 <- swrc_metrics(c(0.30, 0.25, 0.20), c(0.29, 0.24, 0.21)) |>
  dplyr::mutate(model = "Model 2")
plot_swrc_metrics(dplyr::bind_rows(m1, m2))

# }
```
