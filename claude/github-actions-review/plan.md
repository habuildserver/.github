# Implementation Plan

**Based on:** analysis.md
**Target Grade:** B -> A

## Steps

### Step 1: Upgrade actions to Node.js 24 compatible versions
**Severity:** Must Fix
**Files affected:**
- `.github/workflows/alpha-release.yaml`
- `.github/workflows/release-preview.yaml`
- `.github/workflows/release-version.yaml`
- `.github/workflows/terraform-validate.yaml`
- `.github/workflows/pr-title-check.yaml`

**Actions:**
1. `actions/checkout@v4` -> `@v5` (all 4 workflows that use it)
2. `actions/setup-node@v4` -> `@v5` (alpha-release, release-preview)
3. `hashicorp/setup-terraform@v3` -> check if v4 exists, otherwise keep v3
4. `terraform-linters/setup-tflint@v4` -> check if v5 exists, otherwise keep v4
5. `bridgecrewio/checkov-action@v12` -> verify Node.js 24 compatibility
6. Update `NODE_VERSION` env from `20.11.0` to `22.x` or `24.x`

**Verification:**
- [x] All actions use Node.js 24 compatible versions
- [x] NODE_VERSION env updated to 22

---

### Step 2: Update alpha release PR comment to reflect JIT provisioning
**Severity:** Nice to Have
**Files affected:**
- `.github/workflows/alpha-release.yaml`

**Actions:**
1. Replace `vendor.yaml` reference with stack source version reference
2. Update the test command to use `atmos terraform plan` directly (JIT auto-provisions)

**Verification:**
- [x] Comment template no longer mentions vendor.yaml

---

### Step 3: Pin third-party actions to specific version tags
**Severity:** Should Fix
**Files affected:**
- `.github/workflows/alpha-release.yaml`
- `.github/workflows/release-preview.yaml`

**Actions:**
1. Pin `mshick/add-pr-comment@v2` to latest specific version tag
2. Keep `amannn/action-semantic-pull-request@v6.1.1` as-is (already pinned)
3. Keep `cycjimmy/semantic-release-action@v4` at major tag (well-known action)

**Verification:**
- [x] Third-party actions pinned to specific version tags (mshick/add-pr-comment@v2.8.2)

## Notes
- `development-pr-checks.yml` is excluded from this plan (not owned by user)
- Concurrency is best handled in caller workflows since these are all `workflow_call` — recommend adding concurrency guidance to README or CLAUDE.md
