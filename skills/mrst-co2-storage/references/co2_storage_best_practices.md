# CO2 Storage Best Practices: Open Aquifer Boundary Conditions

When modeling large-scale CO2 migration using Vertical Equilibrium (VE) models in the `co2lab` module, setting correct open boundary conditions is critical for mass balance and pressure conservation. This reference outlines the structural invariants and framework traps associated with open aquifer boundary paradigms and `addBC`.

## Open Aquifer Paradigms

1. **Volume/Pressure Dissipation**: In regional-scale aquifer models, the physical boundary is often far away from the injection site. Using standard closed boundaries will artificially inflate reservoir pressure. You must explicitly define open boundaries to allow fluid volume displacement or pressure dissipation.
2. **Hydrostatic Equilibrium Assumption**: Open boundaries generally assume that the aquifer at the boundary is in hydrostatic equilibrium, typically saturated with brine. CO2 is not expected to cross the boundary during the main injection phase; if it does, the model domain is likely too small.

## `addBC` Structural Invariants

The `addBC` function (when used to define VE open boundaries) maintains specific structural assumptions about the state of the boundary:

1. **Phase Saturation Invariant**: 
   - Open boundaries must be initialized and maintained as 100% brine (water) saturated. Boundary conditions that allow CO2 influx or prescribe CO2 at the boundary violate the VE assumption of a resident brine aquifer.
   
2. **Hydrostatic Pressure Anchoring**:
   - The pressure condition applied at the open boundary must strictly match the initial hydrostatic pressure gradient of the aquifer at that depth.
   - **Invariant**: `p_bc(z) = p_ref + rho_brine * g * (z - z_ref)`. 
   - A mismatch between initial pressure and boundary pressure will cause artificial, instantaneous transient flows at the start of the simulation.

3. **Transmissibility and Volume Multipliers**:
   - Rather than modeling the full regional aquifer, volume multipliers (e.g., using Carter-Tracy aquifer models or simple pore volume multipliers at the boundary cells) are often coupled with open boundary conditions to simulate infinite-acting or semi-infinite behavior.
   - Ensure that the transmissibility between the boundary cells and the simulated domain accounts for the upscaled VE permeability.

## Framework Traps & Pitfalls

- **Top-Surface Grid Disconnect**: Boundary conditions must be applied to the top-surface VE grid (`Gt`), not the 3D grid (`G`). Passing 3D boundary faces to `addBC` when running a VE model will silently corrupt the pressure solve or cause dimension mismatch errors.
- **Density Mismatch**: Hardcoding brine density in the boundary condition instead of extracting it from the `fluid` object is a common trap. If `fluid.rhoWS` differs from the density used to calculate boundary pressures, unphysical buoyancy-driven flows will occur at the boundaries.
- **Boundary Trapping**: Avoid placing boundaries directly adjacent to structural traps identified by `trapAnalysis`. If a boundary cuts through a trap, the volume calculations for capillary trapping and structural spill will be invalidated.
