# Predict method for swrc_fit

Dispatches to
[`predict_swrc()`](https://hugomachadorodrigues.github.io/soilFlux/reference/predict_swrc.md).

## Usage

``` r
# S3 method for class 'swrc_fit'
predict(object, newdata, pf = NULL, heads = NULL, ...)
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

A numeric vector of predicted volumetric water content values (m3/m3),
one per row in `newdata`.
