# Safely compute a TensorFlow gradient

Wraps `tape$gradient()` and returns `tf$zeros_like(x)` on error or when
the result is a Python `None`.

## Usage

``` r
safe_grad(tape, y, x)
```

## Arguments

- tape:

  A `tf$GradientTape` object.

- y:

  The tensor to differentiate.

- x:

  The variable with respect to which to differentiate.

## Value

A TensorFlow tensor (gradient or zeros).
