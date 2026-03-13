# Normalise matric head (cm) to the pF domain

Convenience wrapper: converts head to pF then normalises.

## Usage

``` r
head_normalize(h_cm, pf_left = -2, pf_right = 7.6)
```

## Arguments

- h_cm:

  Numeric vector of matric heads in cm.

- pf_left:

  Left boundary (default `-2`).

- pf_right:

  Right boundary (default `7.6`).

## Value

Numeric vector in `[0, 1]`.

## Examples

``` r
head_normalize(c(1, 10, 100, 15850))
#> [1] 0.2083333 0.3125000 0.4166667 0.6458364
```
