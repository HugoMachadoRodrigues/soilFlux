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
fit <- load_swrc_model(tempdir(), "model_5")
#> Error in load_swrc_model(tempdir(), "model_5"): Weights file not found: /tmp/RtmpLpxlIc/model_5.weights.h5
pred <- predict_swrc(fit, newdata = test_df)
#> Error: object 'fit' not found
# }
```
