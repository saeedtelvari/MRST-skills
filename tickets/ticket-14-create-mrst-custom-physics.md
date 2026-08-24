Type: task
Status: resolved
Blocked by:

## Question

Create the `mrst-custom-physics` skill to teach agents how to extend the MRST Object-Oriented framework by subclassing `PhysicalModel` and `StateFunction`.

**Labels**: `wayfinder:task`

## Specification

### Deliverables

1. `skills/mrst-custom-physics/SKILL.md`
   - **Core Paradigms**: Explain how to subclass `PhysicalModel` (or a specific model like `TwoPhaseOilWaterModel`), how to define `PrimaryVariables`, how to implement `getEquations` (assembling accumulation and flux), and how to write custom `StateFunction` classes to evaluate properties lazily.
   - **Agent Instructions**: Emphasize this is for extending MRST to use with `simulateScheduleAD`, optimization, and linear solvers.
2. `skills/mrst-custom-physics/examples/custom_physics_model.m`
   - A script that defines a simple custom `StateFunction` (e.g., a custom viscosity or density relation) and a custom `PhysicalModel` that uses it, then runs it using `simulateScheduleAD`.

### Rationale
Unlocks the ability for agents to add novel physics to production-grade reservoir models while still leveraging MRST's enterprise features (schedules, adjoints, solvers).

## Answer
The `mrst-custom-physics` skill has been created successfully. It includes the `SKILL.md` documentation covering `StateFunction` creation, `TwoPhaseOilWaterModel` subclassing, overriding `getEquations` and `getPrimaryVariables`, along with agent instructions and cross-references. An example script `custom_physics_model.m` has been provided to demonstrate subclassing and evaluating a custom pressure-dependent viscosity using `simulateScheduleAD`.
