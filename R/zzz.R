#' soilFlux: Physics-Informed Neural Networks for Soil Water Retention Curves
#'
#' The `soilFlux` package implements a physics-informed 1-D convolutional
#' neural network (CNN1D-PINN) for estimating the complete soil water
#' retention curve (SWRC) as a continuous function of matric potential,
#' from soil texture, organic carbon, bulk density, and depth.
#'
#' ## Main functions
#'
#' | Function | Purpose |
#' |---|---|
#' | [prepare_swrc_data()] | Standardise raw soil data |
#' | [fit_swrc()] | Train the CNN1D-PINN model |
#' | [predict_swrc()] | Predict theta at given pF values |
#' | [predict_swrc_dense()] | Predict full SWRC curves |
#' | [swrc_metrics()] | Evaluate model performance |
#' | [plot_swrc()] | Plot retention curves |
#' | [plot_pred_obs()] | Predicted vs. observed plot |
#' | [save_swrc_model()] / [load_swrc_model()] | Persist the model |
#' | [classify_texture()] | USDA texture classification |
#'
#' ## References
#'
#' Norouzi, A. M., et al. (2025). Physics-Informed Neural Networks for
#'   Estimating a Continuous Form of the Soil Water Retention Curve.
#'   *Journal of Hydrology*.
#'
#' @keywords internal
"_PACKAGE"

# Suppress R CMD CHECK notes for NSE variables and TF operators
utils::globalVariables(c(
  ".data",
  # TF GradientTape context vars (assigned via `%as%`)
  "tape", "t2", "t4",
  # dplyr/ggplot2 NSE column names
  "Depth_label", "Depth_num", "theta_n",
  # ggplot2 aes variables
  "x", "y", "value", "epoch"
))

#' @importFrom tensorflow %as%
NULL

.onAttach <- function(libname, pkgname) {
  ver <- tryCatch(
    as.character(utils::packageVersion(pkgname)),
    error = function(e) "unknown"
  )
  packageStartupMessage(
    "\n",
    "  soilFlux v", ver, " -- Physics-Informed SWRC Modelling\n",
    "  Based on Norouzi et al. (2025)\n",
    "  Run ?soilFlux or vignette('introduction', package='soilFlux') for help.\n"
  )
}
