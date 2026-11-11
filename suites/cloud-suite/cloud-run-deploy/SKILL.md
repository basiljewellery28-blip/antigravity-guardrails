---
name: cloud-run-deploy
description: Configures, containerizes, deploys, and manages serverless applications on Google Cloud Run. Use when deploying microservices, web apps, HTTP APIs, background jobs, configuring autoscaling and environment variables, or managing traffic splitting and revisions with gcloud.
---

# Google Cloud Run Deployment & Lifecycle

## Overview

Google Cloud Run is a fully managed compute platform that automatically scales stateless containers. This skill provides production patterns for container buildpacks, deployment via `gcloud`, traffic splitting, environment secret management, and zero-downtime canary rollouts.

## Deployment Protocol

```
1. BUILD    → Build container image via Cloud Build or local Docker
2. PROVISION→ Set CPU, memory limits, and minimum instances (cold start mitigation)
3. SECURE   → Bind IAM least privilege service accounts and Secret Manager secrets
4. DEPLOY   → Deploy revision via `gcloud run deploy` with healthcheck probes
5. CANARY   → Route 10% traffic to new revision; monitor error rates; promote to 100%
```

## Standard CLI Commands

### Deploy a Service
```bash
gcloud run deploy my-service \
  --image gcr.io/PROJECT_ID/IMAGE_NAME:TAG \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --min-instances 1 \
  --max-instances 10 \
  --memory 512Mi \
  --cpu 1 \
  --set-env-vars NODE_ENV=production
```

### Canary Traffic Splitting
```bash
# Split 90% to current stable revision, 10% to new revision
gcloud run services update-traffic my-service \
  --to-revisions=my-service-00001=90,my-service-00002=10 \
  --region us-central1
```

## Invariants

- **Statelessness**: Never rely on local filesystem persistence between requests.
- **Port Binding**: Application must bind to the port defined by `$PORT` (default `8080`).
- **Graceful Shutdown**: Handle `SIGTERM` signals within 10 seconds to finish in-flight requests.

