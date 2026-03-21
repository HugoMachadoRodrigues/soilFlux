# CRAN submission comments — soilFlux 0.1.5

## Resubmission

This is a resubmission addressing all points raised by the CRAN reviewer:

1. **Single quotes in DESCRIPTION**: removed quotes around acronyms (`CNN1D-PINN`,
   `SWRC`, `pF`). Single quotes are now used only for package/software names, as
   required.

2. **Reference linking in DESCRIPTION**: added `<doi:10.1029/2024WR038149>` to
   the Norouzi et al. (2025) reference. Also corrected the journal name
   (*Water Resources Research*, not *Journal of Hydrology*).

3. **Missing `\value` tags**: added `\value` documentation to all flagged `.Rd`
   files: `predict.Rd`, `predict.swrc_fit.Rd`, `print.swrc_fit.Rd`, and
   `summary.swrc_fit.Rd`.

4. **`\dontrun{}` → `\donttest{}`**: replaced all occurrences of `\dontrun{}`
   with `\donttest{}` throughout the package. Examples require TensorFlow/Python
   at runtime but are not inherently unrunnable.

5. **Writing to home filespace (R/io.R)**: removed the default
   `dir = "./models/swrc"` path from `save_swrc_model()`. The `dir` argument is
   now required (no default). Examples use `tempdir()`.

## Test environments

* macOS Sequoia 15.x (aarch64), R 4.5.x — local `devtools::check()`
* GitHub Actions: ubuntu-latest (R release, devel, oldrel-1),
  windows-latest (release), macos-latest (release)

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

* All functions that call TensorFlow are wrapped in `\donttest{}` in the
  `@examples` sections.
* The vignette uses `eval = FALSE` for all code chunks and shows
  representative pre-computed outputs. It does not require TensorFlow to build.
* A pre-built HTML version of the vignette is included in `inst/doc/` so
  that `R CMD check --no-build-vignettes` finds it on all platforms.
* Package installation succeeds without Python/TensorFlow installed;
  a clear error message is issued when TF functions are called without a
  valid Python environment.

### Downstream effects

This is a new submission. There are no reverse dependencies.
