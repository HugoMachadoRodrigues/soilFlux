# Prepare a soil data frame for SWRC modelling

A convenience wrapper that:

1.  Renames columns to standard names.

2.  Parses the depth column.

3.  Fixes bulk-density units.

4.  Detects and normalises volumetric water content units.

5.  Computes per-profile maximum theta.

6.  Drops rows with missing key variables.

## Usage

``` r
prepare_swrc_data(
  df,
  x_cols = NULL,
  depth_col = "depth",
  fix_bd = TRUE,
  fix_theta = TRUE
)
```

## Arguments

- df:

  A data frame with soil characterization data.

- x_cols:

  Named character vector mapping standard names to actual column names.
  Standard names: `"PEDON_ID"`, `"sand"`, `"silt"`, `"clay"`, `"soc"`,
  `"bd"`, `"matric_head"`, `"water_content"`, `"depth"`. Unneeded
  variables may be omitted.

- depth_col:

  Column name for depth (character string, default `"depth"`). If
  already parsed, set to `NULL`.

- fix_bd:

  Logical; apply
  [`fix_bd_units()`](https://hugomachadorodrigues.github.io/soilFlux/reference/fix_bd_units.md)
  to bulk density (default `TRUE`).

- fix_theta:

  Logical; scale theta to m3/m3 if needed (default `TRUE`).

## Value

A tibble with standardised columns plus `Depth_num`, `Depth_label`,
`bd_gcm3`, `theta_n` (normalised WC), and `theta_max_n` (per-profile
maximum theta).

## Examples

``` r
if (FALSE) { # \dontrun{
df_prep <- prepare_swrc_data(raw_df,
  x_cols = c(PEDON_ID = "ID", sand = "sand_pct", ...))
} # }
```
