---
name: mrst-geomechanics
description: Coupled flow-mechanics (poroelastic) simulation in MRST — stress, strain, compaction, subsidence, and caprock integrity using ad-mechanics and vemmech.
---

# MRST Geomechanics & Poroelasticity Skill

When reservoir pressure changes, it affects rock deformation (compaction/expansion), and rock deformation affects fluid flow (pore volume and permeability changes). This two-way coupled problem is critical for predicting subsidence, caprock integrity, and stress-dependent behavior in fractured reservoirs. MRST handles this through the `ad-mechanics`, `vemmech`, and `fvbiot` modules.

## Prerequisites

> Before using this skill, ensure you've consulted:
> - `mrst-gridding` — for grid generation and data import
> - `mrst-ad-oo` — for the AD-OO simulation framework
## Core Paradigms

### 1. Virtual Element Method for Mechanics (vemmech)
- `VEM_linElast` — linear elasticity solver on irregular grids
- Virtual Element Method (VEM): works on general polyhedral cells, providing flexibility compared to standard finite elements.
- Input: Young's modulus, Poisson's ratio, boundary conditions.
- Output: displacement field (`uu`), which can be used to derive stress and strain tensors.

### 2. Coupled Flow-Mechanics (ad-mechanics)
- `MechFluidModel` / `MechWaterModel` / `MechBlackOilModel` — fully coupled model classes.
- Alternative coupling: `MechFluidFixedStressSplitModel` for sequential fixed-stress split (often more stable and computationally efficient for large cases).
- Key parameters: Biot's coefficient (`alpha`), permeability, porosity, Young's modulus (`E`), Poisson's ratio (`nu`), and fluid bulk modulus (`Kf`).
- Boundary conditions (for mechanics):
  - Fixed displacement (e.g., roller or locked).
  - Traction (forces applied to boundary faces).
  - Defined in the `el_bc` structure.

### 3. Applications
- **Terzaghi consolidation**: 1D benchmark for code verification.
- **Mandel's problem**: 2D benchmark with Biot coupling and anomalous pressure rise (Mandel-Cryer effect).
- **Reservoir compaction**: Subsidence from pressure depletion.
- **Caprock integrity**: Stress state assessment during injection (CO2, H2).

## Agent Instructions: Initialization

Modules to load in any geomechanics script:
```matlab
% Initialize MRST
run('database/MRST-main/startup.m');

% Load geomechanics and flow modules
mrstModule add ad-mechanics vemmech ad-core ad-props ad-blackoil
```

For the finite-volume Biot discretization (alternative to VEM):
```matlab
mrstModule add fvbiot
```

## Agent Instructions: Knowledge Retrieval

1. **Search the Textbooks and Source Code**:
   Run the following Python CLI to query the FTS5 knowledge base:
   ```bash
   python -m tools.mrst_index.search_index keyword "MechFluidModel"
   python -m tools.mrst_index.search_index keyword "VEM_linElast"
   ```
2. **Navigate the Codebase Graph (GraphRAG)**:
   Use `graphify` to understand module interactions:
   - `graphify query "How does coupled flow-mechanics work in MRST?"`
   - `graphify path "MechWaterModel" "simulateScheduleAD"`

For deep coverage, refer to Chapter 14 of "Advanced Modeling with the MATLAB Reservoir Simulation Toolbox".

## Standard Workflows

### Workflow A: Pure Mechanics (Linear Elasticity)

```matlab
% 1. Build grid
G = cartGrid([10, 10, 10], [10, 10, 10]);
G = computeGeometry(G);
G = createAugmentedGrid(G); % Required for VEM

% 2. Define mechanical properties (E, ν)
Nc = G.cells.num;
E = 5 * giga * Pascal;
nu = 0.3;
C = Enu2C(E * ones(Nc, 1), nu * ones(Nc, 1), G);

% 3. Set boundary conditions (e.g., locked bottom)
bottom_nodes = find(G.nodes.coords(:,3) == max(G.nodes.coords(:,3)));
el_bc.disp_bc.nodes = bottom_nodes;
el_bc.disp_bc.uu = zeros(numel(bottom_nodes), 3);
el_bc.disp_bc.mask = true(numel(bottom_nodes), 3); % locked in x,y,z
el_bc.force_bc = [];

% 4. Load (gravity)
density = 2500;
load_fn = @(x) repmat(density * gravity(), size(x, 1), 1);

% 5. Solve
uu = VEM_linElast(G, C, el_bc, load_fn);
```

### Workflow B: Coupled Flow-Mechanics (Fixed-Stress Split)

```matlab
% 1. Build Grid
G = createAugmentedGrid(computeGeometry(cartGrid([10, 1, 10], [100, 10, 100])));
Nc = G.cells.num;

% 2. Define rock properties with mechanics
rock = struct('perm', 100*milli*darcy*ones(Nc,1), 'poro', 0.25*ones(Nc,1), 'alpha', 0.9*ones(Nc,1));
E = 5 * giga * Pascal;
nu = 0.3;

% 3. Define fluid (slightly compressible)
fluid = initSimpleADIFluid('phases', 'W', 'mu', 1*centi*poise, 'rho', 1000, 'c', 1e-9);

% 4. Set Mechanical boundary conditions
el_bc.disp_bc.nodes = find(G.nodes.coords(:,3) == max(G.nodes.coords(:,3))); % Bottom
el_bc.disp_bc.uu = zeros(numel(el_bc.disp_bc.nodes), 3);
el_bc.disp_bc.mask = true(numel(el_bc.disp_bc.nodes), 3);
load_fn = @(x) zeros(size(x,1), 3); % no gravity
mech_problem = struct('E', E*ones(Nc,1), 'nu', nu*ones(Nc,1), 'el_bc', el_bc, 'load', load_fn);

% 5. Create coupled model
model = MechFluidFixedStressSplitModel(G, rock, fluid, mech_problem);

% 6. Initial state
num_mech = sum(~model.mechModel.operators.isdirdofs);
initState = struct('pressure', 100*barsa*ones(Nc,1), 'xd', zeros(num_mech,1));
initState = addDerivedQuantities(model.mechModel, initState);

% 7. Set up schedule and simulate
W = addWell([], G, rock, 1, 'Type', 'bhp', 'Val', 50*barsa, 'comp_i', 1);
schedule = simpleSchedule(repmat(30*day, 10, 1), 'W', W);
[wellSols, states] = simulateScheduleAD(initState, model, schedule);
```
## Cross-References

- **Related**: `mrst-co2-storage`, `mrst-geothermal`, `mrst-fractured-reservoirs`
- **Best Practices**: [geomechanics_best_practices.md](file:///D:/MRST-skills/skills/mrst-geomechanics/references/geomechanics_best_practices.md)
