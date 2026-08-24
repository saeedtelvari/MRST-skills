Type: task
Status: resolved
Blocked by:

## Question

Create a top-level `mrst` router/meta-skill that maps user intent to the correct specialist skill(s) and provides multi-skill composition recipes.

**Labels**: `wayfinder:task`

## Specification

### Deliverables

1. `skills/mrst/SKILL.md` — The router skill with routing table, dependency DAG, and composition recipes.

### Rationale

With 11 specialist skills, an agent faces selection paralysis. A single entry-point skill that routes based on keywords and provides multi-skill recipes eliminates this problem without restructuring the existing paradigm-based skills.
