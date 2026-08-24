---
name: mrst-linear-solvers
description: Configure high-performance linear solvers and preconditioners (CPR, AMG, ILU) in MRST.
---

# MRST Linear Solvers Skill

This skill provides the knowledge to replace MATLAB's default direct solver (`mldivide` / `\`) with high-performance iterative linear solvers and preconditioners in MRST, crucial for large-scale 3D models.

## Prerequisites

> Before using this skill, ensure you've consulted:
> - `mrst-ad-oo` — for the AD-OO simulation framework

## Core Paradigms

1. **Constrained Pressure Residual (CPR)**: 
   - A two-stage preconditioner that extracts a pressure equation (solved usually by AMG) and handles the transport part with ILU0 or similar.
2. **Algebraic Multigrid (AMG)**: 
   - Provided via AGMG or similar third-party wrappers, used heavily in CPR.
3. **LinearSolverAD**: 
   - The wrapper class in MRST that bridges iterative preconditioners to the generalized `NonLinearSolver`.

## Agent Instructions: Initialization

You **MUST** include the following initialization at the top of your scripts. 

```matlab
% Initialize MRST Setup
run('database/MRST-main/startup.m');

% Add required modules for linear solvers
mrstModule add linearsolvers ad-core
```
*(Optionally add `agmg` if available).*

## Agent Instructions: Knowledge Retrieval

Configuring solver options correctly is non-trivial. Use the AI knowledge tools:

1. **Search the Textbooks and Source Code**:
   ```bash
   python -m tools.mrst_index.search_index keyword "CPRSolverAD"
   python -m tools.mrst_index.search_index keyword "ILU0"
   ```

2. **Navigate the Codebase Graph (GraphRAG)**:
   Use `graphify` to explore the interactions:
   - `graphify query "How does CPRSolverAD connect to LinearSolverAD?"`
   - `graphify explain "LinearSolverAD"`

## Standard Linear Solver Workflow

Instead of passing just `NonLinearSolver()`, you configure a linear solver backend and pass it to the nonlinear solver.

1. **Configure the Linear Solver (e.g., CPR)**:
   ```matlab
   % Instantiate CPRSolverAD directly (it inherently uses GMRES).
   % It defaults to Backslash for the elliptic part, but you can pass AMG wrappers:
   % linsolve = CPRSolverAD('ellipticSolver', AGMGSolverAD(), 'tolerance', 1e-3);
   linsolve = CPRSolverAD('tolerance', 1e-3, 'maxIterations', 50);
   ```
2. **Inject into NonLinearSolver**:
   ```matlab
   % Instantiate the generalized NonLinearSolver with the iterative backend
   solver = NonLinearSolver('LinearSolver', linsolve);
   
   % Execute
   [wellSols, states, report] = simulateScheduleAD(state0, model, schedule, ...
                                                   'NonLinearSolver', solver);
   ```
## Cross-References

- **Downstream**: Accelerates all AD-based skills
- **Reference**: [Linear Solvers Best Practices](references/linear_solvers_best_practices.md) - Deep dive into CPR preconditioner structural configurations and block-ILU framework invariants.
