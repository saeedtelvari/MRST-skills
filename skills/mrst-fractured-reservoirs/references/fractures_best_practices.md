# Fractured Reservoirs Best Practices

This document outlines structural invariants and framework traps when modeling naturally fractured reservoirs using MRST, specifically focusing on Non-Neighboring Connections (NNCs) and Dual-Porosity (DPDP) coupling.

## Non-Neighboring Connections (NNCs) Structural Invariants

1. **Topology Augmentation**: NNCs break standard topological assumptions. They add off-diagonal terms to the discrete flux operators. The primary invariant is that an NNC structure must consistently map `cells` to `cells` with associated transmissibilities, bypassing standard face-based topology.
2. **Global Indexing Trap**: NNC pairs are defined using global cell indices. A common trap is failing to update NNCs when the global grid is modified (e.g., cell refinement, removal of inactive cells). NNC indices *must* be remapped to the new global cell indices.
3. **Undirected Edges Constraint**: Standard MRST TPFA operators treat all connections as undirected edges. Each NNC pair must be defined exactly once with a single scalar transmissibility `T`. Providing duplicate directed pairs (e.g., `[i, j]` and `[j, i]`) or attempting to define one-way NNCs is unsupported and will result in duplicated parallel interfaces, not directional flow.
4. **Volume Consistency**: Embedded fractures via NNCs effectively add control volumes to the domain without altering the matrix geometry. Ensure the total pore volume (matrix + fracture) accurately represents the physical system, as pEDFM might double-count intersection volumes if not explicitly handled.

## Dual-Porosity (DPDP) Matrix-Fracture Coupling Paradigms

1. **State Variable Separation**: Unlike some commercial simulators, the standard MRST `dual-porosity` module does *not* augment the grid to `2N` cells. Instead, it maintains `G.cells.num = N` and introduces distinct state fields for the matrix domain (e.g., `pressure_matrix`, `sm`), while the fracture domain uses the standard state fields (`pressure`, `s`).
2. **Coupling Transmissibility**: The shape factor dictates the transfer rate between matrix and fracture. The structural invariant is that this transfer acts as an internal source/sink term per spatial block, directly coupling the fracture and matrix equations at the same local cell index `i`.
3. **Initialization Trap**: A frequent framework trap is attempting to initialize pressures or saturations with an augmented `2N` array. Because the grid size remains `N`, initial state vectors must have size `N`. Users must explicitly initialize the required matrix fields (e.g., `state.pressure_matrix = state.pressure` and `state.sm = state.s`) alongside the fracture fields.
4. **Well Trajectory Intersections**: In the `dual-porosity` module, well equations are automatically assembled against the primary (fracture) variables. Since there is no augmented `2N` grid, well completion indices map to the standard `1` to `N` cell indices. Direct matrix stimulation requires custom well equation modifications.
