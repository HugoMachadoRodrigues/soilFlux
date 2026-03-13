#' @title Data preparation for CNN1D SWRC modelling
#' @name data_prep
#' @description Functions to prepare soil data for input to the CNN1D
#'   monotone-integral model, including 3-D sequence array construction and
#'   observation matrix creation.
NULL

#' Prepare a soil data frame for SWRC modelling
#'
#' A convenience wrapper that:
#' \enumerate{
#'   \item Renames columns to standard names.
#'   \item Parses the depth column.
#'   \item Fixes bulk-density units.
#'   \item Detects and normalises volumetric water content units.
#'   \item Computes per-profile maximum theta.
#'   \item Drops rows with missing key variables.
#' }
#'
#' @param df            A data frame with soil characterization data.
#' @param x_cols        Named character vector mapping standard names to
#'   actual column names.  Standard names: `"PEDON_ID"`, `"sand"`,
#'   `"silt"`, `"clay"`, `"soc"`, `"bd"`, `"matric_head"`,
#'   `"water_content"`, `"depth"`.  Unneeded variables may be omitted.
#' @param depth_col     Column name for depth (character string, default
#'   `"depth"`).  If already parsed, set to `NULL`.
#' @param fix_bd        Logical; apply [fix_bd_units()] to bulk density
#'   (default `TRUE`).
#' @param fix_theta     Logical; scale theta to m3/m3 if needed (default
#'   `TRUE`).
#'
#' @return A tibble with standardised columns plus `Depth_num`,
#'   `Depth_label`, `bd_gcm3`, `theta_n` (normalised WC), and
#'   `theta_max_n` (per-profile maximum theta).
#'
#' @examples
#' \dontrun{
#' df_prep <- prepare_swrc_data(raw_df,
#'   x_cols = c(PEDON_ID = "ID", sand = "sand_pct", ...))
#' }
#'
#' @importFrom dplyr mutate group_by ungroup select left_join
#' @importFrom tidyr drop_na
#' @importFrom purrr map map_dbl map_chr
#' @export
prepare_swrc_data <- function(df,
                              x_cols    = NULL,
                              depth_col = "depth",
                              fix_bd    = TRUE,
                              fix_theta = TRUE) {
  stopifnot(is.data.frame(df))

  # Rename columns if mapping provided
  if (!is.null(x_cols)) {
    stopifnot(is.character(x_cols), !is.null(names(x_cols)))
    for (std in names(x_cols)) {
      actual <- x_cols[[std]]
      if (actual %in% names(df) && !(std %in% names(df))) {
        names(df)[names(df) == actual] <- std
      }
    }
  }

  # Parse depth column
  if (!is.null(depth_col) && depth_col %in% names(df)) {
    df <- parse_depth_column(df, depth_col)
  }

  # Fix bulk density units
  if (fix_bd && "bd" %in% names(df)) {
    df$bd_gcm3 <- fix_bd_units(df$bd)
  } else if ("bd" %in% names(df)) {
    df$bd_gcm3 <- as.numeric(df$bd)
  }

  # Normalise water content
  if (fix_theta && "water_content" %in% names(df)) {
    fac        <- theta_unit_factor(df$water_content)
    df$theta_n <- as.numeric(df$water_content) / fac
    attr(df, "theta_factor") <- fac
  } else if ("water_content" %in% names(df)) {
    df$theta_n <- as.numeric(df$water_content)
    attr(df, "theta_factor") <- 1
  }

  # Compute per-profile maximum theta
  if ("theta_n" %in% names(df) && "PEDON_ID" %in% names(df)) {
    key_cols <- intersect(c("PEDON_ID", "Depth_num"), names(df))
    df <- df |>
      dplyr::group_by(dplyr::across(dplyr::all_of(key_cols))) |>
      dplyr::mutate(theta_max_n = max(theta_n, na.rm = TRUE)) |>
      dplyr::ungroup()
  }

  tibble::as_tibble(df)
}

# ---------------------------------------------------------------------------
# Observation matrix builder
# ---------------------------------------------------------------------------

#' Build observation matrices for the CNN1D model
#'
#' Converts a prepared data frame into the arrays needed for training or
#' evaluation: a 3-D sequence array `Xseq` (shape `[N, K, p+1]`) and
#' companion vectors `pf`, `y`, and sample weights `w`.
#'
#' @param df           A prepared data frame (output of [prepare_swrc_data()]
#'   or compatible structure) containing covariate columns, `matric_head`,
#'   `theta_n`, and `theta_max_n`.
#' @param x_inputs     Character vector of covariate column names.
#' @param scaler       A fitted scaler from [fit_minmax()].
#' @param K            Number of knot points (default `64L`).
#' @param knot_grid    Numeric vector of knot positions (default
#'   `seq(0, 1, length.out = K)`).
#' @param pf_left      Left boundary of the pF domain (default `-2`).
#' @param pf_right     Right boundary of the pF domain (default `7.6`).
#' @param wet_split_cm Matric head threshold (cm) separating wet / dry end
#'   (default `4.2`, corresponding to pF approximately 0.62).
#' @param w_wet        Sample weight for wet-end observations (default `1`).
#' @param w_dry        Sample weight for dry-end observations (default `1`).
#'
#' @return A named list:
#'   \describe{
#'     \item{`Xseq`}{3-D numeric array \[N, K, p+1\].}
#'     \item{`pf`}{Numeric matrix \[N, 1\] of normalised pF values.}
#'     \item{`y`}{Numeric matrix \[N, 2\]: columns are `theta_n` and
#'       `theta_max_n`.}
#'     \item{`w`}{Numeric vector of sample weights.}
#'   }
#'
#' @keywords internal
#' @export
make_obs_matrices <- function(df, x_inputs, scaler,
                              K            = 64L,
                              knot_grid    = seq(0, 1, length.out = K),
                              pf_left      = -2.0,
                              pf_right     =  7.6,
                              wet_split_cm = 4.2,
                              w_wet        = 1.0,
                              w_dry        = 1.0) {
  Xcov <- apply_minmax(df, scaler)
  N    <- nrow(Xcov)
  p    <- ncol(Xcov)
  K    <- as.integer(K)

  Xseq <- array(0, dim = c(N, K, p + 1L))
  for (i in seq_len(N)) {
    Xseq[i, , seq_len(p)] <- matrix(rep(Xcov[i, ], each = K),
                                    nrow = K, byrow = FALSE)
    Xseq[i, , p + 1L]     <- knot_grid
  }

  h       <- as.numeric(df$matric_head)
  pf_norm <- head_normalize(h, pf_left, pf_right)
  y_theta <- as.numeric(df$theta_n)
  y_max   <- as.numeric(df$theta_max_n)
  y_max[!is.finite(y_max)] <- y_theta[!is.finite(y_max)]
  w       <- ifelse(h <= wet_split_cm, w_wet, w_dry)

  list(
    Xseq = Xseq,
    pf   = matrix(pf_norm, ncol = 1L),
    y    = cbind(y_theta, y_max),
    w    = as.numeric(w)
  )
}

# ---------------------------------------------------------------------------
# Sequence array for profile prediction
# ---------------------------------------------------------------------------

#' Build a sequence array for one or more soil profiles
#'
#' Each row of `df_profiles` (one profile) is expanded over a pF grid to
#' produce the `[N_profiles * N_pf, K, p+1]` array needed for dense
#' curve prediction.
#'
#' @param df_profiles  Data frame with one row per profile (unique PEDON ×
#'   depth combination).
#' @param x_inputs     Character vector of covariate names.
#' @param scaler       Fitted scaler from [fit_minmax()].
#' @param K            Number of knots (default `64L`).
#' @param knot_grid    Knot positions (default `seq(0,1,length.out=K)`).
#'
#' @return Named list:
#'   \describe{
#'     \item{`Xseq`}{3-D array \[Np, K, p+1\].}
#'     \item{`Np`}{Number of profiles.}
#'     \item{`p`}{Number of covariates.}
#'   }
#'
#' @keywords internal
#' @export
make_profile_array <- function(df_profiles, x_inputs, scaler,
                               K         = 64L,
                               knot_grid = seq(0, 1, length.out = K)) {
  Xcov <- apply_minmax(df_profiles, scaler)
  Np   <- nrow(Xcov)
  p    <- ncol(Xcov)
  K    <- as.integer(K)

  Xseq <- array(0, dim = c(Np, K, p + 1L))
  for (i in seq_len(Np)) {
    Xseq[i, , seq_len(p)] <- matrix(rep(Xcov[i, ], each = K),
                                    nrow = K, byrow = FALSE)
    Xseq[i, , p + 1L]     <- knot_grid
  }

  list(Xseq = Xseq, Np = Np, p = p)
}
