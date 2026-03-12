# =============================================================================
# Create the swrc_example dataset bundled with soilFlux
#
# Generates a synthetic but realistic soil characterisation dataset that
# mimics the structure of the Florida Soil Characterization Database (FSCD)
# used in Rodrigues & Norouzi et al. (2025).
#
# Run this script once from the package root:
#   source("data-raw/create_example_data.R")
#
# Output: data/swrc_example.rda
# =============================================================================

set.seed(2025)

n_pedons <- 120L          # number of unique soil profiles
depths   <- c("0-5", "5-15", "15-30", "30-60", "60-100")  # depth intervals
n_heads  <- 8L            # number of matric-head measurement points per depth

# Typical pF measurement points: pF 0, 1, 1.5, 2, 2.5, 3, 4.2, 7.0
heads_cm <- c(1, 10, 32, 100, 316, 1000, 15849, 1e7)

# ---- Texture categories (approximate USDA proportions) -------------------
texture_classes <- list(
  Sand        = list(sand = c(80, 92), silt = c(0, 12), clay = c(0, 8)),
  "Loamy Sand" = list(sand = c(70, 85), silt = c(5, 20), clay = c(5, 15)),
  "Sandy Loam" = list(sand = c(45, 70), silt = c(10, 30), clay = c(5, 20)),
  Loam        = list(sand = c(25, 50), silt = c(25, 50), clay = c(10, 27)),
  "Silt Loam"  = list(sand = c(0, 50), silt = c(50, 90), clay = c(0, 27)),
  "Clay Loam"  = list(sand = c(20, 45), silt = c(15, 55), clay = c(27, 40)),
  Clay        = list(sand = c(0, 45), silt = c(0, 40), clay = c(40, 100))
)

gen_texture <- function(class_name) {
  tc <- texture_classes[[class_name]]
  sa <- runif(1, tc$sand[1], tc$sand[2])
  si <- runif(1, tc$silt[1], tc$silt[2])
  cl <- 100 - sa - si
  cl <- max(tc$clay[1], min(tc$clay[2], cl))
  si <- 100 - sa - cl
  c(sand = sa, silt = si, clay = cl)
}

# ---- van Genuchten SWRC (physics-based theta generation) -----------------
vg_theta <- function(h, theta_r, theta_s, alpha, n) {
  m    <- 1 - 1 / n
  Se   <- (1 + (alpha * h)^n)^(-m)
  theta_r + (theta_s - theta_r) * Se
}

rows <- vector("list", n_pedons * length(depths) * n_heads)
idx  <- 1L

class_names <- names(texture_classes)
n_classes   <- length(class_names)

for (pid in seq_len(n_pedons)) {
  pedon_id   <- sprintf("P%04d", pid)
  class_name <- class_names[((pid - 1L) %% n_classes) + 1L]
  tex        <- gen_texture(class_name)

  sa <- tex["sand"]; si <- tex["silt"]; cl <- tex["clay"]

  # Sand fractions (very fine, fine, medium, coarse)
  vf <- runif(1, 0.05, 0.20) * sa
  fi <- runif(1, 0.25, 0.40) * sa
  md <- runif(1, 0.20, 0.35) * sa
  co <- sa - vf - fi - md

  soc    <- exp(rnorm(1, mean = log(1.5), sd = 0.6))  # % (log-normal)
  bd     <- rnorm(1, mean = 1.35 - 0.004 * cl, sd = 0.07)

  for (dep in depths) {
    depth_val <- as.numeric(strsplit(dep, "-")[[1]])
    depth_mid <- mean(depth_val)

    # van Genuchten parameters vary with depth and texture
    theta_s <- pmax(0.30, 0.55 - 0.0012 * depth_mid + 0.002 * cl + rnorm(1, 0, 0.02))
    theta_r <- pmax(0,    0.02 + 0.0005 * cl + rnorm(1, 0, 0.005))
    alpha   <- exp(rnorm(1, mean = log(0.04 - 0.0003 * cl + 0.0001 * sa), sd = 0.3))
    n_vg    <- pmax(1.05, rnorm(1, mean = 1.5 + 0.01 * sa - 0.005 * cl, sd = 0.15))

    for (h in heads_cm) {
      theta <- vg_theta(h, theta_r, theta_s, alpha, n_vg)
      theta <- pmax(0, theta + rnorm(1, 0, 0.005))  # add small noise

      rows[[idx]] <- list(
        PEDON_ID    = pedon_id,
        sand_total  = round(sa, 2),
        silt        = round(si, 2),
        clay        = round(cl, 2),
        soc         = round(soc, 3),
        bd          = round(bd, 3),
        sand_vf     = round(vf, 2),
        sand_f      = round(fi, 2),
        sand_m      = round(md, 2),
        sand_c      = round(co, 2),
        matric_head = h,
        water_content = round(theta, 4),
        depth       = dep,
        Texture     = class_name
      )
      idx <- idx + 1L
    }
  }
}

swrc_example <- do.call(rbind, lapply(rows, as.data.frame))
swrc_example <- swrc_example[!is.na(swrc_example$water_content), ]

# Add a small fraction of NA to make it realistic
na_idx <- sample(nrow(swrc_example), size = floor(0.01 * nrow(swrc_example)))
swrc_example$water_content[na_idx] <- NA

message("Created swrc_example with ", nrow(swrc_example), " rows and ",
        n_pedons, " unique profiles.")
message("Texture distribution:")
print(table(swrc_example$Texture[!duplicated(swrc_example$PEDON_ID)]))

# Save
usethis::use_data(swrc_example, overwrite = TRUE, compress = "xz")
message("Saved to data/swrc_example.rda")
