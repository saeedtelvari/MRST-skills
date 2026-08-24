# MRST Gridding: Best Practices & Framework Invariants

This document focuses on the robust, timeless structural invariants and framework traps of MRST gridding. It is not an exhaustive API reference, but rather a guide to the fundamental structural laws of the MRST grid system.

## 1. `computeGeometry` Lifecycle Constraints

The `computeGeometry` function is the core geometry engine of MRST. It computes cell volumes, centroids, face normals, and areas. It is **mandatory** for discretization schemes.

**The Golden Rule:**
You **must** call `computeGeometry(G)` immediately after any structural modification to the grid `G`.

**Traps & Invariants:**
*   **Stale Geometry Trap:** Modifying coordinates (`G.nodes.coords`), adding/removing cells, or coarsening without subsequently calling `computeGeometry` will result in silently incorrect physics. The simulator does not automatically check if `G.cells.volumes` or `G.faces.normals` match the current node coordinates.
*   **Initialization:** Every fresh grid creation (`cartGrid`, `tensorGrid`, `initEclipseGrid`, `pebiGrid2D`, etc.) must be followed by `G = computeGeometry(G)`. 
*   **Mutation:** If you extract a subgrid (e.g., `extractSubgrid`), you must re-run `computeGeometry` (or rely on `extractSubgrid` to do it if specified, but always verify).

## 2. Unstructured Topology Invariants: `faces.neighbors` vs `cells.faces`

MRST handles both structured (Cartesian/Corner-Point) and fully unstructured grids (PEBI/Voronoi) using a unified, unstructured topological format. 

**The Golden Rules of Topology:**

*   **`G.faces.neighbors` (Face-to-Cell mapping):**
    *   This is an $N_f \times 2$ matrix, where $N_f$ is the total number of faces.
    *   Each row represents a face. The two columns contain the indices of the cells sharing that face.
    *   **Invariant:** For internal faces, both columns contain valid cell indices ($> 0$). For boundary faces, one of the columns is exactly `0` (indicating the "outside" of the domain).
    *   **Normal Vector Convention:** The face normal (`G.faces.normals`) is **area-weighted** (its magnitude equals the face area) and ALWAYS points from the cell in column 1 towards the cell in column 2. 

*   **`G.cells.faces` (Cell-to-Face mapping):**
    *   This maps cells to their constituent faces using a compressed sparse row (CSR) or similar pointer structure.
    *   `G.cells.facePos` (length $N_c + 1$): Pointers into `G.cells.faces`. The face indices for cell `i` are found in the first column: `G.cells.faces(G.cells.facePos(i) : G.cells.facePos(i+1)-1, 1)`.
    *   **Trap:** Do not assume a fixed number of faces per cell (e.g., 6 for a hexahedron). Unstructured grids (and structurally faulted corner-point grids) can have an arbitrary number of faces per cell. Always use the `facePos` pointers.

## 3. Internal SI Unit Invariants (`centi*poise`, `darcy`)

MRST strictly enforces the use of SI units internally. However, reservoir engineering often uses mixed field units (e.g., milliDarcy, centipoise, days, bars). 

**The Golden Rule of Units:**
**All** inputs to MRST functions must be in pure SI units (meters, seconds, kilograms, Pascals). Use MRST's built-in unit conversion constants to scale field units to SI.

**Invariants & Framework Traps:**
*   **Built-in Constants:** MRST provides constants like `milli`, `centi`, `darcy`, `poise`, `day`, `bar`, `atm`. These are conversion factors *to* SI.
    *   Example: `100 * milli * darcy` evaluates to the SI equivalent of 100 mD in $m^2$.
    *   Example: `2 * centi * poise` evaluates to the SI equivalent of 2 cP in $Pa \cdot s$.
*   **The Trap of Assumed Units:** Never pass `100` thinking it means 100 mD. It means 100 $m^2$ (a massive, unphysical permeability). You must write `100 * milli * darcy`.
*   **Eclipse Deck Import:** The function `convertDeckUnits(deck)` is mandatory after `readEclipseDeck`. It converts the raw numbers in the `.DATA` file (which might be in `METRIC`, `FIELD`, or `LAB` units) into internal SI units. If you skip this, your simulation will run with unscaled, physically meaningless numbers.
