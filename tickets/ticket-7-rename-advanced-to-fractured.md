Type: task
Status: resolved
Blocked by:


## Question

Rename `mrst-advanced-solvers` to `mrst-fractured-reservoirs`, refocus the SKILL.md purely on fracture modeling (DFM, pEDFM, EDFM, NNCs), and extract multiscale methods (MsRSB) to `mrst-diagnostics` (ticket-9).

**Labels**: `wayfinder:task`

## Specification

### Rationale

The current name "advanced solvers" creates two problems:
1. **Routing ambiguity**: An agent seeing both `mrst-advanced-solvers` and `mrst-linear-solvers` will hesitate — both claim to be about "advanced" solving.
2. **Scope conflation**: The skill conflates fracture *physics/geometry* (DFM, pEDFM) with solver *acceleration* (MsRSB multiscale). A user asking "model a fractured reservoir" and one asking "speed up my simulation with multiscale" need different instructions but land in the same skill.

### Deliverables

1. Rename directory: `skills/mrst-advanced-solvers/` → `skills/mrst-fractured-reservoirs/`
2. Rewrite `skills/mrst-fractured-reservoirs/SKILL.md` — focused purely on fracture modeling
3. Rename example: `examples/basic_multiscale_msrsb.m` → `examples/basic_dfm_fracture.m` (replace with fracture-focused example)
4. Add `examples/pedfm_embedded_fractures.m` — pEDFM example
5. Update cross-references in ALL other SKILL.md files that reference `mrst-advanced-solvers`

### SKILL.md Structure

```
---
name: mrst-fractured-reservoirs
description: Model naturally fractured reservoirs in MRST using Discrete Fracture Models (DFM), Embedded Discrete Fracture Models (pEDFM/EDFM), and Non-Neighboring Connections (NNCs).
---

# MRST Fractured Reservoir Modeling Skill

<intro: explicit fracture representation for reservoirs where matrix-fracture 
interaction dominates flow behavior>

## Prerequisites

- Grid generation basics: consult `mrst-gridding`
- For AD-based fracture models: consult `mrst-ad-oo`
- For procedural fracture models: consult `mrst-core-procedural`

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

## Agent Instructions: Knowledge Retrieval

<standard FTS5 + graphify pattern, querying dfm, pEDFM, NNC, shale>

## Standard Workflows

### Workflow A: DFM with Explicit Fracture Grid
<code template>

### Workflow B: pEDFM with Embedded Fractures
<code template>

## Cross-References
- **Grid generation**: `mrst-gridding` for PEBI grids conforming to fractures
- **Flow solvers**: `mrst-core-procedural` (incompTPFA) or `mrst-ad-oo` (simulateScheduleAD)
- **Performance**: `mrst-linear-solvers` for large fractured models
```

### What to Extract (move to ticket-9 mrst-diagnostics)

The following content currently in `mrst-advanced-solvers` should be **removed** and placed in the new `mrst-diagnostics` skill instead:
- MsRSB (Multiscale Restricted Smoothed Basis) workflow
- `incompMultiscale` solver
- `getMultiscaleBasis` basis function computation
- `generateCoarseGrid` and coarsening-related content (shared with mrst-gridding)

### Cross-Reference Updates Required

After renaming, grep all `SKILL.md` files for references to `mrst-advanced-solvers` and update them to `mrst-fractured-reservoirs`. Currently referenced by:
- `mrst-core-procedural/SKILL.md` (if it mentions advanced solvers)
- `wayfinder-map.md` (the Destination line references "Advanced Solvers")

### Research Guidance

```
python -m tools.mrst_index.search_index keyword "dfm"
python -m tools.mrst_index.search_index keyword "pEDFM"
python -m tools.mrst_index.search_index keyword "NNC"
graphify query "How do DFM and pEDFM differ in MRST?"
graphify explain "shale module"
```

## Answer

Resolved by replacing mrst-advanced-solvers with mrst-fractured-reservoirs and writing SKILL.md along with basic_dfm_fracture.m and pedfm_embedded_fractures.m.
