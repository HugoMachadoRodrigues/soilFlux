# Detect and correct bulk-density units

If the median raw value is \> 10 it is assumed to be in kg/m3 and is
divided by 100 to convert to g/cm3.

## Usage

``` r
fix_bd_units(bd_raw)
```

## Arguments

- bd_raw:

  Numeric vector of raw bulk-density values.

## Value

Numeric vector in g/cm3.

## Examples

``` r
fix_bd_units(c(1.2, 1.45, 1.3))   # already g/cm3
#> [1] 1.20 1.45 1.30
fix_bd_units(c(120, 145, 130))    # kg/m3 -> g/cm3
#> [1] 1.20 1.45 1.30
```
