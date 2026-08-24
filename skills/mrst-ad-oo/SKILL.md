---
name: mrst-ad-oo
description: Build Automatic Differentiation (AD) and Object-Oriented (OO) fully implicit simulations in MRST — Black-Oil, Compositional EOS, EOR, and generalized models.
---

# MRST AD-OO Simulator Skill

This skill provides the knowledge and workflow for building Automatic Differentiation and Object-Oriented (AD-OO) simulations in MRST. This paradigm is the foundation for Black-Oil, Compositional, EOR, and generalized fully implicit solvers.

## Prerequisites

> Before using this skill, ensure you've consulted:
> - `mrst-gridding` — for grid generation and data import (if you don't already have a grid)

## Core Paradigms

The AD-OO framework relies on core abstractions (often referred to as "God Nodes" in our graph analysis):
1. **`PhysicalModel`**: Represents the physics of the reservoir (e.g., `ThreePhaseBlackOilModel`, `WaterGasModel`).
2. **`NonLinearSolver`**: The generalized Newton-like solver that handles the non-linear iterations.
3. **`simulateScheduleAD`**: The core driver script that steps through the simulation schedule using the model and solver.

## Agent Instructions: Initialization

Whenever you write a MATLAB script for MRST AD-OO, you **MUST** include the following initialization sequence at the top of your script. This is required because relying on a wrapper script destroys MATLAB stack trace line numbers during debugging.

```matlab
% Initialize MRST Setup
run('database/MRST-main/startup.m');

% Add required modules for AD-OO
mrstModule add ad-core ad-props ad-blackoil
```
*(Add other modules like `ad-eor` or `compositional` for EOS models if the specific physics require them).*

## Agent Instructions: Knowledge Retrieval

If you are unsure about the parameters of an AD-OO function, class, or the theoretical formulation, use the pre-built AI knowledge tools rather than guessing:

1. **Search the Textbooks and Source Code**:
   Run the following Python CLI to query the FTS5 knowledge base:
   ```bash
   python -m tools.mrst_index.search_index keyword "simulateScheduleAD"
   ```
   *Available modes*: `keyword`, `lookup`, `explain`, `hybrid`.

2. **Navigate the Codebase Graph (GraphRAG)**:
   Use `graphify` to understand how modules interact:
   - `graphify query "How does NonLinearSolver interact with PhysicalModel?"`
   - `graphify path "simulateScheduleAD.m" "ThreePhaseBlackOilModel.m"`
   - `graphify explain "BasicAD"`

   If you need deep codebase navigation, you can also spawn the graphify subagent by invoking `skill: "graphify"`.

## Standard AD-OO Workflow

A standard script using this paradigm usually follows this structural shape:

1. **Geometry & Petrophysics**: Define `G`, `rock` (via `cartGrid`, `computeGeometry`).
2. **Fluid & Model**:
   ```matlab
   fluid = initSimpleADIFluid('phases', 'WOG', ...);
   model = ThreePhaseBlackOilModel(G, rock, fluid);
   ```
3. **Schedule**: Define wells (using `addWell`) and set up the `schedule` struct with `step` and `control`.
4. **Solver & Execution**:
   ```matlab
   % Initialize nonlinear solver
   solver = NonLinearSolver();
   
   % Execute the AD-OO simulation
   [wellSols, states, report] = simulateScheduleAD(state0, model, schedule, 'NonLinearSolver', solver);
   ```

## Compositional Modeling (EOS-Based)

For multi-component simulations where phase behavior is governed by an Equation of 
State (e.g., gas condensate, volatile oil, CO2-hydrocarbon miscible flooding), MRST 
provides the `compositional` module with two formulation choices.

### Required Modules
```matlab
mrstModule add ad-core ad-props compositional
```

### Key Abstractions

1. **`CompositionalMixture`**: Defines the component set and EOS parameters
   ```matlab
   mixture = CompositionalMixture({'Methane', 'Ethane', 'Propane', 'nDecane'});
   ```
   - Uses the Peng-Robinson EOS by default
   - Critical properties (Tc, Pc, acentric factor) looked up from internal database
   - Binary interaction parameters (BIPs) auto-populated

2. **Two Formulations**:
   - `NaturalVariablesCompositionalModel(G, rock, fluid, mixture)` 
     — Primary variables: pressure, saturations, phase compositions
     — More intuitive but phase-appearance/disappearance handling is complex
   - `OverallCompositionCompositionalModel(G, rock, fluid, mixture)`
     — Primary variables: pressure, overall molar fractions z_i
     — Handles phase transitions robustly (preferred for complex phase behavior)

3. **State Initialization**:
   ```matlab
   state0 = initCompositionalState(G, p0, T, s0, z0, model);
   ```
   - `z0`: overall molar composition vector (sums to 1)
   - `T`: temperature (Kelvin)
   - Flash calculation determines initial phase split

### Workflow
1. Define `mixture = CompositionalMixture({...})` with component names
2. Create fluid: `fluid = initSimpleADIFluid('phases', 'OG', ...)`
3. Choose formulation: `model = NaturalVariablesCompositionalModel(G, rock, fluid, mixture)`
4. Initialize state with `initCompositionalState`
5. Define wells, schedule, and run `simulateScheduleAD`

### When to Use Compositional vs Black-Oil
- **Black-Oil**: When fluid can be described by Rs, Rv (dissolved gas ratio, vaporized oil ratio)
- **Compositional**: When you need full EOS phase equilibrium — gas condensate, volatile oil, 
  miscible flooding, CO2 injection near MMP, any problem with >2 components where phase 
  behavior matters
## Cross-References

- **Downstream**: `mrst-co2-storage`, `mrst-hydrogen-storage`, `mrst-geothermal`, `mrst-optimization`, `mrst-geomechanics`, `mrst-linear-solvers`
- **References**:
  - [AD-OO Best Practices: PhysicalModel and Variables](file:///D:/MRST-skills/skills/mrst-ad-oo/references/ad_oo_best_practices.md)
