# Build the CNN1D monotone-integral SWRC model

Constructs a Keras model implementing the monotone-integral architecture
of Norouzi et al. (2025). The returned list contains two models that
share weights:

- `theta_model` — full prediction model (pF query + covariates → theta).

- `param_model` — extracts the saturated water content (theta_s) from
  covariates only.

## Usage

``` r
build_swrc_model(n_covariates, hidden = c(128L, 64L), dropout = 0.1, K = 64L)
```

## Arguments

- n_covariates:

  Integer. Number of soil-property covariates (`p`).

- hidden:

  Integer vector of length 2. Number of filters in the first and second
  Conv1D layers (default `c(128L, 64L)`).

- dropout:

  Numeric dropout rate after each Conv1D layer (default `0.10`).

- K:

  Integer. Number of knot points for the cumulative integration grid
  (default `64L`).

## Value

A named list:

- `theta_model`:

  Keras model: inputs `[Xseq_knots, pf_norm]`, output shape `[N, 2]`
  (theta_hat, theta_s).

- `param_model`:

  Keras model: input `Xseq_knots`, output shape `[N, 1]` (theta_s only).

- `K`:

  The `K` value used.

- `dk`:

  The knot spacing `1 / (K - 1)`.

- `knot_grid`:

  Numeric vector of knot positions.

## Examples

``` r
if (FALSE) { # \dontrun{
mod <- build_swrc_model(n_covariates = 9L)
mod$theta_model$summary()
} # }
```
