# Modern Secret & Credential Management Reference

Guidelines for handling secrets securely in cloud-native and multi-agent systems.

---

## 1. Secrets Hierarchy

1. **Development**:
   - Store developer secrets in `.env` (strictly ignored by `.gitignore`).
   - Maintain `.env.example` with non-secret defaults.
2. **CI / CD Pipelines**:
   - Store build secrets in GitHub Encrypted Secrets, GitLab CI Variables, or Google Cloud Secret Manager.
3. **Production**:
   - Inject secrets at container or orchestration startup via environment variables or secret vaults (AWS Secrets Manager, GCP Secret Manager, HashiCorp Vault).

---

## 2. Accidental Secret Leak Remediation

If an API key or password is accidentally committed:
1. **Rotate Immediately**: Invalidate the key in the provider console immediately. Commits are scraped by bots within seconds of being pushed to public remotes.
2. **Purge Git History**: Use `git-filter-repo` or BFG Repo-Cleaner to rewrite history, or rotate and recommit. Never rely merely on a `git revert`.

