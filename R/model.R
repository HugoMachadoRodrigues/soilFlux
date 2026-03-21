#' @title CNN1D monotone-integral model architecture
#' @name model
#' @description Build the physics-informed 1-D CNN with a monotone integral
#'   output layer, as described in Norouzi et al. (2025).
#'
#' @details
#' ## Architecture
#'
#' The model takes two inputs:
#' \enumerate{
#'   \item `Xseq_knots`: a 3-D tensor of shape `[N, K, p+1]` — for each
#'     observation, `p` scaled covariates are broadcast across `K` knot
#'     positions, and the knot positions themselves form the last channel.
#'   \item `pf_norm`: a 2-D tensor of shape `[N, 1]` — the query pF value
#'     normalised to `[0, 1]`.
#' }
#'
#' The output satisfies:
#' \deqn{\hat{\theta}(pF) = \theta_s - \int_0^{pF} \text{softplus}(s(t))\,dt}
#'
#' where \eqn{s(t)} is a 1-channel convolutional output.  Monotone decrease
#' is guaranteed **by construction** because the integrand is always positive.
#'
#' @references
#' Norouzi, A. M., et al. (2025). Physics-Informed Neural Networks for
#'   Estimating a Continuous Form of the Soil Water Retention Curve.
#'   *Journal of Hydrology*.
NULL

#' Build the CNN1D monotone-integral SWRC model
#'
#' Constructs a Keras model implementing the monotone-integral architecture
#' of Norouzi et al. (2025).  The returned list contains two models that
#' share weights:
#' * `theta_model` — full prediction model (pF query + covariates → theta).
#' * `param_model` — extracts the saturated water content (theta_s) from
#'   covariates only.
#'
#' @param n_covariates Integer. Number of soil-property covariates (`p`).
#' @param hidden       Integer vector of length 2. Number of filters in the
#'   first and second Conv1D layers (default `c(128L, 64L)`).
#' @param dropout      Numeric dropout rate after each Conv1D layer
#'   (default `0.10`).
#' @param K            Integer. Number of knot points for the cumulative
#'   integration grid (default `64L`).
#'
#' @return A named list:
#'   \describe{
#'     \item{`theta_model`}{Keras model: inputs `[Xseq_knots, pf_norm]`,
#'       output shape `[N, 2]` (theta_hat, theta_s).}
#'     \item{`param_model`}{Keras model: input `Xseq_knots`,
#'       output shape `[N, 1]` (theta_s only).}
#'     \item{`K`}{The `K` value used.}
#'     \item{`dk`}{The knot spacing `1 / (K - 1)`.}
#'     \item{`knot_grid`}{Numeric vector of knot positions.}
#'   }
#'
#' @examples
#' \donttest{
#' mod <- build_swrc_model(n_covariates = 9L)
#' }
#'
#' @export
build_swrc_model <- function(n_covariates,
                             hidden  = c(128L, 64L),
                             dropout = 0.10,
                             K       = 64L) {
  stopifnot(
    is.numeric(n_covariates), n_covariates >= 1L,
    length(hidden) == 2L,
    is.numeric(dropout), dropout >= 0, dropout < 1,
    is.numeric(K), K >= 2L
  )

  tf <- tensorflow::tf
  tf$keras$backend$clear_session()
  gc()

  K   <- as.integer(K)
  p   <- as.integer(n_covariates)
  C   <- as.integer(p + 1L)
  dk  <- 1.0 / (as.numeric(K) - 1.0)

  knot_grid <- seq(0, 1, length.out = K)

  # TF constants (shared across the Lambda layer)
  dk_c  <- tf$constant(dk,               dtype = "float32")
  Km1_c <- tf$constant(as.numeric(K-1L), dtype = "float32")
  Km1_i <- tf$constant(as.integer(K-1L), dtype = "int32")
  one_c <- tf$constant(1.0,              dtype = "float32")
  eps_c <- tf$constant(1e-6,             dtype = "float32")

  tpl <- reticulate::tuple

  # --- Inputs ---
  xseq_in <- tf$keras$Input(shape = tpl(K, C), name = "Xseq_knots")
  pf_in   <- tf$keras$Input(shape = list(1L),  name = "pf_norm")

  # --- Shared feature extraction (2 x Conv1D + Dropout) ---
  z <- xseq_in
  z <- tf$keras$layers$Conv1D(
    filters     = as.integer(hidden[1]),
    kernel_size = 3L,
    padding     = "same",
    activation  = "relu",
    name        = "conv1"
  )(z)
  z <- tf$keras$layers$Dropout(rate = dropout, name = "drop1")(z)
  z <- tf$keras$layers$Conv1D(
    filters     = as.integer(hidden[2]),
    kernel_size = 3L,
    padding     = "same",
    activation  = "relu",
    name        = "conv2"
  )(z)
  z <- tf$keras$layers$Dropout(rate = dropout, name = "drop2")(z)

  # --- Global average pooling -> theta_s (saturated WC) ---
  g       <- tf$keras$layers$GlobalAveragePooling1D(name = "gap")(z)
  theta_s <- tf$keras$layers$Dense(1L, activation = "sigmoid",
                                   name = "theta_s")(g)

  # --- Per-knot slope (monotone integrand) ---
  slope_raw <- tf$keras$layers$Conv1D(
    filters     = 1L,
    kernel_size = 1L,
    padding     = "same",
    activation  = NULL,
    name        = "slope_raw"
  )(z)

  # --- Monotone integral: theta_hat = theta_s - CumInt(softplus(slope)) ---
  theta_hat <- tf$keras$layers$Lambda(
    function(inputs) {
      ts  <- inputs[[1]]
      sr  <- inputs[[2]]
      pf  <- inputs[[3]]

      pf    <- tf$clip_by_value(pf, 0.0, 1.0)
      s_pos <- tf$nn$softplus(tf$squeeze(sr, axis = 2L)) + eps_c
      I_k   <- (tf$cumsum(s_pos, axis = 1L) - s_pos) * dk_c

      u  <- pf * Km1_c
      i0 <- tf$cast(tf$floor(u), tf$int32)
      i1 <- tf$minimum(i0 + 1L, Km1_i)
      t  <- u - tf$cast(i0, tf$float32)

      i0v <- tf$squeeze(i0, axis = 1L)
      i1v <- tf$squeeze(i1, axis = 1L)
      I0  <- tf$reshape(tf$gather(I_k, i0v, batch_dims = 1L), tpl(-1L, 1L))
      I1  <- tf$reshape(tf$gather(I_k, i1v, batch_dims = 1L), tpl(-1L, 1L))

      ts - ((one_c - t) * I0 + t * I1)
    },
    output_shape = tpl(1L),
    name         = "theta_hat"
  )(list(theta_s, slope_raw, pf_in))

  theta_out <- tf$keras$layers$Concatenate(
    axis = 1L, name = "theta_out"
  )(list(theta_hat, theta_s))

  # --- Assemble models ---
  theta_model <- tf$keras$Model(
    inputs  = list(xseq_in, pf_in),
    outputs = theta_out,
    name    = "CNN1D_SWRC_theta_model"
  )

  param_model <- tf$keras$Model(
    inputs  = xseq_in,
    outputs = theta_s,
    name    = "CNN1D_SWRC_param_model"
  )

  list(
    theta_model = theta_model,
    param_model = param_model,
    K           = K,
    dk          = dk,
    knot_grid   = knot_grid
  )
}
