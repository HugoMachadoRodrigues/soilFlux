# Convert residual point sets to TensorFlow tensors

Takes one residual data frame (as returned by
[`build_residual_sets()`](https://hugomachadorodrigues.github.io/soilFlux/reference/build_residual_sets.md))
and builds the 3-D sequence array `Xseq` (shape `[N, K, p+1]`) and the
`pf` tensor (shape `[N, 1]`) needed by the CNN1D model.

## Usage

``` r
residual_to_tensors(
  df_res,
  scaler,
  K = 64L,
  knot_grid = seq(0, 1, length.out = K),
  pf_left = -2,
  pf_right = 7.6
)
```

## Arguments

- df_res:

  A residual data frame (one of `set1` – `set4`).

- scaler:

  A scaler object from
  [`fit_minmax()`](https://hugomachadorodrigues.github.io/soilFlux/reference/fit_minmax.md).

- K:

  Number of knot points (default 64).

- knot_grid:

  Numeric vector of knot positions in \[0, 1\] (default
  `seq(0, 1, length.out = K)`).

- pf_left:

  Left boundary of the pF domain (default -2).

- pf_right:

  Right boundary of the pF domain (default 7.6).

## Value

A named list with TensorFlow tensors:

- `Xseq`:

  float32 tensor, shape \[N, K, p+1\].

- `pf`:

  float32 tensor, shape \[N, 1\].
