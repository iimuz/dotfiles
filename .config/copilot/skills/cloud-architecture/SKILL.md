---
name: cloud-architecture
description: This skill should be used when designing or reviewing multi-cloud architectures, migrations, or cloud-native patterns with security, cost, and resilience requirements.
---

# Cloud Architecture

## Overview

- Guide discovery, design, and delivery of scalable, secure, cost-efficient cloud architectures across AWS, Azure, and GCP.
- Apply Well-Architected principles with focus on business value, compliance, and operational excellence.
- Keep workflow guidance here and load detailed checklists from references/ as needed.

## When to Use This Skill

- Invoke this skill when defining or reviewing multi-cloud strategy and landing zone design.
- Invoke this skill when planning cloud migrations or modernization programs.
- Invoke this skill when selecting architecture patterns for reliability, security, cost, or performance outcomes.
- Invoke this skill when validating architecture excellence and delivery readiness.

## Core Workflow Phases

### Discovery → Analysis

- Establish business objectives, compliance needs, SLAs, and constraints.
- Inventory current architecture, workloads, dependencies, and costs.
- Consult [references/discovery-analysis.md](references/discovery-analysis.md) for analysis priorities and technical evaluation.

### Implementation → Architecture & Delivery

- Select patterns, services, and landing zone foundations.
- Implement security layers, automation, monitoring, and documentation.
- Consult [references/implementation-patterns.md](references/implementation-patterns.md) and specialized pattern references:
  - [references/multi-cloud-strategy.md](references/multi-cloud-strategy.md)
  - [references/migration-strategies.md](references/migration-strategies.md)
  - [references/specialized-patterns.md](references/specialized-patterns.md)

### Excellence → Validation & Operations

- Validate availability, security, performance, compliance, and cost targets.
- Confirm disaster recovery readiness, documentation, and enable continuous improvement.
- Consult [references/excellence-checklist.md](references/excellence-checklist.md) and:
  - [references/cost-optimization.md](references/cost-optimization.md)
  - [references/security-architecture.md](references/security-architecture.md)

## Tooling and Documentation Sources

- Prefer AWS Documentation MCP tools when available for service discovery and official guidance.
- Fall back to AWS CLI (`aws`) and `web_fetch` for documentation and service metadata when MCP tools are unavailable.
- Use standard CLI tools: `bash`, `view`, `grep`, `glob`, `edit`, `web_fetch`.
