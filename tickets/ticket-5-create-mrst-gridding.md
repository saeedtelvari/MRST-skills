Type: task
Status: resolved
Blocked by:

## Question

Create the new `mrst-gridding` skill covering grid generation, Eclipse data import, and geometry computation — the universal upstream step every MRST simulation depends on.

**Labels**: `wayfinder:task`

## Specification

### Deliverables

1. `skills/mrst-gridding/SKILL.md` — The monolithic skill instruction file.
2. `skills/mrst-gridding/examples/basic_cartesian_grid.m` — Minimal cartesian grid example.
3. `skills/mrst-gridding/examples/import_eclipse_deck.m` — Eclipse `.DATA` deck import workflow.
4. `skills/mrst-gridding/examples/pebi_grid_with_faults.m` — PEBI/Voronoi grid conforming to faults and wells.

### SKILL.md Structure

Follow the exact pattern established in `skills/mrst-ad-oo/SKILL.md`:

```
---
name: mrst-gridding
description: Build grids and import industry data files for MRST simulations — cartesian, corner-point, PEBI/Voronoi, Eclipse deck import, and geometry computation.
---

# MRST Grid Generation & Data Import Skill

<introductory paragraph>

## Core Paradigms

Cover these 4 sub-paradigms:

### 1. Structured Grids (Cartesian / Tensor)
- `cartGrid`, `tensorGrid`, logarithmic/graded spacing
- `computeGeometry` — cell volumes, centroids, face normals, areas

### 2. Corner-Point / Industry Grids
- `processGRDECL` — parsing GRDECL geometry
- `initEclipseGrid` — building MRST grid from Eclipse grid keywords
- Handling faults, inactive cells, pinchout, NNCs
- `readEclipseDeck`, `convertDeckUnits` — full deck import
- `initEclipseProblemAD` — one-call setup of model+schedule+state from deck

### 3. Unstructured / PEBI / Voronoi Grids
- `upr` module: `pebiGrid`, `compositePebiGrid`
- Constraint alignment to faults, fractures, well paths
- `nwm` module: near-wellbore radial refinement
- `triangleGrid`, `voronoiGrid`

### 4. Grid Manipulation & Coarsening
- `partitionUI`, `partitionMetis` — domain partitioning
- `generateCoarseGrid`, `coarsenGeometry` — coarse grid generation
- `topSurfaceGrid` — 2D VE grid extraction (cross-ref to mrst-co2-storage)

## Agent Instructions: Initialization

<standard startup + mrstModule add pattern>

Modules to load:
- Always: (core is loaded by startup)
- Structured grids: no extra module needed
- Eclipse import: `deckformat` (and `ad-core ad-blackoil ad-props` if using `initEclipseProblemAD`)
- PEBI/Voronoi: `upr`
- Near-wellbore: `nwm`
- Coarsening: `coarsegrid`
- Geometry acceleration: `libgeometry` (optional, MEX-compiled)

## Agent Instructions: Knowledge Retrieval

<standard FTS5 + graphify query pattern>

## Standard Workflows

### Workflow A: Cartesian Grid (simplest)
<code template>

### Workflow B: Eclipse Deck Import
<code template using readEclipseDeck → convertDeckUnits → initEclipseGrid → computeGeometry>

### Workflow C: PEBI Grid with Fault Conformity
<code template using pebiGrid or compositePebiGrid with constraints>

## Cross-References
- This skill is **upstream of all other skills**. Once you have a grid `G` and `rock`, hand off to:
  - `mrst-core-procedural` for incompressible flow
  - `mrst-ad-oo` for AD-OO simulations
  - `mrst-fractured-reservoirs` for fracture modeling
```

### Example Scripts

Each example must begin with the standard initialization:
```matlab
run('database/MRST-main/startup.m');
mrstModule add <relevant modules>
```

**basic_cartesian_grid.m**: Create a 10×10×10 cartesian grid, assign homogeneous rock, compute geometry, plot.

**import_eclipse_deck.m**: Read SPE1 or SPE9 `.DATA` file using `readEclipseDeck`, `convertDeckUnits`, build grid with `initEclipseGrid`, compute geometry, extract rock and fluid, plot.

**pebi_grid_with_faults.m**: Use `upr` module to create a 2D PEBI grid with a fault line constraint and a well point constraint, compute geometry, plot.

### Research Guidance

Use these queries to gather API details during implementation:
```
python -m tools.mrst_index.search_index keyword "readEclipseDeck"
python -m tools.mrst_index.search_index keyword "pebiGrid"
python -m tools.mrst_index.search_index keyword "processGRDECL"
python -m tools.mrst_index.search_index keyword "initEclipseProblemAD"
graphify query "How does readEclipseDeck connect to initEclipseGrid?"
graphify explain "computeGeometry"
```

Also reference `gridding_info.txt` in the repo root for pre-gathered notes (note: UTF-16LE encoding, read with `Get-Content -Encoding UTF8` or `[System.IO.File]::ReadAllText()`).

## Answer
The `mrst-gridding` skill has been created successfully. 

The following deliverables were completed:
1. Created `skills/mrst-gridding/SKILL.md` covering the specified grid paradigms, required module initializations, retrieval instructions, and structural workflows.
2. Created `skills/mrst-gridding/examples/basic_cartesian_grid.m` defining a standard 10x10x10 Cartesian grid with rock properties and basic plotting.
3. Created `skills/mrst-gridding/examples/import_eclipse_deck.m` showing the workflow to import SPE9 data using `readEclipseDeck`, convert units, initialize the grid, and extract rock and ADI fluid properties.
4. Created `skills/mrst-gridding/examples/pebi_grid_with_faults.m` utilizing `pebiGrid2D` from the `upr` module to constrain the grid to fault lines and well points.
