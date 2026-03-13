# Add texture classification column to a data frame

Add texture classification column to a data frame

## Usage

``` r
add_texture(
  df,
  sand_col = "sand_total",
  silt_col = "silt",
  clay_col = "clay",
  out_col = "Texture"
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

- out_col:

  Name of the output column (default `"Texture"`).

## Value

The input data frame with an additional `out_col` column.

## Examples

``` r
df <- data.frame(sand_total = c(70, 20), silt = c(15, 50), clay = c(15, 30))
add_texture(df)
#>   sand_total silt clay         Texture
#> 1         70   15   15      Sandy Loam
#> 2         20   50   30 Silty Clay Loam
```
