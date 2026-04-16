# Build & Push to ECR

Composite action that builds a Docker image and pushes to Amazon ECR. Tags with git SHA (for K8s/ArgoCD) and `latest` (for ECS).

## Features

- BuildKit with GHA cache for fast builds
- Auto-creates ECR repo if it doesn't exist (with scan-on-push)
- Skips build if SHA tag already exists in ECR
- Atomic push (all tags in one operation)
- ClickUp notifications on success and failure
- Input validation (service name, environment, account ID, file paths)
- OCI labels for build traceability
- All third-party actions pinned to SHA

## Usage

### Single service

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      id-token: write
    steps:
      - uses: actions/checkout@v4

      - uses: habuildserver/.github/.github/actions/build-push-ecr@main
        id: build
        with:
          service-name: chat-service
          environment: development
          aws-account-id: '963127282571'
          sdk-token: ${{ secrets.SDK_TOKEN }}

      - run: echo "Pushed ${{ steps.build.outputs.image-uri }}"
```

### Mono-repo (multiple services)

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      id-token: write
    steps:
      - uses: actions/checkout@v4

      - uses: habuildserver/.github/.github/actions/build-push-ecr@main
        with:
          service-name: orchestration-service
          environment: development
          aws-account-id: '963127282571'
          dockerfile: orchestration-service/build/Dockerfile
          context: .

      - uses: habuildserver/.github/.github/actions/build-push-ecr@main
        with:
          service-name: provider-service
          environment: development
          aws-account-id: '963127282571'
          dockerfile: provider-service/build/Dockerfile
          context: .
```

### Worker from same repo

```yaml
      - uses: habuildserver/.github/.github/actions/build-push-ecr@main
        with:
          service-name: chat-worker
          environment: development
          aws-account-id: '963127282571'
          dockerfile: build/worker/Dockerfile-development
```

### With submodules and ClickUp notifications

```yaml
      - uses: habuildserver/.github/.github/actions/build-push-ecr@main
        with:
          service-name: user-service
          environment: development
          aws-account-id: '963127282571'
          sdk-token: ${{ secrets.SDK_TOKEN }}
          common-token: ${{ secrets.COMMON_TOKEN }}
          use-submodules: 'true'
          clickup-token: ${{ secrets.CLICKUP_TOKEN }}
          clickup-workspace-id: ${{ secrets.CLICKUP_WORKSPACE_ID }}
          clickup-channel-id: ${{ secrets.CLICKUP_CHANNEL_ID }}
```

### With extra build args

```yaml
      - uses: habuildserver/.github/.github/actions/build-push-ecr@main
        with:
          service-name: chat-service
          environment: development
          aws-account-id: '963127282571'
          extra-build-args: |
            NODE_ENV=production
            BUILD_DATE=2026-04-17
```

## Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `service-name` | Yes | | ECR repo name (e.g., `chat-service`) |
| `environment` | Yes | `development` | `development`, `staging`, or `production` |
| `aws-account-id` | Yes | | 12-digit AWS account ID |
| `dockerfile` | No | `build/Dockerfile-<env>` | Path to Dockerfile |
| `context` | No | `.` | Docker build context |
| `aws-region` | No | `ap-south-1` | AWS region |
| `use-submodules` | No | `false` | Checkout with recursive submodules |
| `extra-build-args` | No | | Additional build args (one per line, `KEY=value`) |
| `notify-clickup` | No | `true` | Send ClickUp notifications |
| `sdk-token` | No | | GitHub Packages token for private npm |
| `common-token` | No | | PAT for submodule checkout |
| `clickup-token` | No | | ClickUp API token |
| `clickup-workspace-id` | No | | ClickUp workspace ID |
| `clickup-channel-id` | No | | ClickUp channel ID |

## Outputs

| Output | Description | Example |
|--------|-------------|---------|
| `image-tag` | Full git SHA | `abc123def456...` |
| `image-uri` | Full image URI with SHA tag | `963127282571.dkr.ecr.ap-south-1.amazonaws.com/chat-service-development:abc123...` |
| `short-sha` | 7-char SHA | `abc123d` |
| `ecr-repo` | ECR repo URI (without tag) | `963127282571.dkr.ecr.ap-south-1.amazonaws.com/chat-service-development` |

## ECR naming convention

Repos are named `<service-name>-<environment>`:
- `chat-service-development`
- `chat-service-staging`
- `chat-service-production`

## Rollback

**ECS:** Re-run the workflow for the desired commit, or re-tag a previous SHA image as `latest`.

**K8s/ArgoCD:** Revert the gitops manifest to the previous SHA tag. ArgoCD self-heals automatically.

## Prerequisites

- AWS OIDC role `github-actions-oidc-role` configured in the target account
- Caller job must have `permissions: { contents: read, id-token: write }`
- `jq` available on runner (pre-installed on `ubuntu-latest`)
