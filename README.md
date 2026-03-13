# soilFlux <img src="man/figures/logo.png" align="right" height="170" alt="" />

<!-- badges: start -->
[![R-CMD-check](https://github.com/HugoMachadoRodrigues/soilFlux/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/HugoMachadoRodrigues/soilFlux/actions/workflows/R-CMD-check.yaml)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.18990856.svg)](https://doi.org/10.5281/zenodo.18990856)
<!-- badges: end -->

## Overview

**soilFlux** implements a physics-informed 1-D convolutional neural network
(CNN1D-PINN) for estimating the complete **soil water retention curve** (SWRC)
as a continuous function of matric potential. The architecture and physics
constraints are adapted from **Norouzi et al. (2025)** and implemented in R
via TensorFlow/Keras.

The model estimates volumetric water content (θ, m³/m³) at *any* pF value
from soil texture fractions, organic carbon, bulk density, and depth — without
discrete look-up tables.

### Why soilFlux?

| Classical PTFs | soilFlux |
|---|---|
| Predict θ at fixed pressure heads (e.g. FC, PWP) | Predict θ at **any** pF value |
| No physics constraints | Four physics constraints embedded in the loss |
| May violate monotonicity | **Monotone by construction** (cumulative integral) |
| Point estimates | Full continuous SWRC curves |

---

## Installation

```r
# Install from GitHub (development version)
remotes::install_github("HugoMachadoRodrigues/soilFlux")

# Install TensorFlow backend (once per machine)
tensorflow::install_tensorflow()
```

**Dependencies:** R ≥ 4.1, TensorFlow ≥ 2.14, keras3, reticulate.

---

## Quick example

```r
library(soilFlux)

# 1. Prepare data
data("swrc_example")
df <- prepare_swrc_data(swrc_example, depth_col = "depth")

# Split into train / validation / test
ids     <- unique(df$PEDON_ID)
set.seed(42)
tr_ids  <- sample(ids, floor(0.70 * length(ids)))
val_ids <- sample(setdiff(ids, tr_ids), floor(0.15 * length(ids)))
te_ids  <- setdiff(ids, c(tr_ids, val_ids))

train_df <- df[df$PEDON_ID %in% tr_ids,  ]
val_df   <- df[df$PEDON_ID %in% val_ids, ]
test_df  <- df[df$PEDON_ID %in% te_ids,  ]

# 2. Fit model
fit <- fit_swrc(
  train_df  = train_df,
  x_inputs  = c("clay", "silt", "bd_gcm3", "soc", "Depth_num"),
  val_df    = val_df,
  epochs    = 80,
  lambdas   = norouzi_lambdas("norouzi"),
  verbose   = TRUE
)

# 3. Evaluate
evaluate_swrc(fit, test_df)

# 4. Dense curve prediction
dense <- predict_swrc_dense(fit, newdata = test_df, n_points = 500)

# 5. Plot
plot_swrc(dense, obs_points = test_df,
          obs_col   = "theta_n",
          facet_row = "Depth_label",
          facet_col = "Texture")
```

---

## Architecture

The model takes two inputs:

1. **`Xseq_knots`** (shape `[N, K, p+1]`) — covariates broadcast across `K` knot positions.
2. **`pf_norm`** (shape `[N, 1]`) — query pF value normalised to `[0, 1]`.

Output:

$$\hat{\theta}(\text{pF}) = \theta_s - \int_0^{\text{pF}} \text{softplus}(s(t)) \, dt$$

where $s(t)$ is a Conv1D output.  Because `softplus > 0`, the integral is
strictly increasing, so $\hat{\theta}$ is **strictly decreasing** — monotonicity
is guaranteed *by architecture*, not by post-processing.

---

## Physics constraints (Norouzi et al. 2025, Table 1)

| Set | Physics condition | Domain | Weight |
|-----|-----------------|--------|--------|
| S1 | Linearity at dry end: ∣∂²θ/∂pF²∣ → 0 | pF ∈ [5.0, 7.6] | λ₃ = 1 |
| S2 | Non-negativity: θ(pF = 6.2) ≥ 0 | fixed | λ₄ = 1000 |
| S3 | Non-positivity: θ(pF = 7.6) ≤ 0 | fixed | λ₅ = 1000 |
| S4 | Flat saturated plateau: ∣∂θ/∂pF∣ → 0 | pF ∈ [−2.0, −0.3] | λ₆ = 1 |

Data loss weights: λ₁ = 1 (wet end, pF ≤ 4.2), λ₂ = 10 (dry end).

---

## Main functions

| Function | Purpose |
|---|---|
| `prepare_swrc_data()` | Standardise raw soil data |
| `fit_swrc()` | Train the CNN1D-PINN model |
| `predict_swrc()` | Predict θ at specific pF / head values |
| `predict_swrc_dense()` | Predict full SWRC curves |
| `predict_theta_s()` | Extract modelled θs |
| `evaluate_swrc()` | R², RMSE, MAE on test set |
| `swrc_metrics()` | Regression metrics |
| `norouzi_lambdas()` | Default loss-weight configurations |
| `build_residual_sets()` | Physics collocation points |
| `save_swrc_model()` | Save weights + metadata |
| `load_swrc_model()` | Reload saved model |
| `plot_swrc()` | SWRC curve figure |
| `plot_pred_obs()` | Predicted vs. observed plot |
| `plot_swrc_metrics()` | Model comparison bar chart |
| `plot_training_history()` | Training loss curves |
| `classify_texture()` | USDA texture classification |
| `texture_triangle()` | Ternary texture diagram |

---

## Reference

Norouzi, A. M., Feyereisen, G. W., Papanicolaou, A. N., & Wilson, C. G.
(2025). Physics-Informed Neural Networks for Estimating a Continuous Form
of the Soil Water Retention Curve. *Journal of Hydrology*.

---

## License

MIT © 2025 Hugo Rodrigues

