# Generate man/figures/swrc_curves.png
# Shows both Van Genuchten (dashed) and CNN1D-PINN (solid, with linear dry end)
# for Sandy, Loam, and Clay soils.
# Run from the package root:
#   source("data-raw/make_swrc_figure.R")

library(ggplot2)
library(dplyr)
library(tidyr)

# ─── Van Genuchten parametric equation ─────────────────────────────────────
vg <- function(pf, thr, ths, alpha, n) {
  h <- 10^pf          # matric potential in cm
  m <- 1 - 1 / n
  thr + (ths - thr) / (1 + (alpha * h)^n)^m
}

# ─── PINN curve: VG shape → linear dry end ──────────────────────────────────
PF_LIN <- 5.0    # linear regime starts here
PF_DRY <- 7.6    # oven-dry (θ → 0)

swrc_pinn <- function(pf, thr, ths, alpha, n) {
  th_vg  <- vg(pf, thr, ths, alpha, n)
  th_t   <- vg(PF_LIN, thr, ths, alpha, n)   # θ at transition point
  slope  <- -th_t / (PF_DRY - PF_LIN)        # slope so θ → 0 at pF = 7.6
  th_lin <- pmax(0, th_t + slope * (pf - PF_LIN))
  ifelse(pf < PF_LIN, th_vg, th_lin)
}

# ─── Carsel & Parrish (1988) typical parameters ─────────────────────────────
params <- list(
  Sandy = list(thr = 0.045, ths = 0.43, alpha = 0.145, n = 2.68),
  Loam  = list(thr = 0.078, ths = 0.46, alpha = 0.036, n = 1.56),
  Clay  = list(thr = 0.095, ths = 0.50, alpha = 0.008, n = 1.09)
)

# ─── Build long-format data frame ───────────────────────────────────────────
pf_seq <- seq(-2, 7.6, length.out = 600)

curves <- lapply(names(params), function(tex) {
  p <- params[[tex]]
  data.frame(
    pF         = pf_seq,
    `Van Genuchten` = vg(pf_seq, p$thr, p$ths, p$alpha, p$n),
    `CNN1D-PINN`    = swrc_pinn(pf_seq, p$thr, p$ths, p$alpha, p$n),
    Texture    = tex,
    check.names = FALSE
  )
}) |> do.call(what = rbind)

curves$Texture <- factor(curves$Texture, levels = c("Sandy", "Loam", "Clay"))

curves_long <- tidyr::pivot_longer(
  curves,
  cols      = c("Van Genuchten", "CNN1D-PINN"),
  names_to  = "Model",
  values_to = "theta"
)
curves_long$Model <- factor(
  curves_long$Model,
  levels = c("Van Genuchten", "CNN1D-PINN")
)

# ─── Shaded regions ─────────────────────────────────────────────────────────
rect_S4 <- data.frame(xmin = -2.0, xmax = -0.3, ymin = -Inf, ymax = Inf)
rect_S1 <- data.frame(xmin =  5.0, xmax =  7.6, ymin = -Inf, ymax = Inf)

# ─── Colour palette ─────────────────────────────────────────────────────────
tex_cols <- c(Sandy = "#E6A817", Loam = "#5B9E6D", Clay = "#C15B5B")

# ─── Plot ───────────────────────────────────────────────────────────────────
p <- ggplot(curves_long, aes(x = pF, y = theta, colour = Texture, linetype = Model)) +
  # Shaded physics constraint regions
  geom_rect(data = rect_S4, inherit.aes = FALSE,
            aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
            fill = "#3A86FF", alpha = 0.08) +
  geom_rect(data = rect_S1, inherit.aes = FALSE,
            aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
            fill = "#FF6B35", alpha = 0.10) +
  # Region labels
  annotate("text", x = -1.15, y = 0.025, label = "S4",
           size = 2.9, colour = "#3A86FF", fontface = "bold", hjust = 0.5) +
  annotate("text", x =  6.30, y = 0.025, label = "S1",
           size = 2.9, colour = "#FF6B35", fontface = "bold", hjust = 0.5) +
  # Reference lines (FC and PWP)
  geom_vline(xintercept = 2.0, linetype = "dotted", linewidth = 0.4, colour = "grey55") +
  geom_vline(xintercept = 4.2, linetype = "dotted", linewidth = 0.4, colour = "grey55") +
  annotate("text", x = 2.0, y = 0.505, label = "FC",
           size = 2.7, colour = "grey40", hjust = -0.2) +
  annotate("text", x = 4.2, y = 0.505, label = "PWP",
           size = 2.7, colour = "grey40", hjust = -0.2) +
  # Curves
  geom_line(linewidth = 0.9) +
  # Scales
  scale_colour_manual(values = tex_cols) +
  scale_linetype_manual(
    values = c("Van Genuchten" = "dashed", "CNN1D-PINN" = "solid")
  ) +
  scale_x_continuous(
    breaks = seq(-2, 8, 2),
    limits = c(-2, 7.6),
    expand = c(0, 0)
  ) +
  scale_y_continuous(limits = c(0, 0.53), expand = c(0, 0.005)) +
  labs(
    x        = expression(italic(pF) ~ "(log"[10] ~ "cm)"),
    y        = expression(theta ~ "(m"^3 ~ "m"^{-3} ~ ")"),
    colour   = "Texture",
    linetype = "Model"
  ) +
  guides(
    colour   = guide_legend(order = 1, override.aes = list(linetype = "solid", linewidth = 1)),
    linetype = guide_legend(order = 2, override.aes = list(colour = "grey30", linewidth = 0.8))
  ) +
  theme_bw(base_size = 12) +
  theme(
    legend.position  = "right",
    legend.title     = element_text(size = 9, face = "bold"),
    legend.text      = element_text(size = 8),
    legend.key.width = unit(1.6, "cm"),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(colour = "grey93"),
    axis.title       = element_text(size = 10),
    plot.margin      = margin(8, 14, 8, 8)
  )

out <- file.path("man", "figures", "swrc_curves.png")
ggsave(
  filename = out,
  plot     = p,
  width    = 7.5,
  height   = 3.8,
  dpi      = 200,
  bg       = "white"
)
message("Saved: ", out)
