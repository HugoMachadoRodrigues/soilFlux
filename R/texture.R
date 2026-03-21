#' @title USDA soil texture classification
#' @name texture
#' @description Classify soil samples into USDA texture classes from sand,
#'   silt, and clay percentages, and create texture triangle plots.
NULL

#' Classify soil texture according to the USDA system
#'
#' Returns the USDA texture class name for each row based on the sand, silt,
#' and clay fractions.  Inputs are expected in per-cent (0–100) and must sum
#' to approximately 100.
#'
#' @param sand Numeric vector: sand content (%).
#' @param silt Numeric vector: silt content (%).
#' @param clay Numeric vector: clay content (%).
#' @param tol  Tolerance for the 100 % sum check (default `1.0`).
#'
#' @return Character vector of USDA texture class names.  Returns `NA`
#'   for rows where values are missing or do not sum to approximately 100.
#'
#' @examples
#' classify_texture(sand = c(70, 20, 10, 40),
#'                 silt = c(15, 50, 30, 40),
#'                 clay = c(15, 30, 60, 20))
#'
#' @export
classify_texture <- function(sand, silt, clay, tol = 1.0) {
  n    <- max(length(sand), length(silt), length(clay))
  sand <- rep_len(as.numeric(sand), n)
  silt <- rep_len(as.numeric(silt), n)
  clay <- rep_len(as.numeric(clay), n)

  result <- character(n)
  for (i in seq_len(n)) {
    sa <- sand[i]; si <- silt[i]; cl <- clay[i]
    if (any(is.na(c(sa, si, cl)))) { result[i] <- NA_character_; next }
    if (abs(sa + si + cl - 100) > tol) { result[i] <- NA_character_; next }
    result[i] <- .usda_class(sa, si, cl)
  }
  result
}

#' @keywords internal
.usda_class <- function(sa, si, cl) {
  # Reference: USDA Soil Survey Manual (2017)
  if (cl >= 60)                                   return("Clay")
  if (cl >= 40 && si >= 40)                        return("Silty Clay")
  if (cl >= 35 && sa >= 45)                        return("Sandy Clay")
  if (cl >= 40)                                    return("Clay")
  if (cl >= 27 && cl < 40 && si >= 20 && si < 40) return("Clay Loam")
  if (cl >= 27 && cl < 40 && si >= 40)             return("Silty Clay Loam")
  if (cl >= 20 && cl < 35 && sa >= 45 && si < 15) return("Sandy Clay Loam")
  if (cl >= 7  && cl < 27 && si >= 28 && si < 50 && sa <= 52) return("Loam")
  if ((cl < 12  && si >= 80) || (cl >= 12 && si >= 50))       return("Silt Loam")
  if (cl < 12  && si >= 50 && si < 80)            return("Silt Loam")
  if (si >= 80 && cl < 12)                         return("Silt")
  if (sa >= 85 && cl < 10 && si < 15)              return("Sand")
  if (sa >= 70 && sa < 85 && cl < 15 && si < 30)  return("Loamy Sand")
  if (sa >= 70 && cl < 20 && si < 30)              return("Sandy Loam")
  if (sa >= 52 && si < 28 && cl >= 7 && cl < 20)  return("Sandy Loam")
  if (sa < 52  && cl < 27 && si < 28)              return("Loam")
  "Loam"    # fallback
}

#' Add texture classification column to a data frame
#'
#' @param df       A data frame.
#' @param sand_col Column name for sand (default `"sand_total"`).
#' @param silt_col Column name for silt (default `"silt"`).
#' @param clay_col Column name for clay (default `"clay"`).
#' @param out_col  Name of the output column (default `"Texture"`).
#'
#' @return The input data frame with an additional `out_col` column.
#'
#' @examples
#' df <- data.frame(sand_total = c(70, 20), silt = c(15, 50), clay = c(15, 30))
#' add_texture(df)
#'
#' @export
add_texture <- function(df,
                        sand_col = "sand_total",
                        silt_col = "silt",
                        clay_col = "clay",
                        out_col  = "Texture") {
  stopifnot(is.data.frame(df))
  for (col in c(sand_col, silt_col, clay_col)) {
    if (!(col %in% names(df)))
      rlang::abort(paste("Column not found:", col))
  }
  df[[out_col]] <- classify_texture(
    sand = df[[sand_col]],
    silt = df[[silt_col]],
    clay = df[[clay_col]]
  )
  df
}

#' Plot a soil texture triangle (ternary diagram)
#'
#' Creates a ternary diagram coloured by a grouping variable using
#' `ggplot2`.  Requires the `ggtern` package (not a hard dependency).
#'
#' @param df         A data frame.
#' @param sand_col   Column name for sand (default `"sand_total"`).
#' @param silt_col   Column name for silt (default `"silt"`).
#' @param clay_col   Column name for clay (default `"clay"`).
#' @param color_col  Column name for colouring points (default `NULL` for
#'   a single colour).
#' @param title      Plot title.
#' @param point_size Point size (default `1.5`).
#' @param alpha      Point transparency (default `0.6`).
#'
#' @return A `ggplot` object (or `ggtern` object if `ggtern` is available).
#'
#' @examples
#' \donttest{
#' if (requireNamespace("ggtern", quietly = TRUE)) {
#'   df <- data.frame(sand_total = c(70, 20, 10),
#'                    silt = c(15, 50, 30),
#'                    clay = c(15, 30, 60),
#'                    Texture = c("Sand", "Silt Loam", "Clay"))
#'   p <- texture_triangle(df, color_col = "Texture")
#' }
#' }
#'
#' @importFrom ggplot2 ggplot aes geom_point labs theme_bw theme
#' @export
texture_triangle <- function(df,
                             sand_col   = "sand_total",
                             silt_col   = "silt",
                             clay_col   = "clay",
                             color_col  = NULL,
                             title      = "Soil Texture Triangle",
                             point_size = 1.5,
                             alpha      = 0.6) {
  if (!requireNamespace("ggtern", quietly = TRUE)) {
    message("Install 'ggtern' for a proper texture triangle: install.packages('ggtern')")
    message("Falling back to a projected scatter plot (clay vs sand).")
    p <- ggplot2::ggplot(df, ggplot2::aes(
      x      = .data[[sand_col]],
      y      = .data[[clay_col]],
      colour = if (!is.null(color_col)) .data[[color_col]] else NULL
    )) +
      ggplot2::geom_point(size = point_size, alpha = alpha) +
      ggplot2::labs(title = title, x = "Sand (%)", y = "Clay (%)") +
      ggplot2::theme_bw(base_size = 12)
    return(p)
  }

  aes_args <- list(
    T = as.name(clay_col),
    L = as.name(sand_col),
    R = as.name(silt_col)
  )
  if (!is.null(color_col))
    aes_args$colour <- as.name(color_col)

  ggtern::ggtern(df, do.call(ggtern::aes, aes_args)) +
    ggplot2::geom_point(size = point_size, alpha = alpha) +
    ggplot2::labs(title = title) +
    ggtern::theme_bw()
}
