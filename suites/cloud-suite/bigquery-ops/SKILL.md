---
name: bigquery-ops
description: Provisions BigQuery datasets, designs partitioned and clustered table schemas, analyzes query execution plans, and enforces cost controls via dry runs and slot reservation. Use when querying analytical datasets, designing data pipelines, writing SQL transformations, or troubleshooting query latency.
---

# Google BigQuery Operations & Cost Optimization

## Overview

BigQuery is Google's fully managed, petabyte-scale enterprise data warehouse. Because BigQuery charges primarily by the number of bytes scanned by queries, poorly optimized queries can rapidly burn budget. This skill enforces cost-conscious schema design, partitioning, clustering, and dry-run query validation.

## Cost Optimization Invariants

1. **Never Run `SELECT *`**: Always explicitly select only the columns needed. BigQuery is a columnar store — selecting 20 unused columns multiplies query costs proportionally.
2. **Mandatory Partitioning**: Large tables ($> 1\text{ GB}$) must be partitioned by ingestion time, event timestamp, or integer range.
3. **Clustering on High-Cardinality Columns**: Cluster partitioned tables by commonly filtered IDs (e.g., `user_id`, `tenant_id`, `status`).
4. **Always Dry-Run First**: Before executing unknown or ad-hoc queries, run with `--dry_run` to inspect bytes scanned.

## CLI & Query Patterns

### Dry Run Query Cost Estimation
```bash
bq query \
  --use_legacy_sql=false \
  --dry_run \
  'SELECT status, count(1) FROM `my_project.analytics.events` WHERE _PARTITIONDATE = "2026-11-10" GROUP BY 1'
```

### Create Partitioned & Clustered Table
```bash
bq mk \
  --table \
  --time_partitioning_field=created_at \
  --time_partitioning_type=DAY \
  --clustering_fields=customer_id,event_type \
  my_project:analytics.events \
  schema.json
```

