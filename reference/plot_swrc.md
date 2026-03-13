# Plot soil water retention curves (SWRC)

Creates a `ggplot2` figure showing continuous SWRC predictions (lines)
optionally overlaid with observed data points.

## Usage

``` r
plot_swrc(
  pred_curves,
  obs_points = NULL,
  curve_col = "theta",
  obs_col = "theta_n",
  group_col = "PEDON_ID",
  facet_row = NULL,
  facet_col = NULL,
  x_limits = NULL,
  y_limits = c(-0.25, 7.75),
  line_colour = "steelblue4",
  point_colour = "black",
  base_size = 12,
  title = NULL
)
```

## Arguments

- pred_curves:

  A data frame (or tibble) of dense curve predictions, typically
  returned by
  [`predict_swrc_dense()`](https://hugomachadorodrigues.github.io/soilFlux/reference/predict_swrc_dense.md).
  Must contain columns `pF` and `theta`.

- obs_points:

  Optional data frame of observed data. Must contain `pF` and `theta`
  columns (or `matric_head` and a theta column).

- curve_col:

  Column in `pred_curves` for the predicted theta (default `"theta"`).

- obs_col:

  Column in `obs_points` for observed theta (default `"theta_n"`).

- group_col:

  Column name used to distinguish individual profiles in `pred_curves`
  (default `"PEDON_ID"`).

- facet_row:

  Column for facet rows (default `NULL`).

- facet_col:

  Column for facet columns (default `NULL`).

- x_limits:

  Numeric vector of length 2 for the x-axis (theta) range (default
  `NULL`, auto).

- y_limits:

  Numeric vector of length 2 for the y-axis (pF) range (default
  `c(-0.25, 7.75)`).

- line_colour:

  Colour of the predicted curve lines (default `"steelblue4"`).

- point_colour:

  Colour of the observed data points (default `"black"`).

- base_size:

  Base font size for `theme_bw` (default `12`).

- title:

  Plot title (default `NULL`).

## Value

A `ggplot` object.

## Examples

``` r
if (FALSE) { # \dontrun{
dense <- predict_swrc_dense(fit, newdata = test_df)
plot_swrc(dense, obs_points = test_df,
          facet_row = "Depth_label", facet_col = "Texture")
} # }
```
