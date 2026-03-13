# Compute metrics from a swrc_fit on new data

A convenience wrapper that calls
[`predict_swrc()`](https://hugomachadorodrigues.github.io/soilFlux/reference/predict_swrc.md)
and
[`swrc_metrics()`](https://hugomachadorodrigues.github.io/soilFlux/reference/swrc_metrics.md).

## Usage

``` r
evaluate_swrc(object, newdata, obs_col = "theta_n")
```

## Arguments

- object:

  A `swrc_fit` object.

- newdata:

  Data frame with covariate columns and `matric_head` and `theta_n`
  columns.

- obs_col:

  Name of the observed theta column in `newdata` (default `"theta_n"`).

## Value

A tibble with columns `R2`, `RMSE`, `MAE`, `n`.
