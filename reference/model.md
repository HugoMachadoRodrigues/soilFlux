# CNN1D monotone-integral model architecture

Build the physics-informed 1-D CNN with a monotone integral output
layer, as described in Norouzi et al. (2025).

## Details

### Architecture

The model takes two inputs:

1.  `Xseq_knots`: a 3-D tensor of shape `[N, K, p+1]` — for each
    observation, `p` scaled covariates are broadcast across `K` knot
    positions, and the knot positions themselves form the last channel.

2.  `pf_norm`: a 2-D tensor of shape `[N, 1]` — the query pF value
    normalised to `[0, 1]`.

The output satisfies: \$\$\hat{\theta}(pF) = \theta_s - \int_0^{pF}
\text{softplus}(s(t))\\dt\$\$

where \\s(t)\\ is a 1-channel convolutional output. Monotone decrease is
guaranteed **by construction** because the integrand is always positive.

## References

Norouzi, A. M., et al. (2025). Physics-Informed Neural Networks for
Estimating a Continuous Form of the Soil Water Retention Curve. *Journal
of Hydrology*.
