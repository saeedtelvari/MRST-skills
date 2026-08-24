Type: task
Status: resolved
Blocked by: 7

## Question

Create the new `mrst-diagnostics` skill covering flow diagnostics (TOF, tracers, sweep efficiency), upscaling, and multiscale methods (MsRSB) — the reservoir characterization and model-reduction paradigm.

**Labels**: `wayfinder:task`

## Specification

### Rationale

Flow diagnostics is a fundamentally different workflow from forward simulation or optimization. It's about *understanding* a reservoir's flow structure quickly using proxy computations (time-of-flight, tracer partitioning) without running full multiphase simulations. Upscaling and multiscale methods are conceptually related: they reduce model complexity while preserving flow characteristics.

This ticket is blocked by ticket-7 (rename advanced-solvers to fractured-reservoirs) because the multiscale content (MsRSB, `incompMultiscale`) needs to be extracted from `mrst-advanced-solvers` and placed here.

### Deliverables

1. `skills/mrst-diagnostics/SKILL.md` — The monolithic skill instruction file.
2. `skills/mrst-diagnostics/examples/flow_diagnostics_tof.m` — TOF and tracer computation.
3. `skills/mrst-diagnostics/examples/upscaling_workflow.m` — Permeability upscaling.
4. `skills/mrst-diagnostics/examples/multiscale_msrsb.m` — MsRSB multiscale solver (moved from mrst-advanced-solvers).

### SKILL.md Structure

```
---
name: mrst-diagnostics
description: Reservoir characterization and model reduction in MRST — flow diagnostics (TOF, tracers, sweep efficiency, Lorenz coefficient), upscaling, and multiscale methods (MsRSB).
---

# MRST Flow Diagnostics, Upscaling & Multiscale Skill

<intro: proxy-based reservoir characterization and model reduction without 
full multiphase simulation>

## Prerequisites

- Grid and basic flow setup: consult `mrst-gridding` and `mrst-core-procedural`
- Flow diagnostics require a solved incompressible flow field as input

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
- `upscalePermeability` — Compute effective permeability on coarse blocks
- `upscaleTransmissibility` — Compute coarse-scale transmissibilities
- Validation: compare fine-scale vs upscaled solution

### 3. Multiscale Methods (MsRSB / MsFVM)
- Domain coarsening: `partitionUI`, `generateCoarseGrid`
- Global matrix assembly: `computeTrans`, `getIncomp1PhMatrix`
- Basis function computation: `getMultiscaleBasis(CG, A, 'type', 'msrsb')`
- Multiscale solver: `incompMultiscale`
- When to use: large heterogeneous models where direct solvers are too slow
  but full AD is not needed

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

## Agent Instructions: Knowledge Retrieval

<standard FTS5 + graphify pattern>

## Standard Workflows

### Workflow A: Flow Diagnostics
1. Set up grid, rock, fluid (incompressible)
2. Solve pressure: `state = incompTPFA(state, G, T, fluid, 'wells', W)`
3. Compute diagnostics: `D = computeTOFandTracer(state, G, rock, 'wells', W)`
4. Compute sweep: `[Ev, tD] = computeSweep(pv, D.tof)`
5. Plot F-Phi: `[F, Phi] = computeFandPhi(pv, D.tof)`
6. Lorenz coefficient: `Lc = computeLorenz(F, Phi)`

### Workflow B: Permeability Upscaling
1. Build fine grid and heterogeneous rock
2. Partition into coarse blocks
3. `rock_coarse = upscalePermeability(G_coarse, G_fine, rock_fine)`
4. Solve on both scales, compare

### Workflow C: Multiscale MsRSB
1. Build fine grid, compute transmissibility
2. Partition: `p = partitionUI(G, coarseDims); CG = generateCoarseGrid(G, p)`
3. Assemble: `A = getIncomp1PhMatrix(G, T)`
4. Basis: `basis = getMultiscaleBasis(CG, A, 'type', 'msrsb')`
5. Solve: `state = incompMultiscale(state, CG, T, fluid, basis, 'wells', W)`

## Cross-References
- **Input from**: `mrst-core-procedural` (incompressible flow solution)
- **Grid tools from**: `mrst-gridding` (partitioning, coarsening)
- **Not the same as**: `mrst-linear-solvers` (which accelerates AD solves, not incompressible)
```

### Research Guidance

```
python -m tools.mrst_index.search_index keyword "computeTOFandTracer"
python -m tools.mrst_index.search_index keyword "computeWellPairs"
python -m tools.mrst_index.search_index keyword "computeSweep"
python -m tools.mrst_index.search_index keyword "upscalePermeability"
python -m tools.mrst_index.search_index keyword "incompMultiscale"
python -m tools.mrst_index.search_index keyword "getMultiscaleBasis"
graphify query "How do flow diagnostics work in MRST?"
graphify explain "computeTOFandTracer"
```

## Answer

Created the `mrst-diagnostics` skill.
- Added `SKILL.md` detailing flow diagnostics, upscaling, and multiscale methodologies.
- Created `examples/flow_diagnostics_tof.m` with TOF/tracer implementations and F-Phi curve computations.
- Created `examples/upscaling_workflow.m` showing flow-based permeability upscaling (`upscalePerm`).
- Created `examples/multiscale_msrsb.m` demonstrating MsRSB solver with basis generation and evaluation against the full fine-scale TPFA model.
