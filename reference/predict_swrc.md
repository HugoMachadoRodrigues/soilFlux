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
if (FALSE) { # \dontrun{
fit  <- fit_swrc(train_df, x_inputs = c("clay","silt","bd_gcm3","soc","Depth_num"),
                val_df = val_df)
pred <- predict_swrc(fit, newdata = test_df)
} # }
```
