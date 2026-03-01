# GitOps Configuration - The Bible

Based on: https://codefresh.io/blog/how-to-structure-your-argo-cd-repositories-using-application-sets/
Example repo: https://github.com/kostis-codefresh/many-appsets-demo

## The Four Categories of Manifests

| Category | Description | Type | Change Frequency | Target Users |
|----------|-------------|------|-----------------|--------------|
| 1 | Developer Kubernetes manifests | Helm, Kustomize or plain manifests in Git | Very often | Developers mostly |
| 2 | Developer Argo CD manifests | Argo CD app and Application Set | Almost never | Operators/Developers |
| 3 | Infrastructure Kubernetes manifests | Usually external Helm charts | Sometimes | Operators |
| 4 | Infrastructure Argo CD manifests | Argo CD app and Application Set | Almost never | Operators |

**Critical insight**: Each category has a different lifecycle. Never mix them.

### Category 1 - Developer K8s Manifests
- Standard Kubernetes resources (Deployment, Service, Ingress, ConfigMap, Secret)
- Can be deployed WITHOUT Argo CD on any local cluster
- Changes: updating image version (~80%), image + config (~15%), config only (~5%)
- Managed by: Helm, Kustomize, or plain YAML

### Category 2 - Argo CD Manifests
- Application CRDs and ApplicationSets
- Links a Git repo (cat 1) to a destination cluster
- Change frequency: set up once, then ALMOST NEVER change
- Anti-pattern alert: if these change constantly, something is wrong

## The Three-Level Structure (THE Standard)

```
Level 3: App-of-Apps (optional bootstrap)
    └── Level 2: ApplicationSets (per environment/team)
            └── Level 1: Kubernetes Manifests (Helm/Kustomize overlays)
```

### Repository Layout

```
repo/
├── apps/                          # Level 1 - K8s manifests
│   ├── billing/
│   │   └── envs/
│   │       └── prod/             # Only prod (not in QA)
│   ├── invoices/
│   │   └── envs/
│   │       ├── qa/
│   │       └── prod/
│   └── orders/
│       └── envs/
│           ├── qa/
│           └── prod/
├── appsets/                       # Level 2 - ApplicationSets
│   ├── qa-appset.yaml
│   ├── prod-appset.yaml
│   └── staging-appset.yaml
└── app-of-apps.yaml              # Level 3 - optional bootstrap
```

### Key Properties
- Only 3 levels of abstraction (4-5 = complexity disaster)
- Each level is completely independent
- Helm/Kustomize used ONCE at level 1, nowhere else
- Adding a new app = add folder under apps/
- Adding a new cluster = connect to ArgoCD, appsets auto-discover
- Adding a new environment = copy/modify an appset file

## ApplicationSet Examples

### Git Generator (Environment-based)

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: my-qa-appset
  namespace: argocd
spec:
  goTemplate: true
  goTemplateOptions: ["missingkey=error"]
  generators:
  - git:
      repoURL: https://github.com/org/gitops-repo.git
      revision: HEAD
      directories:
      - path: apps/*/envs/qa         # Finds all apps with qa overlay
  template:
    metadata:
      name: '{{index .path.segments 1}}-{{index .path.segments 3}}'
    spec:
      project: default
      source:
        repoURL: https://github.com/org/gitops-repo.git
        targetRevision: HEAD
        path: '{{.path.path}}'
      destination:
        server: https://kubernetes.default.svc
        namespace: '{{index .path.segments 1}}-{{index .path.segments 3}}'
```

### Matrix Generator (Apps × Clusters)

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: cluster-git
spec:
  generators:
  - matrix:
      generators:
      - git:                         # Child 1: discover apps from git
          repoURL: https://github.com/org/gitops-repo.git
          revision: HEAD
          directories:
          - path: apps/*
      - clusters: {}                 # Child 2: all registered clusters
  template:
    metadata:
      name: '{{path.basename}}-{{name}}'
    spec:
      project: default
      source:
        repoURL: https://github.com/org/gitops-repo.git
        targetRevision: HEAD
        path: '{{path}}'
      destination:
        server: '{{server}}'
        namespace: '{{path.basename}}'
```

### Cluster Generator (Cross-cluster deployment)

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: prod-appset
spec:
  generators:
  - clusters:
      selector:
        matchLabels:
          environment: production    # Only prod clusters
  template:
    metadata:
      name: '{{name}}-myapp'
    spec:
      destination:
        server: '{{server}}'
        namespace: myapp
```

## The Four Anti-Patterns

### Anti-Pattern 1 - Mixing Manifest Types

**Wrong**: Putting Helm values or Kustomize overrides inside the Application CRD

```yaml
# NEVER DO THIS
spec:
  source:
    helm:
      parameters:                    # Category 1 bleeding into Category 2
      - name: "image.tag"
        value: "1.2.3"
      values: |
        ingress:
          enabled: true
```

**Right**: Values belong in valueFiles in the same repo as the chart

```yaml
# DO THIS
spec:
  source:
    helm:
      valueFiles:
      - values-production.yaml       # Separate file in git
```

**Litmus test**: Can a developer deploy locally with ONLY kustomize or helm, without any knowledge of ArgoCD? If NO → you're mixing manifests.

### Anti-Pattern 2 - Wrong Abstraction Level

**Wrong**: CI pipeline changing `targetRevision` or `path` in Application CRDs

```yaml
# NEVER DO THIS
spec:
  source:
    targetRevision: dev              # This was main, then staging, now dev?!
    path: my-qa-app                  # This changes constantly
```

**Right**: Change the actual Kubernetes manifest (image tag in Deployment), not the ArgoCD Application CRD. The Application CRD should be set once and forgotten.

### Anti-Pattern 3 - Multiple Templating Levels

**Wrong**: Helm chart that contains Application CRDs which point to other Helm charts → double templating
- Creates impossible-to-debug nested template resolution
- Makes onboarding new engineers a nightmare
- Completely unnecessary with ApplicationSets

**Right**: Use ApplicationSets for templating at the ArgoCD layer. Use Helm/Kustomize for the K8s layer. One templating system per level.

### Anti-Pattern 4 - Not Using ApplicationSets

**Wrong**: Manually creating individual Application CRDs for each app/cluster combination
- 20 apps × 5 clusters = 100 files to manage manually
- Every new cluster = manual update to dozens of files

**Right**: ONE ApplicationSet with matrix generator → auto-generates all 100 combinations, automatically picks up new clusters and new apps.

## Repository Strategy

### Multi-Repo (Recommended)
- One repo per team (or related set of microservices)
- One repo for infrastructure apps (cert-manager, nginx, prometheus)
- Additional "common" repo if apps are shared across teams

```
org/
├── team-payments-gitops/           # Payments team manifests
├── team-orders-gitops/             # Orders team manifests
├── team-billing-gitops/            # Billing team manifests
└── infra-gitops/                   # cert-manager, nginx, prometheus, etc.
```

### Why NOT Monorepo for GitOps
- Performance: ArgoCD polls all repos; one giant repo = slow detection
- Git conflicts: all CI pipelines competing on the same repo
- Security: fine-grained access control becomes impossible
- Developer focus: devs only need their team's repo

### Monorepo Definition Clarification
- Source code monorepo (Google style) → NOT relevant to ArgoCD
- Same repo for source code + K8s manifests → separate these
- Single Git repo for ALL ArgoCD apps → this is the one to avoid at scale

## Cross-Cluster / Cross-Account Patterns

### Cluster Registration

```bash
# Register a cluster with ArgoCD
argocd cluster add <context-name> --name production-eu

# Add labels for cluster selection
kubectl label secret <cluster-secret> -n argocd \
  environment=production \
  region=eu \
  team=payments
```

### Cluster Labels for ApplicationSet Targeting

```yaml
# Target only EU production clusters
generators:
- clusters:
    selector:
      matchLabels:
        environment: production
        region: eu
```

### Cross-Account Pattern
- ArgoCD control plane in management/hub account
- Spoke clusters in workload accounts
- ArgoCD service account with minimal RBAC in each spoke
- Secret stored in ArgoCD namespace with cluster credentials

### Hub-and-Spoke AppSet Pattern

```yaml
# Deploy different apps to different cluster tiers
generators:
- list:
    elements:
    - cluster: cluster-dev
      url: https://dev.example.com
      environment: dev
    - cluster: cluster-staging
      url: https://staging.example.com
      environment: staging
    - cluster: cluster-prod-eu
      url: https://prod-eu.example.com
      environment: prod
    - cluster: cluster-prod-us
      url: https://prod-us.example.com
      environment: prod
```

## Day-2 Operations Quick Reference

| Task | Action | ArgoCD Change? |
|------|---------|----------------|
| Deploy app to new env | Add Kustomize overlay | No |
| Remove app from env | Delete Kustomize overlay | No |
| Create brand new app | Add folder under apps/ | No |
| Create new environment | Copy/modify an appset file | Yes (one file) |
| Add new cluster | Connect cluster to ArgoCD | No (auto-discovered) |
| Move cluster to diff env | Edit cluster label | No |
| Upgrade infra component | Update Helm chart version | No |

## Validation Commands

```bash
# Validate kustomize overlay (no ArgoCD needed)
kustomize build apps/invoices/envs/qa

# Compare environments
kustomize build apps/billing/envs/prod-eu > /tmp/eu.yaml
kustomize build apps/billing/envs/prod-us > /tmp/us.yaml
diff /tmp/eu.yaml /tmp/us.yaml

# Install locally (no ArgoCD)
kubectl apply -k apps/orders/envs/qa

# Check ArgoCD application health
argocd app list
argocd app get <app-name>
argocd app sync <app-name>
```

## ApplicationSet Generator Reference

| Generator | Use Case |
|-----------|----------|
| `git` | Discover apps from directory structure |
| `clusters` | Target registered ArgoCD clusters |
| `matrix` | Combine two generators (apps × clusters) |
| `list` | Explicit list of parameters |
| `merge` | Merge multiple generators with override |
| `scm-provider` | Discover repos in GitHub org/GitLab group |
| `pull-request` | PR preview environments |
| `cluster-decision-resource` | Integration with cluster fleet management |
