# Return default Norouzi et al. (2025) loss weights (lambdas)

Table 1 of Norouzi et al. (2025) defines six loss-weight
hyperparameters. This function returns them as a named list that can be
passed to
[`fit_swrc()`](https://hugomachadorodrigues.github.io/soilFlux/reference/fit_swrc.md)
and
[`compute_physics_loss()`](https://hugomachadorodrigues.github.io/soilFlux/reference/compute_physics_loss.md).

## Usage

``` r
norouzi_lambdas(config = c("norouzi", "smooth"))
```

## Arguments

- config:

  Character string; either `"norouzi"` (exact replication, default) or
  `"smooth"` (lambda3 = 10 for a smoother dry-end).

## Value

A named list:

- `lambda_wet`:

  Weight for wet-end data loss (lambda1 = 1).

- `lambda_dry`:

  Weight for dry-end data loss (lambda2 = 10).

- `lambda3`:

  S1 dry-end linearity (lambda3 = 1 or 10).

- `lambda4`:

  S2 non-negativity at pF0 (lambda4 = 1000).

- `lambda5`:

  S3 non-positivity at pF1 (lambda5 = 1000).

- `lambda6`:

  S4 saturated-plateau flatness (lambda6 = 1).

## Examples

``` r
norouzi_lambdas()
#> $lambda_wet
#> [1] 1
#> 
#> $lambda_dry
#> [1] 10
#> 
#> $lambda4
#> [1] 1000
#> 
#> $lambda5
#> [1] 1000
#> 
#> $lambda6
#> [1] 1
#> 
#> $lambda3
#> [1] 1
#> 
norouzi_lambdas("smooth")
#> $lambda_wet
#> [1] 1
#> 
#> $lambda_dry
#> [1] 10
#> 
#> $lambda4
#> [1] 1000
#> 
#> $lambda5
#> [1] 1000
#> 
#> $lambda6
#> [1] 1
#> 
#> $lambda3
#> [1] 10
#> 
```
