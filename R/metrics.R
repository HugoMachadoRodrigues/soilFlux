#' @title Performance metrics for SWRC models
#' @name metrics
#' @description Functions to compute R², RMSE, and MAE for soil water
#'   content predictions.
NULL

#' Compute regression metrics for SWRC predictions
#'
#' Returns R², RMSE, and MAE between observed and predicted volumetric
#' water content (or any continuous response).
#'
#' @param observed  Numeric vector of observed values.
#' @param predicted Numeric vector of predicted values (same length).
#' @param na.rm     Logical; remove `NA` pairs before computing (default
#'   `TRUE`).
#'
#' @return A [tibble::tibble()] with one row and columns `R2`, `RMSE`,
#'   `MAE`, `n` (number of non-missing pairs).
#'
#' @examples
#' obs  <- c(0.30, 0.25, 0.20, 0.15, 0.10)
#' pred <- c(0.28, 0.26, 0.22, 0.14, 0.11)
#' swrc_metrics(obs, pred)
#'
#' @importFrom tibble tibble
#' @export
swrc_metrics <- function(observed, predicted, na.rm = TRUE) {
  stopifnot(length(observed) == length(predicted))

  if (na.rm) {
    ok        <- is.finite(observed) & is.finite(predicted)
    observed  <- observed[ok]
    predicted <- predicted[ok]
  }

  n      <- length(observed)
  ss_res <- sum((observed - predicted)^2)
  ss_tot <- sum((observed - mean(observed))^2)
  r2     <- if (ss_tot == 0) NA_real_ else 1 - ss_res / ss_tot
  rmse   <- sqrt(mean((observed - predicted)^2))
  mae    <- mean(abs(observed - predicted))

  tibble::tibble(R2 = r2, RMSE = rmse, MAE = mae, n = n)
}

#' Compute regression metrics by group
#'
#' Applies [swrc_metrics()] within each level of one or more grouping
#' variables, returning a tidy data frame.
#'
#' @param df        A data frame containing observed and predicted columns.
#' @param obs_col   Name of the observed-values column (character string).
#' @param pred_col  Name of the predicted-values column (character string).
#' @param group_col Character vector of grouping column names.
#' @param na.rm     Logical; passed to [swrc_metrics()] (default `TRUE`).
#'
#' @return A tibble with one row per group and columns: grouping variables,
#'   `R2`, `RMSE`, `MAE`, `n`.
#'
#' @examples
#' df <- data.frame(
#'   obs  = c(0.30, 0.25, 0.20, 0.15, 0.10, 0.35, 0.28, 0.18),
#'   pred = c(0.28, 0.26, 0.22, 0.14, 0.11, 0.33, 0.27, 0.19),
#'   texture = c("Clay","Clay","Clay","Clay","Clay","Sand","Sand","Sand")
#' )
#' swrc_metrics_by_group(df, "obs", "pred", "texture")
#'
#' @importFrom dplyr group_by summarise across all_of
#' @importFrom tibble tibble
#' @importFrom purrr map_dfr
#' @export
swrc_metrics_by_group <- function(df, obs_col, pred_col,
                                  group_col, na.rm = TRUE) {
  stopifnot(
    is.data.frame(df),
    obs_col  %in% names(df),
    pred_col %in% names(df),
    all(group_col %in% names(df))
  )

  groups <- unique(df[, group_col, drop = FALSE])

  purrr::map_dfr(seq_len(nrow(groups)), function(i) {
    keys  <- groups[i, , drop = FALSE]
    cond  <- Reduce(`&`, lapply(group_col, function(g) df[[g]] == keys[[g]]))
    sub   <- df[cond, , drop = FALSE]
    m     <- swrc_metrics(sub[[obs_col]], sub[[pred_col]], na.rm = na.rm)
    cbind(keys, m)
  })
}

#' Compute metrics from a swrc_fit on new data
#'
#' A convenience wrapper that calls [predict_swrc()] and [swrc_metrics()].
#'
#' @param object  A `swrc_fit` object.
#' @param newdata Data frame with covariate columns and `matric_head` and
#'   `theta_n` columns.
#' @param obs_col Name of the observed theta column in `newdata` (default
#'   `"theta_n"`).
#'
#' @return A tibble with columns `R2`, `RMSE`, `MAE`, `n`.
#'
#' @export
evaluate_swrc <- function(object, newdata, obs_col = "theta_n") {
  stopifnot(inherits(object, "swrc_fit"), obs_col %in% names(newdata))
  pred <- predict_swrc(object, newdata)
  swrc_metrics(as.numeric(newdata[[obs_col]]), pred)
}
