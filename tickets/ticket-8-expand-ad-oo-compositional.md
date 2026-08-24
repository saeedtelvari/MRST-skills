Type: task
Status: resolved
Blocked by:

## Question

Expand `mrst-ad-oo/SKILL.md` with a "General Compositional Modeling" section covering `CompositionalMixture`, `NaturalVariablesCompositionalModel`, `OverallCompositionCompositionalModel`, and EOS flash calculations — closing the gas-condensate / generic compositional gap.

**Labels**: `wayfinder:task`

## Specification

### Rationale

Currently, compositional modeling knowledge is siloed in `mrst-hydrogen-storage` (which hardcodes H2/CH4 mixtures and UHS-specific biochemistry). A user asking "set up a 5-component gas condensate simulation" or "model CO2-hydrocarbon miscible flooding using compositional EOS" has no skill to invoke. The general compositional framework (`ad-compositional`) is a core AD-OO paradigm that belongs in the base skill.

### Deliverables

1. **Modified**: `skills/mrst-ad-oo/SKILL.md` — Add a new section after the existing Standard AD-OO Workflow
2. **New example**: `skills/mrst-ad-oo/examples/basic_compositional_eos.m`

### What to Add to SKILL.md

Insert a new major section titled `## Compositional Modeling (EOS-Based)` after the existing `## Standard AD-OO Workflow` section. This section should cover:

```markdown
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
```

### Also Update

- The SKILL.md description (YAML frontmatter) to mention compositional:
  ```yaml
  description: Build Automatic Differentiation (AD) and Object-Oriented (OO) fully implicit simulations in MRST — Black-Oil, Compositional EOS, EOR, and generalized models.
  ```
- The `mrstModule add` line in Agent Instructions to note: `compositional` for EOS models

### Example Script: basic_compositional_eos.m

```matlab
% basic_compositional_eos.m
% A minimal 3-component compositional simulation using Peng-Robinson EOS
% Demonstrates: CompositionalMixture, NaturalVariablesCompositionalModel, 
%               initCompositionalState, simulateScheduleAD

run('database/MRST-main/startup.m');
mrstModule add ad-core ad-props compositional

% Grid and rock
G = cartGrid([20, 1, 1], [1000, 10, 10]*meter);
G = computeGeometry(G);
rock = makeRock(G, 100*milli*darcy, 0.2);

% Define 3-component mixture (light oil system)
mixture = CompositionalMixture({'Methane', 'nPentane', 'nDecane'});

% Fluid
fluid = initSimpleADIFluid('phases', 'OG', ...
    'mu', [1, 0.05]*centi*poise, ...
    'rho', [700, 100]*kilogram/meter^3);

% Model (Natural Variables formulation)
model = NaturalVariablesCompositionalModel(G, rock, fluid, mixture);

% Initial state: 200 bar, 350 K, fully liquid, composition [0.3, 0.4, 0.3]
state0 = initCompositionalState(G, 200*barsa, 350, [1 0], ...
    [0.3, 0.4, 0.3], model);

% Wells
W = [];
W = addWell(W, G, rock, 1, 'Type', 'rate', 'Val', 1e-3, ...
    'Comp_i', [1, 0], 'Name', 'Inj');
W = addWell(W, G, rock, G.cells.num, 'Type', 'bhp', 'Val', 100*barsa, ...
    'Comp_i', [0, 1], 'Name', 'Prod');

% Schedule
schedule = simpleSchedule(repmat(30*day, 1, 12), 'W', W);

% Simulate
[wellSols, states, report] = simulateScheduleAD(state0, model, schedule);
```

### Research Guidance

```
python -m tools.mrst_index.search_index keyword "CompositionalMixture"
python -m tools.mrst_index.search_index keyword "NaturalVariablesCompositionalModel"
python -m tools.mrst_index.search_index keyword "OverallCompositionCompositionalModel"
python -m tools.mrst_index.search_index keyword "initCompositionalState"
graphify query "How does compositional simulation differ from black-oil in MRST?"
graphify path "CompositionalMixture" "NaturalVariablesCompositionalModel"
```

## Answer
Expanded the mrst-ad-oo skill by adding the requested Compositional Modeling section to SKILL.md. Updated the YAML frontmatter description to include 'Compositional EOS'. Created the basic_compositional_eos.m example demonstrating the usage of CompositionalMixture, NaturalVariablesCompositionalModel, and initCompositionalState.
