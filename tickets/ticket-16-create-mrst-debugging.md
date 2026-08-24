Type: task
Status: resolved
Blocked by:

## Question

Create the `mrst-debugging` skill. This skill adapts the ruthless feedback-loop principles of the `diagnosing-bugs` workflow specifically for the MRST ecosystem. It must handle both architecture/setup crashes and nonlinear solver divergence with full autonomy, only interrupting the user with a final Brief.

**Labels**: `wayfinder:task`

## Specification

### Deliverables

1. `skills/mrst-debugging/SKILL.md`
   - **Trigger**: An error is reported, or a simulation diverges/crashes.
   - **Phase 1 (Isolate & Miniaturize)**: Mandate creating a fast <10s throwaway harness (e.g., `cartGrid([5,5])`, 1 timestep) that reproduces the exact error. Never debug against a multi-minute full simulation.
   - **Phase 2 (Instrument & Diagnose)**: Use MRST-specific probes (e.g., `mrstVerbose(true)`, `validateModel()`, plotting residuals).
   - **Phase 3 (Fix & Port)**: Fix the bug in the harness, then port it back to the main script.
   - **Phase 4 (The Brief)**: Push-right philosophy. Present a concise summary of the root cause, the applied fix, and the green result.
2. `skills/mrst-debugging/examples/debugging_workflow_demo.md` (or `.m`)
   - A markdown walkthrough or script demonstrating how an agent should apply this loop to a common MRST bug (e.g., an AD dimension mismatch or unmet state function dependency).
