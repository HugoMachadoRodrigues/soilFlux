# Parse a soil depth string into midpoint and label

Accepts strings of the form `"0-5"`, `"5-15"`, `"100"`, etc. and returns
the numeric midpoint and a human-readable label (e.g. `"0-5 cm"`).

## Usage

``` r
parse_depth(s)
```

## Arguments

- s:

  A character string describing a depth interval or single depth.

## Value

A named list with elements:

- `mid`:

  Numeric midpoint in cm.

- `label`:

  Character label, e.g. `"0-5 cm"`.

## Examples

``` r
parse_depth("0-5")
#> $mid
#> [1] 2.5
#> 
#> $label
#> [1] "0-5 cm"
#> 
parse_depth("100-200")
#> $mid
#> [1] 150
#> 
#> $label
#> [1] "100-200 cm"
#> 
parse_depth("30")
#> $mid
#> [1] 30
#> 
#> $label
#> [1] "30 cm"
#> 
```
