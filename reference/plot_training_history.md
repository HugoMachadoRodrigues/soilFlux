# Plot training loss history

Plots the per-epoch training and (optionally) validation loss from the
`history` slot of a `swrc_fit` object.

## Usage

``` r
plot_training_history(
  fit,
  loss_col = "loss",
  val_col = "val_mse",
  base_size = 12
)
```

## Arguments

- fit:

  A `swrc_fit` object.

- loss_col:

  Column in `fit$history` to display (default `"loss"`).

- val_col:

  Validation loss column (default `"val_mse"`). Pass `NULL` to omit.

- base_size:

  Base font size (default `12`).

## Value

A `ggplot` object.
