#' @title Publication-quality plots for SWRC analysis
#' @name plots
#' @description Functions for visualising soil water retention curves,
#'   predicted vs. observed scatter plots, and model performance metrics.
NULL

#' Plot soil water retention curves (SWRC)
#'
#' Creates a `ggplot2` figure showing continuous SWRC predictions
#' (lines) optionally overlaid with observed data points.
#'
#' @param pred_curves  A data frame (or tibble) of dense curve predictions,
#'   typically returned by [predict_swrc_dense()].  Must contain columns
#'   `pF` and `theta`.
#' @param obs_points   Optional data frame of observed data.  Must contain
#'   `pF` and `theta` columns (or `matric_head` and a theta column).
#' @param curve_col    Column in `pred_curves` for the predicted theta
#'   (default `"theta"`).
#' @param obs_col      Column in `obs_points` for observed theta (default
#'   `"theta_n"`).
#' @param group_col    Column name used to distinguish individual profiles
#'   in `pred_curves` (default `"PEDON_ID"`).
#' @param facet_row    Column for facet rows (default `NULL`).
#' @param facet_col    Column for facet columns (default `NULL`).
#' @param x_limits     Numeric vector of length 2 for the x-axis (theta)
#'   range (default `NULL`, auto).
#' @param y_limits     Numeric vector of length 2 for the y-axis (pF)
#'   range (default `c(-0.25, 7.75)`).
#' @param line_colour  Colour of the predicted curve lines (default
#'   `"steelblue4"`).
#' @param point_colour Colour of the observed data points (default
#'   `"black"`).
#' @param base_size    Base font size for `theme_bw` (default `12`).
#' @param title        Plot title (default `NULL`).
#'
#' @return A `ggplot` object.
#'
#' @examples
#' \dontrun{
#' dense <- predict_swrc_dense(fit, newdata = test_df)
#' plot_swrc(dense, obs_points = test_df,
#'           facet_row = "Depth_label", facet_col = "Texture")
#' }
#'
#' @importFrom ggplot2 ggplot aes geom_path geom_point facet_grid
#'   scale_x_continuous scale_y_continuous labs theme_bw theme element_rect
#'   element_text element_blank
#' @export
plot_swrc <- function(pred_curves,
                      obs_points   = NULL,
                      curve_col    = "theta",
                      obs_col      = "theta_n",
                      group_col    = "PEDON_ID",
                      facet_row    = NULL,
                      facet_col    = NULL,
                      x_limits     = NULL,
                      y_limits     = c(-0.25, 7.75),
                      line_colour  = "steelblue4",
                      point_colour = "black",
                      base_size    = 12,
                      title        = NULL) {

  stopifnot(
    "pF"       %in% names(pred_curves),
    curve_col  %in% names(pred_curves)
  )

  # Build group aesthetic
  if (group_col %in% names(pred_curves)) {
    group_aes <- interaction(pred_curves[[group_col]])
  } else {
    group_aes <- rep(1, nrow(pred_curves))
  }

  p <- ggplot2::ggplot() +
    ggplot2::geom_path(
      data    = pred_curves,
      mapping = ggplot2::aes(
        x     = .data[[curve_col]],
        y     = .data[["pF"]],
        group = group_aes
      ),
      linewidth = 0.9,
      colour    = line_colour
    )

  # Observed points
  if (!is.null(obs_points)) {
    # Allow matric_head -> pF conversion if pF not present
    if (!("pF" %in% names(obs_points)) && "matric_head" %in% names(obs_points))
      obs_points$pF <- pf_from_head(obs_points$matric_head)

    stopifnot(obs_col %in% names(obs_points), "pF" %in% names(obs_points))
    p <- p + ggplot2::geom_point(
      data    = obs_points,
      mapping = ggplot2::aes(x = .data[[obs_col]], y = .data[["pF"]]),
      size    = 1.4,
      alpha   = 0.75,
      colour  = point_colour
    )
  }

  # Faceting
  if (!is.null(facet_row) && !is.null(facet_col)) {
    p <- p + ggplot2::facet_grid(
      rows = ggplot2::vars(.data[[facet_row]]),
      cols = ggplot2::vars(.data[[facet_col]])
    )
  } else if (!is.null(facet_col)) {
    p <- p + ggplot2::facet_wrap(ggplot2::vars(.data[[facet_col]]))
  } else if (!is.null(facet_row)) {
    p <- p + ggplot2::facet_wrap(ggplot2::vars(.data[[facet_row]]))
  }

  p +
    ggplot2::scale_y_continuous(
      breaks = c(0, 2.5, 5.0, 7.5),
      limits = y_limits
    ) +
    ggplot2::labs(
      x     = expression(theta ~ (m^3 ~ m^{-3})),
      y     = expression(pF == log[10](h ~ "[cm]")),
      title = title
    ) +
    ggplot2::theme_bw(base_size = base_size) +
    ggplot2::theme(
      strip.background = ggplot2::element_rect(fill = "grey95"),
      strip.text       = ggplot2::element_text(size  = base_size,
                                               face  = "bold",
                                               colour = "black"),
      axis.title       = ggplot2::element_text(size  = base_size + 2,
                                               face  = "bold",
                                               colour = "black"),
      axis.text        = ggplot2::element_text(size  = base_size,
                                               face  = "bold",
                                               colour = "black"),
      panel.grid.minor = ggplot2::element_blank()
    )
}

#' Plot predicted vs. observed water content
#'
#' Creates a scatter plot of predicted vs. observed theta with a 1:1 line
#' and optional regression line, optionally faceted by a grouping variable.
#'
#' @param df          Data frame containing observed and predicted columns.
#' @param obs_col     Column name for observed theta (default `"theta_n"`).
#' @param pred_col    Column name for predicted theta (default
#'   `"theta_predicted"`).
#' @param group_col   Column name for facet grouping (default `NULL`).
#' @param show_lm     Logical; add a linear regression line (default `TRUE`).
#' @param show_stats  Logical; add R², RMSE, MAE text annotations (default
#'   `TRUE`).
#' @param ncol        Number of facet columns when `group_col` is supplied
#'   (default `5`).
#' @param base_size   Base font size (default `12`).
#' @param point_alpha Point transparency (default `0.25`).
#' @param title       Plot title (default `NULL`).
#'
#' @return A `ggplot` object.
#'
#' @examples
#' \dontrun{
#' df <- data.frame(theta_n = obs, theta_predicted = pred, Texture = grp)
#' plot_pred_obs(df, group_col = "Texture")
#' }
#'
#' @importFrom ggplot2 ggplot aes geom_point geom_abline geom_smooth
#'   geom_text coord_equal labs theme_bw theme facet_wrap element_rect
#'   element_text element_blank
#' @importFrom dplyr group_by summarise
#' @export
plot_pred_obs <- function(df,
                          obs_col      = "theta_n",
                          pred_col     = "theta_predicted",
                          group_col    = NULL,
                          show_lm      = TRUE,
                          show_stats   = TRUE,
                          ncol         = 5L,
                          base_size    = 12,
                          point_alpha  = 0.25,
                          title        = NULL) {
  stopifnot(
    is.data.frame(df),
    obs_col  %in% names(df),
    pred_col %in% names(df)
  )

  lims  <- range(c(df[[obs_col]], df[[pred_col]]), na.rm = TRUE)
  x_span <- diff(lims)

  p <- ggplot2::ggplot(df, ggplot2::aes(x = .data[[obs_col]],
                                        y = .data[[pred_col]])) +
    ggplot2::geom_point(alpha = point_alpha, size = 0.85, colour = "steelblue") +
    ggplot2::geom_abline(slope = 1, intercept = 0,
                         colour = "red", linewidth = 0.9)

  if (show_lm)
    p <- p + ggplot2::geom_smooth(method = "lm", se = FALSE,
                                  colour = "black", linewidth = 0.75,
                                  linetype = "dashed",
                                  formula = y ~ x)

  if (show_stats) {
    if (!is.null(group_col) && group_col %in% names(df)) {
      stats_df <- swrc_metrics_by_group(df, obs_col, pred_col, group_col)
      stats_df$label <- sprintf("R\u00B2 = %.2f\nRMSE = %.3f\nMAE = %.3f",
                                stats_df$R2, stats_df$RMSE, stats_df$MAE)
      stats_df$x <- lims[1] + 0.04 * x_span
      stats_df$y <- lims[2] - 0.06 * x_span

      p <- p + ggplot2::geom_text(
        data    = stats_df,
        mapping = ggplot2::aes(x = x, y = y, label = label),
        inherit.aes = FALSE,
        hjust = 0, vjust = 1, size = 3.9, lineheight = 1.0
      )
    } else {
      m     <- swrc_metrics(df[[obs_col]], df[[pred_col]])
      label <- sprintf("R\u00B2 = %.2f\nRMSE = %.3f\nMAE = %.3f",
                       m$R2, m$RMSE, m$MAE)
      p <- p + ggplot2::annotate(
        "text",
        x = lims[1] + 0.04 * x_span,
        y = lims[2] - 0.06 * x_span,
        label = label, hjust = 0, vjust = 1, size = 3.9
      )
    }
  }

  if (!is.null(group_col) && group_col %in% names(df)) {
    p <- p + ggplot2::facet_wrap(ggplot2::vars(.data[[group_col]]),
                                 ncol = ncol)
  }

  p +
    ggplot2::coord_equal(xlim = lims, ylim = lims) +
    ggplot2::labs(
      x     = expression("Observed" ~ theta ~ (m^3 ~ m^{-3})),
      y     = expression("Predicted" ~ theta ~ (m^3 ~ m^{-3})),
      title = title
    ) +
    ggplot2::theme_bw(base_size = base_size) +
    ggplot2::theme(
      strip.background = ggplot2::element_rect(fill = "grey95"),
      strip.text       = ggplot2::element_text(size   = base_size + 1,
                                               face   = "bold"),
      axis.title       = ggplot2::element_text(size   = base_size + 2,
                                               face   = "bold"),
      axis.text        = ggplot2::element_text(size   = base_size,
                                               face   = "bold",
                                               colour = "black"),
      panel.grid.minor = ggplot2::element_blank()
    )
}

#' Plot model performance metric comparison
#'
#' Creates a bar chart comparing R², RMSE, and MAE across multiple models
#' or configurations.
#'
#' @param metrics_df  A data frame with columns `model` (character/factor),
#'   `R2`, `RMSE`, `MAE`.  Typically produced by stacking the output of
#'   [swrc_metrics()].
#' @param model_col   Column name for the model identifier (default
#'   `"model"`).
#' @param palette     RColorBrewer palette (default `"Blues"`).
#' @param base_size   Base font size (default `12`).
#' @param title       Plot title (default `NULL`).
#'
#' @return A `ggplot` object.
#'
#' @examples
#' \dontrun{
#' m1 <- swrc_metrics(obs, pred1) |> dplyr::mutate(model = "Model 1")
#' m2 <- swrc_metrics(obs, pred2) |> dplyr::mutate(model = "Model 2")
#' plot_swrc_metrics(dplyr::bind_rows(m1, m2))
#' }
#'
#' @importFrom ggplot2 ggplot aes geom_col facet_wrap scale_fill_brewer
#'   labs theme_bw theme element_text element_blank element_rect
#' @importFrom tidyr pivot_longer
#' @export
plot_swrc_metrics <- function(metrics_df,
                              model_col = "model",
                              palette   = "Blues",
                              base_size = 12,
                              title     = NULL) {
  stopifnot(is.data.frame(metrics_df),
            all(c("R2", "RMSE", "MAE", model_col) %in% names(metrics_df)))

  long_df <- tidyr::pivot_longer(
    metrics_df,
    cols      = c("R2", "RMSE", "MAE"),
    names_to  = "metric",
    values_to = "value"
  )
  long_df$metric <- factor(long_df$metric,
                           levels = c("R2", "RMSE", "MAE"),
                           labels = c("R\u00B2", "RMSE (m\u00B3/m\u00B3)",
                                      "MAE (m\u00B3/m\u00B3)"))

  ggplot2::ggplot(
    long_df,
    ggplot2::aes(x = .data[[model_col]], y = value,
                 fill = .data[[model_col]])
  ) +
    ggplot2::geom_col(width = 0.65, color = "grey30", linewidth = 0.3) +
    ggplot2::facet_wrap(~ metric, scales = "free_y", ncol = 3L) +
    ggplot2::scale_fill_brewer(palette = palette) +
    ggplot2::labs(x = NULL, y = NULL, fill = "Model", title = title) +
    ggplot2::theme_bw(base_size = base_size) +
    ggplot2::theme(
      axis.text.x      = ggplot2::element_text(angle = 30, hjust = 1,
                                               size = base_size,
                                               face = "bold",
                                               colour = "black"),
      axis.text.y      = ggplot2::element_text(size = base_size,
                                               face = "bold",
                                               colour = "black"),
      strip.text       = ggplot2::element_text(size = base_size + 1,
                                               face = "bold",
                                               colour = "black"),
      legend.position  = "none",
      strip.background = ggplot2::element_rect(fill = "grey95"),
      panel.grid.minor = ggplot2::element_blank()
    )
}

#' Plot training loss history
#'
#' Plots the per-epoch training and (optionally) validation loss from the
#' `history` slot of a `swrc_fit` object.
#'
#' @param fit       A `swrc_fit` object.
#' @param loss_col  Column in `fit$history` to display (default `"loss"`).
#' @param val_col   Validation loss column (default `"val_mse"`).
#'   Pass `NULL` to omit.
#' @param base_size Base font size (default `12`).
#'
#' @return A `ggplot` object.
#'
#' @importFrom ggplot2 ggplot aes geom_line labs theme_bw
#' @export
plot_training_history <- function(fit,
                                  loss_col  = "loss",
                                  val_col   = "val_mse",
                                  base_size = 12) {
  stopifnot(inherits(fit, "swrc_fit"), !is.null(fit$history))
  h <- fit$history

  p <- ggplot2::ggplot(h, ggplot2::aes(x = epoch)) +
    ggplot2::geom_line(ggplot2::aes(y = .data[[loss_col]],
                                   colour = "Training"), linewidth = 0.9)

  if (!is.null(val_col) && val_col %in% names(h)) {
    hv <- h[is.finite(h[[val_col]]), ]
    p <- p + ggplot2::geom_line(
      data    = hv,
      mapping = ggplot2::aes(y = .data[[val_col]], colour = "Validation"),
      linewidth = 0.9
    )
  }

  p +
    ggplot2::scale_colour_manual(
      values = c(Training = "steelblue4", Validation = "tomato3")
    ) +
    ggplot2::labs(x = "Epoch", y = "Loss", colour = NULL,
                  title = "Training history") +
    ggplot2::theme_bw(base_size = base_size)
}
