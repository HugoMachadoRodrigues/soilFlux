# Changelog

## soilFlux (development version)

## soilFlux 0.1.0

### New features

- [`build_swrc_model()`](https://hugomachadorodrigues.github.io/soilFlux/reference/build_swrc_model.md)
  — CNN1D monotone-integral architecture (Norouzi et al. 2025).
- [`fit_swrc()`](https://hugomachadorodrigues.github.io/soilFlux/reference/fit_swrc.md)
  — Full training loop with physics constraints, early stopping, and
  configurable loss weights.
- [`predict_swrc()`](https://hugomachadorodrigues.github.io/soilFlux/reference/predict_swrc.md)
  — Point predictions at arbitrary pF / matric-head values.
- [`predict_swrc_dense()`](https://hugomachadorodrigues.github.io/soilFlux/reference/predict_swrc_dense.md)
  — Dense continuous SWRC curves for any number of soil profiles.
- [`predict_theta_s()`](https://hugomachadorodrigues.github.io/soilFlux/reference/predict_theta_s.md)
  — Extract modelled saturated water content (θs).
- [`evaluate_swrc()`](https://hugomachadorodrigues.github.io/soilFlux/reference/evaluate_swrc.md)
  — Compute R², RMSE, MAE on a test set.
- [`swrc_metrics()`](https://hugomachadorodrigues.github.io/soilFlux/reference/swrc_metrics.md)
  /
  [`swrc_metrics_by_group()`](https://hugomachadorodrigues.github.io/soilFlux/reference/swrc_metrics_by_group.md)
  — Regression performance metrics.
- [`norouzi_lambdas()`](https://hugomachadorodrigues.github.io/soilFlux/reference/norouzi_lambdas.md)
  — Loss-weight configurations from Norouzi et al. (2025) Table 1.
- [`build_residual_sets()`](https://hugomachadorodrigues.github.io/soilFlux/reference/build_residual_sets.md)
  /
  [`residual_to_tensors()`](https://hugomachadorodrigues.github.io/soilFlux/reference/residual_to_tensors.md)
  — Physics collocation points (S1–S4).
- [`compute_physics_loss()`](https://hugomachadorodrigues.github.io/soilFlux/reference/compute_physics_loss.md)
  — Evaluate the four physics constraints.
- [`fit_minmax()`](https://hugomachadorodrigues.github.io/soilFlux/reference/fit_minmax.md)
  /
  [`apply_minmax()`](https://hugomachadorodrigues.github.io/soilFlux/reference/apply_minmax.md)
  /
  [`invert_minmax()`](https://hugomachadorodrigues.github.io/soilFlux/reference/invert_minmax.md)
  — Column-wise min-max scaling.
- [`prepare_swrc_data()`](https://hugomachadorodrigues.github.io/soilFlux/reference/prepare_swrc_data.md)
  — Standardise raw soil data (units, depth parsing, theta
  normalisation).
- [`make_obs_matrices()`](https://hugomachadorodrigues.github.io/soilFlux/reference/make_obs_matrices.md)
  /
  [`make_profile_array()`](https://hugomachadorodrigues.github.io/soilFlux/reference/make_profile_array.md)
  — Build 3-D sequence arrays for the CNN1D.
- [`parse_depth()`](https://hugomachadorodrigues.github.io/soilFlux/reference/parse_depth.md)
  /
  [`parse_depth_column()`](https://hugomachadorodrigues.github.io/soilFlux/reference/parse_depth_column.md)
  — Parse depth strings to midpoint and label.
- [`pf_from_head()`](https://hugomachadorodrigues.github.io/soilFlux/reference/pf_from_head.md)
  /
  [`head_from_pf()`](https://hugomachadorodrigues.github.io/soilFlux/reference/head_from_pf.md)
  /
  [`pf_normalize()`](https://hugomachadorodrigues.github.io/soilFlux/reference/pf_normalize.md)
  /
  [`head_normalize()`](https://hugomachadorodrigues.github.io/soilFlux/reference/head_normalize.md)
  — pF / matric-head conversion helpers.
- [`fix_bd_units()`](https://hugomachadorodrigues.github.io/soilFlux/reference/fix_bd_units.md)
  /
  [`theta_unit_factor()`](https://hugomachadorodrigues.github.io/soilFlux/reference/theta_unit_factor.md)
  — Automatic unit correction.
- [`save_swrc_model()`](https://hugomachadorodrigues.github.io/soilFlux/reference/save_swrc_model.md)
  /
  [`load_swrc_model()`](https://hugomachadorodrigues.github.io/soilFlux/reference/load_swrc_model.md)
  /
  [`swrc_model_exists()`](https://hugomachadorodrigues.github.io/soilFlux/reference/swrc_model_exists.md)
  — Model persistence (weights + metadata).
- [`plot_swrc()`](https://hugomachadorodrigues.github.io/soilFlux/reference/plot_swrc.md)
  — Publication-quality SWRC curve figure.
- [`plot_pred_obs()`](https://hugomachadorodrigues.github.io/soilFlux/reference/plot_pred_obs.md)
  — Predicted vs. observed scatter plot with metrics.
- [`plot_swrc_metrics()`](https://hugomachadorodrigues.github.io/soilFlux/reference/plot_swrc_metrics.md)
  — Bar chart comparing model performance.
- [`plot_training_history()`](https://hugomachadorodrigues.github.io/soilFlux/reference/plot_training_history.md)
  — Training / validation loss curves.
- [`classify_texture()`](https://hugomachadorodrigues.github.io/soilFlux/reference/classify_texture.md)
  /
  [`add_texture()`](https://hugomachadorodrigues.github.io/soilFlux/reference/add_texture.md)
  /
  [`texture_triangle()`](https://hugomachadorodrigues.github.io/soilFlux/reference/texture_triangle.md)
  — USDA texture classification and ternary diagram.
- `swrc_example` — Example soil characterization dataset.
