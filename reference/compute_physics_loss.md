# Compute the physics-informed residual loss (Norouzi et al. 2025)

Evaluates four physics constraints against the current model weights:

- S1 (L_lin):

  Second derivative \\\|\partial^2\theta/\partial pF^2\|\\ in the dry
  end \\pF \in \[5, 7.6\]\\ should be near zero (linearity).

- S2 (L_pos):

  \\\theta(pF = 6.2) \geq 0\\ (non-negativity).

- S3 (L_neg):

  \\\theta(pF = 7.6) \leq 0\\ (non-positivity).

- S4 (L_sat):

  First derivative \\\|\partial\theta/\partial pF\|\\ near zero in the
  saturated plateau \\pF \in \[-2, -0.3\]\\.

## Usage

``` r
compute_physics_loss(
  theta_model,
  res_tensors,
  lambda3 = 1,
  lambda4 = 1000,
  lambda5 = 1000,
  lambda6 = 1,
  pf_left = -2,
  pf_right = 7.6,
  training = TRUE
)
```

## Arguments

- theta_model:

  A Keras model with two inputs: `Xseq` and `pf_norm`.

- res_tensors:

  A named list with four sublists (`set1` – `set4`), each containing
  `Xseq` and `pf` tensors (output of
  [`residual_to_tensors()`](https://hugomachadorodrigues.github.io/soilFlux/reference/residual_to_tensors.md)).

- lambda3:

  Weight for S1 linearity loss (default 1.0).

- lambda4:

  Weight for S2 non-negativity loss (default 1000.0).

- lambda5:

  Weight for S3 non-positivity loss (default 1000.0).

- lambda6:

  Weight for S4 saturation loss (default 1.0).

- pf_left:

  Left boundary of the normalised pF domain (default -2).

- pf_right:

  Right boundary (default 7.6).

- training:

  Logical passed to the model call (default `TRUE`).

## Value

A named list of TensorFlow scalars: `L_phys`, `L_lin`, `L_pos`, `L_neg`,
`L_sat`.
