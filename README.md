# Exmox Data Engineer — Databricks

A serverless Databricks medallion pipeline for rewarded-offer data, built with Unity Catalog, DLT/AutoLoader, dbt, Declarative Automation Bundles, and an AI/BI dashboard.

## Source data

| Source | Rows | Grain and purpose |
|---|---:|---|
| `installs.csv` | 40,000 | One row per user; install time, country, platform, acquisition, device, and campaign attributes. |
| `events.csv` | 435,907 | One row per event across five event types; includes event and ingestion timestamps. Contains duplicates and late arrivals. |
| `offers.csv` | 180 | One row per offer; category, payout type, and payout in EUR. |
| `user_profile.csv` | 40,000 | One row per user; current backend lifetime/activity snapshot. Not used to calculate gold metrics. |

All supplied data is synthetic.

## Pipeline outline

```text
CSV files in a Unity Catalog managed volume
  → Bronze: typed ingestion with DLT and AutoLoader
  → Silver: dbt validation, filtering, and event deduplication
  → Gold: daily metrics by country and platform
  → AI/BI dashboard with country/platform filters
```

A single DAB orchestrates `ingest_bronze → transform_silver → transform_gold`. Development and production use separate schemas; production runs as a dedicated service principal.

Key behavior:

- Idempotent reruns and incremental event/gold merges.
- Historical gold-day recomputation when late events arrive.
- UTC event/install dates and documented cleaning rules.
- 42 dbt tests covering contracts, references, uniqueness, non-emptiness, and reconciliation.

## Documentation

See [SOLUTION.md](SOLUTION.md) for setup and verification commands, verified outputs, data-quality decisions, platform trade-offs, failure modes, scaling considerations, and the AI workflow.
