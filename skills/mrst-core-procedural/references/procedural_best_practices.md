# Procedural Transport Best Practices: Explicit vs. Implicit

When building procedural transport simulations in MRST, choosing between `explicitTransport` and `implicitTransport` dictates the fundamental stability and computational invariants of your solver loop.

## The CFL Time-Stepping Trap (Explicit Transport)

Using `explicitTransport` is computationally sensitive due to the Courant-Friedrichs-Lewy (CFL) condition constraint, which it enforces automatically.

**Framework Traps:**
* **Unpredictable Time-Step Collapse:** The maximum stable time-step ($\Delta t$) is strictly bounded by the fastest-moving fluid front traversing the smallest grid cell. High-permeability streaks or sudden high-rate well injections cause the stable CFL limit to plunge. While MRST's `explicitTransport` automatically handles sub-stepping to maintain stability, a microscopic CFL limit will cause its internal `while t < tf` loop to take an enormous number of tiny steps, effectively halting progress.
* **Stale Fluxes during Sub-stepping:** MRST's `explicitTransport` internally sub-steps to reach the target `tf` while holding the phase fluxes constant. If the outer schedule step is too large, saturations will change significantly, rendering the constant-flux assumption inaccurate and requiring the user to manually script an outer pressure-update loop (IMPES).

**Structural Invariant:** *Explicit transport is automatically stable due to MRST's internal CFL-based sub-stepper (`computedt = true`). You can pass hardcoded schedule-driven time-steps without risking stability collapse, but you risk severe performance degradation and IMPES accuracy loss if the internal sub-steps become too small or numerous.*

## Unconditional Stability (Implicit Transport)

`implicitTransport` resolves CFL fragility by solving the saturation equations implicitly, making it unconditionally stable for any time-step size.

**Structural Invariants:**
* **Time-Step Independence:** You are guaranteed a mathematically stable saturation update regardless of grid heterogeneity, extreme permeability contrasts, or injection rates. $\Delta t$ can be driven entirely by the reporting schedule (e.g., monthly outputs) rather than stability limits.
* **Absolute Bounds:** The implicit upwind formulation strictly preserves bounds, preventing unphysical fluid saturations outside the $[0, 1]$ interval that often plague unstable explicit runs.

**Framework Traps:**
* **Artificial Smearing:** Unconditional stability trades accuracy for robustness. Taking massive time steps introduces severe numerical diffusion, artificially smearing out sharp fluid shock fronts. This can lead to predicting prematurely early water/gas breakthrough at producer wells.
* **Non-linear Solver Choking:** While stable, massive implicit time steps push a heavier burden onto the underlying non-linear Newton solver. Extremely large steps can cause the solver to struggle with convergence, replacing explicit time-step collapse with implicit iteration stalling.

## Architectural Decision Rule

1. Default to **`implicitTransport`** for robust, schedule-driven simulations, highly heterogeneous reservoirs, or when writing simplified procedural solver loops.
2. Only switch to **`explicitTransport`** (paired with a frequent pressure-update loop for IMPES accuracy) when the accuracy of sharp fluid fronts and exact breakthrough timing are paramount, and the grid geometry is sufficiently regular to avoid microscopic CFL limits that would stall the solver.
