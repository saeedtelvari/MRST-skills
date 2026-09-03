---
name: mrst-gridding
description: Build grids and import industry data files for MRST simulations — cartesian, corner-point, PEBI/Voronoi, Eclipse deck import, and geometry computation.
---

# MRST Grid Generation & Data Import Skill

This skill provides the knowledge and workflow for generating grids, importing industry-standard Eclipse decks, and computing essential geometrical properties in MRST. Gridding and geometry computation form the universal upstream step upon which all MRST simulations depend.

## Prerequisites

> None (root skill)

## Core Paradigms

Cover these 4 sub-paradigms:

### 1. Structured Grids (Cartesian / Tensor)
- `cartGrid`, `tensorGrid`, logarithmic/graded spacing
- `computeGeometry` — computes cell volumes, centroids, face normals, and areas required by discretization schemes.

### 2. Corner-Point / Industry Grids
- `processGRDECL` — parsing GRDECL geometry
- `initEclipseGrid` — building MRST grid from Eclipse grid keywords
- Handling faults, inactive cells, pinchout, NNCs
- `readEclipseDeck`, `convertDeckUnits` — full deck import from `.DATA` files
- `initEclipseProblemAD` — one-call setup of model, schedule, and state from an imported deck.

### 3. Unstructured / PEBI / Voronoi Grids
- `upr` module: `pebiGrid2D`, `compositePebiGrid2D`
- Constraint alignment to faults, fractures, and well paths via `cellConstraints` or `faceConstraints`
- `nwm` module: near-wellbore radial refinement
- `triangleGrid`, `voronoiGrid`

### 4. Grid Manipulation & Coarsening
- `partitionUI`, `partitionMetis` — domain partitioning
- `generateCoarseGrid`, `coarsenGeometry` — coarse grid generation
- `topSurfaceGrid` — 2D VE grid extraction (cross-ref to mrst-co2-storage)

## Agent Instructions: Initialization

Whenever you write a MATLAB script for MRST gridding or deck import, you **MUST** include the following initialization sequence at the top of your script.

```matlab
% Initialize MRST Setup
run('database/MRST-main/startup.m');

% Add required modules
mrstModule add deckformat ad-core ad-blackoil ad-props upr
```

Modules to load:
- Always: (core is loaded by startup)
- Structured grids: no extra module needed
- Eclipse import: `deckformat` (and `ad-core ad-blackoil ad-props` if using `initEclipseProblemAD` or `initDeckADIFluid`)
- PEBI/Voronoi: `upr`
- Near-wellbore: `nwm`
- Coarsening: `coarsegrid`
- Geometry acceleration: `libgeometry` (optional, MEX-compiled)

## Agent Instructions: Reference Documentation & Examples

Always consult the curated reference documentation and verified examples in this skill rather than guessing API parameters:

1. **Curated Reference Guide**:
   Read `skills/mrst-gridding/references/gridding_best_practices.md` (Gridding Best Practices) for exact function signatures, physics formulations, and gotchas.

2. **Executable Examples**:
   Refer to verified, runnable scripts in `skills/mrst-gridding/examples/` for canonical setups and workflows.
## Standard Workflows

### Workflow A: Cartesian Grid (simplest)
```matlab
% Create a 10x10x10 Cartesian grid
G = cartGrid([10, 10, 10], [100, 100, 100]);
G = computeGeometry(G);

% Assign homogeneous rock
rock = makeRock(G, 100*milli*darcy, 0.2);
```

### Workflow B: Eclipse Deck Import
```matlab
% Load modules
mrstModule add deckformat ad-core ad-props

% Read deck and convert units
deck = readEclipseDeck('MODEL.DATA');
deck = convertDeckUnits(deck);

% Build grid and compute geometry
G = initEclipseGrid(deck);
G = computeGeometry(G);

% Extract rock and fluid properties
rock  = initEclipseRock(deck);
fluid = initDeckADIFluid(deck);
```

### Workflow C: PEBI Grid with Fault Conformity
```matlab
% Load upr module
mrstModule add upr

% Define physical domain and resolution
pdims = [1000, 1000];
resGridSize = 100;

% Define structural constraints (faults, wells)
constraints = struct('fault', [200, 200; 800, 800], 'well', [500, 200]);

% Generate 2D PEBI grid
G = pebiGrid2D(resGridSize, pdims, 'cellConstraints', constraints);
G = computeGeometry(G);
```
## References

- [Gridding Best Practices](references/gridding_best_practices.md): Core structural invariants, geometry lifecycle constraints, unstructured topology rules, and MRST SI unit conversions.

## Cross-References

- **Downstream**: All other skills depend on this for grids
