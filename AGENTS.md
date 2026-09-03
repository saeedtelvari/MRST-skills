# AGENTS.md - MRST Agentic Ecosystem Instructions

## Universal MRST Execution Contract
Whenever you write or run MATLAB scripts for reservoir simulation:
1. **Startup**: Always begin scripts with `run('database/MRST-main/startup.m');`
2. **Modules**: Explicitly load needed modules with `mrstModule add <modules>`.
3. **SI Units**: MRST operates strictly in SI units internally (meters, Pascals, seconds, kg). Use MRST unit conversion constants (`barsa`, `milli*darcy`, `day`, `centi*poise`, `meter`). Never treat raw numbers as field units.
4. **StateFunctions**: In custom physical properties, specify grouping for primary variables: `gp = gp.dependsOn({'pressure'}, 'state');`.
5. **Polymer Adsorption**: Initialize `state0.cpmax = zeros(G.cells.num, 1);` for irreversible adsorption models.

## Skill Routing
For any MRST simulation task, consult the specialist skill:
- **Grid Generation & Eclipse Import**: `mrst-gridding`
- **Incompressible Flow (TPFA/IMPES)**: `mrst-core-procedural`
- **Black-Oil & Compositional Flow (AD-OO)**: `mrst-ad-oo`
- **CO2 Storage & Vertical Equilibrium**: `mrst-co2-storage`
- **Underground Hydrogen Storage**: `mrst-hydrogen-storage`
- **Geothermal Heat Transport**: `mrst-geothermal`
- **Naturally Fractured Reservoirs (DFM/pEDFM/NNC)**: `mrst-fractured-reservoirs`
- **Coupled Geomechanics (Biot/VEM)**: `mrst-geomechanics`
- **Enhanced Oil Recovery (Polymer/Surfactant)**: `mrst-eor`
- **Flow Diagnostics, Upscaling & Multiscale (MsRSB)**: `mrst-diagnostics`
- **Adjoint Optimization & Well Controls**: `mrst-optimization`
- **Linear Solvers & CPR Preconditioners**: `mrst-linear-solvers`
- **Wells & Surface Facilities**: `mrst-wells-facilities`
- **Visualization & Plotting (mrst-gui)**: `mrst-visualization`
- **AD Scripting & Raw ADI Prototyping**: `mrst-ad-scripting`
- **Custom Physics & Model Subclassing**: `mrst-custom-physics`
- **Debugging & Miniaturized Triage Loop**: `mrst-debugging`
- **Unit Testing Framework (matlab.unittest)**: `mrst-testing`

## Knowledge Base & Architecture
- **Curated Best Practices**: Each skill folder contains `references/*_best_practices.md` detailing mathematical formulations, APIs, and framework traps.
- **Runnable Examples**: Each skill folder contains `examples/*.m` with minimal, verified simulation scripts.
- **Skill Routing & Dependencies**: Consult `skills_manifest.yaml` or `skills/mrst/SKILL.md` for upstream and downstream skill DAG connections.

