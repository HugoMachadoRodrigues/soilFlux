# Plot a soil texture triangle (ternary diagram)

Creates a ternary diagram coloured by a grouping variable using
`ggplot2`. Requires the `ggtern` package (not a hard dependency).

## Usage

``` r
texture_triangle(
  df,
  sand_col = "sand_total",
  silt_col = "silt",
  clay_col = "clay",
  color_col = NULL,
  title = "Soil Texture Triangle",
  point_size = 1.5,
  alpha = 0.6
)
```

## Arguments

- df:

  A data frame.

- sand_col:

  Column name for sand (default `"sand_total"`).

- silt_col:

  Column name for silt (default `"silt"`).

- clay_col:

  Column name for clay (default `"clay"`).

- color_col:

  Column name for colouring points (default `NULL` for a single colour).

- title:

  Plot title.

- point_size:

  Point size (default `1.5`).

- alpha:

  Point transparency (default `0.6`).

## Value

A `ggplot` object (or `ggtern` object if `ggtern` is available).

## Examples

``` r
# \donttest{
if (requireNamespace("ggtern", quietly = TRUE)) {
  df <- data.frame(sand_total = c(70, 20, 10),
                   silt = c(15, 50, 30),
                   clay = c(15, 30, 60),
                   Texture = c("Sand", "Silt Loam", "Clay"))
  p <- texture_triangle(df, color_col = "Texture")
}
# }
```
