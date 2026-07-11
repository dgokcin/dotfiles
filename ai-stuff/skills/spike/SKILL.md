---
name: spike
description: Create a structured technical spike/assessment document for research topics. Use when starting technical research, evaluating a technology, or writing an assessment.
tools: Write, Read, Glob, WebFetch, WebSearch
disable-model-invocation: true
argument-hint: <topic name>
---

# Create Technical Spike

Create structured spike assessment in Obsidian vault.

## Instructions

1. Parse topic from: `$ARGUMENTS`
   - No args → ask for topic
2. Create spike dir + assessment at:
   `~/vault/work/spikes/<topic-slug>/assessment.md`
   - Vault path: `/Users/denizgokcin/Library/Mobile Documents/iCloud~md~obsidian/Documents/vault`
   - topic-slug: lowercase, spaces → hyphens

### Assessment Structure

Follow pattern from existing spikes (karpenter, crac, argocd):

```markdown
# <Topic> Assessment - Executive Summary

## Problem Statement

**Context:**

- [What problem are we solving]
- [Current pain points with metrics if available]

**Constraint:**

- [Key constraints or limitations]

## Proposed Solution

**What is <topic>?**
[Brief explanation]

**How it Works:**
[ASCII diagram or bullet points explaining the mechanism]

## Expected Improvements

| Metric | Current | Expected | Improvement |
| ------ | ------- | -------- | ----------- |
| ...    | ...     | ...      | ...         |

## Technical Feasibility

### Dependencies

- [List key dependencies]

### Compatibility

- [Compatibility considerations]

## Implementation Plan

### Phase 1: POC

- [POC steps]

### Phase 2: Integration Testing

- [Testing approach]

### Phase 3: Production Rollout

- [Rollout strategy]

## Risk Assessment

| Risk | Probability | Impact | Mitigation |
| ---- | ----------- | ------ | ---------- |
| ...  | ...         | ...    | ...        |

## Cost-Benefit Analysis

[ROI estimates, developer productivity gains, infrastructure savings]

## Resource Links

- [Relevant documentation links]
```

3. User provides context → pre-fill sections
4. User asks → web search/fetch for current docs
5. Report created file path when done