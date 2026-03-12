#' @title Min-max feature scaling
#' @name scale
#' @description Fit and apply a column-wise min-max scaler to a data frame
#'   or matrix, mapping each feature to \[0, 1\].
NULL

#' Fit a min-max scaler from a training data frame
#'
#' Computes per-column minimum and range from `df[, cols]`.
#' Constant columns (range == 0) are assigned a range of 1 to avoid
#' division by zero.
#'
#' @param df   A data frame or tibble.
#' @param cols Character vector of column names to include.
#'
#' @return A list with elements:
#'   \describe{
#'     \item{`min`}{Named numeric vector of per-column minima.}
#'     \item{`rng`}{Named numeric vector of per-column ranges.}
#'     \item{`cols`}{The character vector `cols` (stored for later use).}
#'   }
#'
#' @examples
#' df <- data.frame(sand = c(20, 40, 60), clay = c(30, 20, 10))
#' sc <- fit_minmax(df, c("sand", "clay"))
#' sc
#'
#' @importFrom dplyr select across everything mutate
#' @export
fit_minmax <- function(df, cols) {
  stopifnot(is.data.frame(df), is.character(cols))
  missing_cols <- setdiff(cols, names(df))
  if (length(missing_cols) > 0L)
    rlang::abort(paste("Columns not found in df:", paste(missing_cols, collapse = ", ")))

  X  <- as.matrix(dplyr::mutate(
    dplyr::select(df, dplyr::all_of(cols)),
    dplyr::across(dplyr::everything(), as.numeric)
  ))
  mn <- apply(X, 2L, min, na.rm = TRUE)
  mx <- apply(X, 2L, max, na.rm = TRUE)
  rg <- mx - mn
  rg[rg == 0] <- 1

  list(min = mn, rng = rg, cols = cols)
}

#' Apply a fitted min-max scaler to a data frame
#'
#' Scales `df[, scaler$cols]` using the precomputed min/range.
#' Returns a numeric matrix with the same column order as `scaler$cols`.
#'
#' @param df     A data frame or tibble.
#' @param scaler A scaler object returned by [fit_minmax()].
#'
#' @return A numeric matrix scaled to approximately \[0, 1\] per column.
#'   Columns correspond to `scaler$cols`.
#'
#' @examples
#' df_train <- data.frame(sand = c(20, 40, 60), clay = c(30, 20, 10))
#' sc       <- fit_minmax(df_train, c("sand", "clay"))
#' df_new   <- data.frame(sand = c(50, 25), clay = c(15, 28))
#' apply_minmax(df_new, sc)
#'
#' @importFrom dplyr select across everything mutate
#' @export
apply_minmax <- function(df, scaler) {
  stopifnot(is.list(scaler), all(c("min", "rng", "cols") %in% names(scaler)))
  cols <- scaler$cols
  missing_cols <- setdiff(cols, names(df))
  if (length(missing_cols) > 0L)
    rlang::abort(paste("Columns not found in df:", paste(missing_cols, collapse = ", ")))

  X <- as.matrix(dplyr::mutate(
    dplyr::select(df, dplyr::all_of(cols)),
    dplyr::across(dplyr::everything(), as.numeric)
  ))
  X <- sweep(X, 2L, scaler$min[cols], "-")
  X <- sweep(X, 2L, scaler$rng[cols], "/")
  X
}

#' Invert a min-max scaling transformation
#'
#' Converts scaled values back to original units.
#'
#' @param X_scaled Numeric matrix (or vector) of scaled values.
#' @param scaler   A scaler object returned by [fit_minmax()].
#'
#' @return Numeric matrix in the original (unscaled) units.
#'
#' @examples
#' df <- data.frame(sand = c(20, 40, 60), clay = c(30, 20, 10))
#' sc <- fit_minmax(df, c("sand", "clay"))
#' Xs <- apply_minmax(df, sc)
#' invert_minmax(Xs, sc)
#'
#' @export
invert_minmax <- function(X_scaled, scaler) {
  stopifnot(is.list(scaler), all(c("min", "rng", "cols") %in% names(scaler)))
  X <- as.matrix(X_scaled)
  cols <- scaler$cols
  X <- sweep(X, 2L, scaler$rng[cols], "*")
  X <- sweep(X, 2L, scaler$min[cols], "+")
  X
}
