# AD-OO Best Practices: PhysicalModel and Variables

This document focuses on the timeless structural invariants and common framework traps when working with `PhysicalModel`, `PrimaryVariables`, and `StateFunctions` in the MRST AD-OO framework. It intentionally omits textbook math and exhaustive API documentation in favor of structural clarity.

## The PhysicalModel Lifecycle

The `PhysicalModel` is the God Node of the AD-OO architecture. Its lifecycle is tightly constrained by the non-linear solver loop.

### Invariants & Constraints

1. **Initialization is Immutable (mostly):**
   A `PhysicalModel` is instantiated once per simulation. It defines the physics, active equations, and variable structure. Do not attempt to fundamentally alter the model's structure (like adding new phases or changing the fundamental equations) midway through a simulation step.
2. **State Updates:**
   The model does not hold the simulation state itself. The state is passed through as a separate `state` struct. The solver queries the model to compute residuals and Jacobians based on the current state.
3. **The `stepFunction` and `getEquations` Contract:**
   The solver calls the model's `stepFunction`, which manages a single nonlinear iteration. During this step, the model calls `getEquations` (or equivalent equation evaluation methods). The `getEquations` method expects a precisely formatted state and returns a linearized problem containing the nonlinear equations' residuals and Jacobians.

### Framework Traps

- **Modifying Model Properties Mid-Step:** Avoid trying to change core model properties (like relative permeability curves) inside the nonlinear iteration loop unless you are writing a custom subclass and fully understand the caching and differentiation implications.
- **State/Model Mismatch:** A common error is passing a state struct that was initialized for a different `PhysicalModel` subclass. The state must contain the exact `PrimaryVariables` the current model expects.

## PrimaryVariables vs. StateFunctions

MRST enforces a strict structural distinction between variables that the solver updates directly and variables derived from them. Mixing these up will break the Automatic Differentiation (AD) chain or cause solver divergence.

### PrimaryVariables

- **Definition:** The independent variables solved for by the Newton-Raphson iterations (e.g., Pressure, Saturations, Molar Fractions).
- **Structure:** They form the core unknowns vector. The solver directly applies increments to these variables.
- **AD Role:** These are the roots of the AD tree. They are initialized as AD variables (with values and Jacobians) at the start of an iteration.

### StateFunctions

- **Definition:** Dependent variables computed strictly from `PrimaryVariables` (and static parameters like rock properties). Examples include Capillary Pressure, Relative Permeabilities, Viscosities, and Phase Densities.
- **Structure:** They are evaluated during the assembly of the governing equations.
- **AD Role:** They inherit their AD type (values + derivatives) automatically when evaluated using `PrimaryVariables`.
- **The Golden Rule:** **NEVER** treat a `StateFunction` as a `PrimaryVariable`. The solver must not update a `StateFunction` directly. It must only update `PrimaryVariables`, and the framework will re-evaluate the `StateFunctions`.

### Framework Traps

- **Dependencies in StateFunctions:** If `StateFunction A` depends on `StateFunction B`, ensure you explicitly declare this dependency (e.g., using `dependsOn` or by populating the `dependencies` and `externals` properties). The framework will automatically resolve the correct evaluation order. Avoid actual circular dependencies (A depends on B, B depends on A), as they will cause the dependency graph evaluation to fail.
- **Breaking the AD Chain:** If you compute a property using standard double-precision MATLAB functions that don't support AD objects, the derivative information is lost. The Jacobian will be silently incorrect, leading to poor convergence or failure. Always ensure operations on `PrimaryVariables` result in valid AD objects.
