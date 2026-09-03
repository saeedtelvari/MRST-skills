---
name: mrst-eor
description: Build Automatic Differentiation (AD) Enhanced Oil Recovery (EOR) simulations in MRST, including Polymer and Surfactant flooding.
---

# MRST EOR Skill

This skill provides the knowledge and workflow for building Enhanced Oil Recovery (EOR) simulations using the Automatic Differentiation (`ad-eor`) framework in MRST. It specifically covers Polymer injection and Surfactant flooding models.

## Prerequisites

> Before using this skill, ensure you've consulted:
> - `mrst-gridding` — for grid generation and data import.
> - `mrst-ad-oo` — for the foundational Object-Oriented simulation concepts (Model, Schedule, NonLinearSolver).

## Core Paradigms

The `ad-eor` module extends the standard AD-OO framework. You instantiate a specific EOR model (e.g., `OilWaterPolymerModel` or `ThreePhaseBlackOilPolymerModel`) and supply EOR-specific properties in the `fluid` object. 

1. **`OilWaterPolymerModel`**: Two-phase (oil/water) flow with polymer dissolved in the water phase.
2. **`ThreePhaseBlackOilPolymerModel`**: Three-phase (oil/water/gas) black-oil model with polymer.
3. **`OilWaterSurfactantModel`**: Models surfactant flooding including microemulsion phases and interfacial tension (IFT) effects.

## Agent Instructions: Initialization

Whenever you write a MATLAB script for MRST EOR, you **MUST** include the following initialization sequence at the top of your script.

```matlab
% Initialize MRST Setup
run('database/MRST-main/startup.m');

% Add required modules for AD-OO and EOR
mrstModule add ad-core ad-props ad-blackoil ad-eor
```

## Agent Instructions: Reference Documentation & Examples

Always consult the curated reference documentation and verified examples in this skill rather than guessing API parameters:

1. **Curated Reference Guide**:
   Read `skills/mrst-eor/references/eor_best_practices.md` (EOR Best Practices) for exact function signatures, physics formulations, and gotchas.

2. **Executable Examples**:
   Refer to verified, runnable scripts in `skills/mrst-eor/examples/` for canonical setups and workflows.
## Standard Polymer Workflow

A standard script using this paradigm follows this structural shape:

1. **Geometry & Petrophysics**: Define `G`, `rock`.
2. **Standard Fluid**:
   ```matlab
   fluid = initSimpleADIFluid('phases', 'WO', 'mu', [1, 10]*centi*poise);
   ```
3. **Add Polymer Properties**:
   Append EOR-specific properties to the `fluid` object:
   ```matlab
   fluid.cpmax = 10;                     % Max polymer concentration
   fluid.mixPar = 1.0;                   % Todd-Longstaff mixing parameter
   fluid.dps = 0.0;                      % Inaccessible pore volume (dead pore space)
   fluid.rhoR = 2000;                    % Rock density (kg/m3) for adsorption
   fluid.adsInx = 2;                     % 1=reversible, 2=irreversible
   fluid.ads = @(c) 1e-5 * c;            % Adsorption isotherm function
   fluid.muWMult = @(c) 1 + 5 * c;       % Viscosity multiplier as function of concentration
   ```
4. **Instantiate Model**:
   ```matlab
   model = OilWaterPolymerModel(G, rock, fluid);
   ```
5. **Initial State & Schedule**:
   ```matlab
   state0 = initResSol(G, 100*barsa, [0.1, 0.9]);
   state0.cp = zeros(G.cells.num, 1);    % Polymer concentration
   state0.cpmax = zeros(G.cells.num, 1); % Max concentration seen (for irreversible adsorption)
   
   % When adding wells, specify 'polymer' injection concentration
   W = addWell(W, G, rock, inj_cells, 'Type', 'rate', 'Val', q, 'comp_i', [1, 0], 'polymer', 2.0);
   ```
6. **Execution**:
   ```matlab
   % Invariant check: cpmax is strictly required by the Newton solver for adsorption
   assert(isfield(state0, 'cpmax'), 'state0.cpmax is required for polymer models with adsorption');
   
   solver = NonLinearSolver();
   [wellSols, states, report] = simulateScheduleAD(state0, model, schedule, 'NonLinearSolver', solver);
   ```

## Cross-References

- **Upstream**: `mrst-gridding`, `mrst-ad-oo`
- **Downstream**: `mrst-optimization` (for optimizing polymer slug sizes)
