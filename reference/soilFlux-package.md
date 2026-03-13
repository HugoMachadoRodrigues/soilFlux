# soilFlux: Physics-Informed Neural Networks for Soil Water Retention Curves

The `soilFlux` package implements a physics-informed 1-D convolutional
neural network (CNN1D-PINN) for estimating the complete soil water
retention curve (SWRC) as a continuous function of matric potential,
from soil texture, organic carbon, bulk density, and depth.

## Details

### Main functions

|                                                                                                                                                                                                           |                                  |
|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------|
| Function                                                                                                                                                                                                  | Purpose                          |
| [`prepare_swrc_data()`](https://hugomachadorodrigues.github.io/soilFlux/reference/prepare_swrc_data.md)                                                                                                   | Standardise raw soil data        |
| [`fit_swrc()`](https://hugomachadorodrigues.github.io/soilFlux/reference/fit_swrc.md)                                                                                                                     | Train the CNN1D-PINN model       |
| [`predict_swrc()`](https://hugomachadorodrigues.github.io/soilFlux/reference/predict_swrc.md)                                                                                                             | Predict theta at given pF values |
| [`predict_swrc_dense()`](https://hugomachadorodrigues.github.io/soilFlux/reference/predict_swrc_dense.md)                                                                                                 | Predict full SWRC curves         |
| [`swrc_metrics()`](https://hugomachadorodrigues.github.io/soilFlux/reference/swrc_metrics.md)                                                                                                             | Evaluate model performance       |
| [`plot_swrc()`](https://hugomachadorodrigues.github.io/soilFlux/reference/plot_swrc.md)                                                                                                                   | Plot retention curves            |
| [`plot_pred_obs()`](https://hugomachadorodrigues.github.io/soilFlux/reference/plot_pred_obs.md)                                                                                                           | Predicted vs. observed plot      |
| [`save_swrc_model()`](https://hugomachadorodrigues.github.io/soilFlux/reference/save_swrc_model.md) / [`load_swrc_model()`](https://hugomachadorodrigues.github.io/soilFlux/reference/load_swrc_model.md) | Persist the model                |
| [`classify_texture()`](https://hugomachadorodrigues.github.io/soilFlux/reference/classify_texture.md)                                                                                                     | USDA texture classification      |

### References

Norouzi, A. M., et al. (2025). Physics-Informed Neural Networks for
Estimating a Continuous Form of the Soil Water Retention Curve. *Journal
of Hydrology*.

## See also

Useful links:

- <https://github.com/HugoMachadoRodrigues/soilFlux>

- <https://hugomachadorodrigues.github.io/soilFlux/>

- Report bugs at
  <https://github.com/HugoMachadoRodrigues/soilFlux/issues>

## Author

**Maintainer**: Hugo Rodrigues <rodrigues.machado.hugo@gmail.com>
([ORCID](https://orcid.org/0000-0002-8070-8126))
