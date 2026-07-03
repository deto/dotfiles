---
name: single-cell-umap
description: Guidance for producing readable single-cell/scRNA/snRNA UMAP or t-SNE plots, feature plots, covariate panels, genotype/condition highlights, marker-expression panels, and cluster identity/signature score visualizations from AnnData, Scanpy, Seurat-derived tables, or pandas/matplotlib workflows. Use when Codex needs to plot single-cell embeddings, compare clusters to marker signatures, visualize sparse gene expression, or diagnose over/underclustering.
---

# Single-Cell UMAP

## Workflow

1. Inspect the data before plotting:
   - Identify the embedding coordinates, cluster column, `.obs` covariates, gene identifiers, and expression matrix/layer.
   - Confirm whether expression values are raw counts, normalized counts, or already log-transformed.
   - Check category levels and cell counts; do not assume clusters are biologically annotated.

2. Generate reproducible artifacts:
   - Prefer a script or workflow rule over notebook-only plotting.
   - Save both figures and the tables used to build them.
   - Use a fixed random seed for point ordering, subsampling, or jitter.
   - Record the cluster key and embedding source in output names or figure captions.

## Categorical UMAPs

- Randomize point draw order for categorical covariates. Do not loop through categories with one `ax.scatter` per category unless the category order is intentionally meaningful; later categories will cover earlier ones.
- For categorical plots, draw all cells in one scatter call after shuffling rows, or use a shuffled dataframe and a vector of per-cell colors.
- Use fixed, high-contrast palettes for important binary or three-level covariates. Avoid assigning related groups to dark/light variants of the same hue.
- For small key covariates such as genotype or treatment, also create one-vs-rest highlight panels: all other cells in light gray, focal group in a strong color.
- For high-cardinality covariates such as sample, use a qualitative palette with enough distinct hues and keep the legend outside the plot.

Suggested categorical colors:

```python
palettes = {
    "genotype": {"ST": "#4d4d4d", "Gfral": "#d95f02", "Glp1r": "#1b9e77"},
    "sex": {"F": "#7570b3", "M": "#e7298a"},
    "diet": {"chow": "#66a61e", "HFD": "#e6ab02"},
}
```

Suggested randomized scatter pattern:

```python
rng = np.random.default_rng(20260527)
order = rng.permutation(len(obs))
ax.scatter(
    obs["umap_1"].to_numpy()[order],
    obs["umap_2"].to_numpy()[order],
    c=colors[order],
    s=2,
    alpha=0.75,
    linewidths=0,
    rasterized=True,
)
```

## Expression Feature Plots

- Sparse marker expression is easy to miss. Make zero or near-zero cells light gray and use a darker sequential scale for positive expression.
- Avoid colormaps where the highest expression is very light, because high-expressing cells disappear against white backgrounds.
- Plot higher-expression cells last by sorting points by expression before scatter.
- Cap `vmax` at a high percentile of positive values, usually the 99th percentile, so a few outliers do not flatten the signal.
- If starting from raw counts, use a library-size-normalized scale such as `log1p(CP10K)` or document the chosen transform.

Suggested expression colormap:

```python
from matplotlib.colors import LinearSegmentedColormap

expression_cmap = LinearSegmentedColormap.from_list(
    "gray_to_expression",
    ["#d8d8d8", "#2b8cbe", "#084081", "#3f007d"],
)

vals = expression_values
finite = np.isfinite(vals)
positive = (vals > 0) & finite
vmax = np.nanpercentile(vals[positive], 99) if positive.any() else 1
order = np.argsort(np.where(finite, vals, -1))

ax.scatter(
    obs["umap_1"].to_numpy()[order],
    obs["umap_2"].to_numpy()[order],
    c=vals[order],
    cmap=expression_cmap,
    vmin=0,
    vmax=max(vmax, 0.01),
    s=1.2,
    linewidths=0,
    rasterized=True,
)
```

## Signature And Cluster Identity Plots

- When comparing clusters to external identities, create both:
  - a cluster-by-signature heatmap using aggregate expression or module scores;
  - UMAP panels for key individual marker genes and signature scores.
- Show how many signature genes were present in the target dataset.
- Use aggregate cluster tables, not only UMAP impressions, to identify candidate clusters.
- Treat partial or split signatures as a clue for under/overclustering; inspect UMAPs before assigning final biological labels.
- Include covariate UMAPs for possible confounders such as sample, batch, genotype, sex, diet, treatment, and guide/condition.

Simple cluster score approach:

```python
wide = expression_by_cluster.pivot(index="gene", columns="cluster", values="log1p_cpm")
z = wide.sub(wide.mean(axis=1), axis=0).div(wide.std(axis=1).replace(0, np.nan), axis=0)
score = z.loc[[g for g in signature if g in z.index]].mean(axis=0)
```

## Plot Quality Checks

- Confirm every expected output file exists and is nonempty.
- Open or inspect image dimensions after generation.
- Check that zero-expression cells are visible but unobtrusive.
- Check that high-expression cells are not pale or hidden behind non-expressing cells.
- Check that categorical groups are not systematically occluded.
- Make sure legends, titles, and panel labels identify the embedding, cluster key, and covariates without overcrowding the figure.
