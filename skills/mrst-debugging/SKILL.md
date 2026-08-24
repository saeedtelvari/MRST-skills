---
name: mrst-debugging
description: Robust diagnosis and bug-fixing loop for MRST. Handles architecture errors (missing modules, AD dimension mismatches) and numerical divergence (Newton failures). Use when a simulation crashes or fails.
---

# MRST Debugging Loop

A ruthless, fully autonomous discipline for diagnosing and fixing MRST bugs. MRST simulations can be slow and their object-oriented Automatic Differentiation (AD) traces can be opaque. **You must not guess.** Follow this loop to isolate the failure, fix it, and port the fix back to the user.

## Phase 1: The Tight MRST Feedback Loop (Miniaturize)

MRST simulations can take minutes or hours to crash. **Never debug against the full simulation.**

1. **Isolate**: Create a throwaway MATLAB script (`debug_harness.m`) in your scratch directory or workspace using `skills/mrst-debugging/examples/debug_harness_template.m` as a starting point.
2. **Miniaturize**: Strip down the physics and geometry to the bare minimum required to reproduce the exact symptom.
   - Use a tiny grid: `G = cartGrid([3,3,1]); G = computeGeometry(G);`
   - Use 1 or 2 wells instead of 50.
   - Run 1 or 2 small timesteps (e.g., `schedule = simpleSchedule(1*day, 'W', W);`).
   - If the bug is a syntax/architecture error (e.g., `Unmet dependency`), you might only need the initialization code, no `simulateScheduleAD` required!
3. **Verify Red**: Run your `debug_harness.m`. It **must** throw the exact same error or divergence the user reported. If it throws a different error, you minimized incorrectly.

*Completion Criterion*: You have a script that runs in <10 seconds and reliably reproduces the bug.

## Phase 2: Instrument & Diagnose

Once the harness goes red, inspect the MRST internals. Do not just stare at the code.

### For Architecture & Setup Errors:
- Check module dependencies: Did you run `mrstModule add ...` for all required modules (e.g., `ad-props`, `mrst-gui`, `ad-blackoil`)?
- Call `model.validateModel()` to check for missing setup steps.
- If it's a `StateFunction` dependency error, check the groupings (`model.FlowPropertyFunctions`, `model.PVTPropertyFunctions`) to see where the dependency graph broke. Note: assigning a property directly to an empty grouping creates a struct instead of an object. Always instantiate groupings properly (e.g. `model.PVTPropertyFunctions = PVTPropertyFunctions(model);`).

### For Solver Divergence (Newton-Raphson failures):
- Turn on verbosity: `mrstVerbose(true)` and `solver.Verbose = true;` to watch the residuals.
- Check if initial conditions are unphysical (e.g., negative pressures, saturations summing > 1).
- Inspect the AD variables inside the Newton loop. Are gradients exploding?
- Try switching the linear solver to a direct solver (`'LinearSolver', BackslashSolverAD()`) to rule out CPR/AMG preconditioner failures.

## Phase 3: Fix & Validate (Max 3 Cycles)

You have a **maximum of 3 fix-validate cycles** per hypothesis category (architecture vs. numerical). Track your cycle count explicitly.

1. Apply your hypothesized fix to `debug_harness.m`.
2. Run it. Check if it goes Green.
3. **If Green**: Port the fix to the user's actual codebase. Run or instruct the user to run it.
4. **If Still Red (cycle < 3)**: Re-diagnose with new instrumentation from Phase 2. Return to step 1 with a *different* hypothesis.
5. **If Still Red (cycle = 3)**: **STOP. Escalate to user.** Present everything you know (see Phase 4 Escalation below). Do NOT attempt a 4th cycle.

### Exit Conditions

| Condition | Action |
|-----------|--------|
| Fix goes Green in harness + main code | → Phase 4: Success Brief |
| 3 fix cycles exhausted, still Red | → Phase 4: Escalation Brief |
| Cannot reproduce bug in Phase 1 after 2 attempts | → STOP. Tell user the bug is environment-specific |
| Bug requires MRST source modification (not user code) | → STOP. Report as upstream MRST framework bug |

## Phase 4: The Brief (Push Right)

Do not interrupt the user with intermediate questions unless you are completely blocked and cannot reproduce the bug in Phase 1. Work autonomously.

### Success Brief
Once the bug is fixed in the main codebase, present:
1. **The Root Cause**: A 1-2 sentence explanation of exactly what failed in MRST's architecture or physics.
2. **The Fix**: What you changed.
3. **Verification**: Confirmation that the minimal harness and/or full script now runs green.

### Escalation Brief (3 cycles exhausted)
If you could not fix the bug after 3 cycles, present:
1. **Symptom**: The exact error or divergence behavior.
2. **Hypotheses Tested**: What you tried and why each failed.
3. **Diagnostic Data**: Key instrumentation output (residuals, AD variable shapes, stack traces).
4. **Recommended Next Steps**: What the user should investigate manually or what external expertise is needed.

---

## Prerequisites
- Knowledge of MRST architecture (see `mrst-ad-oo`, `mrst-custom-physics`, `mrst-gridding`).

## Cross-References
- `mrst-linear-solvers`: Useful if the bug is related to CPR or GMRES failing to invert the Jacobian.
- `mrst-diagnostics`: For flow-based sanity checks before running full AD.
- **References**:
  - [Debugging Best Practices: Diagnosis Patterns & Invariants](references/debugging_best_practices.md)
