---
name: mrst-fractured-reservoirs
description: Model naturally fractured reservoirs in MRST using Discrete Fracture Models (DFM), Embedded Discrete Fracture Models (pEDFM/EDFM), and Non-Neighboring Connections (NNCs).
---

# MRST Fractured Reservoir Modeling Skill

This skill provides the knowledge and workflow for explicit fracture representation for reservoirs where matrix-fracture interaction dominates flow behavior, using advanced discretization techniques.

## Prerequisites

> Before using this skill, ensure you've consulted:
> - `mrst-gridding` — for grid generation and data import
> - `mrst-core-procedural` or `mrst-ad-oo` — for the simulation framework
## Core Paradigms

### 1. Discrete Fracture Model (DFM)
- Lower-dimensional explicit fracture interfaces embedded in the grid
- `dfm` module: fracture grid generation, hybrid cell types
- Transmissibility computation across matrix-fracture interfaces
- Applicable to explicitly meshed, conforming fracture networks

### 2. Embedded Discrete Fracture Model (pEDFM / EDFM)
- Fractures embedded in structured or PEBI matrix grids
- No mesh conformity required — fractures handled via Non-Neighboring Connections (NNCs)
- `shale` module for pEDFM-specific functionality
- Fracture aperture, permeability, and conductivity specification

### 3. Non-Neighboring Connections (NNCs)
- The general mechanism for connecting non-adjacent cells
- Used by pEDFM, faults, and multi-segment well models
- Transmissibility calculation for NNC pairs

## Agent Instructions: Initialization

Modules to load:
```matlab
run('database/MRST-main/startup.m');
% For DFM:
mrstModule add dfm incomp
% For pEDFM (add these instead/additionally):
mrstModule add shale ad-core ad-props
% For fracture grid generation:
mrstModule add upr coarsegrid
```

## Agent Instructions: Reference Documentation & Examples

Always consult the curated reference documentation and verified examples in this skill rather than guessing API parameters:

1. **Curated Reference Guide**:
   Read `skills/mrst-fractured-reservoirs/references/fractures_best_practices.md` (Fractures Best Practices) for exact function signatures, physics formulations, and gotchas.

2. **Executable Examples**:
   Refer to verified, runnable scripts in `skills/mrst-fractured-reservoirs/examples/` for canonical setups and workflows.
## Standard Workflows

### Workflow A: DFM with Explicit Fracture Grid

```matlab
% 1. Create a matrix grid and geometry
G = cartGrid([10 10], [100 100]);
G = computeGeometry(G);

% 2. Identify fracture faces and assign aperture
fracFaces = find(G.faces.centroids(:,1) == 50);
G.faces.tags = zeros(G.faces.num, 1);
G.faces.tags(fracFaces) = 1;
apt = zeros(G.faces.num, 1);
aperture = 0.001;
apt(fracFaces) = aperture;

% 3. Add hybrid cells
G = addhybrid(G, G.faces.tags > 0, apt);
G = computeGeometry(G);
rock = makeRock(G, 10*milli*darcy, 0.2);
hybridInd = find(G.cells.hybrid);
rock.perm(hybridInd, :) = aperture^2/12;
rock.poro(hybridInd) = 0.5;

% 4. Compute transmissibilities
T = computeTrans_DFM(G, rock, 'hybrid', true);
[G, T2] = computeHybridTrans(G, T);

% 5. Solve using DFM TPFA
% state = incompTPFA_DFM(state, G, T, fluid, 'wells', W, 'c2cTrans', T2);
```

### Workflow B: pEDFM with Embedded Fractures

```matlab
% 1. Create matrix grid
G = cartGrid([10 10 1], [100 100 10]);
G = computeGeometry(G);
G.rock = makeRock(G, 1*milli*darcy, 0.1);

% 2. Define fractures
fracplanes = struct('points', [], 'aperture', [], 'poro', [], 'perm', []);
fracplanes(1).points = [20, 20, 0; 80, 80, 0; 80, 80, 10; 20, 20, 10]; 
fracplanes(1).aperture = 1*milli*meter;
fracplanes(1).poro = 0.5;
fracplanes(1).perm = 100*darcy;

% 3. pEDFM PreProcessing (creates NNCs)
tol = 1e-5;
[G, fracplanes] = EDFMshalegrid(G, fracplanes, 'Tolerance', tol);
G = fracturematrixShaleNNC3D(G, tol);
[G, fracplanes] = fracturefractureShaleNNCs3D(G, fracplanes, tol);
G = pMatFracNNCs3D(G, tol); % The pEDFM specific projection-based NNCs

% 4. Set up pEDFM TPFA operators
TPFAoperators = setupPEDFMOpsTPFA(G, G.rock, tol);

% 5. Pass operators to AD-OO model
% model = TwoPhaseOilWaterModel(G, rock, fluid);
% model.operators = TPFAoperators;
```
## Cross-References

- **Orthogonal**: `mrst-linear-solvers` (for performance)
- **References**: [fractures_best_practices.md](file:///D:/MRST-skills/skills/mrst-fractured-reservoirs/references/fractures_best_practices.md) (NNCs and DPDP)
