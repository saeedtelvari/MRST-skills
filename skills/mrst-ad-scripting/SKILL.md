---
name: mrst-ad-scripting
description: Use raw ADI variables and manual Newton loops for rapid prototyping of custom PDEs without MRST's full object-oriented overhead.
---

# MRST AD Scripting Skill

This skill explains how to build lightweight, standalone solvers using MRST's Automatic Differentiation (AD) engine (`initVariablesADI`). This approach avoids the `PhysicalModel` hierarchy and is ideal for fast prototyping, custom PDEs, or educational scripts where the full schedule/facility integration is unnecessary.

## Prerequisites

> Before using this skill, ensure you've consulted:
> - `mrst-gridding` — for grid generation and geometry computations.

## Core Paradigms

The scripting paradigm treats MRST as a raw algebraic AD framework:

1. **`initVariablesADI`**: Initializes variables as objects tracking both their values and their sparse Jacobians with respect to independent variables.
2. **Discrete Operators**: You manually construct difference operators (like gradient and divergence) using sparse connection matrices (`C`) derived from `G.faces.neighbors`.
3. **Manual Newton-Raphson**: You write a custom `while` loop that evaluates the residual `eq.val`, checks convergence (`norm(eq.val, inf) < tol`), and updates the independent variables (`p = p - eq.jac{1}\eq.val`).

## Agent Instructions: Initialization

Whenever you write a MATLAB script for AD scripting in MRST, you **MUST** include the following initialization sequence at the top of your script. 

```matlab
% Initialize MRST Setup
run('database/MRST-main/startup.m');

% Add required modules for AD
mrstModule add ad-core
```

## Agent Instructions: Usage Guidelines

- **Standalone Fast Prototyping**: This paradigm is strictly for lightweight standalone scripts. Do **NOT** try to hook these raw loops into `simulateScheduleAD` or the `FacilityModel`.
- **Operator Construction**: Always use `sparse` to build the connection matrix `C` for interior faces.
- **Upwinding / Averaging**: When evaluating properties on faces (e.g., mobilities or transmissibilities), you must either upwind (using `upwindPlane`) or average cell values to faces (e.g., using `abs(C)` for arithmetic averages).

## Standard Workflow (Nonlinear PDE)

A typical script using this paradigm follows this shape:

1. **Grid & Operators**: Create grid and build `C`, `grad`, and `div`.
2. **Setup Variables**: Use `initVariablesADI` to initialize your primary variable.
3. **Newton Loop**: 
   ```matlab
   tol = 1e-6;
   err = inf;
   while err > tol
       % 1. Evaluate nonlinear operators / properties on faces
       % 2. Form the discrete equation
       eq = div( ... ) + q;
       
       % 3. Check residual
       err = norm(eq.val, inf);
       if err < tol, break; end
       
       % 4. Update primary variables using the AD Jacobian
       p = p - eq.jac{1}\eq.val; 
   end
   ```

## Cross-References

- **Upstream**: `mrst-gridding`
- **Alternatives**: `mrst-ad-oo` (for full object-oriented simulations with wells, schedules, and complex fluid models).
