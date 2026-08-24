---
name: mrst
description: Route any MRST simulation request to the correct specialist skill(s). Invoke this FIRST for any reservoir simulation task to determine the right workflow, skill ordering, and module dependencies.
---

# MRST Skill Router

This is the **entry-point skill** for the MRST agentic ecosystem. It does not contain simulation instructions itself — instead, it routes you to the correct specialist skill(s) based on what the user wants, and tells you the order to invoke them.

**Always consult this skill first** when a user asks for anything related to MRST or reservoir simulation.

## Routing Table

Match the user's intent against the keywords below. Select the **Primary Skill** and also consult the **Prerequisites** in order.

| User Intent Keywords | Primary Skill | Prerequisites (invoke first, in order) |
|---------------------|--------------|----------------------------------------|
| grid, mesh, cartGrid, tensorGrid, PEBI, Voronoi, Eclipse deck, `.DATA` file, GRDECL, import, corner-point, near-wellbore, geometry | `mrst-gridding` | — |
| incompressible, TPFA, mimetic, two-phase waterflooding, sequential, procedural, `incompTPFA`, `implicitTransport`, `initSimpleFluid` | `mrst-core-procedural` | `mrst-gridding` |
| black-oil, AD, fully implicit, `simulateScheduleAD`, `NonLinearSolver`, `ThreePhaseBlackOilModel`, `GenericBlackOilModel`, three-phase, oil-water, oil-gas | `mrst-ad-oo` | `mrst-gridding` |
| compositional, EOS, Peng-Robinson, gas condensate, volatile oil, `CompositionalMixture`, `NaturalVariablesCompositionalModel`, `OverallCompositionCompositionalModel`, flash calculation, multi-component | `mrst-ad-oo` (compositional section) | `mrst-gridding` |
| fractured reservoir, DFM, EDFM, pEDFM, naturally fractured, fracture network, NNC, non-neighboring connections, fracture aperture | `mrst-fractured-reservoirs` | `mrst-gridding` |
| flow diagnostics, time-of-flight, TOF, tracer, sweep efficiency, Lorenz coefficient, F-Phi curve, well pairs, reservoir characterization | `mrst-diagnostics` | `mrst-gridding`, `mrst-core-procedural` |
| upscaling, coarse grid, permeability upscaling, multiscale, MsRSB, `incompMultiscale`, basis functions | `mrst-diagnostics` | `mrst-gridding`, `mrst-core-procedural` |
| optimize, NPV, adjoint, sensitivity, gradient, well control optimization, well placement, production optimization, `unitBoxBFGS`, `computeGradientAD` | `mrst-optimization` | `mrst-gridding`, `mrst-ad-oo` |
| CO2, carbon capture, CCS, sequestration, saline aquifer, vertical equilibrium, VE, `co2lab`, `topSurfaceGrid`, trap analysis, spill point, plume migration | `mrst-co2-storage` | `mrst-gridding`, `mrst-ad-oo` |
| hydrogen, H2, underground hydrogen storage, UHS, cushion gas, cyclic injection, withdrawal, methanation, `h2store`, `h2-biochem`, hysteresis | `mrst-hydrogen-storage` | `mrst-gridding`, `mrst-ad-oo` |
| geothermal, heat transport, thermal, temperature, `GeothermalModel`, thermal breakthrough, doublet, heat extraction, thermo-hydro | `mrst-geothermal` | `mrst-gridding`, `mrst-ad-oo` |
| linear solver, preconditioner, CPR, AMG, AGMG, AMGCL, GMRES, ILU0, iterative solver, slow simulation, large model, performance, `LinearSolverAD` | `mrst-linear-solvers` | `mrst-ad-oo` |
| geomechanics, stress, strain, compaction, subsidence, poroelasticity, Biot, caprock integrity, VEM, `ad-mechanics`, `vemmech`, fracture reactivation | `mrst-geomechanics` | `mrst-gridding`, `mrst-ad-oo` |
| **DEVELOPER**: custom PDE, raw AD, script-based AD, `initVariablesADI`, manual grad/div operators, fast prototype, Newton loop | `mrst-ad-scripting` | `mrst-gridding` |
| **DEVELOPER**: custom physics, `PhysicalModel`, `StateFunction`, non-Newtonian, complex custom properties hooked into AD-OO | `mrst-custom-physics` | `mrst-ad-oo` |
| polymer, surfactant, EOR, enhanced oil recovery, `OilWaterPolymerModel`, `OilWaterSurfactantModel`, Todd-Longstaff, chemical flooding, `ad-eor` | `mrst-eor` | `mrst-gridding`, `mrst-ad-oo` |
| **DEBUGGING**: error, crash, divergence, Newton failure, unmet dependency, dimension mismatch, bug, slow simulation, fix | `mrst-debugging` | `mrst-gridding`, `mrst-ad-oo` |
| **VISUALIZATION**: plot, 3D, slice, well curves, production data, BHP, interactive, `plotGrid`, `plotCellData`, `plotToolbar`, `plotWellSols`, gui | `mrst-visualization` | `mrst-gridding` |

## Dependency DAG

```
mrst-gridding (root — every simulation starts here)
├── mrst-ad-scripting (Developer: fast ad-hoc prototyping)
├── mrst-core-procedural
│   ├── mrst-diagnostics (TOF, upscaling, multiscale)
│   └── mrst-fractured-reservoirs (DFM, pEDFM)
├── mrst-ad-oo (Black-Oil + Compositional)
│   ├── mrst-co2-storage
│   ├── mrst-hydrogen-storage
│   ├── mrst-geothermal
│   ├── mrst-optimization
│   ├── mrst-geomechanics
│   ├── mrst-eor (Polymer, Surfactant — uses ad-eor module)
│   ├── mrst-custom-physics (Developer: OO custom properties)
│   └── mrst-linear-solvers (accelerates any AD simulation)
├── mrst-fractured-reservoirs (can also use AD)
├── mrst-visualization (can be used on results from any simulation)
└── mrst-debugging (applies ruthlessly tight feedback loops to any failure)
```

## Common Multi-Skill Recipes

Use these when the user's request spans multiple paradigms.

### Recipe 1: "Import an Eclipse deck and run a simulation"
```
1. mrst-gridding      → readEclipseDeck, initEclipseGrid
2. mrst-ad-oo         → initEclipseProblemAD, simulateScheduleAD
```

### Recipe 2: "CO2 storage with injection rate optimization"
```
1. mrst-gridding      → build or import grid
2. mrst-co2-storage   → set up VE model, CO2VEBlackOilTypeModel
3. mrst-optimization  → define NPV objective, run adjoint optimization
```

### Recipe 3: "Large fractured reservoir (fast)"
```
1. mrst-gridding      → PEBI grid with fracture conformity
2. mrst-fractured-reservoirs → DFM or pEDFM fracture model
3. mrst-linear-solvers → CPR preconditioner for performance
```

### Recipe 4: "Reservoir characterization before full simulation"
```
1. mrst-gridding      → build grid
2. mrst-core-procedural → solve incompressible pressure
3. mrst-diagnostics   → compute TOF, sweep efficiency, Lorenz coefficient
```

### Recipe 5: "Geothermal doublet with stress analysis"
```
1. mrst-gridding      → build grid
2. mrst-geothermal    → GeothermalModel, thermal properties
3. mrst-geomechanics  → coupled thermal stress (if needed)
4. mrst-linear-solvers → CPR for large 3D models
```

### Recipe 6: "Hydrogen storage with seasonal cycling"
```
1. mrst-gridding      → build grid
2. mrst-hydrogen-storage → CompositionalMixture, hysteresis, biochemistry
3. mrst-linear-solvers → performance for compositional models
```

### Recipe 7: "Optimize waterflood with adjoint gradients"
```
1. mrst-gridding      → build grid
2. mrst-ad-oo         → GenericBlackOilModel, simulateScheduleAD
3. mrst-optimization  → NPVOW, computeGradientAD, unitBoxBFGS
```

### Recipe 8: "Upscale a fine model for faster simulation"
```
1. mrst-gridding      → fine grid + heterogeneous rock
2. mrst-diagnostics   → upscalePerm, generate coarse grid
3. mrst-ad-oo         → run simulation on coarse model
```

## Ambiguity Resolution

When the user's intent is ambiguous, use these rules:

| Ambiguous Prompt | Resolution |
|-----------------|------------|
| "Simulate CO2 injection" (no mention of VE) | Ask: "Do you want the Vertical Equilibrium (VE) approach from `co2lab` (fast, 2D) or a full 3D compositional model?" If VE → `mrst-co2-storage`. If 3D → `mrst-ad-oo` compositional section. |
| "Speed up my simulation" | If the simulation uses AD/OO → `mrst-linear-solvers`. If incompressible → `mrst-diagnostics` (multiscale MsRSB). |
| "Model fractures" | If explicit fracture geometry → `mrst-fractured-reservoirs`. If stress-dependent fracture aperture → also consult `mrst-geomechanics`. |
| "Set up a simulation" (too vague) | Ask what physics: incompressible → `mrst-core-procedural`, compressible/multiphase → `mrst-ad-oo`. |
| "Compositional simulation" | If general (gas condensate, volatile oil, miscible flooding) → `mrst-ad-oo` compositional section. If specifically hydrogen → `mrst-hydrogen-storage`. |

## Agent Instructions: Knowledge Retrieval

All specialist skills share these knowledge tools. Use them when you need API details:

1. **FTS5 Knowledge Base** (textbooks + source code):
   ```bash
   python -m tools.mrst_index.search_index keyword "<term>"
   ```
   Modes: `keyword`, `lookup`, `explain`, `hybrid`.

2. **Codebase Graph (GraphRAG)**:
   ```
   graphify query "<question>"
   graphify path "<source>" "<target>"
   graphify explain "<concept>"
   ```

## Agent Instructions: Initialization

Every MRST script must begin with:
```matlab
run('database/MRST-main/startup.m');
mrstModule add <modules for the specific skill>
```
Each specialist skill lists its required modules. Never skip `startup.m`.
