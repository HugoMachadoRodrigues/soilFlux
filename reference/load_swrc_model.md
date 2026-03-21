# Load a previously saved SWRC model from disk

Reconstructs the CNN1D Keras model from the saved weights and metadata
and returns a `swrc_fit`-compatible list that can be passed to
[`predict_swrc()`](https://hugomachadorodrigues.github.io/soilFlux/reference/predict_swrc.md),
[`predict_swrc_dense()`](https://hugomachadorodrigues.github.io/soilFlux/reference/predict_swrc_dense.md),
etc.

## Usage

``` r
load_swrc_model(dir = "./models/swrc", name = "swrc_model")
```

## Arguments

- dir:

  Directory containing the saved files (default `"./models/swrc"`).

- name:

  Stem name used when saving (default `"swrc_model"`).

## Value

A `swrc_fit` object (without `history` or `param_model`).

## Examples

``` r
# \donttest{
if (reticulate::py_module_available("tensorflow")) {
  df  <- prepare_swrc_data(swrc_example, depth_col = "depth")
  fit <- fit_swrc(df,
                  x_inputs = c("clay", "silt", "bd_gcm3", "soc", "Depth_num"),
                  epochs = 2L, verbose = FALSE)
  save_swrc_model(fit, dir = tempdir(), name = "model_test")
  fit2 <- load_swrc_model(tempdir(), "model_test")
}
# }
```
