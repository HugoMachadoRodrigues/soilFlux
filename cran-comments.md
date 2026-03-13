# CRAN submission comments — soilFlux 0.1.1

## Test environments

* macOS Tahoe 26.3.1 (aarch64), R 4.5.2 — local devtools::check()
* GitHub Actions: ubuntu-latest (R release, devel, oldrel-1), windows-latest (release), macos-latest (release)

## R CMD check results

0 errors | 0 warnings | 1 note

> checking for future file timestamps ... NOTE
> unable to verify current time

This NOTE is caused by a firewall in the check environment blocking the
time-server lookup. It is unrelated to the package code.

## Notes for CRAN reviewers

### Python / TensorFlow dependency

This package requires Python (>= 3.8) and TensorFlow (>= 2.14) at runtime,
managed via the `reticulate` package. This follows the same pattern as the
CRAN packages `tensorflow` and `keras3`.

* All functions that call TensorFlow are wrapped in `\dontrun{}` in the
  `@examples` sections.
* The vignette uses `eval = FALSE` for all code chunks and shows
  representative pre-computed outputs. It does not require TensorFlow to build.
* Package installation succeeds without Python/TensorFlow installed;
  a clear error message is issued when TF functions are called without a
  valid Python environment.

### Downstream effects

This is a new submission. There are no reverse dependencies.
