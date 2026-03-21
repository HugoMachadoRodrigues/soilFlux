#' @title Physics-informed constraints for SWRC modelling
#' @name physics
#' @description Functions for defining, building, and evaluating the four
#'   physics-based residual constraints of Norouzi et al. (2025).
#'
#' @references
#' Norouzi, A. M., et al. (2025). Physics-Informed Neural Networks for
#'   Estimating a Continuous Form of the Soil Water Retention Curve.
#'   *Journal of Hydrology*.
NULL

# ---------------------------------------------------------------------------
# Lambda configuration
# ---------------------------------------------------------------------------

#' Return default Norouzi et al. (2025) loss weights (lambdas)
#'
#' Table 1 of Norouzi et al. (2025) defines six loss-weight hyperparameters.
#' This function returns them as a named list that can be passed to
#' [fit_swrc()] and [compute_physics_loss()].
#'
#' @param config Character string; either `"norouzi"` (exact replication,
#'   default) or `"smooth"` (lambda3 = 10 for a smoother dry-end).
#'
#' @return A named list:
#'   \describe{
#'     \item{`lambda_wet`}{Weight for wet-end data loss (lambda1 = 1).}
#'     \item{`lambda_dry`}{Weight for dry-end data loss (lambda2 = 10).}
#'     \item{`lambda3`}{S1 dry-end linearity (lambda3 = 1 or 10).}
#'     \item{`lambda4`}{S2 non-negativity at pF0 (lambda4 = 1000).}
#'     \item{`lambda5`}{S3 non-positivity at pF1 (lambda5 = 1000).}
#'     \item{`lambda6`}{S4 saturated-plateau flatness (lambda6 = 1).}
#'   }
#'
#' @examples
#' norouzi_lambdas()
#' norouzi_lambdas("smooth")
#'
#' @export
norouzi_lambdas <- function(config = c("norouzi", "smooth")) {
  config <- match.arg(config)
  base <- list(
    lambda_wet = 1.0,
    lambda_dry = 10.0,
    lambda4    = 1000.0,
    lambda5    = 1000.0,
    lambda6    = 1.0
  )
  base$lambda3 <- if (config == "norouzi") 1.0 else 10.0
  base
}

# ---------------------------------------------------------------------------
# Residual sets (collocation points for physics loss)
# ---------------------------------------------------------------------------

#' Build physics residual point sets (S1 – S4)
#'
#' Generates four sets of collocation points (random soil-property vectors
#' and associated pF values) used to evaluate the physics constraints during
#' training.
#'
#' @param df_raw   Data frame with covariate columns (training split).
#' @param x_inputs Character vector of covariate column names.
#' @param S1       Number of S1 points — dry-end linearity (default 1500).
#' @param S2       Number of S2 points — non-negativity at pF0 (default 500).
#' @param S3       Number of S3 points — non-positivity at pF1 (default 500).
#' @param S4       Number of S4 points — saturated plateau (default 1500).
#' @param pF_lin_min  Lower pF for the S1 linearity constraint (default 5.0).
#' @param pF_lin_max  Upper pF for the S1 linearity constraint (default 7.6).
#' @param pF0_pos     pF at which theta must be >= 0 — S2 (default 6.2).
#' @param pF1_neg     pF at which theta must be <= 0 — S3 (default 7.6).
#' @param pF_sat_min  Lower pF for the S4 plateau constraint (default -2.0).
#' @param pF_sat_max  Upper pF for the S4 plateau constraint (default -0.3).
#' @param seed     Integer random seed (default 123).
#'
#' @return A named list with four data frames: `set1`, `set2`, `set3`,
#'   `set4`. Each data frame has one row per collocation point, with columns
#'   corresponding to `x_inputs` (sampled uniformly within training range)
#'   and a `pF` column.
#'
#' @examples
#' \donttest{
#' df <- data.frame(
#'   clay       = c(20, 30, 10),
#'   silt       = c(30, 40, 20),
#'   sand_total = c(50, 30, 70),
#'   Depth_num  = c(15, 30, 60)
#' )
#' sets <- build_residual_sets(df, c("clay", "silt", "sand_total", "Depth_num"),
#'                             S1 = 50L, S2 = 20L, S3 = 20L, S4 = 50L)
#' }
#'
#' @export
build_residual_sets <- function(df_raw, x_inputs,
                                S1 = 1500L, S2 = 500L, S3 = 500L, S4 = 1500L,
                                pF_lin_min = 5.0,  pF_lin_max = 7.6,
                                pF0_pos    = 6.2,  pF1_neg    = 7.6,
                                pF_sat_min = -2.0, pF_sat_max = -0.3,
                                seed = 123L) {
  set.seed(seed)
  df_num <- as.data.frame(lapply(df_raw[, x_inputs, drop = FALSE], as.numeric))
  mins   <- vapply(df_num, min, numeric(1L), na.rm = TRUE)
  maxs   <- vapply(df_num, max, numeric(1L), na.rm = TRUE)

  blk <- function(n) {
    X <- vapply(seq_along(x_inputs), function(j)
      stats::runif(n, mins[j], maxs[j]), numeric(n))
    X <- as.data.frame(X)
    names(X) <- x_inputs
    X
  }

  s1 <- blk(S1); s1$pF <- stats::runif(S1, pF_lin_min, pF_lin_max)
  s2 <- blk(S2); s2$pF <- pF0_pos
  s3 <- blk(S3); s3$pF <- pF1_neg
  s4 <- blk(S4); s4$pF <- stats::runif(S4, pF_sat_min, pF_sat_max)

  list(set1 = s1, set2 = s2, set3 = s3, set4 = s4)
}

#' Convert residual point sets to TensorFlow tensors
#'
#' Takes one residual data frame (as returned by [build_residual_sets()])
#' and builds the 3-D sequence array `Xseq` (shape `[N, K, p+1]`) and
#' the `pf` tensor (shape `[N, 1]`) needed by the CNN1D model.
#'
#' @param df_res    A residual data frame (one of `set1` – `set4`).
#' @param scaler    A scaler object from [fit_minmax()].
#' @param K         Number of knot points (default 64).
#' @param knot_grid Numeric vector of knot positions in \[0, 1\]
#'   (default `seq(0, 1, length.out = K)`).
#' @param pf_left   Left boundary of the pF domain (default -2).
#' @param pf_right  Right boundary of the pF domain (default 7.6).
#'
#' @return A named list with TensorFlow tensors:
#'   \describe{
#'     \item{`Xseq`}{float32 tensor, shape \[N, K, p+1\].}
#'     \item{`pf`}{float32 tensor, shape \[N, 1\].}
#'   }
#'
#' @keywords internal
#' @export
residual_to_tensors <- function(df_res, scaler,
                                K         = 64L,
                                knot_grid = seq(0, 1, length.out = K),
                                pf_left   = -2.0,
                                pf_right  =  7.6) {
  tf     <- tensorflow::tf
  Xcov   <- apply_minmax(df_res, scaler)
  N      <- nrow(Xcov)
  p      <- ncol(Xcov)
  K      <- as.integer(K)

  Xseq <- array(0, dim = c(N, K, p + 1L))
  for (i in seq_len(N)) {
    Xseq[i, , seq_len(p)]  <- matrix(rep(Xcov[i, ], each = K),
                                     nrow = K, byrow = FALSE)
    Xseq[i, , p + 1L]      <- knot_grid
  }

  pf_norm <- (df_res$pF - pf_left) / (pf_right - pf_left)

  list(
    Xseq = tf$constant(Xseq,                      dtype = "float32"),
    pf   = tf$constant(matrix(pf_norm, ncol = 1L), dtype = "float32")
  )
}

# ---------------------------------------------------------------------------
# Physics loss — Equation (4) of Norouzi et al. (2025)
# ---------------------------------------------------------------------------

#' Compute the physics-informed residual loss (Norouzi et al. 2025)
#'
#' Evaluates four physics constraints against the current model weights:
#' \describe{
#'   \item{S1 (L_lin)}{Second derivative \eqn{|\partial^2\theta/\partial pF^2|}
#'     in the dry end \eqn{pF \in [5, 7.6]} should be near zero (linearity).}
#'   \item{S2 (L_pos)}{\eqn{\theta(pF = 6.2) \geq 0} (non-negativity).}
#'   \item{S3 (L_neg)}{\eqn{\theta(pF = 7.6) \leq 0} (non-positivity).}
#'   \item{S4 (L_sat)}{First derivative \eqn{|\partial\theta/\partial pF|}
#'     near zero in the saturated plateau \eqn{pF \in [-2, -0.3]}.}
#' }
#'
#' @param theta_model  A Keras model with two inputs: `Xseq` and `pf_norm`.
#' @param res_tensors  A named list with four sublists (`set1` – `set4`),
#'   each containing `Xseq` and `pf` tensors (output of
#'   [residual_to_tensors()]).
#' @param lambda3   Weight for S1 linearity loss (default 1.0).
#' @param lambda4   Weight for S2 non-negativity loss (default 1000.0).
#' @param lambda5   Weight for S3 non-positivity loss (default 1000.0).
#' @param lambda6   Weight for S4 saturation loss (default 1.0).
#' @param pf_left   Left boundary of the normalised pF domain (default -2).
#' @param pf_right  Right boundary (default 7.6).
#' @param training  Logical passed to the model call (default `TRUE`).
#'
#' @return A named list of TensorFlow scalars:
#'   `L_phys`, `L_lin`, `L_pos`, `L_neg`, `L_sat`.
#'
#' @keywords internal
#' @export
compute_physics_loss <- function(theta_model, res_tensors,
                                 lambda3  = 1.0,
                                 lambda4  = 1000.0,
                                 lambda5  = 1000.0,
                                 lambda6  = 1.0,
                                 pf_left  = -2.0,
                                 pf_right =  7.6,
                                 training = TRUE) {
  tf   <- tensorflow::tf
  relu <- tf$nn$relu

  rng_pf <- as.numeric(pf_right - pf_left)
  sc1    <- tf$constant(1.0 / rng_pf,    tf$float32)
  sc2    <- tf$constant(1.0 / rng_pf^2, tf$float32)

  # --- S1: dry-end linearity |d2theta/dpF2| ---
  X1  <- res_tensors$set1$Xseq
  pf1 <- res_tensors$set1$pf
  with(tf$GradientTape(persistent = TRUE) %as% t2, {
    t2$watch(pf1)
    with(tf$GradientTape() %as% t1, {
      t1$watch(pf1)
      th1 <- theta_model(list(X1, pf1), training = training)[, 1L, drop = FALSE]
    })
    d1 <- safe_grad(t1, th1, pf1)
  })
  d2    <- safe_grad(t2, d1, pf1)
  L_lin <- tf$reduce_mean(tf$abs(d2 * sc2))

  # --- S2: theta(pF0) >= 0 ---
  X2  <- res_tensors$set2$Xseq
  pf2 <- res_tensors$set2$pf
  th2 <- theta_model(list(X2, pf2), training = training)[, 1L, drop = FALSE]
  L_pos <- tf$reduce_mean(relu(-th2))

  # --- S3: theta(pF1) <= 0 ---
  X3  <- res_tensors$set3$Xseq
  pf3 <- res_tensors$set3$pf
  th3 <- theta_model(list(X3, pf3), training = training)[, 1L, drop = FALSE]
  L_neg <- tf$reduce_mean(relu(th3))

  # --- S4: saturated plateau |dtheta/dpF| ~ 0 ---
  X4  <- res_tensors$set4$Xseq
  pf4 <- res_tensors$set4$pf
  with(tf$GradientTape() %as% t4, {
    t4$watch(pf4)
    th4 <- theta_model(list(X4, pf4), training = training)[, 1L, drop = FALSE]
  })
  d4    <- safe_grad(t4, th4, pf4)
  L_sat <- tf$reduce_mean(tf$abs(d4 * sc1))

  l3 <- tf$constant(lambda3, tf$float32)
  l4 <- tf$constant(lambda4, tf$float32)
  l5 <- tf$constant(lambda5, tf$float32)
  l6 <- tf$constant(lambda6, tf$float32)

  L_phys <- l3 * L_lin + l4 * L_pos + l5 * L_neg + l6 * L_sat

  list(
    L_phys = L_phys,
    L_lin  = L_lin,
    L_pos  = L_pos,
    L_neg  = L_neg,
    L_sat  = L_sat
  )
}
