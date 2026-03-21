# Fit a physics-informed CNN1D SWRC model

The main user-facing function for training. Given prepared training and
(optionally) validation data, it builds the model, creates physics
residual sets, runs the training loop with early stopping, and returns a
fitted object for prediction and evaluation.

## Usage

``` r
fit_swrc(
  train_df,
  x_inputs,
  val_df = NULL,
  hidden = c(128L, 64L),
  dropout = 0.1,
  lr = 0.001,
  epochs = 80L,
  batch_size = 256L,
  patience = 5L,
  K = 64L,
  lambdas = norouzi_lambdas("norouzi"),
  S1 = 1500L,
  S2 = 500L,
  S3 = 500L,
  S4 = 1500L,
  pF_lin_min = 5,
  pF_lin_max = 7.6,
  pF0_pos = 6.2,
  pF1_neg = 7.6,
  pF_sat_min = -2,
  pF_sat_max = -0.3,
  wet_split_cm = 4.2,
  w_wet = 1,
  w_dry = 1,
  pf_left = -2,
  pf_right = 7.6,
  seed = 123L,
  verbose = TRUE
)
```

## Arguments

- train_df:

  Data frame for training (output of
  [`prepare_swrc_data()`](https://hugomachadorodrigues.github.io/soilFlux/reference/prepare_swrc_data.md)).

- x_inputs:

  Character vector of covariate column names.

- val_df:

  Optional validation data frame (same structure as `train_df`). If
  `NULL`, early stopping is skipped.

- hidden:

  Integer vector of length 2: Conv1D filter counts (default
  `c(128L, 64L)`).

- dropout:

  Dropout rate (default `0.10`).

- lr:

  Learning rate for the Adam optimizer (default `1e-3`).

- epochs:

  Maximum number of epochs (default `80`).

- batch_size:

  Mini-batch size (default `256`).

- patience:

  Early-stopping patience in multiples of 5 epochs (default `5`).

- K:

  Number of knot points (default `64L`).

- lambdas:

  Named list of loss weights; use
  [`norouzi_lambdas()`](https://hugomachadorodrigues.github.io/soilFlux/reference/norouzi_lambdas.md)
  to generate (default: `norouzi_lambdas("norouzi")`).

- S1, S2, S3, S4:

  Residual set sizes (defaults: 1500, 500, 500, 1500).

- pF_lin_min:

  Lower pF for S1 linearity constraint (default `5.0`).

- pF_lin_max:

  Upper pF for S1 linearity constraint (default `7.6`).

- pF0_pos:

  pF threshold for S2 (default `6.2`).

- pF1_neg:

  pF threshold for S3 (default `7.6`).

- pF_sat_min:

  Lower pF for S4 (default `-2.0`).

- pF_sat_max:

  Upper pF for S4 (default `-0.3`).

- wet_split_cm:

  Matric head (cm) separating wet/dry end (default `4.2`).

- w_wet:

  Sample weight for wet observations (default `1.0`).

- w_dry:

  Sample weight for dry observations (default `1.0`).

- pf_left:

  Left pF domain boundary (default `-2.0`).

- pf_right:

  Right pF domain boundary (default `7.6`).

- seed:

  Random seed (default `123`).

- verbose:

  Logical; print progress (default `TRUE`).

## Value

An S3 object of class `swrc_fit`, a named list containing:

- `theta_model`:

  The fitted Keras model.

- `param_model`:

  The theta_s extractor model.

- `x_inputs`:

  Covariate names used.

- `scaler`:

  Fitted min-max scaler.

- `K`:

  Number of knot points.

- `dk`:

  Knot spacing.

- `knot_grid`:

  Knot positions in \[0, 1\].

- `pf_left`,`pf_right`:

  pF domain boundaries.

- `theta_factor`:

  Unit multiplier for theta.

- `best_epoch`:

  Epoch at which validation loss was minimised.

- `lambdas`:

  Loss weights used during training.

- `history`:

  Data frame of per-epoch training/validation losses.

## Examples

``` r
# \donttest{
fit <- fit_swrc(train_df, x_inputs = c("clay","silt","bd_gcm3","soc","Depth_num"),
               val_df = val_df, epochs = 80, verbose = TRUE)
#> Error: object 'train_df' not found
# }
```
