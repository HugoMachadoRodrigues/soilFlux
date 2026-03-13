# Package index

## Data preparation

Standardise raw soil data for modelling

- [`prepare_swrc_data()`](https://hugomachadorodrigues.github.io/soilFlux/reference/prepare_swrc_data.md)
  : Prepare a soil data frame for SWRC modelling

## Model fitting

Train the CNN1D-PINN and swrc_fit S3 methods

- [`fit_swrc()`](https://hugomachadorodrigues.github.io/soilFlux/reference/fit_swrc.md)
  : Fit a physics-informed CNN1D SWRC model
- [`build_swrc_model()`](https://hugomachadorodrigues.github.io/soilFlux/reference/build_swrc_model.md)
  : Build the CNN1D monotone-integral SWRC model
- [`norouzi_lambdas()`](https://hugomachadorodrigues.github.io/soilFlux/reference/norouzi_lambdas.md)
  : Return default Norouzi et al. (2025) loss weights (lambdas)
- [`build_residual_sets()`](https://hugomachadorodrigues.github.io/soilFlux/reference/build_residual_sets.md)
  : Build physics residual point sets (S1 – S4)
- [`print(`*`<swrc_fit>`*`)`](https://hugomachadorodrigues.github.io/soilFlux/reference/print.swrc_fit.md)
  : Print method for swrc_fit
- [`summary(`*`<swrc_fit>`*`)`](https://hugomachadorodrigues.github.io/soilFlux/reference/summary.swrc_fit.md)
  : Summary method for swrc_fit

## Prediction

Predict water content at specific or dense pF grids

- [`predict_swrc()`](https://hugomachadorodrigues.github.io/soilFlux/reference/predict_swrc.md)
  : Predict water content at specific pF or matric-head values
- [`predict_swrc_dense()`](https://hugomachadorodrigues.github.io/soilFlux/reference/predict_swrc_dense.md)
  : Predict dense SWRC curves for a set of soil profiles
- [`predict_theta_s()`](https://hugomachadorodrigues.github.io/soilFlux/reference/predict_theta_s.md)
  : Extract saturated water content (theta_s) from covariates
- [`predict(`*`<swrc_fit>`*`)`](https://hugomachadorodrigues.github.io/soilFlux/reference/predict.swrc_fit.md)
  : Predict method for swrc_fit

## Evaluation & metrics

Performance metrics and evaluation

- [`evaluate_swrc()`](https://hugomachadorodrigues.github.io/soilFlux/reference/evaluate_swrc.md)
  : Compute metrics from a swrc_fit on new data
- [`swrc_metrics()`](https://hugomachadorodrigues.github.io/soilFlux/reference/swrc_metrics.md)
  : Compute regression metrics for SWRC predictions
- [`swrc_metrics_by_group()`](https://hugomachadorodrigues.github.io/soilFlux/reference/swrc_metrics_by_group.md)
  : Compute regression metrics by group

## Visualisation

Publication-quality plots

- [`plot_swrc()`](https://hugomachadorodrigues.github.io/soilFlux/reference/plot_swrc.md)
  : Plot soil water retention curves (SWRC)
- [`plot_pred_obs()`](https://hugomachadorodrigues.github.io/soilFlux/reference/plot_pred_obs.md)
  : Plot predicted vs. observed water content
- [`plot_swrc_metrics()`](https://hugomachadorodrigues.github.io/soilFlux/reference/plot_swrc_metrics.md)
  : Plot model performance metric comparison
- [`plot_training_history()`](https://hugomachadorodrigues.github.io/soilFlux/reference/plot_training_history.md)
  : Plot training loss history

## Texture

USDA texture classification and triangle

- [`classify_texture()`](https://hugomachadorodrigues.github.io/soilFlux/reference/classify_texture.md)
  : Classify soil texture according to the USDA system
- [`add_texture()`](https://hugomachadorodrigues.github.io/soilFlux/reference/add_texture.md)
  : Add texture classification column to a data frame
- [`texture_triangle()`](https://hugomachadorodrigues.github.io/soilFlux/reference/texture_triangle.md)
  : Plot a soil texture triangle (ternary diagram)

## Save / Load

Persist and reload trained models

- [`save_swrc_model()`](https://hugomachadorodrigues.github.io/soilFlux/reference/save_swrc_model.md)
  : Save a fitted SWRC model to disk
- [`load_swrc_model()`](https://hugomachadorodrigues.github.io/soilFlux/reference/load_swrc_model.md)
  : Load a previously saved SWRC model from disk
- [`swrc_model_exists()`](https://hugomachadorodrigues.github.io/soilFlux/reference/swrc_model_exists.md)
  : Check whether a model directory contains a valid saved model

## Internal helpers

Scaling, physics, utilities

- [`fit_minmax()`](https://hugomachadorodrigues.github.io/soilFlux/reference/fit_minmax.md)
  : Fit a min-max scaler from a training data frame
- [`apply_minmax()`](https://hugomachadorodrigues.github.io/soilFlux/reference/apply_minmax.md)
  : Apply a fitted min-max scaler to a data frame
- [`invert_minmax()`](https://hugomachadorodrigues.github.io/soilFlux/reference/invert_minmax.md)
  : Invert a min-max scaling transformation
- [`pf_from_head()`](https://hugomachadorodrigues.github.io/soilFlux/reference/pf_from_head.md)
  : Convert matric head (cm) to pF
- [`head_from_pf()`](https://hugomachadorodrigues.github.io/soilFlux/reference/head_from_pf.md)
  : Convert pF to matric head (cm)
- [`pf_normalize()`](https://hugomachadorodrigues.github.io/soilFlux/reference/pf_normalize.md)
  : Normalise pF values to \[0, 1\]
- [`head_normalize()`](https://hugomachadorodrigues.github.io/soilFlux/reference/head_normalize.md)
  : Normalise matric head (cm) to the pF domain
- [`parse_depth()`](https://hugomachadorodrigues.github.io/soilFlux/reference/parse_depth.md)
  : Parse a soil depth string into midpoint and label
- [`parse_depth_column()`](https://hugomachadorodrigues.github.io/soilFlux/reference/parse_depth_column.md)
  : Parse depth column in a data frame
- [`fix_bd_units()`](https://hugomachadorodrigues.github.io/soilFlux/reference/fix_bd_units.md)
  : Detect and correct bulk-density units
- [`theta_unit_factor()`](https://hugomachadorodrigues.github.io/soilFlux/reference/theta_unit_factor.md)
  : Detect theta unit scale factor
- [`compute_physics_loss()`](https://hugomachadorodrigues.github.io/soilFlux/reference/compute_physics_loss.md)
  : Compute the physics-informed residual loss (Norouzi et al. 2025)
- [`residual_to_tensors()`](https://hugomachadorodrigues.github.io/soilFlux/reference/residual_to_tensors.md)
  : Convert residual point sets to TensorFlow tensors
- [`make_obs_matrices()`](https://hugomachadorodrigues.github.io/soilFlux/reference/make_obs_matrices.md)
  : Build observation matrices for the CNN1D model
- [`make_profile_array()`](https://hugomachadorodrigues.github.io/soilFlux/reference/make_profile_array.md)
  : Build a sequence array for one or more soil profiles
- [`make_train_step()`](https://hugomachadorodrigues.github.io/soilFlux/reference/make_train_step.md)
  : Create an eager-mode train step function
- [`safe_grad()`](https://hugomachadorodrigues.github.io/soilFlux/reference/safe_grad.md)
  : Safely compute a TensorFlow gradient
- [`data_prep`](https://hugomachadorodrigues.github.io/soilFlux/reference/data_prep.md)
  : Data preparation for CNN1D SWRC modelling
- [`io`](https://hugomachadorodrigues.github.io/soilFlux/reference/io.md)
  : Save and load fitted SWRC models
- [`metrics`](https://hugomachadorodrigues.github.io/soilFlux/reference/metrics.md)
  : Performance metrics for SWRC models
- [`model`](https://hugomachadorodrigues.github.io/soilFlux/reference/model.md)
  : CNN1D monotone-integral model architecture
- [`physics`](https://hugomachadorodrigues.github.io/soilFlux/reference/physics.md)
  : Physics-informed constraints for SWRC modelling
- [`plots`](https://hugomachadorodrigues.github.io/soilFlux/reference/plots.md)
  : Publication-quality plots for SWRC analysis
- [`predict`](https://hugomachadorodrigues.github.io/soilFlux/reference/predict.md)
  : Prediction from fitted SWRC models
- [`scale`](https://hugomachadorodrigues.github.io/soilFlux/reference/scale.md)
  : Min-max feature scaling
- [`texture`](https://hugomachadorodrigues.github.io/soilFlux/reference/texture.md)
  : USDA soil texture classification
- [`train`](https://hugomachadorodrigues.github.io/soilFlux/reference/train.md)
  : Training the CNN1D SWRC model
- [`utils`](https://hugomachadorodrigues.github.io/soilFlux/reference/utils.md)
  : Utility functions for soilFlux

## Data

Example datasets

- [`swrc_example`](https://hugomachadorodrigues.github.io/soilFlux/reference/swrc_example.md)
  : Example soil water retention dataset
