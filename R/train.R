#' @title Training the CNN1D SWRC model
#' @name train
#' @description High-level and low-level functions for training the
#'   physics-informed CNN1D model, including the eager-mode train step
#'   and the main fitting loop with early stopping.
NULL

# ---------------------------------------------------------------------------
# Low-level: single train step (eager mode)
# ---------------------------------------------------------------------------

#' Create an eager-mode train step function
#'
#' Returns a closure that, when called with a mini-batch, computes the
#' combined data + physics loss and applies gradients.
#'
#' @param theta_model  Keras model returned by [build_swrc_model()]`$theta_model`.
#' @param optimizer    A Keras/TF optimizer (e.g. `tf$keras$optimizers$Adam`).
#' @param lambda_wet   Weight for wet-end data loss (default `1.0`).
#' @param lambda_dry   Weight for dry-end data loss (default `10.0`).
#' @param wet_split_cm Matric head threshold (cm) separating wet/dry
#'   (default `4.2`).
#' @param lambda3      S1 linearity weight (default `1.0`).
#' @param lambda4      S2 non-negativity weight (default `1000.0`).
#' @param lambda5      S3 non-positivity weight (default `1000.0`).
#' @param lambda6      S4 saturation weight (default `1.0`).
#' @param res_tensors  Named list of physics residual tensors (output of
#'   [residual_to_tensors()]).
#' @param pf_left      Left boundary of pF domain (default `-2`).
#' @param pf_right     Right boundary of pF domain (default `7.6`).
#'
#' @return A function `f(Xseq, pf_norm_obs, y, sw)` that performs one
#'   gradient step and returns a named list of loss scalars.
#'
#' @keywords internal
make_train_step <- function(theta_model, optimizer,
                            lambda_wet   = 1.0,
                            lambda_dry   = 10.0,
                            wet_split_cm = 4.2,
                            lambda3      = 1.0,
                            lambda4      = 1000.0,
                            lambda5      = 1000.0,
                            lambda6      = 1.0,
                            res_tensors,
                            pf_left      = -2.0,
                            pf_right     =  7.6) {
  tf <- tensorflow::tf

  pf_left_tf  <- tf$constant(as.numeric(pf_left),  tf$float32)
  pf_right_tf <- tf$constant(as.numeric(pf_right), tf$float32)
  pf_wet_tf   <- tf$constant(log10(as.numeric(wet_split_cm)), tf$float32)
  lam_w <- tf$constant(as.numeric(lambda_wet), tf$float32)
  lam_d <- tf$constant(as.numeric(lambda_dry), tf$float32)

  function(Xseq, pf_norm_obs, y, sw) {
    theta_true <- y[, 1L, drop = FALSE]
    swv        <- tf$reshape(tf$cast(sw, tf$float32), shape = c(-1L, 1L))
    pf_real    <- pf_left_tf + pf_norm_obs * (pf_right_tf - pf_left_tf)
    wet_mask   <- tf$cast(pf_real <= pf_wet_tf, tf$float32)
    dry_mask   <- 1.0 - wet_mask

    with(tf$GradientTape() %as% tape, {
      pred      <- theta_model(list(Xseq, pf_norm_obs), training = TRUE)
      theta_hat <- pred[, 1L, drop = FALSE]
      err2      <- tf$square(theta_true - theta_hat)

      wet_sum <- tf$reduce_sum(wet_mask * swv)
      dry_sum <- tf$reduce_sum(dry_mask * swv)

      L_wet <- tf$where(
        wet_sum > 0,
        tf$reduce_sum(err2 * wet_mask * swv) / (wet_sum + 1e-6),
        tf$constant(0.0, tf$float32)
      )
      L_dry <- tf$where(
        dry_sum > 0,
        tf$reduce_sum(err2 * dry_mask * swv) / (dry_sum + 1e-6),
        tf$constant(0.0, tf$float32)
      )
      L_data <- lam_w * L_wet + lam_d * L_dry

      phys <- compute_physics_loss(
        theta_model = theta_model,
        res_tensors = res_tensors,
        lambda3     = lambda3,
        lambda4     = lambda4,
        lambda5     = lambda5,
        lambda6     = lambda6,
        pf_left     = pf_left,
        pf_right    = pf_right,
        training    = TRUE
      )
      loss <- L_data + phys$L_phys
    })

    grads <- tape$gradient(loss, theta_model$trainable_variables)
    optimizer$apply_gradients(
      Map(function(g, v) reticulate::tuple(g, v),
          grads, theta_model$trainable_variables)
    )

    list(
      loss   = loss,
      L_data = L_data,
      L_phys = phys$L_phys,
      L_lin  = phys$L_lin,
      L_pos  = phys$L_pos,
      L_neg  = phys$L_neg,
      L_sat  = phys$L_sat
    )
  }
}

# ---------------------------------------------------------------------------
# High-level: fit_swrc
# ---------------------------------------------------------------------------

#' Fit a physics-informed CNN1D SWRC model
#'
#' The main user-facing function for training.  Given prepared training and
#' (optionally) validation data, it builds the model, creates physics
#' residual sets, runs the training loop with early stopping, and returns
#' a fitted object for prediction and evaluation.
#'
#' @param train_df     Data frame for training (output of
#'   [prepare_swrc_data()]).
#' @param x_inputs     Character vector of covariate column names.
#' @param val_df       Optional validation data frame (same structure as
#'   `train_df`). If `NULL`, early stopping is skipped.
#' @param hidden       Integer vector of length 2: Conv1D filter counts
#'   (default `c(128L, 64L)`).
#' @param dropout      Dropout rate (default `0.10`).
#' @param lr           Learning rate for the Adam optimizer (default `1e-3`).
#' @param epochs       Maximum number of epochs (default `80`).
#' @param batch_size   Mini-batch size (default `256`).
#' @param patience     Early-stopping patience in multiples of 5 epochs
#'   (default `5`).
#' @param K            Number of knot points (default `64L`).
#' @param lambdas      Named list of loss weights; use [norouzi_lambdas()]
#'   to generate (default: `norouzi_lambdas("norouzi")`).
#' @param S1,S2,S3,S4 Residual set sizes (defaults: 1500, 500, 500, 1500).
#' @param pF_lin_min   Lower pF for S1 linearity constraint (default `5.0`).
#' @param pF_lin_max   Upper pF for S1 linearity constraint (default `7.6`).
#' @param pF0_pos      pF threshold for S2 (default `6.2`).
#' @param pF1_neg      pF threshold for S3 (default `7.6`).
#' @param pF_sat_min   Lower pF for S4 (default `-2.0`).
#' @param pF_sat_max   Upper pF for S4 (default `-0.3`).
#' @param wet_split_cm Matric head (cm) separating wet/dry end (default `4.2`).
#' @param w_wet        Sample weight for wet observations (default `1.0`).
#' @param w_dry        Sample weight for dry observations (default `1.0`).
#' @param pf_left      Left pF domain boundary (default `-2.0`).
#' @param pf_right     Right pF domain boundary (default `7.6`).
#' @param seed         Random seed (default `123`).
#' @param verbose      Logical; print progress (default `TRUE`).
#'
#' @return An S3 object of class `swrc_fit`, a named list containing:
#'   \describe{
#'     \item{`theta_model`}{The fitted Keras model.}
#'     \item{`param_model`}{The theta_s extractor model.}
#'     \item{`x_inputs`}{Covariate names used.}
#'     \item{`scaler`}{Fitted min-max scaler.}
#'     \item{`K`}{Number of knot points.}
#'     \item{`dk`}{Knot spacing.}
#'     \item{`knot_grid`}{Knot positions in \[0, 1\].}
#'     \item{`pf_left`,`pf_right`}{pF domain boundaries.}
#'     \item{`theta_factor`}{Unit multiplier for theta.}
#'     \item{`best_epoch`}{Epoch at which validation loss was minimised.}
#'     \item{`lambdas`}{Loss weights used during training.}
#'     \item{`history`}{Data frame of per-epoch training/validation losses.}
#'   }
#'
#' @examples
#' \dontrun{
#' fit <- fit_swrc(train_df, x_inputs = c("clay","silt","bd_gcm3","soc","Depth_num"),
#'                val_df = val_df, epochs = 80, verbose = TRUE)
#' }
#'
#' @export
fit_swrc <- function(train_df,
                     x_inputs,
                     val_df       = NULL,
                     hidden       = c(128L, 64L),
                     dropout      = 0.10,
                     lr           = 1e-3,
                     epochs       = 80L,
                     batch_size   = 256L,
                     patience     = 5L,
                     K            = 64L,
                     lambdas      = norouzi_lambdas("norouzi"),
                     S1 = 1500L, S2 = 500L, S3 = 500L, S4 = 1500L,
                     pF_lin_min   = 5.0,  pF_lin_max = 7.6,
                     pF0_pos      = 6.2,  pF1_neg    = 7.6,
                     pF_sat_min   = -2.0, pF_sat_max = -0.3,
                     wet_split_cm = 4.2,
                     w_wet        = 1.0,
                     w_dry        = 1.0,
                     pf_left      = -2.0,
                     pf_right     =  7.6,
                     seed         = 123L,
                     verbose      = TRUE) {

  set.seed(seed)
  tf    <- tensorflow::tf
  x_inputs <- as.character(x_inputs)

  # --- Fit scaler on training data ---
  scaler <- fit_minmax(train_df, x_inputs)

  # Theta factor (stored in attribute by prepare_swrc_data)
  theta_factor <- attr(train_df, "theta_factor")
  if (is.null(theta_factor)) theta_factor <- 1

  # --- Build observation matrices ---
  knot_grid <- seq(0, 1, length.out = K)
  tr <- make_obs_matrices(train_df, x_inputs, scaler,
                          K = K, knot_grid = knot_grid,
                          pf_left = pf_left, pf_right = pf_right,
                          wet_split_cm = wet_split_cm,
                          w_wet = w_wet, w_dry = w_dry)

  if (!is.null(val_df)) {
    dv <- make_obs_matrices(val_df, x_inputs, scaler,
                            K = K, knot_grid = knot_grid,
                            pf_left = pf_left, pf_right = pf_right,
                            wet_split_cm = wet_split_cm)
  }

  # --- Build model ---
  mods        <- build_swrc_model(n_covariates = length(x_inputs),
                                  hidden = hidden, dropout = dropout, K = K)
  theta_model <- mods$theta_model
  dk          <- mods$dk
  optimizer   <- tf$keras$optimizers$Adam(learning_rate = lr)

  # --- Build physics residual sets ---
  train_raw <- as.data.frame(
    lapply(train_df[, x_inputs, drop = FALSE], as.numeric)
  )
  res_sets <- build_residual_sets(
    df_raw     = train_raw, x_inputs = x_inputs,
    S1 = S1, S2 = S2, S3 = S3, S4 = S4,
    pF_lin_min = pF_lin_min, pF_lin_max = pF_lin_max,
    pF0_pos    = pF0_pos,    pF1_neg    = pF1_neg,
    pF_sat_min = pF_sat_min, pF_sat_max = pF_sat_max,
    seed       = seed
  )
  res_tensors <- list(
    set1 = residual_to_tensors(res_sets$set1, scaler, K, knot_grid, pf_left, pf_right),
    set2 = residual_to_tensors(res_sets$set2, scaler, K, knot_grid, pf_left, pf_right),
    set3 = residual_to_tensors(res_sets$set3, scaler, K, knot_grid, pf_left, pf_right),
    set4 = residual_to_tensors(res_sets$set4, scaler, K, knot_grid, pf_left, pf_right)
  )

  # --- Create train step ---
  train_step <- make_train_step(
    theta_model  = theta_model,
    optimizer    = optimizer,
    lambda_wet   = lambdas$lambda_wet,
    lambda_dry   = lambdas$lambda_dry,
    wet_split_cm = wet_split_cm,
    lambda3      = lambdas$lambda3,
    lambda4      = lambdas$lambda4,
    lambda5      = lambdas$lambda5,
    lambda6      = lambdas$lambda6,
    res_tensors  = res_tensors,
    pf_left      = pf_left,
    pf_right     = pf_right
  )

  # Convert training tensors
  Xtr  <- tf$constant(tr$Xseq, "float32")
  pftr <- tf$constant(tr$pf,   "float32")
  ytr  <- tf$constant(tr$y,    "float32")
  wtr  <- tf$constant(tr$w,    "float32")

  if (!is.null(val_df)) {
    Xdv  <- tf$constant(dv$Xseq, "float32")
    pfdv <- tf$constant(dv$pf,   "float32")
    ydv  <- tf$constant(dv$y,    "float32")
  }

  eval_val <- function() {
    if (is.null(val_df)) return(NA_real_)
    pred <- theta_model(list(Xdv, pfdv), training = FALSE)
    as.numeric(tf$reduce_mean(
      tf$square(ydv[, 1L, drop = FALSE] - pred[, 1L, drop = FALSE])
    )$numpy())
  }

  # --- Training loop ---
  n_tr   <- dim(tr$Xseq)[1L]
  steps  <- as.integer(ceiling(n_tr / batch_size))
  best_val <- Inf; best_ep <- 1L; wait <- 0L; best_w <- NULL
  history_rows <- list()

  for (ep in seq_len(epochs)) {
    idx <- sample.int(n_tr, n_tr, replace = FALSE)
    ep_loss <- 0; ep_data <- 0; ep_phys <- 0

    for (s in seq_len(steps)) {
      lo <- (s - 1L) * batch_size + 1L
      hi <- min(s * batch_size, n_tr)
      bi  <- idx[lo:hi]
      out <- train_step(
        tf$gather(Xtr,  bi - 1L),
        tf$gather(pftr, bi - 1L),
        tf$gather(ytr,  bi - 1L),
        tf$gather(wtr,  bi - 1L)
      )
      ep_loss <- ep_loss + as.numeric(out$loss$numpy())
      ep_data <- ep_data + as.numeric(out$L_data$numpy())
      ep_phys <- ep_phys + as.numeric(out$L_phys$numpy())

      if (verbose && s %% 50L == 0L)
        message(sprintf(
          "  ep=%d step=%d/%d loss=%.5f data=%.5f phys=%.5f",
          ep, s, steps,
          as.numeric(out$loss$numpy()),
          as.numeric(out$L_data$numpy()),
          as.numeric(out$L_phys$numpy())
        ))
    }

    # Validation every 5 epochs
    val_mse <- NA_real_
    if (ep %% 5L == 0L) {
      val_mse <- eval_val()
      if (verbose)
        message(sprintf("  EPOCH %d | val_mse=%.6f | best=%.6f",
                        ep, val_mse, best_val))
      if (!is.null(val_df) && is.finite(val_mse)) {
        if (val_mse < best_val) {
          best_val <- val_mse
          best_ep  <- ep
          wait     <- 0L
          best_w   <- theta_model$get_weights()
        } else {
          wait <- wait + 1L
        }
        if (wait >= patience) {
          if (verbose)
            message(sprintf("  Early stopping at epoch %d.", ep))
          break
        }
      }
    }

    history_rows[[ep]] <- data.frame(
      epoch   = ep,
      loss    = ep_loss / steps,
      L_data  = ep_data / steps,
      L_phys  = ep_phys / steps,
      val_mse = val_mse
    )
  }

  # Restore best weights
  if (!is.null(best_w)) theta_model$set_weights(best_w)
  history <- do.call(rbind, Filter(Negate(is.null), history_rows))

  structure(
    list(
      theta_model  = theta_model,
      param_model  = mods$param_model,
      x_inputs     = x_inputs,
      scaler       = scaler,
      K            = K,
      dk           = dk,
      knot_grid    = knot_grid,
      pf_left      = pf_left,
      pf_right     = pf_right,
      theta_factor = theta_factor,
      best_epoch   = best_ep,
      lambdas      = lambdas,
      history      = history
    ),
    class = "swrc_fit"
  )
}

#' Print method for swrc_fit
#' @param x An `swrc_fit` object.
#' @param ... Ignored.
#' @export
print.swrc_fit <- function(x, ...) {
  cat("CNN1D SWRC fit (Norouzi et al. 2025)\n")
  cat("  Covariates :", paste(x$x_inputs, collapse = ", "), "\n")
  cat("  K (knots)  :", x$K, "\n")
  cat("  Best epoch :", x$best_epoch, "\n")
  cat("  pF domain  : [", x$pf_left, ",", x$pf_right, "]\n")
  invisible(x)
}

#' Summary method for swrc_fit
#' @param object An `swrc_fit` object.
#' @param ... Ignored.
#' @export
summary.swrc_fit <- function(object, ...) {
  cat("=== soilFlux: swrc_fit object ===\n")
  cat("Covariates  :", paste(object$x_inputs, collapse = ", "), "\n")
  cat("Knots (K)   :", object$K, "\n")
  cat("Best epoch  :", object$best_epoch, "\n")
  cat("pF domain   : [", object$pf_left, ",", object$pf_right, "]\n")
  cat("Theta factor:", object$theta_factor, "\n")
  cat("\nLoss weights:\n")
  cat("  lambda_wet :", object$lambdas$lambda_wet, "\n")
  cat("  lambda_dry :", object$lambdas$lambda_dry, "\n")
  cat("  lambda3    :", object$lambdas$lambda3,    "\n")
  cat("  lambda4    :", object$lambdas$lambda4,    "\n")
  cat("  lambda5    :", object$lambdas$lambda5,    "\n")
  cat("  lambda6    :", object$lambdas$lambda6,    "\n")
  invisible(object)
}
