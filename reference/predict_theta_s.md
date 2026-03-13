# Extract saturated water content (theta_s) from covariates

Uses the `param_model` (which maps covariate inputs to theta_s) to
extract the modelled saturated water content for each row of `newdata`.

## Usage

``` r
predict_theta_s(object, newdata)
```

## Arguments

- object:

  A `swrc_fit` object.

- newdata:

  Data frame with covariate columns.

## Value

Numeric vector of theta_s values (m3/m3).
