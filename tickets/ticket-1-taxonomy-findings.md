# MRST Skill Taxonomy Findings (Ticket 1)

**Recommendation:** Implement a few monolithic, paradigm-based skills (e.g., `mrst-ad-oo`, `mrst-core-procedural`) rather than granular, per-module skills.

## Rationale

1. **Shared Foundational "God Nodes":** 
   GraphRAG analysis (`graphify-out/GRAPH_REPORT.md`) of the MRST codebase shows that out of ~4,900 nodes across 26 modules, core abstractions like `TensorComp`, `BasicAD`, `Options`, and `Graph` are central hubs. Granular skills would either heavily duplicate knowledge of these foundations or force agents into complex, multi-skill dependencies.

2. **Heavy Compositionality of Modules:** 
   Many modules don't introduce new foundational paradigms. For instance, the `visualization` module (204 `.m` files) contributes 0 new code abstractions—it relies entirely on `core` and `autodiff` to render results. 

3. **Core Paradigms Dictate Workflow:** 
   The MRST knowledge database handoff specifically outlines two macro-paradigms: "procedural/incompressible flow" and "AD-OO/fully implicit simulation". Skills should map to these architectural fault lines. If an agent is writing an AD-based simulation, it needs a cohesive guide on setting up `BasicAD` and `simulateScheduleAD`, which a monolithic `mrst-ad-oo` skill provides perfectly.

4. **Agent Effectiveness and Tool Overload:** 
   Providing 26 distinct module skills would overwhelm agent reasoning and tool selection. A monolithic skill bundles exactly the end-to-end knowledge needed for a specific class of simulation workflows, minimizing context switching.
