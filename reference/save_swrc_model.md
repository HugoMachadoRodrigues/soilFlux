# Save a fitted SWRC model to disk

Saves the Keras model weights as an HDF5 file and the R metadata
(scalers, hyperparameters, etc.) as an `.rds` file inside `dir`.

## Usage

``` r
save_swrc_model(fit, dir = "./models/swrc", name = "swrc_model")
```

## Arguments

- fit:

  A `swrc_fit` object returned by
  [`fit_swrc()`](https://hugomachadorodrigues.github.io/soilFlux/reference/fit_swrc.md).

- dir:

  Directory where the model will be saved. Created if it does not exist
  (default `"./models/swrc"`).

- name:

  Stem name for the output files (default `"swrc_model"`).

## Value

Invisibly returns a named list with paths to the two files:

- `weights_path`:

  Path to the `.weights.h5` file.

- `meta_path`:

  Path to the `.rds` metadata file.

## Examples

``` r
if (FALSE) { # \dontrun{
save_swrc_model(fit, dir = "./models", name = "model_5")
} # }
```
