# Build a sequence array for one or more soil profiles

Each row of `df_profiles` (one profile) is expanded over a pF grid to
produce the `[N_profiles * N_pf, K, p+1]` array needed for dense curve
prediction.

## Usage

``` r
make_profile_array(
  df_profiles,
  x_inputs,
  scaler,
  K = 64L,
  knot_grid = seq(0, 1, length.out = K)
)
```

## Arguments

- df_profiles:

  Data frame with one row per profile (unique PEDON × depth
  combination).

- x_inputs:

  Character vector of covariate names.

- scaler:

  Fitted scaler from
  [`fit_minmax()`](https://hugomachadorodrigues.github.io/soilFlux/reference/fit_minmax.md).

- K:

  Number of knots (default `64L`).

- knot_grid:

  Knot positions (default `seq(0,1,length.out=K)`).

## Value

Named list:

- `Xseq`:

  3-D array \[Np, K, p+1\].

- `Np`:

  Number of profiles.

- `p`:

  Number of covariates.
