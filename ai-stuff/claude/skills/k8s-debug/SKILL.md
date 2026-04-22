---
name: k8s-debug
description: "Debug Kubernetes issues using kubectl and Datadog. Investigate pod failures, service latency, errors, and resource constraints. Use when troubleshooting k8s problems, diagnosing application issues in cluster, checking metrics, or correlating logs across services."
disable-model-invocation: true
argument-hint: "[dev-verdigris|prod-lion] (defaults to current context)"
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
  - mcp__datadog-mcp__search_datadog_logs
  - mcp__datadog-mcp__analyze_datadog_logs
  - mcp__datadog-mcp__search_datadog_spans
  - mcp__datadog-mcp__aggregate_spans
  - mcp__datadog-mcp__search_datadog_metrics
  - mcp__datadog-mcp__get_datadog_metric
  - mcp__datadog-mcp__get_datadog_metric_context
  - mcp__datadog-mcp__search_datadog_dashboards
  - mcp__datadog-mcp__get_datadog_dashboard
  - mcp__datadog-mcp__search_datadog_monitors
  - mcp__datadog-mcp__search_datadog_incidents
  - mcp__datadog-mcp__get_datadog_incident
  - mcp__datadog-mcp__search_datadog_events
  - mcp__datadog-mcp__aggregate_events
  - mcp__datadog-mcp__search_datadog_rum_events
  - mcp__datadog-mcp__aggregate_rum_events
  - mcp__datadog-mcp__search_datadog_services
  - mcp__datadog-mcp__search_datadog_service_dependencies
  - mcp__datadog-mcp__get_datadog_trace
---

# Kubernetes Debugging

Debug Kubernetes cluster issues by combining kubectl introspection with Datadog metrics and logs.

## Kubeconfig Context

Current kubeconfig context (default): `!kubectl config current-context 2>/dev/null || echo "(none)"`

User selected context: `$ARGUMENTS`

- If user provided a context hint (e.g., "prod-lion"): Use that context via `kubectl --context=prod-lion`
- If empty: Use current context from `kubeconfig`
- When running kubectl commands, **always include `--context` flag if a specific context was requested**, or omit it to use default

## Instructions

When debugging, follow this systematic approach:

### 1. Understand the Problem

Ask the user what they're investigating:
- **Pod issues**: Pod stuck in pending/crash/error state?
- **Performance**: Latency, slow response times, resource constraints?
- **Service connectivity**: Can't reach service, DNS issues?
- **Resource exhaustion**: CPU/memory pressure, disk space?
- **Error spikes**: Errors appearing in logs/metrics?

### 2. kubectl Introspection

Start with kubectl to understand cluster state:

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

Once you have a lead from kubectl, cross-reference with Datadog:

**Search logs** for the service/pod:
- Query: `service:SERVICE_NAME env:prod` (or appropriate env)
- Look for error messages, exceptions, warnings
- Focus on the time window when the issue occurred

**Check metrics** for anomalies:
- Resource usage: `system.cpu.user{service:...}`, `system.memory.rss{service:...}`
- Request latency: `trace.web.request.duration{service:...}`
- Error rates: Look for spikes in status codes or exception rates

**Search traces** (APM) if available:
- Query: `service:SERVICE_NAME status:error` (for error traces)
- Look for slow spans, service dependencies, bottlenecks
- Identify which upstream service is slow (if applicable)

**Aggregate for patterns:**
- Group errors by source, service, or tag
- Check if issue is widespread or isolated to specific pods/nodes
- Look at P99 latencies, not just averages

### 4. Synthesize Findings

Combine kubectl and Datadog findings:
- **What**: What is the problem (pod crashed, service slow, resource exhausted, etc.)
- **Where**: Which pod/node/service is affected
- **When**: Time window of the issue
- **Why**: Root cause (pending due to node resource limits, crashed due to OOM, slow due to external service latency, etc.)
- **Next steps**: What to investigate further or what to fix

### 5. Deep Dives (as needed)

**If investigating logs:** Use `analyze_datadog_logs` with SQL to aggregate error counts, parse stack traces, group by service
**If investigating spans:** Use `aggregate_spans` to find p95/p99 duration, group by resource or service
**If investigating events:** Use `aggregate_events` to find patterns (e.g., which nodes had issues, when)

## Common Debugging Patterns

| Symptom | Check | Query |
|---------|-------|-------|
| Pod stuck in Pending | Node resources, ResourceQuota | `kubectl describe node`, `kubectl describe pod`, `kubectl get resourcequota` |
| Pod CrashLoopBackOff | Logs, events, resource limits | `kubectl logs --previous`, `kubectl events`, Datadog logs for errors |
| Service slow | Latency spikes, error rates | Datadog traces, `kubectl top pod`, upstream service logs |
| High memory/CPU | Resource requests, top consumers | `kubectl top`, Datadog metrics grouped by pod |
| Node NotReady | Node events, kubelet logs | `kubectl describe node`, check cluster addons |

## Rules

- **Always start with kubectl** — it's fast and gives you cluster state
- **Then cross-reference with Datadog** — metrics/logs confirm and provide context
- **Be specific with queries** — narrow down by service, namespace, time window
- **Ask clarifying questions** if the issue description is vague
- **Show your findings** — tell the user what you found and what it means
- **Don't guess** — if data is missing or inconclusive, say so
