# Optimization Best Practices: Adjoint Gradients & Control Scaling

This document focuses on the structural invariants and framework traps when performing adjoint-based optimization in MRST. It omits textbook math and exhaustive API docs in favor of structural clarity.

## 1. `NPVOW` Sign Convention

The most dangerous trap in MRST optimization is the sign convention of well rates in `NPVOW`.

**Invariant**: In MRST, **producers have negative rates** (`qOs < 0`, `qWs < 0`). The `NPVOW` function accounts for this internally:
- Oil revenue: `-ro * qOs` → positive (because `qOs < 0`)
- Water production cost: `rwp * qWs` → negative (because `qWs < 0`, so cost is added)
- Water injection cost: `rwi * qWs_inj` → positive injection rates

**Framework Trap**: If you write a custom objective function and forget the sign convention, your optimizer will *maximize costs* instead of *maximizing revenue*. Always test your objective function on a single forward simulation before plugging it into the optimization loop.

## 2. `schedule2control` / `control2schedule` Scaling

The `unitBoxBFGS` optimizer operates on a unit-box scaled control vector $u \in [0, 1]^n$. The `scaling` struct maps between physical values and scaled values.

**Invariants**:
- `scaling.boxLims` must be a matrix where each row defines `[lower_bound, upper_bound]` for one control variable in **SI units**.
- The number of rows must equal the number of control variables per time step × number of controlled time steps.
- `schedule2control(schedule, scaling)` extracts well controls from the schedule and scales them to $[0, 1]$.
- `control2schedule(u, schedule, scaling)` maps the scaled vector back to a physical schedule.

**Framework Traps**:
- **Unit Mismatch**: `boxLims` must be in SI. Writing `[0, 400]` when you mean 400 m³/day will be interpreted as 400 m³/s — an absurdly high rate that causes immediate solver divergence. Use `[0, 400/day]`.
- **Objective Scaling**: `scaling.obj` should normalize the objective value to approximately O(1). If NPV is ~$10⁸ and `scaling.obj` is not set, the L-BFGS line search will take microscopic steps and appear to stagnate.
- **Maximization Default**: `unitBoxBFGS` **maximizes** by default. If your objective function returns a cost (to be minimized), negate it.

## 3. `evalObjective` and Adjoint Pass

The `evalObjective` function wraps forward simulation + adjoint gradient computation into a single callable.

**Invariant**: The adjoint method requires stored simulation states from the forward pass. `evalObjective` internally calls `simulateScheduleAD` (storing all states), then runs `computeGradientAdjointAD` backward through the stored states.

**Framework Traps**:
- **Memory**: For long schedules (hundreds of time steps), storing all states consumes significant memory. This is unavoidable for the adjoint method.
- **Gradient Validity**: The adjoint gradient is exact only if the forward simulation converged at every time step. If any time step hit the maximum Newton iteration limit without converging, the gradient is *approximate* and may cause the optimizer to make incorrect steps.
- **Control Parameterization**: The gradient is computed with respect to the well controls defined in `schedule.control`. If your schedule has multiple control periods with different well configurations, the control vector structure must match exactly.

## 4. Convergence Diagnostics

**Invariant**: Track the optimization history (`history` output from `unitBoxBFGS`) to detect pathological behavior:
- Monotonic increase in objective → healthy optimization
- Oscillating objective → step size too large or gradient inaccuracy
- Flat objective after first iteration → `scaling.obj` is wrong or `boxLims` are too tight
