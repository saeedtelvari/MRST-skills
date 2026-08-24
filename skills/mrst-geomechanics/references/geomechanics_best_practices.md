# Geomechanics Best Practices: Invariants & Framework Traps

This reference outlines the structural invariants and common pitfalls in MRST's geomechanics modules (`ad-mechanics`, `fvbiot`). It strictly avoids textbook math and API recitations, focusing instead on framework architectural truths.

## 1. Grid Paradigms: Staggered vs Collocated

MRST geomechanics supports two fundamentally different grid paradigms depending on the module:

1. **Virtual Element Method (`ad-mechanics`) - Staggered Grid**:
   - **Flow Variables (Pressure, Saturation)**: Live on **cell centers** (`[Nc x 1]`).
   - **Mechanical Variables (Displacement)**: Live on **grid nodes** (`[Nn x dim]`).
2. **Finite Volume Method (`fvbiot`) - Collocated Grid**:
   - Both **Flow** and **Mechanical Variables (Displacement)** live on **cell centers** (`[Nc x dim]`).

### Crucial Traps
- **Index Mismatch in `ad-mechanics`**: A common error is applying mechanical boundary conditions using cell indices. 
  - `el_bc.disp_bc.nodes` requires **node indices** (`G.nodes.coords`).
  - Flow boundary conditions and wells require **cell indices** (`G.cells.centroids`).
- **Augmented Grid Assumption**: Standard MRST grids lack sufficient topological data for VEM mechanics. While you might see `createAugmentedGrid(G)` in literature, **do not** call it manually before initialization. The `MechanicModel` constructor automatically checks `G.type` and creates the augmented grid if necessary.

## 2. Biot Coupling Structural Paradigms

Coupling mechanics and flow requires mapping between domains: Pressure changes exert forces on mechanics, and displacements (strain) alter cell pore volumes.

### Coupling Strategies
1. **Fully Coupled (`MechFluidModel`)**:
   - Assembles a monolithic Jacobian containing both `[displacement, pressure]` (or equivalent DOFs).
   - **Trap**: The system matrix mixes extremely disparate scales (Young's modulus in GPa vs. pressure gradients). This can lead to ill-conditioned matrices if not scaled correctly.

2. **Fixed-Stress Split (`MechFluidFixedStressSplitModel`)**:
   - Solves flow and mechanics sequentially. 
   - **Invariant**: The flow problem is solved assuming constant total stress, followed by the mechanics problem using the new pressure field.
   - **Why use it?** It is unconditionally stable and significantly reduces peak memory usage compared to the monolithic approach. It is the gold standard for large-scale MRST geomechanics.

### State Initialization Traps
- **The `xd` Vector**: In AD mechanics, active mechanical degrees of freedom (DOFs) are stored in the state vector as `xd`.
- **Derived Quantities**: During the standard simulation loop, `updateState` automatically calls `addDerivedQuantities` to evaluate stresses, strains, and `vdiv`. The state returned by the solver will already contain these fields. You only need to call this manually if you explicitly alter the primary `xd` vector outside the solver.
