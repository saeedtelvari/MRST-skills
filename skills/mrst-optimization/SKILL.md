---
name: mrst-optimization
description: Adjoint-based optimization and sensitivity analysis for MRST — well control optimization, NPV maximization, gradient computation, and production optimization.
---

# MRST Optimization & Sensitivity Analysis Skill

Optimization in MRST is a qualitatively different workflow from forward simulation. Instead of just simulating a schedule, we define an objective function, compute adjoint gradients backward through the stored simulation states, and use numerical optimization (like L-BFGS) to iteratively update well controls to maximize or minimize the objective.

## Prerequisites

> Before using this skill, ensure you've consulted:
> - `mrst-ad-oo` — for the AD-OO simulation framework
>
> This skill builds on top of a working forward simulation. If you don't have one set up, consult `mrst-ad-oo` first to build the model, schedule, and initial state.

## Core Paradigms

### 1. Adjoint Gradient Computation
- `computeGradientAdjointAD` — compute sensitivities of an objective w.r.t. parameters.
- `evalObjective` — evaluates the objective value and gradients by simulating the schedule and then running the adjoint pass.
- The adjoint method runs backward through stored simulation states, allowing exact (AD chain rule based) gradient computation with respect to many control variables simultaneously without expensive finite differences.

### 2. Objective Functions
- `NPVOW` — Net Present Value for Oil-Water systems (oil revenue minus water handling costs).
  - Note: In MRST's `NPVOW`, producers have negative rates (`qOs < 0`), so `-ro * qOs` yields positive revenue.
- Custom objective functions can be written as scalar functions of well solutions.
- Objective functions incorporate discount factors, price parameters, and operational costs.

### 3. Optimization Algorithms
- `unitBoxBFGS` — box-constrained quasi-Newton (L-BFGS) optimizer.
- By default, `unitBoxBFGS` **MAXIMIZES** the objective function.
- It operates on a scaled control vector $u \in [0, 1]$.
- Bound constraints and scaling are handled using a `scaling` struct with `boxLims`.
- `schedule2control` and `control2schedule` convert between physical schedules and the scaled $[0, 1]$ parameter space.

## Agent Instructions: Initialization

Whenever you write a MATLAB script for MRST optimization, you **MUST** include the following initialization sequence at the top of your script:

```matlab
run('database/MRST-main/startup.m');
mrstModule add ad-core ad-props ad-blackoil optimization
```

## Agent Instructions: Knowledge Retrieval

1. **Search the Textbooks and Source Code**:
   Run the following Python CLI to query the FTS5 knowledge base:
   ```bash
   python -m tools.mrst_index.search_index keyword "computeGradientAdjointAD"
   ```

2. **Navigate the Codebase Graph (GraphRAG)**:
   Use `graphify` to understand how modules interact:
   - `graphify query "How does adjoint optimization work in MRST?"`
   - `graphify path "evalObjective" "simulateScheduleAD"`

## Standard Optimization Workflow

1. **Set up forward simulation** (grid, model, schedule, state0) — use `mrst-ad-oo`.
2. **Define scaling for controls**:
   ```matlab
   % Example limits: injectors 0 to 400 m^3/d, producers 100 to 250 bars
   % Note: boxLims has size [numWells, 2] for EACH control step, but typically we 
   % stack all well limits as rows if they are constant across steps.
   scaling.boxLims = [0, 400/day; 100*barsa, 250*barsa];
   scaling.obj = 1e7; % scale objective to ~O(1)
   u_base = schedule2control(schedule, scaling);
   ```
3. **Define objective function**:
   ```matlab
   npvopts = {'OilPrice', 50/stb, 'WaterProductionCost', 3/stb, 'WaterInjectionCost', 3/stb, 'DiscountFactor', 0.1};
   obj = @(model, states, schedule, varargin) NPVOW(model, states, schedule, varargin{:}, npvopts{:});
   f = @(u) evalObjective(u, obj, state0, model, schedule, scaling);
   ```
4. **Optimize**:
   ```matlab
   [v, u_opt, history] = unitBoxBFGS(u_base, f, 'objChangeTol', 1e-5);
   schedule_opt = control2schedule(u_opt, schedule, scaling);
   ```
5. **Post-process**: compare optimized vs baseline production profiles.
## Cross-References

- **Orthogonal**: `mrst-linear-solvers` (for performance)
- **References**:
  - [Optimization Best Practices: Adjoint Gradients & Control Scaling](references/optimization_best_practices.md)
