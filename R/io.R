#' @title Save and load fitted SWRC models
#' @name io
#' @description Functions to persist a fitted `swrc_fit` object to disk
#'   and reload it for later use (prediction, spatial mapping, etc.).
NULL

#' Save a fitted SWRC model to disk
#'
#' Saves the Keras model weights as an HDF5 file and the R metadata
#' (scalers, hyperparameters, etc.) as an `.rds` file inside `dir`.
#'
#' @param fit  A `swrc_fit` object returned by [fit_swrc()].
#' @param dir  Directory where the model will be saved.  Created if it
#'   does not exist.
#' @param name Stem name for the output files (default `"swrc_model"`).
#'
#' @return Invisibly returns a named list with paths to the two files:
#'   \describe{
#'     \item{`weights_path`}{Path to the `.weights.h5` file.}
#'     \item{`meta_path`}{Path to the `.rds` metadata file.}
#'   }
#'
#' @examples
#' \donttest{
#' save_swrc_model(fit, dir = tempdir(), name = "model_5")
#' }
#'
#' @export
save_swrc_model <- function(fit,
                            dir,
                            name = "swrc_model") {
  stopifnot(inherits(fit, "swrc_fit"))
  dir.create(dir, showWarnings = FALSE, recursive = TRUE)

  wt_path   <- file.path(dir, paste0(name, ".weights.h5"))
  meta_path <- file.path(dir, paste0(name, "_meta.rds"))

  fit$theta_model$save_weights(wt_path)

  meta <- list(
    x_inputs     = fit$x_inputs,
    n_covariates = length(fit$x_inputs),
    K            = fit$K,
    dk           = fit$dk,
    knot_grid    = fit$knot_grid,
    scaler       = fit$scaler,
    theta_factor = fit$theta_factor,
    pf_left      = fit$pf_left,
    pf_right     = fit$pf_right,
    best_epoch   = fit$best_epoch,
    lambdas      = fit$lambdas
  )
  saveRDS(meta, meta_path)

  message("Model weights saved to : ", wt_path)
  message("Model metadata saved to: ", meta_path)

  invisible(list(weights_path = wt_path, meta_path = meta_path))
}

#' Load a previously saved SWRC model from disk
#'
#' Reconstructs the CNN1D Keras model from the saved weights and metadata
#' and returns a `swrc_fit`-compatible list that can be passed to
#' [predict_swrc()], [predict_swrc_dense()], etc.
#'
#' @param dir  Directory containing the saved files (default
#'   `"./models/swrc"`).
#' @param name Stem name used when saving (default `"swrc_model"`).
#'
#' @return A `swrc_fit` object (without `history` or `param_model`).
#'
#' @examples
#' \donttest{
#' fit <- load_swrc_model(tempdir(), "model_5")
#' pred <- predict_swrc(fit, newdata = test_df)
#' }
#'
#' @export
load_swrc_model <- function(dir  = "./models/swrc",
                            name = "swrc_model") {
  wt_path   <- file.path(dir, paste0(name, ".weights.h5"))
  meta_path <- file.path(dir, paste0(name, "_meta.rds"))

  if (!file.exists(wt_path))
    rlang::abort(paste("Weights file not found:", wt_path))
  if (!file.exists(meta_path))
    rlang::abort(paste("Metadata file not found:", meta_path))

  meta <- readRDS(meta_path)

  mods <- build_swrc_model(
    n_covariates = meta$n_covariates,
    K            = meta$K
  )
  mods$theta_model$load_weights(wt_path)

  structure(
    list(
      theta_model  = mods$theta_model,
      param_model  = mods$param_model,
      x_inputs     = meta$x_inputs,
      scaler       = meta$scaler,
      K            = meta$K,
      dk           = meta$dk,
      knot_grid    = meta$knot_grid,
      pf_left      = meta$pf_left,
      pf_right     = meta$pf_right,
      theta_factor = meta$theta_factor,
      best_epoch   = meta$best_epoch,
      lambdas      = meta$lambdas,
      history      = NULL
    ),
    class = "swrc_fit"
  )
}

#' Check whether a model directory contains a valid saved model
#'
#' @param dir  Directory path.
#' @param name Model stem name.
#'
#' @return Logical scalar.
#'
#' @export
swrc_model_exists <- function(dir = "./models/swrc", name = "swrc_model") {
  all(file.exists(
    file.path(dir, paste0(name, ".weights.h5")),
    file.path(dir, paste0(name, "_meta.rds"))
  ))
}
