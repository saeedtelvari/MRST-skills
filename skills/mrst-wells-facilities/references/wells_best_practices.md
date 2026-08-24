# Wells and Facilities Best Practices

This document outlines structural invariants and best practices when dealing with complex well configurations, Multi-Segment Wells (MSW), VFP tables, and group controls in MRST. It focuses on the architectural rules of the simulator rather than reciting API arguments.

## 1. Group Controls: The Structural Invariant

In MRST's `FacilityModel` and associated schedule processing, **Group Controls structurally override individual well limits**. 

If a well is listed as a member of a group, and the solver delegates control to that group (`W(i).type = 'group'`), the following invariants hold true:
- The individual well's limits (e.g., maximum production rate or BHP) are subordinate to the group's target.
- The Non-Linear Solver will evaluate the group's target (e.g., maximum field production) and throttle the individual wells to satisfy the group constraint.
- To correctly pass control from the individual well to the group limit in the simulation `schedule`, you must mutate the well definition inside `schedule.control(step)` so that `type = 'group'`, and subsequently define the group constraints in `schedule.control(step).groups`.

*Failure Mode*: If you define a group limit but leave `schedule.control.W(i).type = 'bhp'`, the solver will ignore the group limit for that well.

## 2. VFP Tables and Unit Alignment

Vertical Flow Performance (VFP) tables define the pressure response of the wellbore based on flow rates, fluid ratios, and wellhead pressures. 

**Invariant**: MRST internally operates on strict SI units (Pascals, cubic meters, seconds), whereas standard ECLIPSE VFP tables (`VFPPROD`, `VFPINJ`) are strictly bound to field units (e.g., `barsa`, `sm3/day`).
- When importing tables via `readSCHEDULE` or `readVFPPROD`, MRST does *not* automatically apply unit conversions on the raw arrays.
- The unit transformation occurs during `convertDeckScheduleToMRST` or when explicitly constructing a `VFPTable` object wrapped by the standard unit parsers.
- If you build a `VFPTable` manually in a script, you must explicitly inject the SI-converted units for all flow rates and pressures, otherwise the nonlinear solver's Newton iterations will fail to converge due to massive gradients in the lift curve interpolation.

## 3. Multi-Segment Wells (MSW) Topological Rules

When extending a standard well into a Multi-Segment Well using `convert2MSWell`:
- **Directionality**: The topology array `topo` must form a valid Directed Acyclic Graph (DAG) pointing from the reservoir face to the wellhead (for producers) or wellhead to reservoir (for injectors). 
- **Volumetric Consistency**: The node depths, lengths, and volumes supplied to `convert2MSWell` must physically match the connections defined in the grid. Disconnected segments or zero-volume nodes will result in singular Jacobian sub-matrices in the `FacilityModel`.
