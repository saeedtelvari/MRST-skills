---
name: mrst-geothermal
description: Build geothermal energy simulations (heat transport, coupled thermo-hydro models).
---

# MRST Geothermal Skill

This skill provides the workflow for modeling Geothermal systems in MRST, coupling fluid flow with heat transport (Thermo-Hydro coupling).

## Prerequisites

> Before using this skill, ensure you've consulted:
> - `mrst-ad-oo` — for the AD-OO simulation framework

## Core Paradigms

1. **Energy Equation**: 
   - Alongside mass conservation, geothermal models solve the energy conservation equation for the rock-fluid system.
2. **Temperature-Dependent Properties**: 
   - Fluid viscosity and density vary significantly with temperature.
3. **`ad-core` Thermal Models**:
   - Built on top of `GenericADModel` or specialized geothermal models in `geothermal` module.

## Agent Instructions: Initialization

You **MUST** include the following initialization at the top of your scripts. 

```matlab
% Initialize MRST Setup
run('database/MRST-main/startup.m');

% Add required modules for geothermal
mrstModule add ad-core ad-props geothermal
```

## Agent Instructions: Knowledge Retrieval

Use the AI knowledge tools:

1. **Search the Textbooks and Source Code**:
   ```bash
   python -m tools.mrst_index.search_index keyword "geothermal"
   ```

2. **Navigate the Codebase Graph (GraphRAG)**:
   - `graphify query "How to set up a thermo-hydro model?"`
   - `graphify path "GenericADModel.m" "geothermal"`

## Standard Geothermal Workflow

1. **Grid & Rock**: Include rock thermal properties using `addThermalRockProps`.
   ```matlab
   rock = makeRock(G, 100*milli*darcy, 0.2);
   rock = addThermalRockProps(rock, 'lambdaR', 2.0, 'rhoR', 2600, 'CpR', 1000);
   ```
2. **Thermal Fluid**: Define a fluid and use `addThermalFluidProps`.
   ```matlab
   fluid = initSimpleADIFluid('phases', 'W', 'mu', 1*centi*poise, 'rho', 1000);
   fluid = addThermalFluidProps(fluid, 'Cp', 4.2e3, 'lambdaF', 0.6);
   ```
3. **Model**:
   ```matlab
   model = GeothermalModel(G, rock, fluid);
   ```
4. **State and Wells**: 
   - State must include `.T` (temperature in K).
   - Wells must be initialized thermally via `addThermalWellProps(W, G, rock, fluid, 'T', 293.15);`.
## Cross-References

- **Downstream/Related**: `mrst-geomechanics` (thermal stress)
- **Orthogonal**: `mrst-linear-solvers`
