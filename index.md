# soilFlux

> **Physics-informed CNN1D for estimating the complete soil water
> retention curve (SWRC) as a continuous, monotone function of matric
> potential.**

![CNN1D-PINN predictions for Sandy, Loam and Clay
soils](reference/figures/swrc_curves.png)

------------------------------------------------------------------------

## Overview

Classical pedotransfer functions (PTFs) predict volumetric water content
(θ) at a handful of fixed pressure heads — field capacity (pF 2.0),
wilting point (pF 4.2), etc. — leaving gaps between measurements and
offering no guarantee of physical consistency.

**soilFlux** fills the entire curve. Given a soil sample described by
texture fractions, organic carbon, bulk density, and depth, the model
returns θ at *any* pF value in \[−2, 7.6\], with four physics
constraints baked into the loss function and strict monotonicity
guaranteed *by architecture*.

------------------------------------------------------------------------

## Why not Van Genuchten?

The Van Genuchten (1980) equation is the standard parametric SWRC model:

$$\theta(h) = \theta_{r} + \frac{\theta_{s} - \theta_{r}}{\left\lbrack 1 + (\alpha\, h)^{n} \right\rbrack^{1 - 1/n}}$$

where *h* = matric potential (cm), θ_r = residual water content, θ_s =
saturated water content, α = inverse air-entry pressure, and *n* =
pore-size distribution index.

Fitting VG requires **measured data at several pressure heads per
sample** and a nonlinear optimiser — and the parametric form can still
violate monotonicity near the wet end. soilFlux replaces parameter
fitting with a single forward pass through a trained neural network:

$$\widehat{\theta}\left( \text{pF} \right) = \theta_{s} - \int_{0}^{\text{pF}}\text{softplus}\!(s(t))\, dt$$

where $s(t)$ is a Conv1D output and softplus \> 0 everywhere, so the
integral is strictly increasing and $\widehat{\theta}$ is **strictly
decreasing** — *monotonicity is a structural property, not a
post-processing step.*

|                         | Van Genuchten                    | soilFlux (CNN1D-PINN)             |
|-------------------------|----------------------------------|-----------------------------------|
| **Inputs**              | Measured θ at ≥ 4 pressure heads | Texture, OC, BD, depth            |
| **Outputs**             | θ at *any* h (after fitting)     | θ at *any* pF (direct inference)  |
| **Monotonicity**        | Not guaranteed                   | ✅ By architecture                |
| **Physics constraints** | None                             | ✅ 4 residual constraints in loss |
| **New samples**         | Re-fit required                  | Single forward pass               |
| **Uncertainty**         | Delta method / bootstrap         | Prediction interval via ensemble  |

------------------------------------------------------------------------

## Architecture

[TABLE]

------------------------------------------------------------------------

## Loss function (Norouzi et al. 2025)

The total training loss combines a **data term** and four **physics
residual terms**, each weighted by a tunable λ:

$$\mathcal{L} = \underset{\text{data loss}}{\underbrace{\lambda_{1}\mathcal{L}_{\text{wet}} + \lambda_{2}\mathcal{L}_{\text{dry}}}} + \underset{\text{physics loss}}{\underbrace{\lambda_{3}\mathcal{L}_{S1} + \lambda_{4}\mathcal{L}_{S2} + \lambda_{5}\mathcal{L}_{S3} + \lambda_{6}\mathcal{L}_{S4}}}$$

### Data loss

The observed data are split at pF = 4.2 (wilting point) and weighted
separately to balance the large dynamic range of the curve:

$$\mathcal{L}_{\text{wet}} = \frac{1}{N_{w}}\sum\limits_{i \in \text{wet}}({\widehat{\theta}}_{i} - \theta_{i})^{2},\qquad\mathcal{L}_{\text{dry}} = \frac{1}{N_{d}}\sum\limits_{i \in \text{dry}}({\widehat{\theta}}_{i} - \theta_{i})^{2}$$

with λ₁ = 1, λ₂ = 10 — the dry end is up-weighted because observed
values are close to zero and small absolute errors carry proportionally
more weight.

### Physics residuals

Collocation points {$t_{j}$} are sampled from each constraint domain at
each training step. Gradients are computed via automatic differentiation
(TensorFlow `GradientTape`).

| Set                     | Residual loss                                                                                                                         | Domain              | λ          |
|-------------------------|---------------------------------------------------------------------------------------------------------------------------------------|---------------------|------------|
| **S1** — linear dry end | $\mathcal{L}_{S1} = \frac{1}{M}\sum_{j}\left( \frac{\partial^{2}\widehat{\theta}}{\partial{pF}^{2}} \parallel_{t_{j}} \right)^{\! 2}$ | pF ∈ \[5.0, 7.6\]   | λ₃ = 1     |
| **S2** — non-negativity | $\mathcal{L}_{S2} = \max\!(0,\, - \widehat{\theta}(6.2))^{2}$                                                                         | pF = 6.2            | λ₄ = 1 000 |
| **S3** — non-positivity | $\mathcal{L}_{S3} = \max\!(0,\,\widehat{\theta}(7.6))^{2}$                                                                            | pF = 7.6            | λ₅ = 1 000 |
| **S4** — wet plateau    | $\mathcal{L}_{S4} = \frac{1}{M}\sum_{j}\left( \frac{\partial\widehat{\theta}}{\partial{pF}} \parallel_{t_{j}} \right)^{\! 2}$         | pF ∈ \[−2.0, −0.3\] | λ₆ = 1     |

**S1** enforces that the curve becomes a straight line at the dry end —
this is the key structural difference from Van Genuchten (shaded orange
region in the figure above). **S2/S3** act as hard barriers that prevent
the network from predicting negative or positive water content at the
physical bounds. **S4** penalises any slope in the saturated plateau
(shaded blue region).

The default weights are accessed via `norouzi_lambdas("norouzi")`; a
smoother dry end uses `norouzi_lambdas("smooth")` (λ₃ = 10).

------------------------------------------------------------------------

## Performance

![Predicted vs observed volumetric water
content](reference/figures/pred_obs.png)

Typical performance on held-out test pedons across texture classes:

| Metric | Value           |
|--------|-----------------|
| R²     | ≥ 0.97          |
| RMSE   | \< 0.030 m³ m⁻³ |
| MAE    | \< 0.020 m³ m⁻³ |
| Bias   | \< 0.005 m³ m⁻³ |

Results vary with dataset size, texture distribution, and number of
training epochs. See the [package
vignette](https://hugomachadorodrigues.github.io/soilFlux/articles/introduction.html)
for a reproducible workflow.

------------------------------------------------------------------------

## Installation

``` r
# Install from GitHub (development version)
remotes::install_github("HugoMachadoRodrigues/soilFlux")

# Install TensorFlow/Keras backend (once per machine)
tensorflow::install_tensorflow()
```

**System requirements:** R ≥ 4.1, Python ≥ 3.8, TensorFlow ≥ 2.14,
keras3.

------------------------------------------------------------------------

## Quick start

``` r
library(soilFlux)

# 1. Prepare data ──────────────────────────────────────────────────────────
data("swrc_example")
df <- prepare_swrc_data(swrc_example, depth_col = "depth")

ids     <- unique(df$PEDON_ID)
set.seed(42)
tr_ids  <- sample(ids, floor(0.70 * length(ids)))
val_ids <- sample(setdiff(ids, tr_ids), floor(0.15 * length(ids)))
te_ids  <- setdiff(ids, c(tr_ids, val_ids))

train_df <- df[df$PEDON_ID %in% tr_ids,  ]
val_df   <- df[df$PEDON_ID %in% val_ids, ]
test_df  <- df[df$PEDON_ID %in% te_ids,  ]

# 2. Fit model ─────────────────────────────────────────────────────────────
fit <- fit_swrc(
  train_df = train_df,
  x_inputs = c("clay", "silt", "bd_gcm3", "soc", "Depth_num"),
  val_df   = val_df,
  epochs   = 80,
  lambdas  = norouzi_lambdas("norouzi"),
  verbose  = TRUE
)

# 3. Evaluate on test set ──────────────────────────────────────────────────
evaluate_swrc(fit, test_df)
#> # A tibble: 1 × 4
#>      R2   RMSE    MAE   Bias
#>   <dbl>  <dbl>  <dbl>  <dbl>
#> 1 0.974 0.0241 0.0163 0.0012

# 4. Predict the full continuous curve ─────────────────────────────────────
dense <- predict_swrc_dense(fit, newdata = test_df, n_points = 500)

# 5. Plot ──────────────────────────────────────────────────────────────────
plot_swrc(dense, obs_points = test_df,
          obs_col   = "theta_n",
          facet_row = "Depth_label",
          facet_col = "Texture")
```

------------------------------------------------------------------------

## Main functions

| Function                                                                                                                                                                                                      | Purpose                                  |
|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------|
| [`prepare_swrc_data()`](https://hugomachadorodrigues.github.io/soilFlux/reference/prepare_swrc_data.md)                                                                                                       | Standardise raw soil data for modelling  |
| [`fit_swrc()`](https://hugomachadorodrigues.github.io/soilFlux/reference/fit_swrc.md)                                                                                                                         | Train the CNN1D-PINN                     |
| [`predict_swrc()`](https://hugomachadorodrigues.github.io/soilFlux/reference/predict_swrc.md)                                                                                                                 | Predict θ at specific pF / head values   |
| [`predict_swrc_dense()`](https://hugomachadorodrigues.github.io/soilFlux/reference/predict_swrc_dense.md)                                                                                                     | Predict full continuous SWRC curves      |
| [`predict_theta_s()`](https://hugomachadorodrigues.github.io/soilFlux/reference/predict_theta_s.md)                                                                                                           | Extract modelled saturated water content |
| [`evaluate_swrc()`](https://hugomachadorodrigues.github.io/soilFlux/reference/evaluate_swrc.md)                                                                                                               | R², RMSE, MAE, Bias on a test set        |
| [`swrc_metrics()`](https://hugomachadorodrigues.github.io/soilFlux/reference/swrc_metrics.md)                                                                                                                 | Per-pedon regression metrics             |
| [`norouzi_lambdas()`](https://hugomachadorodrigues.github.io/soilFlux/reference/norouzi_lambdas.md)                                                                                                           | Default loss-weight configurations       |
| [`build_residual_sets()`](https://hugomachadorodrigues.github.io/soilFlux/reference/build_residual_sets.md)                                                                                                   | Physics collocation points               |
| [`save_swrc_model()`](https://hugomachadorodrigues.github.io/soilFlux/reference/save_swrc_model.md) / [`load_swrc_model()`](https://hugomachadorodrigues.github.io/soilFlux/reference/load_swrc_model.md)     | Persist and reload trained models        |
| [`plot_swrc()`](https://hugomachadorodrigues.github.io/soilFlux/reference/plot_swrc.md)                                                                                                                       | Continuous SWRC curve figure             |
| [`plot_pred_obs()`](https://hugomachadorodrigues.github.io/soilFlux/reference/plot_pred_obs.md)                                                                                                               | Predicted vs. observed scatter           |
| [`plot_swrc_metrics()`](https://hugomachadorodrigues.github.io/soilFlux/reference/plot_swrc_metrics.md)                                                                                                       | Metric comparison bar chart              |
| [`plot_training_history()`](https://hugomachadorodrigues.github.io/soilFlux/reference/plot_training_history.md)                                                                                               | Training and validation loss curves      |
| [`classify_texture()`](https://hugomachadorodrigues.github.io/soilFlux/reference/classify_texture.md) / [`texture_triangle()`](https://hugomachadorodrigues.github.io/soilFlux/reference/texture_triangle.md) | USDA texture classification              |

Full reference:
[hugomachadorodrigues.github.io/soilFlux](https://hugomachadorodrigues.github.io/soilFlux/reference/index.html)

------------------------------------------------------------------------

## Citation

If you use soilFlux, please cite:

**Package:**

> Rodrigues, H. (2026). *soilFlux: Physics-Informed Neural Networks for
> Soil Water Retention Curves*. R package version 0.1.1.
> <https://doi.org/10.5281/zenodo.18990856>

**Original architecture:**

> Norouzi, A. M., Feyereisen, G. W., Papanicolaou, A. N., & Wilson, C.
> G. (2025). Physics-Informed Neural Networks for Estimating a
> Continuous Form of the Soil Water Retention Curve. *Journal of
> Hydrology*.

``` r
citation("soilFlux")
```

------------------------------------------------------------------------

## License

MIT © 2026 Hugo Rodrigues
