Type: task
Status: resolved
Blocked by:

## Question

Create the new `mrst-optimization` skill covering adjoint-based optimization, sensitivity analysis, and production optimization workflows in MRST.

**Labels**: `wayfinder:task`

## Specification

### Deliverables

1. `skills/mrst-optimization/SKILL.md` — The monolithic skill instruction file.
2. `skills/mrst-optimization/examples/optimize_well_controls.m` — Well rate/BHP optimization for NPV.
3. `skills/mrst-optimization/examples/sensitivity_analysis.m` — Adjoint gradient computation and visualization.

### SKILL.md Structure

Follow the pattern in `skills/mrst-ad-oo/SKILL.md`:

```
---
name: mrst-optimization
description: Adjoint-based optimization and sensitivity analysis for MRST — well control optimization, NPV maximization, gradient computation, and production optimization.
---

# MRST Optimization & Sensitivity Analysis Skill

<intro: optimization is a qualitatively different workflow from forward simulation — 
define objective, compute adjoint gradients backward through the simulation, update 
controls via BFGS/L-BFGS, iterate>

## Prerequisites

This skill builds on top of a working forward simulation. If you don't have one set up,
consult `mrst-ad-oo` first to build the model, schedule, and initial state.

## Core Paradigms

### 1. Adjoint Gradient Computation
- `computeGradientAD` — compute sensitivities of an objective w.r.t. well controls
- The adjoint method: runs backward through stored simulation states
- Gradient accuracy: exact (not finite-difference) via AD chain rule

### 2. Objective Functions
- `NPVOW` — Net Present Value (oil revenue minus water handling costs)
- Custom objective functions: any scalar function of well solutions
- Discount factors, price parameters, operational costs

### 3. Optimization Algorithms
- `unitBoxBFGS` — box-constrained quasi-Newton (L-BFGS)
- Line search strategies
- Parameter scaling and bound constraints
- Convergence criteria and iteration limits

### 4. Well Placement Optimization (if supported)
- Gradient of objective w.r.t. well location
- Discrete optimization heuristics

## Agent Instructions: Initialization

<standard pattern>

Modules to load:
```matlab
run('database/MRST-main/startup.m');
mrstModule add ad-core ad-props ad-blackoil optimization
```

## Agent Instructions: Knowledge Retrieval

<standard FTS5 + graphify pattern>

## Standard Optimization Workflow

1. **Set up forward simulation** (grid, model, schedule, state0) — use `mrst-ad-oo`
2. **Define objective function**:
   ```matlab
   objective = @(wellSols, states, schedule) NPVOW(wellSols, schedule, ...
       'OilPrice', 50/stb, 'WaterInjectionCost', 5/stb, ...
       'WaterProductionCost', 3/stb, 'DiscountFactor', 0.1);
   ```
3. **Run forward simulation** to get baseline
4. **Compute adjoint gradients**:
   ```matlab
   gradient = computeGradientAD(state0, states, model, schedule, objective);
   ```
5. **Optimize**:
   ```matlab
   [v, u_opt, history] = unitBoxBFGS(u0, @(u) evalObjective(u, ...
       state0, model, schedule, objective), 'objChangeTol', 1e-5);
   ```
6. **Post-process**: compare optimized vs baseline production profiles

## Cross-References
- **Requires**: `mrst-ad-oo` for the forward simulation setup
- **Accelerated by**: `mrst-linear-solvers` (optimization runs many forward+adjoint solves)
```

### Example Scripts

**optimize_well_controls.m**: 
- Build a simple 2D waterflood case (1 injector, 1 producer)
- Define NPV objective with oil price, water cost
- Run baseline simulation
- Compute adjoint gradients of NPV w.r.t. injection rates
- Optimize rates using `unitBoxBFGS`
- Plot before/after NPV comparison

**sensitivity_analysis.m**:
- Take a black-oil model, simulate forward
- Compute adjoint gradients of cumulative oil production w.r.t. each time step's well controls
- Visualize gradient magnitude per time step as a bar chart
- Interpret which control periods have highest sensitivity

### Research Guidance

```
python -m tools.mrst_index.search_index keyword "computeGradientAD"
python -m tools.mrst_index.search_index keyword "NPVOW"
python -m tools.mrst_index.search_index keyword "unitBoxBFGS"
python -m tools.mrst_index.search_index keyword "evalObjective"
graphify query "How does adjoint optimization work in MRST?"
graphify path "computeGradientAD" "simulateScheduleAD"
```

Also reference `optimization_info.txt` in the repo root for pre-gathered notes (note: UTF-16LE encoding).
  
## Answer  
  
The mrst-optimization skill has been created successfully. The SKILL.md file covers adjoint gradients, NPVOW usage, and unitBoxBFGS. Two examples were created: optimize_well_controls.m and sensitivity_analysis.m. 
