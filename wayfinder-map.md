## Destination

A comprehensive, modular ecosystem of 19 MRST Skills (1 router, 13 specialists, 2 developer frameworks, 1 visualization, 1 debugging loop, 1 automated testing framework), each defined by a SKILL.md and reference examples, empowering AI agents to autonomously write, debug, and visualize reservoir simulations across Gridding & Data Import, Core Procedural Flow, AD-OO Simulation (Black-Oil + Compositional), Fractured Reservoirs, Flow Diagnostics & Upscaling, Optimization, CO2 Storage, Hydrogen Storage, Geothermal Energy, Linear Solvers, Geomechanics, Custom Physics Developer Frameworks (Scripting & Object-Oriented), Visualization, Debugging, EOR, Advanced Wells, and Testing — with a top-level router skill for intent-based dispatch.

## Notes

- **Domain**: MATLAB Reservoir Simulation Toolbox (MRST), agentic workflows, GraphRAG, AI skill design.
- **Rules**:
  - Scripts must run `run('database/MRST-main/startup.m')` and load modules with `mrstModule add`.
  - Python projects use conda env.
  - Queries must use `python -m tools.mrst_index.search_index` and Graphify (`graphify query`, `graphify path`).
- **Skills to consult**: `wayfinder`, `graphify`, `domain-modeling`.
- **Taxonomy review**: See [taxonomy_review.md](file:///C:/Users/st4014/.gemini/antigravity/brain/106860c6-c794-472b-bb1f-b30fd6cc5d1a/taxonomy_review.md) for the full architectural analysis that produced these tickets.

## Decisions so far

- [ticket-1-taxonomy](file:///D:/MRST-skills/tickets/ticket-1-taxonomy.md): We will implement monolithic, paradigm-based skills (e.g. `mrst-ad-oo`, `mrst-core-procedural`) rather than granular skills to prevent tool overload and respect MRST's compositional architecture.
- [ticket-2-knowledge-integration](file:///D:/MRST-skills/tickets/ticket-2-knowledge-integration.md): AI will use raw CLI commands (`tools.mrst_index` and `graphify`) instructed via standard `SKILL.md` templates rather than wrapper scripts.
- [ticket-3-matlab-runner](file:///D:/MRST-skills/tickets/ticket-3-matlab-runner.md): No MATLAB wrapper script; rely on strict `SKILL.md` prompt instructions to inject `startup.m` and `mrstModule add` to preserve stack trace line numbers.
- [ticket-4-graphify-protocol](file:///D:/MRST-skills/tickets/ticket-4-graphify-protocol.md): Use `AGENTS.md` instructions (`graphify query/path/explain`) and `skill: "graphify"`.
- [ticket-5-create-mrst-gridding](file:///D:/MRST-skills/tickets/ticket-5-create-mrst-gridding.md): Create `mrst-gridding` skill — grid generation, Eclipse data import, PEBI/Voronoi, geometry computation.
- [ticket-6-create-mrst-optimization](file:///D:/MRST-skills/tickets/ticket-6-create-mrst-optimization.md): Create `mrst-optimization` skill — adjoint gradients, NPV maximization, well control optimization.
- [ticket-7-rename-advanced-to-fractured](file:///D:/MRST-skills/tickets/ticket-7-rename-advanced-to-fractured.md): Rename `mrst-advanced-solvers` → `mrst-fractured-reservoirs`, refocus on fracture modeling, extract multiscale.
- [ticket-8-expand-ad-oo-compositional](file:///D:/MRST-skills/tickets/ticket-8-expand-ad-oo-compositional.md): Expand `mrst-ad-oo` with general compositional modeling section (CompositionalMixture, EOS flash).
- [ticket-9-create-mrst-diagnostics](file:///D:/MRST-skills/tickets/ticket-9-create-mrst-diagnostics.md): Create `mrst-diagnostics` skill — flow diagnostics, upscaling, multiscale MsRSB.
- [ticket-10-create-mrst-geomechanics](file:///D:/MRST-skills/tickets/ticket-10-create-mrst-geomechanics.md): Create `mrst-geomechanics` skill — coupled flow-mechanics, poroelasticity, stress/strain.
- [ticket-11-cross-references-and-map](file:///D:/MRST-skills/tickets/ticket-11-cross-references-and-map.md): Added `## Prerequisites` and `## Cross-References` to every SKILL.md, updated wayfinder map.
- [ticket-12-create-mrst-router](file:///D:/MRST-skills/tickets/ticket-12-create-mrst-router.md): Created top-level `mrst` router meta-skill with routing table, dependency DAG, multi-skill recipes, and ambiguity resolution.
- [ticket-13-create-mrst-ad-scripting](file:///D:/MRST-skills/tickets/ticket-13-create-mrst-ad-scripting.md): Created `mrst-ad-scripting` skill for raw procedural AD (`initVariablesADI`) fast prototyping.
- [ticket-14-create-mrst-custom-physics](file:///D:/MRST-skills/tickets/ticket-14-create-mrst-custom-physics.md): Created `mrst-custom-physics` skill for OO developer framework (`StateFunction`, `PhysicalModel`).
- [ticket-15-create-mrst-visualization](file:///D:/MRST-skills/tickets/ticket-15-create-mrst-visualization.md): Created `mrst-visualization` skill for 3D grid slices, well plots, and production curves.
- [ticket-16-create-mrst-debugging](file:///D:/MRST-skills/tickets/ticket-16-create-mrst-debugging.md): Created `mrst-debugging` skill applying strict `diagnosing-bugs` tight-loop principles to MRST.

- [ticket-17-create-mrst-eor](file:///D:/MRST-skills/tickets/ticket-17-create-mrst-eor.md): Created EOR skill (polymer, surfactant) utilizing the `references/` architecture.
- [ticket-18-create-mrst-wells-facilities](file:///D:/MRST-skills/tickets/ticket-18-create-mrst-wells-facilities.md): Created advanced wells skill (limit switching, VFP).
- [ticket-19-create-mrst-testing](file:///D:/MRST-skills/tickets/ticket-19-create-mrst-testing.md): Created automated testing skill using `matlab.unittest` for custom simulators.

## Open tickets

None currently.

## Not yet specified

## Out of scope

<!-- work ruled beyond the destination; closed, never graduates -->
