# Normalise pF values to \[0, 1\]

Maps the pF domain `[pf_left, pf_right]` linearly to `[0, 1]`. Values
outside the domain are clipped.

## Usage

``` r
pf_normalize(pf, pf_left = -2, pf_right = 7.6)
```

## Arguments

- pf:

  Numeric vector of pF values.

- pf_left:

  Left boundary of the pF domain (default `-2`).

- pf_right:

  Right boundary of the pF domain (default `7.6`).

## Value

Numeric vector in `[0, 1]`.

## Examples

``` r
pf_normalize(c(-2, 0, 4, 7.6))
#> [1] 0.0000000 0.2083333 0.6250000 1.0000000
```
