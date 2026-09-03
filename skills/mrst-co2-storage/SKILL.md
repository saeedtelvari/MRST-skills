---
name: mrst-co2-storage
description: Build Carbon Capture and Storage (CCS) simulations, specifically Vertical Equilibrium (VE) models, using co2lab.
---

# MRST CO2 Storage Skill

This skill provides the workflow for modeling Carbon Capture and Storage (CCS) using the `co2lab` module in MRST.

## Prerequisites

> Before using this skill, ensure you've consulted:
> - `mrst-ad-oo` — for the AD-OO simulation framework

## Core Paradigms

1. **CO2 Storage (`co2lab`)**:
   - Focuses on **Vertical Equilibrium (VE)** models for large-scale, long-term aquifer storage.
   - Computes structural traps (`trapAnalysis`) and uses 2D VE grids (`topSurfaceGrid`) to simulate 3D migration extremely fast.

## Agent Instructions: Initialization

You **MUST** include the following initialization at the top of your scripts. 

```matlab
% Initialize MRST Setup
run('database/MRST-main/startup.m');

% Add required modules for energy transition (e.g., CO2 VE)
mrstModule add co2lab ad-core ad-blackoil
```

## Agent Instructions: Reference Documentation & Examples

Always consult the curated reference documentation and verified examples in this skill rather than guessing API parameters:

1. **Curated Reference Guide**:
   Read `skills/mrst-co2-storage/references/co2_storage_best_practices.md` (CO2 Storage Best Practices) for exact function signatures, physics formulations, and gotchas.

2. **Executable Examples**:
   Refer to verified, runnable scripts in `skills/mrst-co2-storage/examples/` for canonical setups and workflows.
## Standard CO2 VE Workflow

1. **Top-Surface Grid**: 
   Instead of a full 3D grid, extract the top surface:
   ```matlab
   Gt = topSurfaceGrid(G);
   ```
2. **Trap Analysis**:
   ```matlab
   traps = trapAnalysis(Gt, true);
   ```
3. **VE Fluid & Model**:
   ```matlab
   fluid = makeVEFluid(Gt, rock, 'sharp_interface_simple');
   model = CO2VEBlackOilTypeModel(Gt, rock, fluid);
   ```
4. **Execution**:
   Passed into the standard `simulateScheduleAD` solver.
## Cross-References

- **Downstream/Related**: `mrst-geomechanics` (caprock integrity)
- **Orthogonal**: `mrst-linear-solvers`
- **References**: [CO2 Storage Best Practices: Open Aquifer Boundary Conditions](references/co2_storage_best_practices.md)
