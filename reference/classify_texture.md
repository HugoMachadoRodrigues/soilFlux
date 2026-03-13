# Classify soil texture according to the USDA system

Returns the USDA texture class name for each row based on the sand,
silt, and clay fractions. Inputs are expected in per-cent (0–100) and
must sum to approximately 100.

## Usage

``` r
classify_texture(sand, silt, clay, tol = 1)
```

## Arguments

- sand:

  Numeric vector: sand content (%).

- silt:

  Numeric vector: silt content (%).

- clay:

  Numeric vector: clay content (%).

- tol:

  Tolerance for the 100 % sum check (default `1.0`).

## Value

Character vector of USDA texture class names. Returns `NA` for rows
where values are missing or do not sum to approximately 100.

## Examples

``` r
classify_texture(sand = c(70, 20, 10, 40),
                silt = c(15, 50, 30, 40),
                clay = c(15, 30, 60, 20))
#> [1] "Sandy Loam"      "Silty Clay Loam" "Clay"            "Loam"           
```
