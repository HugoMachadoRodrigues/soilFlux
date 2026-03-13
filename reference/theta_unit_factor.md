# Detect theta unit scale factor

Returns 100 if the maximum value suggests percentage units (\> 1.5),
otherwise returns 1 (m3/m3 assumed).

## Usage

``` r
theta_unit_factor(theta_vec)
```

## Arguments

- theta_vec:

  Numeric vector of volumetric water content values.

## Value

Numeric scalar: 100 (percentage) or 1 (m3/m3).

## Examples

``` r
theta_unit_factor(c(0.1, 0.35, 0.5))  # returns 1
#> [1] 1
theta_unit_factor(c(10, 35, 50))       # returns 100
#> [1] 100
```
