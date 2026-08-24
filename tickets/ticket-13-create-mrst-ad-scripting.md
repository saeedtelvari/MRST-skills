Type: task
Status: resolved
Blocked by:

## Question

Create the `mrst-ad-scripting` skill to teach agents how to use raw `ADI` variables (`initVariablesADI`) and manual Newton loops for rapid prototyping of custom PDEs without object-oriented overhead.

**Labels**: `wayfinder:task`

## Specification

### Deliverables

1. `skills/mrst-ad-scripting/SKILL.md`
   - **Core Paradigms**: Explain `initVariablesADI`, constructing discrete differential operators (grad, div) using `G.faces.neighbors` and connection matrices, upwinding, and the manual Newton-Raphson `while` loop.
   - **Agent Instructions**: Emphasize this is for standalone fast prototyping, not for hooking into schedule/facility models.
2. `skills/mrst-ad-scripting/examples/raw_ad_nonlinear_pde.m`
   - A complete script demonstrating grid setup, defining discrete operators `grad` and `div`, initializing `p = initVariablesADI(p0)`, writing a nonlinear equation (e.g., pressure-dependent transmissibility or simple multiphase), and the `eq.val` / `eq.jac` solution loop.

### Rationale
Provides a lightweight, highly readable alternative for custom physics when the full `PhysicalModel` hierarchy is unnecessary.

## Answer

Created the `mrst-ad-scripting` skill which outlines the fundamental usage of `initVariablesADI` and custom loop abstractions.

Deliverables:
- `skills/mrst-ad-scripting/SKILL.md` outlines the paradigm and how to create the differential operators manually.
- `skills/mrst-ad-scripting/examples/raw_ad_nonlinear_pde.m` provides an executable example of solving `div((1+p^2)grad(p))=q` using a purely manual setup and Newton iteration via ADI Jacobians.
