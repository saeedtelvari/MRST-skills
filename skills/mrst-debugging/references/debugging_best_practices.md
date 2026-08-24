# MRST Debugging Best Practices: Diagnosis Patterns & Invariants

This document captures structural invariants and diagnostic patterns for debugging MRST simulations. It complements the debugging loop in SKILL.md with concrete diagnostic techniques.

## 1. Module Dependency Errors

The most common MRST startup failure is a missing module dependency.

**Invariant**: Every MRST function lives inside a module. If you call a function without loading its module via `mrstModule add <module>`, MATLAB will report `Undefined function or variable`. The error message does *not* tell you which module to load.

**Diagnostic Pattern**:
```matlab
% Find which module provides a function:
mrstPath search <functionName>
```

**Framework Traps**:
- **Transitive Dependencies**: Some modules depend on others (e.g., `ad-blackoil` depends on `ad-core` and `ad-props`). `mrstModule add ad-blackoil` will *not* auto-load `ad-core`. You must explicitly add all required modules.
- **Module Name vs Directory Name**: Module names use hyphens (e.g., `ad-core`), not underscores. Passing `ad_core` to `mrstModule add` will silently do nothing.

## 2. Newton Divergence Diagnosis

When `simulateScheduleAD` reports "Solver did not converge" or the residual norm grows, use this diagnostic ladder:

### Step 1: Enable Verbosity
```matlab
mrstVerbose(true);
solver = NonLinearSolver('verbose', true);
```
Watch the residual norm at each Newton iteration. Healthy convergence shows monotonic decrease.

### Step 2: Check Initial Conditions
- Pressure must be positive and physically reasonable (not 0, not 1e20)
- Saturations must sum to exactly 1 per cell
- Compositions (if compositional) must sum to 1

### Step 3: Isolate the Linear Solver
```matlab
solver.LinearSolver = BackslashSolverAD();
```
If the simulation converges with `BackslashSolverAD` but not with CPR/AMG, the problem is the preconditioner, not the physics. Consult `mrst-linear-solvers`.

### Step 4: Reduce Time Step
```matlab
schedule.step.val = schedule.step.val / 10;
schedule.step.control = repelem(schedule.step.control, 10);
```
If smaller steps converge, the original steps were too aggressive for the nonlinearity.

## 3. AD Dimension Mismatch Errors

**Invariant**: Every AD variable in the state struct must have exactly `G.cells.num` rows. If a state field has a different number of rows, the Jacobian assembly will fail with a cryptic dimension mismatch.

**Diagnostic Pattern**: Before calling `simulateScheduleAD`, validate:
```matlab
assert(numel(state0.pressure) == G.cells.num, 'Pressure size mismatch');
assert(size(state0.s, 1) == G.cells.num, 'Saturation size mismatch');
```

**Framework Trap**: When extracting subgrids or merging models, cell counts can silently change. Always re-validate state dimensions after grid operations.

## 4. The `validateModel` Diagnostic

**Invariant**: `model.validateModel(forces)` checks the model's internal consistency, including:
- Required state function dependencies are satisfied
- Well configurations match the grid
- Module dependencies are loaded

Call this before `simulateScheduleAD` to catch setup errors early:
```matlab
forces = getValidDrivingForces(model, 'W', W);
model = model.validateModel(forces);
```
