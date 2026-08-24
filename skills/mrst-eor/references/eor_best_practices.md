# EOR Best Practices & Structural Invariants

This document outlines the fundamental invariants and structural relationships you must respect when building EOR (Polymer/Surfactant) models in MRST's `ad-eor` module.

## Polymer Structural Invariants

1. **Polymer Exists Within the Water Phase**
   - The polymer component is transported *only* within the water phase. 
   - All polymer mass conservation equations scale with the water velocity (`vW` / `bW`). 
   - You MUST have a water phase present in your `initSimpleADIFluid` (e.g., `'WO'` or `'WOG'`) to use Polymer models.

2. **Todd-Longstaff Mixing Rule (`fluid.mixPar`)**
   - MRST handles polymer solution viscosity via the Todd-Longstaff model.
   - The mixing parameter (`w` or `mixPar`) ranges from `0.0` (completely unmixed) to `1.0` (fully mixed). 
   - The water mobility calculation structurally depends on this mixing parameter. If `mixPar = 1.0`, polymer and water travel at the same velocity (no slip).

3. **Adsorption and Mass Conservation**
   - **Fields**: You must define `fluid.ads(c)`, `fluid.rhoR` (rock density), and `fluid.adsInx`.
   - **State Variables**: The AD-OO framework requires `state.cp` (current concentration) and `state.cpmax` (maximum historical concentration) to compute hysteresis in irreversible adsorption. 
   - **Irreversible Adsorption** (`fluid.adsInx = 2`): Adsorption depends on `max(cp, cpmax)`. If you do not initialize `state.cpmax`, the Newton solver will fail when validating the state.
   - **Pore Volume Reduction**: The dead pore space (`fluid.dps`) reduces the accessible pore volume for the polymer component, causing polymer to travel faster than the tracer water front.

4. **Viscosity Multiplier (`fluid.muWMult`)**
   - The multiplier function MUST return `1.0` when concentration is `0`.
   - Example invariant: `fluid.muWMult(0) == 1.0`.

5. **Well Control**
   - When injecting polymer, the injection concentration is defined dynamically in the well setup. You MUST specify the `'polymer'` argument in `addWell` (e.g., `'polymer', 5.0`). 
   - The solver multiplies this concentration by the water injection rate to determine the polymer mass source.

## Surfactant Structural Invariants (Brief)

1. **Interfacial Tension (IFT) and Capillary Desaturation**
   - Surfactant models in MRST primarily act by lowering the oil-water interfacial tension, which increases the capillary number.
   - Relative permeabilities are typically modified as a function of the capillary number (Capillary Desaturation Curve).

2. **Microemulsion Phase**
   - Depending on the surfactant model (e.g., Winsor Type I, II, III), the surfactant may reside in the water phase, oil phase, or form a distinct microemulsion phase. Ensure your `fluid` properties (like partition coefficients) correctly align with the chosen `OilWaterSurfactantModel`.
