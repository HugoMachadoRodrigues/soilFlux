# Create an eager-mode train step function

Returns a closure that, when called with a mini-batch, computes the
combined data + physics loss and applies gradients.

## Usage

``` r
make_train_step(
  theta_model,
  optimizer,
  lambda_wet = 1,
  lambda_dry = 10,
  wet_split_cm = 4.2,
  lambda3 = 1,
  lambda4 = 1000,
  lambda5 = 1000,
  lambda6 = 1,
  res_tensors,
  pf_left = -2,
  pf_right = 7.6
)
```

## Arguments

- theta_model:

  Keras model returned by
  [`build_swrc_model()`](https://hugomachadorodrigues.github.io/soilFlux/reference/build_swrc_model.md)`$theta_model`.

- optimizer:

  A Keras/TF optimizer (e.g. `tf$keras$optimizers$Adam`).

- lambda_wet:

  Weight for wet-end data loss (default `1.0`).

- lambda_dry:

  Weight for dry-end data loss (default `10.0`).

- wet_split_cm:

  Matric head threshold (cm) separating wet/dry (default `4.2`).

- lambda3:

  S1 linearity weight (default `1.0`).

- lambda4:

  S2 non-negativity weight (default `1000.0`).

- lambda5:

  S3 non-positivity weight (default `1000.0`).

- lambda6:

  S4 saturation weight (default `1.0`).

- res_tensors:

  Named list of physics residual tensors (output of
  [`residual_to_tensors()`](https://hugomachadorodrigues.github.io/soilFlux/reference/residual_to_tensors.md)).

- pf_left:

  Left boundary of pF domain (default `-2`).

- pf_right:

  Right boundary of pF domain (default `7.6`).

## Value

A function `f(Xseq, pf_norm_obs, y, sw)` that performs one gradient step
and returns a named list of loss scalars.
