## ----setup, eval=FALSE, include = FALSE---------------------------------------
# knitr::opts_chunk$set(
#   collapse  = TRUE,
#   comment   = "#>",
#   eval      = FALSE,   # set TRUE after TF environment is confirmed
#   fig.align = "center"
# )
# library(soilFlux)

## ----setup-note, echo=FALSE---------------------------------------------------
knitr::opts_chunk$set(eval = FALSE)

## ----install, eval = FALSE----------------------------------------------------
# # Install development version from GitHub
# remotes::install_github("hugo-rodrigues/soilFlux")
# 
# # Required Python backend (once per machine)
# tensorflow::install_tensorflow()

## ----quickstart, eval=FALSE---------------------------------------------------
# library(soilFlux)
# 
# # 1. Load and prepare data --------------------------------------------------
# data("swrc_example")   # example dataset bundled with the package
# 
# df <- prepare_swrc_data(
#   swrc_example,
#   depth_col = "depth",
#   fix_bd    = TRUE,
#   fix_theta = TRUE
# )
# 
# # Train / validation / test split (by PEDON_ID)
# ids      <- unique(df$PEDON_ID)
# set.seed(42)
# tr_ids   <- sample(ids, floor(0.7 * length(ids)))
# val_ids  <- sample(setdiff(ids, tr_ids), floor(0.15 * length(ids)))
# te_ids   <- setdiff(ids, c(tr_ids, val_ids))
# 
# train_df <- df[df$PEDON_ID %in% tr_ids,  ]
# val_df   <- df[df$PEDON_ID %in% val_ids, ]
# test_df  <- df[df$PEDON_ID %in% te_ids,  ]
# 
# # 2. Fit model --------------------------------------------------------------
# fit <- fit_swrc(
#   train_df   = train_df,
#   x_inputs   = c("clay", "silt", "bd_gcm3", "soc", "Depth_num"),
#   val_df     = val_df,
#   epochs     = 60,
#   batch_size = 256,
#   lambdas    = norouzi_lambdas("norouzi"),
#   verbose    = TRUE
# )
# 
# # 3. Evaluate ---------------------------------------------------------------
# m <- evaluate_swrc(fit, test_df)
# print(m)
# 
# # 4. Dense SWRC curves ------------------------------------------------------
# dense <- predict_swrc_dense(fit, newdata = test_df, n_points = 500)
# 
# # 5. Plot -------------------------------------------------------------------
# plot_swrc(dense, obs_points = test_df,
#           obs_col   = "theta_n",
#           facet_row = "Depth_label",
#           facet_col = "Texture")

## ----units, eval=FALSE--------------------------------------------------------
# # Bulk density: if median > 10, assumes kg/m3 and converts to g/cm3
# fix_bd_units(c(1200, 1450, 1300))   # kg/m3 -> g/cm3
# 
# # Theta: if max > 1.5, assumes % and divides by 100
# theta_unit_factor(c(30, 40, 25))    # returns 100

## ----lambdas, eval=FALSE------------------------------------------------------
# # Exact replication of Norouzi et al. (2025) Table 1
# norouzi_lambdas("norouzi")
# 
# # Smoother dry-end (lambda3 = 10)
# norouzi_lambdas("smooth")

## ----save-load, eval=FALSE----------------------------------------------------
# # Save
# save_swrc_model(fit, dir = "./models", name = "model_5")
# 
# # Check it exists
# swrc_model_exists("./models", "model_5")
# 
# # Reload (in a new session, after library(soilFlux))
# fit2 <- load_swrc_model("./models", "model_5")
# pred <- predict_swrc(fit2, newdata = test_df)

## ----plot-swrc, eval=FALSE----------------------------------------------------
# dense <- predict_swrc_dense(fit, newdata = test_df, n_points = 500)
# 
# plot_swrc(
#   pred_curves  = dense,
#   obs_points   = test_df,
#   obs_col      = "theta_n",
#   facet_row    = "Depth_label",
#   facet_col    = "Texture",
#   line_colour  = "steelblue4",
#   point_colour = "black"
# )

## ----plot-pvo, eval=FALSE-----------------------------------------------------
# pred_df <- data.frame(
#   theta_n         = test_df$theta_n,
#   theta_predicted = predict_swrc(fit, test_df),
#   Texture         = test_df$Texture
# )
# plot_pred_obs(pred_df, group_col = "Texture")

## ----plot-history, eval=FALSE-------------------------------------------------
# plot_training_history(fit)

## ----texture, eval=FALSE------------------------------------------------------
# classify_texture(
#   sand = c(70, 20, 10),
#   silt = c(15, 50, 30),
#   clay = c(15, 30, 60)
# )
# 
# # Add as a column to a data frame
# add_texture(df, sand_col = "sand_total")
# 
# # Texture triangle (requires ggtern)
# texture_triangle(df, color_col = "Texture")

## ----session, eval=FALSE------------------------------------------------------
# sessionInfo()

