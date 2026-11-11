---
name: gcs-storage
description: Manages Google Cloud Storage (GCS) buckets, object lifecycles, access control (IAM/ACLs), CORS policies, signed URLs, and data transfers. Use when provisioning object storage, uploading/downloading cloud assets, configuring static site hosting, or setting retention policies.
---

# Google Cloud Storage (GCS) Management

## Overview

Google Cloud Storage (GCS) provides unified object storage with global edge caching and tiered storage classes. This skill defines secure patterns for bucket provisioning, least-privilege access control, signed URL delegation, and automated lifecycle policies.

## Storage Classes & Selection

| Class | Minimum Storage Duration | Typical Use Case |
| :--- | :--- | :--- |
| **Standard** | None | Actively served web assets, dynamic API uploads |
| **Nearline** | 30 days | Monthly backups, infrequent report archives |
| **Coldline** | 90 days | Disaster recovery, quarterly compliance records |
| **Archive** | 365 days | Long-term digital preservation, legal holds |

## Essential CLI Patterns

### Create Secure Bucket
```bash
# Uniform bucket-level access prevents accidental public object exposure
gcloud storage buckets create gs://BUCKET_NAME \
  --project=PROJECT_ID \
  --location=us-central1 \
  --uniform-bucket-level-access \
  --default-storage-class=STANDARD
```

### Lifecycle Rules (Auto-Transition to Coldline after 30 days)
```json
{
  "rule": [
    {
      "action": {"type": "SetStorageClass", "storageClass": "COLDLINE"},
      "condition": {"age": 30}
    }
  ]
}
```

```bash
gcloud storage buckets update gs://BUCKET_NAME --lifecycle-file=lifecycle.json
```

## Security Invariants

- **Uniform Access**: Always enforce uniform bucket-level access (`--uniform-bucket-level-access`).
- **No Public Read by Default**: Keep all buckets private; generate time-limited Signed URLs for client uploads/downloads.
- **CORS Minimal Scopes**: Restrict allowed origins to production domains only.
