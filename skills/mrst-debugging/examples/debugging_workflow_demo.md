# MRST Debugging Workflow Demo

This document demonstrates how an agent should apply the `mrst-debugging` loop to a real scenario.

## The Scenario
The user reports: *"My custom surfactant simulation is crashing with `Unmet internal dependency for Viscosity in group PVTPropertyFunctions: Did not find pressure in own group.` Fix it."*

## Phase 1: Isolate & Miniaturize
Instead of running the user's 3-hour Surfactant-Polymer field model, the agent writes a tiny 5-second harness:

```matlab
% debug_harness.m
run('database/MRST-main/startup.m');
mrstModule add ad-core ad-blackoil ad-props
G = computeGeometry(cartGrid([3,3,1]));
rock = makeRock(G, 100*milli*darcy, 0.2);
fluid = initSimpleADIFluid('phases', 'WO', 'mu', [1, 5]*centi*poise, 'rho', [1000, 800]);
model = TwoPhaseOilWaterModel(G, rock, fluid);

% Inject a custom viscosity that explicitly depends on 'pressure'
model.PVTPropertyFunctions = PVTPropertyFunctions(model);
model.PVTPropertyFunctions = model.PVTPropertyFunctions.setStateFunction('Viscosity', PressureDependentViscosity(model));

state0 = initResSol(G, 100*barsa, [0,1]);
W = addWell([], G, rock, 1, 'Type', 'bhp', 'Val', 50*barsa, 'comp_i', [1,0]);
schedule = simpleSchedule(1*day, 'W', W);

[ws, states] = simulateScheduleAD(state0, model, schedule);
```
**Result**: The harness goes RED in 2 seconds with the exact same `Unmet internal dependency` error. Phase 1 is complete.

## Phase 2: Instrument & Diagnose
The agent inspects MRST's property groupings. It realizes that `pressure` is a **Primary Variable**, not a `StateFunction` inside `PVTPropertyFunctions`. By declaring `gp.dependsOn({'pressure'})` in the custom class, the graph search failed. 

**Hypothesis**: Primary variables should be accessed directly via `model.getProp(state, 'pressure')` during evaluation, rather than declared as a graph dependency.

## Phase 3: Fix & Validate
The agent modifies `PressureDependentViscosity.m` in the harness directory:
- Removes `gp = gp.dependsOn({'pressure'});` from the constructor.
- Adds `p = model.getProp(state, 'pressure');` to the `evaluateOnDomain` function.

The agent runs `debug_harness.m` again. It goes GREEN.
The agent then ports this exact change to the user's real `SurfactantViscosity.m` file.

## Phase 4: The Brief
The agent presents the following to the user:

> **Root Cause**: Your custom viscosity class declared a formal graph dependency on `'pressure'`. In MRST, `pressure` is a primary variable, not a state function inside the PVT group, which caused the dependency resolver to crash.
> 
> **The Fix**: I removed the `dependsOn({'pressure'})` declaration in `SurfactantViscosity.m` and updated it to pull pressure directly from the state object (`p = model.getProp(state, 'pressure')`). 
> 
> **Verification**: I built a miniaturized 3x3 model which reproduced the exact crash in 2 seconds. The fix resolved it there, and I have ported the fix to your main repository. Your full simulation is now ready to run.
