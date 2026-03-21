#' @title Prediction from fitted SWRC models
#' @name predict
#' @description Functions for generating soil water content predictions
#'   from a fitted `swrc_fit` object, both at specific pF points and as
#'   dense continuous curves.
#' @return See [predict_swrc()] and [predict_swrc_dense()] for return value
#'   details.
NULL

#' Predict water content at specific pF or matric-head values
#'
#' Given a fitted `swrc_fit` object and a new data frame of soil properties,
#' returns predicted volumetric water content at each supplied pF (or matric
#' head) value.
#'
#' @param object  A `swrc_fit` object returned by [fit_swrc()].
#' @param newdata A data frame with the same covariate columns used during
#'   training (i.e. `object$x_inputs`).  Must have a `matric_head` column
#'   **or** supply `pf` directly.
#' @param pf      Optional numeric vector of pF values (overrides
#'   `matric_head` in `newdata`).
#' @param heads   Optional numeric vector of matric heads in cm (overrides
#'   `matric_head` in `newdata`).
#' @param ...     Ignored.
#'
#' @return A numeric vector of predicted theta values (m3/m3), one per row
#'   in `newdata`.
#'
#' @examples
#' \donttest{
#' if (reticulate::py_module_available("tensorflow")) {
#'   df   <- prepare_swrc_data(swrc_example, depth_col = "depth")
#'   fit  <- fit_swrc(df,
#'                    x_inputs = c("clay", "silt", "bd_gcm3", "soc", "Depth_num"),
#'                    epochs = 2L, verbose = FALSE)
#'   pred <- predict_swrc(fit, newdata = df)
#' }
#' }
#'
#' @export
predict_swrc <- function(object, newdata, pf = NULL, heads = NULL, ...) {
  stopifnot(inherits(object, "swrc_fit"))
  tf <- tensorflow::tf
  tpl <- reticulate::tuple

  K         <- object$K
  knot_grid <- object$knot_grid
  pf_left   <- object$pf_left
  pf_right  <- object$pf_right
  x_inputs  <- object$x_inputs

  # Resolve pF values
  if (!is.null(pf)) {
    pf_vals <- as.numeric(pf)
  } else if (!is.null(heads)) {
    pf_vals <- pf_from_head(heads)
  } else if ("matric_head" %in% names(newdata)) {
    pf_vals <- pf_from_head(newdata$matric_head)
  } else {
    rlang::abort("Provide pf, heads, or a 'matric_head' column in newdata.")
  }

  pf_norm <- pf_normalize(pf_vals, pf_left, pf_right)

  # Build sequence array
  Xcov <- apply_minmax(newdata, object$scaler)
  N    <- nrow(Xcov)
  p    <- ncol(Xcov)

  Xseq <- array(0, dim = c(N, K, p + 1L))
  for (i in seq_len(N)) {
    Xseq[i, , seq_len(p)] <- matrix(rep(Xcov[i, ], each = K),
                                    nrow = K, byrow = FALSE)
    Xseq[i, , p + 1L]     <- knot_grid
  }

  Xseq_tf <- tf$constant(Xseq,                        dtype = "float32")
  pf_tf   <- tf$constant(matrix(pf_norm, ncol = 1L),  dtype = "float32")

  pred <- object$theta_model$predict(tpl(Xseq_tf, pf_tf), verbose = 0L)
  as.numeric(pred[, 1L])
}

#' Predict dense SWRC curves for a set of soil profiles
#'
#' For each unique (PEDON_ID × depth) profile in `newdata`, predicts theta
#' across a dense grid of pF values and returns a tidy long-format tibble.
#'
#' @param object     A `swrc_fit` object.
#' @param newdata    A data frame with covariate columns plus (optionally)
#'   `PEDON_ID`, `Depth_num`, `Depth_label`, and `Texture`.
#' @param n_points   Number of equally spaced pF points (default `1000`).
#' @param pf_range   Numeric vector of length 2: min and max pF values for
#'   the output grid (default `c(-2, 7.6)`).
#' @param id_cols    Character vector of columns used to identify profiles
#'   (default `c("PEDON_ID","Depth_num","Depth_label","Texture")`).
#'
#' @return A tibble with columns: all `id_cols` present in `newdata`,
#'   `pF`, `matric_head`, and `theta` (predicted volumetric water content
#'   in m3/m3).
#'
#' @examples
#' \donttest{
#' if (reticulate::py_module_available("tensorflow")) {
#'   df    <- prepare_swrc_data(swrc_example, depth_col = "depth")
#'   fit   <- fit_swrc(df,
#'                     x_inputs = c("clay", "silt", "bd_gcm3", "soc", "Depth_num"),
#'                     epochs = 2L, verbose = FALSE)
#'   dense <- predict_swrc_dense(fit, newdata = df, n_points = 50)
#' }
#' }
#'
#' @importFrom dplyr group_by summarise across all_of ungroup
#' @importFrom tibble tibble
#' @importFrom purrr map_dfr
#' @export
predict_swrc_dense <- function(object, newdata,
                               n_points = 1000L,
                               pf_range = NULL,
                               id_cols  = c("PEDON_ID", "Depth_num",
                                            "Depth_label", "Texture")) {
  stopifnot(inherits(object, "swrc_fit"))
  tf  <- tensorflow::tf
  tpl <- reticulate::tuple

  if (is.null(pf_range))
    pf_range <- c(object$pf_left, object$pf_right)

  pf_grid    <- seq(pf_range[1], pf_range[2], length.out = n_points)
  heads_grid <- head_from_pf(pf_grid)
  pfq        <- pf_normalize(pf_grid, object$pf_left, object$pf_right)

  K         <- object$K
  knot_grid <- object$knot_grid
  x_inputs  <- object$x_inputs

  # Collapse to unique profiles
  avail_id <- intersect(id_cols, names(newdata))
  x_cov    <- setdiff(x_inputs, avail_id)

  group_expr <- if (length(avail_id) > 0) avail_id else character(0)

  if (length(group_expr) > 0) {
    prof_tbl <- newdata |>
      dplyr::group_by(dplyr::across(dplyr::all_of(group_expr))) |>
      dplyr::summarise(
        dplyr::across(dplyr::all_of(x_cov), ~ as.numeric(first_non_na(.x))),
        .groups = "drop"
      )
  } else {
    prof_tbl <- newdata[!duplicated(newdata[, x_inputs, drop = FALSE]), ]
  }

  # Build profile array
  arr <- make_profile_array(prof_tbl, x_inputs, object$scaler, K, knot_grid)
  Np  <- arr$Np

  # Replicate profiles × pF grid
  Xrep  <- arr$Xseq[rep(seq_len(Np), each = n_points), , , drop = FALSE]
  pfrep <- matrix(rep(pfq, times = Np), ncol = 1L)

  Xrep_tf  <- tf$constant(Xrep,  dtype = "float32")
  pfnorm_tf <- tf$constant(pfrep, dtype = "float32")

  pred      <- object$theta_model$predict(tpl(Xrep_tf, pfnorm_tf), verbose = 0L)
  pred_mat  <- matrix(as.numeric(pred[, 1L]),
                      nrow = Np, ncol = n_points, byrow = TRUE)

  # Build output tibble
  purrr::map_dfr(seq_len(Np), function(i) {
    row_vals <- as.list(prof_tbl[i, avail_id, drop = FALSE])
    tibble::tibble(
      !!!row_vals,
      pF          = pf_grid,
      matric_head = heads_grid,
      theta       = pred_mat[i, ]
    )
  })
}

#' Extract saturated water content (theta_s) from covariates
#'
#' Uses the `param_model` (which maps covariate inputs to theta_s) to
#' extract the modelled saturated water content for each row of `newdata`.
#'
#' @param object  A `swrc_fit` object.
#' @param newdata Data frame with covariate columns.
#'
#' @return Numeric vector of theta_s values (m3/m3).
#'
#' @export
predict_theta_s <- function(object, newdata) {
  stopifnot(inherits(object, "swrc_fit"))
  tf  <- tensorflow::tf
  tpl <- reticulate::tuple

  K         <- object$K
  knot_grid <- object$knot_grid
  x_inputs  <- object$x_inputs

  Xcov <- apply_minmax(newdata, object$scaler)
  N    <- nrow(Xcov)
  p    <- ncol(Xcov)

  Xseq <- array(0, dim = c(N, K, p + 1L))
  for (i in seq_len(N)) {
    Xseq[i, , seq_len(p)] <- matrix(rep(Xcov[i, ], each = K),
                                    nrow = K, byrow = FALSE)
    Xseq[i, , p + 1L]     <- knot_grid
  }

  Xseq_tf <- tf$constant(Xseq, dtype = "float32")
  ts      <- object$param_model$predict(Xseq_tf, verbose = 0L)
  as.numeric(ts)
}

# ---------------------------------------------------------------------------
# S3 predict method
# ---------------------------------------------------------------------------

#' Predict method for swrc_fit
#'
#' Dispatches to [predict_swrc()].
#'
#' @inheritParams predict_swrc
#' @return A numeric vector of predicted volumetric water content values
#'   (m3/m3), one per row in `newdata`.
#' @export
predict.swrc_fit <- function(object, newdata, pf = NULL, heads = NULL, ...) {
  predict_swrc(object, newdata = newdata, pf = pf, heads = heads, ...)
}

# ---------------------------------------------------------------------------
# Internal helper
# ---------------------------------------------------------------------------
first_non_na <- function(x) x[which(!is.na(x))[1L]]
