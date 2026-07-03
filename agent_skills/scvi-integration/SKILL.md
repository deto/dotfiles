---
name: scvi-integration
description: Use when building, reviewing, or diagnosing scVI/scANVI single-cell integration workflows, especially choices around HVGs, batch/covariates, KL warmup, learning-rate scheduling, training-history inspection, and required scVI diagnostic plots.
---

# scVI Integration

## Default Workflow

1. Confirm `.X` is raw integer-like counts. If counts are in a layer, register that layer with `SCVI.setup_anndata`.
2. Choose a shared feature set before training:
   - Use intersected genes across datasets for cross-study integrations.
   - Prefer batch-aware HVGs over all intersected genes for initial integrations.
   - Save both the full intersected-gene list and the selected HVG table.
3. Register biological and technical covariates deliberately:
   - Use `batch_key` for the main unwanted axis to remove, often `dataset` for cross-study integration.
   - Use `categorical_covariate_keys` for nested or secondary effects such as mouse, sample, sex, chemistry, or donor.
   - If mouse/sample is fully nested in dataset, compare `batch_key="dataset"` plus mouse covariate against `batch_key="mouse_id"`; do not assume one is correct.
4. Train a short smoke run first, then the full run. The smoke run should exercise the same feature-selection and covariate-registration path as the full run.
5. Always write latent `.h5ad`, model directory, training history CSV, training history plot, feature-selection table, and a concise run-summary CSV.
6. Record Torch thread count and benchmark it on a one-epoch run. More threads can be slower for scVI CPU training; for medium-width HVG matrices, 8-16 Torch threads may outperform 64.

## Training Plan Settings

Set `plan_kwargs` explicitly. Do not rely on scvi-tools defaults for integration work.

Recommended starting point for a local full integration run:

```python
model.train(
    max_epochs=200,
    batch_size=1024,
    early_stopping=False,
    plan_kwargs={
        "n_epochs_kl_warmup": 30,
        "lr": 1e-3,
        "reduce_lr_on_plateau": True,
        "lr_patience": 5,
    },
)
```

Guidelines:

- `n_epochs_kl_warmup`: make KL reach full weight well before training ends. For 200 epochs, use about 30 epochs. Avoid the default 400-epoch warmup for short local runs.
- `reduce_lr_on_plateau`: useful for full runs, but make sure validation starts after the KL term is fully warmed up or that LR reduction cannot trigger until after warmup.
- `lr_patience`: should be short enough to reduce LR while many epochs remain, but not so short that it reduces before KL warmup completes. For 200 epochs with 30 warmup epochs, start around 5-10 if validation is only logged after warmup; use a larger patience if validation starts immediately.
- `lr`: start with `1e-3`. Lower it only if loss is unstable or the run diverges; raise it only with clear evidence from a smoke run or prior dataset-specific experience.
- If using early stopping, make patience longer than KL warmup for the same reason.

## CPU Threading

For local CPU runs, set `torch.set_num_threads(...)` explicitly and record the value in the run summary. Do not assume the machine's full core count is fastest. `torch.set_num_threads(...)` controls Torch CPU compute parallelism; it does not set PyTorch/scVI DataLoader worker processes.

Suggested approach:

- Benchmark one epoch at a small set of thread counts, commonly 8, 16, 32, and the machine maximum.
- Use the fastest stable setting for the full run.
- If `reduce_lr_on_plateau=True`, benchmark the intended validation-enabled setup too.
- Set scVI DataLoader workers separately with `datasplitter_kwargs={"num_workers": ...}` or `scvi.settings.dl_num_workers`. Start with `num_workers=0` for sparse AnnData integrations unless a loader-only benchmark shows benefit.
- Treat DataLoader warnings from Lightning as generic hints, not proof of a bottleneck. Confirm by timing one full pass through the scVI `AnnDataLoader`; if iteration is seconds but an epoch is minutes, the bottleneck is model compute or thread scheduling, not data loading.
- If high Torch thread counts are slower while `num_workers=0`, lowering DataLoader workers cannot fix the issue. In a Ludwig/DVC CPU integration with 189k cells and 5k HVGs, 8 Torch threads took about 33 seconds/epoch while 64 threads took about 5.7 minutes/epoch, and loader-only iteration was about 2 seconds at both 8 and 64 threads.
- Tune DataLoader workers only after compute thread count is no longer the bottleneck. Worker processes can add multiprocessing overhead and may require less-restricted execution environments.

## Training History

`model.history` is a dict-like structure whose values are usually pandas Series/DataFrames indexed by epoch. Convert it to a single table and preserve the epoch index.

Common columns:

- `train_loss`: Lightning training objective reported during training.
- `elbo_train`, `reconstruction_loss_train`, `kl_local_train`, `kl_global_train`: train-set decomposition.
- Validation columns may appear when scvi-tools creates a validation split, commonly `elbo_validation`, `reconstruction_loss_validation`, and `kl_local_validation`.
- `kl_weight`: should rise to 1.0 before LR reduction is expected.
- `lr` may or may not appear depending on scvi-tools/Lightning logging.

Always plot:

- loss curves: `train_loss`, `elbo_train`, `reconstruction_loss_train`, validation counterparts if available;
- KL diagnostics: `kl_weight`;
- learning rate if logged.

Do not put `kl_local_train` or `kl_local_validation` on the main loss panel; they are on a different scale and make the plot harder to read. Avoid markers on long epoch trajectories.

The plot should make it obvious whether KL fully warmed up, whether LR reduction happened too early, and whether losses were still improving at the end.

## Integration Diagnostics

After training, generate UMAP/neighbor graphs from `X_scVI` and plot at least:

- dataset;
- selected cluster;
- batch key;
- important covariates such as mouse/sample;
- available reference labels.

Also save dataset composition by cluster. If UMAP clusters are nearly pure by dataset, inspect:

- raw-count status and library-size distributions;
- HVG choice and whether all genes were used by mistake;
- KL warmup reaching 1.0;
- `batch_key` versus nested covariates;
- whether biological cell-type composition differs too much for the chosen integration scope.
