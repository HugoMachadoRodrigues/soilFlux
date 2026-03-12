#' @title Utility functions for soilFlux
#' @name utils
#' @description Internal and exported helpers for pF conversion,
#'   depth parsing, and unit detection.
NULL

# ---------------------------------------------------------------------------
# pF / matric-head conversion
# ---------------------------------------------------------------------------

#' Convert matric head (cm) to pF
#'
#' @param h_cm Numeric vector of matric head values in cm (positive).
#'
#' @return Numeric vector of pF values (\eqn{\log_{10}(h)}).
#'
#' @examples
#' pf_from_head(c(1, 10, 100, 1000, 15850))
#'
#' @export
pf_from_head <- function(h_cm) {
  h_cm <- as.numeric(h_cm)
  log10(pmax(h_cm, 1e-6))
}

#' Convert pF to matric head (cm)
#'
#' @param pf Numeric vector of pF values.
#'
#' @return Numeric vector of matric head values in cm.
#'
#' @examples
#' head_from_pf(c(0, 1, 2, 3, 4.2))
#'
#' @export
head_from_pf <- function(pf) {
  10^as.numeric(pf)
}

#' Normalise pF values to \[0, 1\]
#'
#' Maps the pF domain `[pf_left, pf_right]` linearly to `[0, 1]`.
#' Values outside the domain are clipped.
#'
#' @param pf      Numeric vector of pF values.
#' @param pf_left  Left boundary of the pF domain (default `-2`).
#' @param pf_right Right boundary of the pF domain (default `7.6`).
#'
#' @return Numeric vector in `[0, 1]`.
#'
#' @examples
#' pf_normalize(c(-2, 0, 4, 7.6))
#'
#' @export
pf_normalize <- function(pf, pf_left = -2.0, pf_right = 7.6) {
  pf <- as.numeric(pf)
  rng <- pf_right - pf_left
  stopifnot(rng > 0)
  (pf - pf_left) / rng
}

#' Normalise matric head (cm) to the pF domain
#'
#' Convenience wrapper: converts head to pF then normalises.
#'
#' @param h_cm    Numeric vector of matric heads in cm.
#' @param pf_left  Left boundary (default `-2`).
#' @param pf_right Right boundary (default `7.6`).
#'
#' @return Numeric vector in `[0, 1]`.
#'
#' @examples
#' head_normalize(c(1, 10, 100, 15850))
#'
#' @export
head_normalize <- function(h_cm, pf_left = -2.0, pf_right = 7.6) {
  pf_normalize(pf_from_head(h_cm), pf_left = pf_left, pf_right = pf_right)
}

# ---------------------------------------------------------------------------
# Depth parsing
# ---------------------------------------------------------------------------

#' Parse a soil depth string into midpoint and label
#'
#' Accepts strings of the form `"0-5"`, `"5-15"`, `"100"`, etc. and returns
#' the numeric midpoint and a human-readable label (e.g. `"0-5 cm"`).
#'
#' @param s A character string describing a depth interval or single depth.
#'
#' @return A named list with elements:
#'   \describe{
#'     \item{`mid`}{Numeric midpoint in cm.}
#'     \item{`label`}{Character label, e.g. `"0-5 cm"`.}
#'   }
#'
#' @examples
#' parse_depth("0-5")
#' parse_depth("100-200")
#' parse_depth("30")
#'
#' @importFrom stringr str_extract_all
#' @export
parse_depth <- function(s) {
  v <- as.numeric(stringr::str_extract_all(as.character(s), "\\d+\\.?\\d*")[[1]])
  if (length(v) == 2L) {
    list(mid = mean(v), label = paste0(v[1], "-", v[2], " cm"))
  } else if (length(v) == 1L) {
    list(mid = v[1], label = paste0(v[1], " cm"))
  } else {
    list(mid = NA_real_, label = NA_character_)
  }
}

#' Parse depth column in a data frame
#'
#' Applies [parse_depth()] row-wise and appends `Depth_num` and
#' `Depth_label` columns.
#'
#' @param df        A data frame.
#' @param depth_col Name of the depth column (character string).
#'
#' @return The input data frame with two extra columns:
#'   `Depth_num` (numeric midpoint) and `Depth_label` (factor, ordered by
#'   depth).
#'
#' @examples
#' df <- data.frame(depth = c("0-5", "5-15", "15-30"), x = 1:3)
#' parse_depth_column(df, "depth")
#'
#' @importFrom purrr map map_dbl map_chr
#' @importFrom dplyr mutate distinct arrange pull
#' @export
parse_depth_column <- function(df, depth_col = "depth") {
  stopifnot(depth_col %in% names(df))
  parsed      <- purrr::map(df[[depth_col]], parse_depth)
  df$Depth_num   <- purrr::map_dbl(parsed, "mid")
  df$Depth_label <- purrr::map_chr(parsed, "label")

  # order levels by midpoint
  lvls <- df |>
    dplyr::distinct(Depth_label, Depth_num) |>
    dplyr::arrange(Depth_num) |>
    dplyr::pull(Depth_label)

  df$Depth_label <- factor(df$Depth_label, levels = lvls)
  df
}

# ---------------------------------------------------------------------------
# Unit detection / correction
# ---------------------------------------------------------------------------

#' Detect and correct bulk-density units
#'
#' If the median raw value is > 10 it is assumed to be in kg/m3 and is
#' divided by 100 to convert to g/cm3.
#'
#' @param bd_raw Numeric vector of raw bulk-density values.
#'
#' @return Numeric vector in g/cm3.
#'
#' @examples
#' fix_bd_units(c(1.2, 1.45, 1.3))   # already g/cm3
#' fix_bd_units(c(120, 145, 130))    # kg/m3 -> g/cm3
#'
#' @export
fix_bd_units <- function(bd_raw) {
  bd <- as.numeric(bd_raw)
  if (stats::median(bd, na.rm = TRUE) > 10) bd <- bd / 100
  bd
}

#' Detect theta unit scale factor
#'
#' Returns 100 if the maximum value suggests percentage units (> 1.5),
#' otherwise returns 1 (m3/m3 assumed).
#'
#' @param theta_vec Numeric vector of volumetric water content values.
#'
#' @return Numeric scalar: 100 (percentage) or 1 (m3/m3).
#'
#' @examples
#' theta_unit_factor(c(0.1, 0.35, 0.5))  # returns 1
#' theta_unit_factor(c(10, 35, 50))       # returns 100
#'
#' @export
theta_unit_factor <- function(theta_vec) {
  mx <- max(as.numeric(theta_vec), na.rm = TRUE)
  if (is.finite(mx) && mx > 1.5) 100 else 1
}

# ---------------------------------------------------------------------------
# Gradient helper (safe for TensorFlow)
# ---------------------------------------------------------------------------

#' Safely compute a TensorFlow gradient
#'
#' Wraps `tape$gradient()` and returns `tf$zeros_like(x)` on error or
#' when the result is a Python `None`.
#'
#' @param tape A `tf$GradientTape` object.
#' @param y    The tensor to differentiate.
#' @param x    The variable with respect to which to differentiate.
#'
#' @return A TensorFlow tensor (gradient or zeros).
#'
#' @keywords internal
safe_grad <- function(tape, y, x) {
  tf <- tensorflow::tf
  g  <- tryCatch(tape$gradient(y, x), error = function(e) NULL)
  if (is.null(g) || .is_py_none(g)) tf$zeros_like(x) else g
}

#' @keywords internal
.is_py_none <- function(x) {
  if (is.null(x)) return(TRUE)
  if (exists("py_is_null_xptr", where = asNamespace("reticulate"),
             inherits = FALSE))
    return(reticulate::py_is_null_xptr(x))
  FALSE
}
