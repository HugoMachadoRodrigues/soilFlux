# Predict water content at specific pF or matric-head values

Given a fitted `swrc_fit` object and a new data frame of soil
properties, returns predicted volumetric water content at each supplied
pF (or matric head) value.

## Usage

``` r
predict_swrc(object, newdata, pf = NULL, heads = NULL, ...)
```

## Arguments

- object:

  A `swrc_fit` object returned by
  [`fit_swrc()`](https://hugomachadorodrigues.github.io/soilFlux/reference/fit_swrc.md).

- newdata:

  A data frame with the same covariate columns used during training
  (i.e. `object$x_inputs`). Must have a `matric_head` column **or**
  supply `pf` directly.

- pf:

  Optional numeric vector of pF values (overrides `matric_head` in
  `newdata`).

- heads:

  Optional numeric vector of matric heads in cm (overrides `matric_head`
  in `newdata`).

- ...:

  Ignored.

## Value

A numeric vector of predicted theta values (m3/m3), one per row in
`newdata`.

## Examples

``` r
# \donttest{
if (reticulate::py_module_available("tensorflow")) {
  df   <- prepare_swrc_data(swrc_example, depth_col = "depth")
  fit  <- fit_swrc(df,
                   x_inputs = c("clay", "silt", "bd_gcm3", "soc", "Depth_num"),
                   epochs = 2L, verbose = FALSE)
  pred <- predict_swrc(fit, newdata = df)
}
# }
```
