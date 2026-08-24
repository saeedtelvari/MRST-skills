---
name: mrst-custom-physics
description: Extend the MRST Object-Oriented framework by subclassing PhysicalModel and StateFunction for custom physics.
---

# MRST Custom Physics Skill

This skill provides the knowledge and workflow for extending MRST's AD-OO framework with custom physics. By subclassing `PhysicalModel` and `StateFunction`, agents can add novel physics (e.g., non-Newtonian fluids, custom equations of state, or new primary variables) while retaining compatibility with MRST's enterprise features such as `simulateScheduleAD`, adjoint optimization, and advanced linear solvers.

## Prerequisites

> Before using this skill, ensure you've consulted:
> - `mrst-gridding` — for grid generation.
> - `mrst-ad-oo` — for the foundational understanding of the AD-OO paradigm.

## Core Paradigms

Extending MRST involves subclassing one of the base model classes (like `PhysicalModel`, `ReservoirModel`, or `TwoPhaseOilWaterModel`) and replacing or extending its state functions.

### 1. Custom `StateFunction`

A `StateFunction` defines a physical property and its dependencies. It evaluates lazily during the nonlinear iterations. 

To create a custom `StateFunction`, inherit from `StateFunction`, declare dependencies in the constructor, and override `evaluateOnDomain`:

```matlab
classdef PressureDependentViscosity < StateFunction
    methods
        function gp = PressureDependentViscosity(model, varargin)
            gp@StateFunction(model, varargin{:});
            % Declare dependency on 'pressure' — a primary variable living
            % in the 'state' struct, NOT in any StateFunctionGrouping.
            % You MUST specify the 'state' grouping for primary variables,
            % otherwise the framework looks for 'pressure' in the current
            % grouping and fails silently.
            gp = gp.dependsOn({'pressure'}, 'state');
        end
        
        function mu = evaluateOnDomain(prop, model, state)
            % 1. Retrieve primary variable via the model (returns AD object)
            p = model.getProp(state, 'pressure');
            
            % 2. Get baseline parameters from the model
            mu_base = model.fluid.mu; 
            
            % 3. Calculate the property (AD-safe operations preserve derivatives)
            scale = 1 + 1e-4 * (p / barsa);
            
            % 4. Return as a cell array for phases {water, oil}
            mu = {mu_base(1) * scale, mu_base(2) * scale};
        end
    end
end
```

### 2. Subclassing `PhysicalModel` / `TwoPhaseOilWaterModel`

To inject your custom physics into the simulation, subclass an existing model and replace the default property function groupings (like `PVTPropertyFunctions` or `FlowPropertyFunctions`).

```matlab
classdef CustomTwoPhaseModel < TwoPhaseOilWaterModel
    methods
        function model = CustomTwoPhaseModel(G, rock, fluid, varargin)
            % Call parent constructor
            model = model@TwoPhaseOilWaterModel(G, rock, fluid, varargin{:});
            
            % Replace the standard viscosity with our custom StateFunction
            model.PVTPropertyFunctions.Viscosity = PressureDependentViscosity(model);
        end
    end
end
```

### 3. Defining `PrimaryVariables`

If your custom physics requires introducing new variables (e.g., a tracer concentration or a new temperature field), override `getPrimaryVariables`:

```matlab
function [vars, names, origin] = getPrimaryVariables(model, state)
    % Call parent method to get existing variables (e.g., pressure, saturation)
    [vars, names, origin] = getPrimaryVariables@TwoPhaseOilWaterModel(model, state);
    
    % Append the new custom variable
    vars{end+1} = state.tracer_conc;
    names{end+1} = 'tracer_conc';
    
    % (Optional) Update origin to track where the variable came from
    origin{end+1} = class(model); 
end
```

### 4. Overriding `getEquations`

To assemble new accumulation and flux terms, override `getModelEquations`. Use `model.FlowDiscretization` to compute fluxes and divergences.

```matlab
function [eqs, names, types, state] = getModelEquations(model, state0, state, dt, drivingForces)
    % 1. Get base equations from the parent class
    [eqs, names, types, state] = getModelEquations@TwoPhaseOilWaterModel(model, state0, state, dt, drivingForces);
    
    % 2. Retrieve variables needed for the new equation
    c = state.tracer_conc;
    c0 = state0.tracer_conc;
    pv = model.getProp(state, 'PoreVolume');
    
    % 3. Build accumulation and flux terms
    % Accumulation
    acc = (pv .* c - pv .* c0) / dt;
    
    % Flux (example: explicit upwinding using phase fluxes)
    flux = state.flux; % computed by parent model
    div = model.operators.Div; % divergence operator
    % ... compute tracer flux ...
    
    % 4. Append the new equation
    eqs{end+1} = acc + div * tracer_flux;
    names{end+1} = 'tracer_conservation';
    types{end+1} = 'cell';
end
```

## Agent Instructions

When implementing custom physics:
1. **Always use StateFunctions** for properties. Do not hardcode property calculations inside `getModelEquations` unless absolutely necessary, as `StateFunctions` ensure correct AD chaining, dependency resolution, and caching.
2. **Reuse the Model Hierarchy**. Inherit from `TwoPhaseOilWaterModel` or `ThreePhaseBlackOilModel` whenever possible rather than `PhysicalModel` to leverage existing initialization and validation routines.
3. **Execution**: The resulting custom model integrates directly with standard MRST tools like `simulateScheduleAD`, optimization, and nonlinear solvers without any changes to the driver script.

## Standard Workflow

1. Initialize G, rock, fluid.
2. Instantiate the custom model: `model = CustomTwoPhaseModel(G, rock, fluid);`
3. Initialize the state struct (ensuring new primary variables are included if added).
4. Run standard `simulateScheduleAD`.

## Cross-References

- **Best Practices**: [Custom Physics Best Practices](references/custom_physics_best_practices.md)
- **Upstream**: `mrst-ad-oo`
- **Downstream**: `mrst-optimization`, `mrst-linear-solvers`
