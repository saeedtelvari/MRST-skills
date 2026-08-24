Type: task
Status: resolved
Blocked by: 

## Question

Create the `mrst-eor` (Enhanced Oil Recovery) skill. Focus on the `ad-eor` and `polymer` modules. This skill should introduce the `references/` architecture to store deep domain knowledge without bloating the main `SKILL.md`.

**Labels**: `wayfinder:task`, `physics`

## Specification

1. **`SKILL.md`**: Main routing and basic usage for EOR. Must explicitly tell the agent to read the reference files for specific math/physics implementations.
2. **`references/eor_physics.md`**: A deep-dive reference document covering the math and MRST implementation details for Polymer (shear thinning, adsorption, permeability reduction) and Surfactant (interfacial tension, microemulsions).
3. **`examples/polymer_flooding.m`**: A working script demonstrating a basic polymer flood with non-Newtonian effects.

## Answer

Created the `mrst-eor` skill containing:
- `SKILL.md`: Main entrypoint outlining the model usage (`OilWaterPolymerModel`), how to setup the fluid properties, and routing agents to the reference file.
- `references/eor_best_practices.md`: Structural invariants and physics best practices for EOR models without overwhelming the agent with equations.
- `examples/polymer_flooding.m`: A self-contained script modeling a 2D polymer flood with water pre-flush, polymer slug, and water chase. Uses `OilWaterPolymerModel` directly instead of relying on an Eclipse dataset.
