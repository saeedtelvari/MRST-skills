---
name: mrst-core-procedural
description: Build incompressible and procedural simulation models using the core MRST modules.
---

# MRST Core Procedural Simulator Skill

This skill provides the knowledge and workflow for building traditional, procedural-style simulations in MRST. This covers standard gridding, property generation, incompressible solvers (TPFA/Mimetic), and explicit/implicit transport steps.

## Prerequisites

> Before using this skill, ensure you've consulted:
> - `mrst-gridding` — for grid generation and data import (if you don't already have a grid)

## Core Paradigms

Unlike the AD-OO paradigm which relies on large encompassing objects, the core procedural paradigm passes state structs explicitly through standalone solver functions. The primary building blocks are:
1. **Gridding & Geometry**: Building grid structures with `cartGrid`, `tensorGrid`, or `pebi`, and computing cell/face properties with `computeGeometry`.
2. **Procedural Solvers**: Computing pressure and fluxes using `incompTPFA` or `incompMimetic`, rather than a generic non-linear solver.
3. **Transport Solvers**: Updating phase saturations using procedural functions like `implicitTransport` or `explicitTransport`.

## Agent Instructions: Initialization

Whenever you write a MATLAB script for MRST Core Procedural workflows, you **MUST** include the following initialization sequence at the top of your script. This is required because relying on a wrapper script destroys MATLAB stack trace line numbers during debugging.

```matlab
% Initialize MRST Setup
run('database/MRST-main/startup.m');

% Add required modules for core procedural simulations
mrstModule add incomp
```
*(Add other modules like `mimetic` or `libgeometry` if the specific physics or grids require them).*

## Agent Instructions: Knowledge Retrieval

If you are unsure about the parameters of a core function, class, or the theoretical formulation, use the pre-built AI knowledge tools rather than guessing:

1. **Search the Textbooks and Source Code**:
   Run the following Python CLI to query the FTS5 knowledge base:
   ```bash
   python -m tools.mrst_index.search_index keyword "incompTPFA"
   ```
   *Available modes*: `keyword`, `lookup`, `explain`, `hybrid`.

2. **Navigate the Codebase Graph (GraphRAG)**:
   Use `graphify` to understand how modules interact:
   - `graphify query "What are the required inputs for implicitTransport?"`
   - `graphify path "incompTPFA.m" "implicitTransport.m"`
   - `graphify explain "Transmissibility"`

   If you need deep codebase navigation, you can also spawn the graphify subagent by invoking `skill: "graphify"`.

## Standard Core Procedural Workflow

A standard script using this paradigm usually follows this structural shape in a time-stepping loop:

1. **Geometry & Petrophysics**: Define `G`, `rock` (via `cartGrid`, `computeGeometry`, `makeRock`).
2. **Fluid & Initial State**:
   ```matlab
   fluid = initSimpleFluid('mu', [1, 10]*centi*poise, 'rho', [1000, 800]*kilogram/meter^3, 'n', [2, 2]);
   state = initResSol(G, 100*barsa, [1, 0]); % Pressure and saturation
   ```
3. **Wells**: Define wells using the structural `addWell` function.
4. **Solver & Time-stepping Execution**:
   ```matlab
   T = computeTrans(G, rock); % Compute transmissibilities once
   
   for t = 1:num_steps
       % 1. Solve pressure equation to get fluxes
       state = incompTPFA(state, G, T, fluid, 'wells', W);
       
       % 2. Solve transport equation to update saturations
       state = implicitTransport(state, G, dt, rock, fluid, 'wells', W);
   end
   ```
## References & Best Practices

- [Procedural Transport Best Practices: Explicit vs. Implicit](file:///D:/MRST-skills/skills/mrst-core-procedural/references/procedural_best_practices.md)

## Cross-References

- **Downstream**: `mrst-diagnostics`, `mrst-fractured-reservoirs`
