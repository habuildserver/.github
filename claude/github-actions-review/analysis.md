# GitHub Actions Review

**Repository:** habuildserver/.github
**Date:** 2026-03-11
**Branch:** feat/centralize-terraform-workflows
**Workflows reviewed:** 6

## Workflow Inventory

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `alpha-release.yaml` | `workflow_call` | Create alpha pre-release from PR branch |
| `release-preview.yaml` | `workflow_call` | Dry-run semantic-release and comment preview on PR |
| `release-version.yaml` | `workflow_call` | Run validation then create stable release on main push |
| `terraform-validate.yaml` | `workflow_call` | Terraform fmt, validate, tflint, test, checkov |
| `pr-title-check.yaml` | `workflow_call` | Enforce conventional commit PR titles |
| `development-pr-checks.yml` | `workflow_call` | Node.js lint, test, coverage (not owned by user) |

## Findings

### Must Fix

1. **Node.js 20 deprecation across all workflows** — `actions/checkout@v4`, `actions/setup-node@v4`, `hashicorp/setup-terraform@v3`, `terraform-linters/setup-tflint@v4` all run on Node.js 20, deprecated June 2, 2026. GitHub will force Node.js 24 after that date. Upgrade to `@v5` where available (`actions/checkout@v5` exists) and monitor others.

2. **CI check gate has a race condition** — The new "Verify CI checks passed" step in `alpha-release.yaml` queries check runs on the HEAD SHA. If CI is triggered by the same push that the `/alpha-release` comment targets, the check runs may still be `in_progress` or `queued` — the gate would see them as "not passed" and fail. This is actually safe (fails closed), but the error message could be confusing. Checks with `null` conclusion (in-progress) would be caught by the `!= "success"` filter, which is correct behavior.

3. **Semantic-release version inline in release-version.yaml differs in format** — `release-version.yaml` uses `cycjimmy/semantic-release-action@v4` with `semantic_version: 24.2.0`, while `alpha-release.yaml` and `release-preview.yaml` use `npx --package semantic-release@24.2.0`. The versions match (24.2.0), but the execution paths differ — the action bundles its own runner vs. npx downloading fresh. This could produce different behavior if the action version drifts.

### Should Fix

4. **No concurrency control on any workflow** — All 6 workflows lack `concurrency` groups. Since they're all `workflow_call`, concurrency is inherited from the caller. However, callers may also lack concurrency. Recommend documenting that callers MUST set concurrency, or add it here as a defensive measure. Particularly important for `alpha-release.yaml` — two simultaneous `/alpha-release` comments could race on tag creation.

5. **`mshick/add-pr-comment@v2` is a third-party action used without version pinning** — Used in both `alpha-release.yaml` (line 166) and `release-preview.yaml` (line 102). Major version tag `@v2` is the minimum acceptable level, but for third-party actions, SHA pinning is more secure. At minimum, pin to a specific version tag.

6. **`actions/github-script@v6` in development-pr-checks.yml is outdated** — v7 is current. (Note: this file is not owned by user, flagging for awareness only.)

7. **`pr-title-check.yaml` uses specific version `@v6.1.1`** — Good practice for third-party action, but inconsistent with other actions using major version tags. Choose one pinning strategy across the repo.

### Nice to Have

8. **Alpha release PR comment still references `vendor.yaml`** — Line 178 says "Update `vendor.yaml` or catalog source version". Since infra-stacks switched to JIT source provisioning, the comment should reference only catalog/stack source version.

9. **No `README.md` documenting the reusable workflows** — Consumers need to know inputs, permissions required, and expected caller setup.

10. **`development-pr-checks.yml` has a debug step** — Line 53: `ls -R src/app/common || echo "No common folder!"` should be removed for production use. (Not owned by user.)

## Checklist Results

| Check | Status | Notes |
|-------|--------|-------|
| Version consistency | Pass | semantic-release 24.2.0 across all workflows, plugins match |
| Plugin alignment | Pass | Same 3 plugins in alpha-release, release-preview, release-version |
| Permissions | Pass | Job-level permissions, least-privilege applied |
| Concurrency control | Warn | No concurrency groups — relies on callers to set them |
| Path filters | N/A | All `workflow_call` — callers control triggers |
| Reusable workflows | Pass | Good DRY pattern — validation reused in release-version |
| Action pinning | Warn | Mix of major tag (`@v4`) and specific version (`@v6.1.1`) |
| Secrets handling | Pass | `GITHUB_TOKEN` via env vars, no hardcoded secrets |
| Node.js 20 deprecation | Fail | All actions on Node.js 20, deadline June 2, 2026 |
| CI gate on alpha release | Pass | New check verifies all PR checks pass before release |

## Grade: B

**Justification:**
- Good reusable workflow architecture with `workflow_call` pattern
- Consistent semantic-release version and plugin set
- Proper least-privilege permissions at job level
- `persist-credentials: false` applied to all checkouts
- CI gate on alpha release is a solid addition
- Loses points for Node.js 20 deprecation, missing concurrency, and inconsistent action pinning

**What would move to next grade:**
1. Upgrade actions to Node.js 24 compatible versions
2. Add concurrency groups (or document caller requirement)
3. Standardize action version pinning strategy
