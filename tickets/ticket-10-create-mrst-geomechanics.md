Type: task
Status: resolved
Blocked by:

## Question

Create the new `mrst-geomechanics` skill covering coupled flow-mechanics simulations using `ad-mechanics` and `vemmech` modules — poroelasticity, stress/strain, compaction, and subsidence modeling.

**Labels**: `wayfinder:task`

## Specification

### Rationale

MRST provides mature modules for coupled flow-geomechanics simulation (`ad-mechanics`, `vemmech`, `fvbiot`). This is relevant for:
- CO2 storage: caprock integrity assessment, induced seismicity risk
- Geothermal: thermal stress, fracture reactivation
- Unconventional: stress-dependent permeability, hydraulic fracturing
- Compaction drive reservoirs: subsidence prediction

This is the lowest priority new skill (Tier 3) but completes the MRST ecosystem coverage.

### Deliverables

1. `skills/mrst-geomechanics/SKILL.md` — The monolithic skill instruction file.
2. `skills/mrst-geomechanics/examples/poroelastic_terzaghi.m` — Classic Terzaghi consolidation benchmark.
3. `skills/mrst-geomechanics/examples/coupled_flow_mechanics.m` — Coupled reservoir simulation with compaction.

## Answer

Created the `mrst-geomechanics` skill successfully:
- `skills/mrst-geomechanics/SKILL.md`: Documented core paradigms, agent instructions, and workflows for pure mechanics and coupled poroelasticity using `ad-mechanics` and `vemmech`.
- `skills/mrst-geomechanics/examples/poroelastic_terzaghi.m`: Implemented a 1D column script using `MechFluidFixedStressSplitModel` to solve Terzaghi's consolidation problem.
- `skills/mrst-geomechanics/examples/coupled_flow_mechanics.m`: Implemented a 3D depletion scenario showing reservoir compaction and surface subsidence from pressure depletion.
