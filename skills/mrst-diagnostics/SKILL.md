---
name: mrst-diagnostics
description: Reservoir characterization and model reduction in MRST — flow diagnostics (TOF, tracers, sweep efficiency, Lorenz coefficient), upscaling, and multiscale methods (MsRSB).
---

# MRST Flow Diagnostics, Upscaling & Multiscale Skill

Flow diagnostics, upscaling, and multiscale methods represent a proxy-based reservoir characterization and model reduction paradigm. These workflows allow for the rapid evaluation of a reservoir's flow structure and the reduction of model complexity without the need for full multiphase simulations.

## Prerequisites

> Before using this skill, ensure you've consulted:
> - `mrst-gridding` — for grid generation and data import
> - `mrst-core-procedural` — for incompressible flow setup
>
> Flow diagnostics require a solved incompressible flow field as input (usually from `incompTPFA`).

## Core Paradigms

### 1. Flow Diagnostics
- `computeTOFandTracer` — Time-of-flight and tracer partitioning
  - Forward TOF: time from injector to cell
  - Backward TOF: time from cell to producer
  - Tracer partition: which injector/producer controls each cell
- `computeWellPairs` — Injector-producer connectivity analysis
- `computeSweep` — Sweep efficiency vs PVI
- `computeLorenz` — Lorenz coefficient (heterogeneity measure)
- `computeFandPhi` — Flow-capacity vs storage-capacity (F-Φ) diagrams
- `plotTracerBlend` — Visualization of tracer partitions

### 2. Upscaling
- `upscalePerm` — Compute effective permeability on coarse blocks using flow-based upscaling
- `upscaleTrans` — Compute coarse-scale transmissibilities
- Validation: compare fine-scale vs upscaled solution

### 3. Multiscale Methods (MsRSB)
- Domain coarsening: `partitionUI`, `generateCoarseGrid`
- Global matrix assembly: `computeTrans`, `getIncomp1PhMatrix`
- Basis function computation: `getMultiscaleBasis(CG, A, 'type', 'msrsb')`
- Multiscale solver: `incompMultiscale`
- When to use: large heterogeneous models where direct solvers are too slow but full AD is not needed

## Agent Instructions: Initialization

Modules to load:
```matlab
run('database/MRST-main/startup.m');
% For flow diagnostics:
mrstModule add diagnostics incomp
% For upscaling:
mrstModule add upscaling coarsegrid incomp
% For multiscale:
mrstModule add msrsb coarsegrid incomp
```

## Agent Instructions: Reference Documentation & Examples

Always consult the curated reference documentation and verified examples in this skill rather than guessing API parameters:

1. **Curated Reference Guide**:
   Read `skills/mrst-diagnostics/references/diagnostics_best_practices.md` (Diagnostics Best Practices) for exact function signatures, physics formulations, and gotchas.

2. **Executable Examples**:
   Refer to verified, runnable scripts in `skills/mrst-diagnostics/examples/` for canonical setups and workflows.
## Standard Workflows

### Workflow A: Flow Diagnostics
1. Set up grid, rock, fluid (incompressible)
2. Solve pressure: `state = incompTPFA(state, G, T, fluid, 'wells', W)`
3. Compute diagnostics: `D = computeTOFandTracer(state, G, rock, 'wells', W)`
4. Compute sweep: `[Ev, tD] = computeSweep(F, Phi)` (Wait, `[F, Phi] = computeFandPhi(pv, D.tof)`)
5. Plot F-Phi: `[F, Phi] = computeFandPhi(pv, D.tof)`
6. Lorenz coefficient: `Lc = computeLorenz(F, Phi)`

### Workflow B: Permeability Upscaling
1. Build fine grid and heterogeneous rock
2. Partition into coarse blocks
3. `rock_coarse.perm = upscalePerm(G_fine, G_coarse, rock_fine)`
4. Solve on both scales, compare

### Workflow C: Multiscale MsRSB
1. Build fine grid, compute transmissibility
2. Partition: `p = partitionUI(G, coarseDims); CG = generateCoarseGrid(G, p)`
3. Assemble: `A = getIncomp1PhMatrix(G, T)` (or `A = getIncomp1PhMatrix(G, T, state, fluid)`)
4. Basis: `basis = getMultiscaleBasis(CG, A, 'type', 'msrsb')`
5. Solve: `state = incompMultiscale(state, CG, T, fluid, basis, 'wells', W)`
## Cross-References

- **Downstream**: Informs optimization decisions (`mrst-optimization`)
- **References**:
  - [Diagnostics Best Practices: Flow Diagnostics, Upscaling & Multiscale](references/diagnostics_best_practices.md)
