# Parse depth column in a data frame

Applies
[`parse_depth()`](https://hugomachadorodrigues.github.io/soilFlux/reference/parse_depth.md)
row-wise and appends `Depth_num` and `Depth_label` columns.

## Usage

``` r
parse_depth_column(df, depth_col = "depth")
```

## Arguments

- df:

  A data frame.

- depth_col:

  Name of the depth column (character string).

## Value

The input data frame with two extra columns: `Depth_num` (numeric
midpoint) and `Depth_label` (factor, ordered by depth).

## Examples

``` r
df <- data.frame(depth = c("0-5", "5-15", "15-30"), x = 1:3)
parse_depth_column(df, "depth")
#>   depth x Depth_num Depth_label
#> 1   0-5 1       2.5      0-5 cm
#> 2  5-15 2      10.0     5-15 cm
#> 3 15-30 3      22.5    15-30 cm
```
