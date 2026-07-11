---
name: k8s-debug
description: "Debug Kubernetes cluster issues by investigating pods, deployments, services, resource constraints, and performance. Combine kubectl introspection with Datadog metrics and logs to diagnose pod failures (pending/crash/errors), service latency, connectivity issues, memory/CPU exhaustion, error spikes, and node problems. Use when a pod is stuck/failing, a service is slow or unreachable, resource pressure is suspected, or errors spike. Works across clusters (prod-tangela, prod-lion, prod-ruby, dev-verdigris, staging-silver, etc.) — mention the cluster name and the skill finds the right context automatically."
allowed-tools:
  # kubectl (read-only)
  - Bash(kubectl config:*)
  - Bash(kubectl get:*)
  - Bash(kubectl describe:*)
  - Bash(kubectl logs:*)
  - Bash(kubectl top:*)
  - Bash(kubectl events:*)
  - Bash(kubectl explain:*)
  - Bash(rtk kubectl config:*)
  - Bash(rtk kubectl get:*)
  - Bash(rtk kubectl describe:*)
  - Bash(rtk kubectl logs:*)
  - Bash(rtk kubectl top:*)
  - Bash(rtk kubectl events:*)
  - Bash(rtk kubectl explain:*)
  # General bash (read-only utilities)
  - Bash(grep:*)
  - Bash(awk:*)
  - Bash(sed:*)
  - Bash(head:*)
  - Bash(tail:*)
  - Bash(sort:*)
  - Bash(cut:*)
  - Bash(wc:*)
  - Bash(jq:*)
  - Bash(ls:*)
  - Bash(cat:*)
  - Bash(echo:*)
  - Bash(sleep:*)
  - Bash(rtk grep:*)
  - Bash(rtk awk:*)
  - Bash(rtk sed:*)
  - Bash(rtk head:*)
  - Bash(rtk tail:*)
  - Bash(rtk sort:*)
  - Bash(rtk cut:*)
  - Bash(rtk wc:*)
  - Bash(rtk jq:*)
  - Bash(rtk ls:*)
  - Bash(rtk cat:*)
  - Bash(rtk echo:*)
  - Bash(rtk sleep:*)
  # Datadog MCP - all commands
  - mcp__claude_ai_Datadog
---

# Kubernetes Debugging

Debug k8s cluster issues — combine kubectl introspection with Datadog metrics/logs.

## Cluster Context

Current context: `!kubectl config current-context 2>/dev/null || echo "(none)"`

**Cluster lookup**: read [.clusters.json](../_shared/config/.clusters.json) (relative to this skill's directory) and find the entry whose `.cluster` contains CLUSTER_NAME; use its `.context`.

If user mentions cluster name:

1. Extract cluster name (e.g., "prod-tangela", "dev-verdigris")
2. Query clusters.json → find full context (e.g., "argocd-prod/prod-tangela")
3. Use `kubectl --context=<full-context>` in all kubectl commands
4. If cluster not found or already current context → proceed with default or user-specified context

## Instructions

Systematic debug approach:

### 1. Understand the Problem

Ask user what they're investigating:

- **Pod issues**: Pod stuck in pending/crash/error?
- **Performance**: Latency, slow response, resource constraints?
- **Service connectivity**: Can't reach service, DNS issues?
- **Resource exhaustion**: CPU/memory pressure, disk space?
- **Error spikes**: Errors in logs/metrics?

### 2. kubectl Introspection

Start with kubectl — get cluster state:

**For pod issues:**

```bash
kubectl get pods -A --context=CONTEXT (or omit for default)
kubectl describe pod POD_NAME -n NAMESPACE
kubectl logs POD_NAME -n NAMESPACE (latest logs)
kubectl logs POD_NAME -n NAMESPACE --previous (previous container if crashed)
kubectl top pod POD_NAME -n NAMESPACE (resource usage)
kubectl events -n NAMESPACE --sort-by='.lastTimestamp' (recent events)
```

**For service/deployment issues:**

```bash
kubectl get svc -A
kubectl describe svc SERVICE_NAME -n NAMESPACE
kubectl get deployment -A
kubectl describe deployment DEPLOYMENT_NAME -n NAMESPACE
kubectl logs deployment/DEPLOYMENT_NAME -n NAMESPACE
kubectl top nodes (node resource usage)
```

**For resource constraints:**

```bash
kubectl describe nodes (check allocatable vs requested)
kubectl top nodes
kubectl get resourcequota -A
```

### 3. Correlate with Datadog

Got lead from kubectl → cross-reference Datadog:

**Search logs** for service/pod:

- Query: `service:SERVICE_NAME env:prod` (or appropriate env)
- Look for errors, exceptions, warnings
- Focus on time window when issue occurred

**Check metrics** for anomalies:

- Resource usage: `system.cpu.user{service:...}`, `system.memory.rss{service:...}`
- Request latency: `trace.web.request.duration{service:...}`
- Error rates: spikes in status codes or exception rates

**Search traces** (APM) if available:

- Query: `service:SERVICE_NAME status:error`
- Look for slow spans, service deps, bottlenecks
- Identify slow upstream services

**Aggregate for patterns:**

- Group errors by source, service, tag
- Issue widespread or isolated to specific pods/nodes?
- Check P99 latencies, not averages

### 4. Synthesize Findings

Combine kubectl + Datadog:

- **What**: Problem (pod crashed, service slow, resource exhausted, etc.)
- **Where**: Affected pod/node/service
- **When**: Issue time window
- **Why**: Root cause (pending → node resource limits, crashed → OOM, slow → external service latency, etc.)
- **Next steps**: What to investigate or fix

### 5. Deep Dives (as needed)

**Logs:** `analyze_datadog_logs` with SQL → aggregate error counts, parse stack traces, group by service
**Spans:** `aggregate_spans` → p95/p99 duration, group by resource/service
**Events:** `aggregate_events` → patterns (which nodes had issues, when)

## Common Debugging Patterns

| Symptom              | Check                            | Query                                                                        |
| -------------------- | -------------------------------- | ---------------------------------------------------------------------------- |
| Pod stuck in Pending | Node resources, ResourceQuota    | `kubectl describe node`, `kubectl describe pod`, `kubectl get resourcequota` |
| Pod CrashLoopBackOff | Logs, events, resource limits    | `kubectl logs --previous`, `kubectl events`, Datadog logs for errors         |
| Service slow         | Latency spikes, error rates      | Datadog traces, `kubectl top pod`, upstream service logs                     |
| High memory/CPU      | Resource requests, top consumers | `kubectl top`, Datadog metrics grouped by pod                                |
| Node NotReady        | Node events, kubelet logs        | `kubectl describe node`, check cluster addons                                |

## Rules

- **Always start with kubectl** — fast, gives cluster state
- **Cross-reference Datadog** — metrics/logs confirm + add context
- **Narrow queries** — by service, namespace, time window
- **Ask clarifying questions** if issue description vague
- **Show findings** — tell user what you found + what it means
- **No guessing** — data missing or inconclusive → say so

