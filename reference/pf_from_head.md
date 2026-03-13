# Convert matric head (cm) to pF

Convert matric head (cm) to pF

## Usage

``` r
pf_from_head(h_cm)
```

## Arguments

- h_cm:

  Numeric vector of matric head values in cm (positive).

## Value

Numeric vector of pF values (\\\log\_{10}(h)\\).

## Examples

``` r
pf_from_head(c(1, 10, 100, 1000, 15850))
#> [1] 0.000000 1.000000 2.000000 3.000000 4.200029
```
