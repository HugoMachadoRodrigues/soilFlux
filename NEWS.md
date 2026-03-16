# soilFlux 0.1.3

## Bug fixes

* Added prebuilt vignette index (`inst/doc/index.html`) to fix CRAN NOTE
  "VignetteBuilder field but no prebuilt vignette index".
* Quoted technical acronyms (`'CNN1D-PINN'`, `'SWRC'`, `'pF'`) in DESCRIPTION
  to reduce spell-check NOTEs on CRAN incoming checks.

# soilFlux 0.1.2

## Bug fixes

* Fixed LaTeX PDF build error caused by Unicode character `≈` (U+2248) in
  `.Rd` documentation. Replaced with `\eqn{\approx}` in `make_obs_matrices`
  and `swrc_example` man pages.
* Added `inst/WORDLIST` with domain-specific terms (`SWRC`, `PINN`, `pF`,
  `Norouzi`, `matric`, `convolutional`, `positivity`) to suppress
  spell-check NOTEs on CRAN incoming checks.

# soilFlux 0.1.1

## Bug fixes

* Pre-built vignette output added to `inst/doc/` to avoid LaTeX/Pandoc
  WARNINGs during CRAN checks.
* Updated `.Rbuildignore` accordingly.

# soilFlux 0.1.0

* Initial CRAN submission.

## New features

* `build_swrc_model()` — CNN1D monotone-integral architecture (Norouzi et al. 2025).
* `fit_swrc()` — Full training loop with physics constraints, early stopping,
  and configurable loss weights.
* `predict_swrc()` — Point predictions at arbitrary pF / matric-head values.
* `predict_swrc_dense()` — Dense continuous SWRC curves for any number of
  soil profiles.
* `predict_theta_s()` — Extract modelled saturated water content (θs).
* `evaluate_swrc()` — Compute R², RMSE, MAE on a test set.
* `swrc_metrics()` / `swrc_metrics_by_group()` — Regression performance metrics.
* `norouzi_lambdas()` — Loss-weight configurations from Norouzi et al. (2025)
  Table 1.
* `build_residual_sets()` / `residual_to_tensors()` — Physics collocation
  points (S1–S4).
* `compute_physics_loss()` — Evaluate the four physics constraints.
* `fit_minmax()` / `apply_minmax()` / `invert_minmax()` — Column-wise min-max
  scaling.
* `prepare_swrc_data()` — Standardise raw soil data (units, depth parsing,
  theta normalisation).
* `make_obs_matrices()` / `make_profile_array()` — Build 3-D sequence arrays
  for the CNN1D.
* `parse_depth()` / `parse_depth_column()` — Parse depth strings to midpoint
  and label.
* `pf_from_head()` / `head_from_pf()` / `pf_normalize()` / `head_normalize()`
  — pF / matric-head conversion helpers.
* `fix_bd_units()` / `theta_unit_factor()` — Automatic unit correction.
* `save_swrc_model()` / `load_swrc_model()` / `swrc_model_exists()` — Model
  persistence (weights + metadata).
* `plot_swrc()` — Publication-quality SWRC curve figure.
* `plot_pred_obs()` — Predicted vs. observed scatter plot with metrics.
* `plot_swrc_metrics()` — Bar chart comparing model performance.
* `plot_training_history()` — Training / validation loss curves.
* `classify_texture()` / `add_texture()` / `texture_triangle()` — USDA
  texture classification and ternary diagram.
* `swrc_example` — Example soil characterization dataset.
