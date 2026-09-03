---
name: mrst-hydrogen-storage
description: Build Underground Hydrogen Storage (UHS) simulations handling gas mixing, biological methanation, and hysteresis.
---

# MRST Hydrogen Storage Skill

This skill provides the workflow for modeling Underground Hydrogen Storage (UHS) utilizing the compositional physics, `h2store`, or `h2-biochem` modules in MRST.

## Prerequisites

> Before using this skill, ensure you've consulted:
> - `mrst-ad-oo` — for the AD-OO simulation framework (compositional section)

## Core Paradigms

1. **Gas Mixing (Compositional/Black-Oil)**: 
   - UHS involves injecting H2 into aquifers or depleted reservoirs where it mixes with cushion gas (e.g., CH4 or N2).
2. **Biological Reactions (`h2-biochem`)**: 
   - H2 is highly reactive. Methanogenic archaea consume H2 and CO2 to produce CH4. This requires kinetic reaction modeling.
3. **Hysteresis**: 
   - Cyclic injection and withdrawal create alternating drainage and imbibition cycles, requiring relative permeability hysteresis (e.g., Carlson or Killough models).

## Agent Instructions: Initialization

You **MUST** include the following initialization at the top of your scripts. 

```matlab
% Initialize MRST Setup
run('database/MRST-main/startup.m');

% Add required modules for UHS (typically compositional and ad-core)
mrstModule add ad-core ad-props compositional
```

## Agent Instructions: Reference Documentation & Examples

Always consult the verified examples and upstream documentation rather than guessing API parameters:

1. **Executable Examples**:
   Refer to verified, runnable scripts in `skills/mrst-hydrogen-storage/examples/` for canonical setups and workflows.

2. **Upstream Reference**:
   Consult `skills/mrst-ad-oo/references/ad_oo_best_practices.md` for general AD-OO simulation guidelines and invariants.
## Standard UHS Workflow (Compositional)

1. **Geometry & Petrophysics**: Standard 3D grids.
2. **Fluid (Compositional)**:
   ```matlab
   % Setup a compositional EOS mixture for H2 and CH4
   mixture = CompositionalMixture({'H2', 'CH4'}, Tc, Pc, Vc, omega, mw);
   mixture.bic = [0 0; 0 0];
   
   % Define an underlying flow fluid for relperms
   flowfluid = initSimpleADIFluid('phases', 'G', 'n', 2);
   ```
3. **Model Setup**:
   ```matlab
   model = NaturalVariablesCompositionalModel(G, rock, flowfluid, mixture, 'water', false);
   ```
4. **Initial State**:
   ```matlab
   % Initialize via the model with pressure, temp, saturation, and overall composition (z)
   state0 = initCompositionalState(model, 100*barsa, 300, 1.0, [0.0, 1.0]);
   ```
5. **Wells**: Ensure injection compositions are defined via `W(i).components = [1.0, 0.0]`.
## Cross-References

- **Orthogonal**: `mrst-linear-solvers`
