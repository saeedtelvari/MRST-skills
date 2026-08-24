# Diagnostics Best Practices: Flow Diagnostics, Upscaling & Multiscale

This document outlines structural invariants and framework traps when using MRST's flow diagnostics, upscaling, and multiscale methods. It focuses on architectural rules rather than exhaustive API references.

## 1. Flow Diagnostics: TOF and Tracer Structural Invariants

### Time-of-Flight (TOF) Computation

**Invariant**: `computeTOFandTracer` solves a *steady-state* transport problem. It requires a converged pressure/flux field from `incompTPFA` (or equivalent). The TOF values are meaningful only if the underlying flow field is physically reasonable.

**Framework Traps**:
- **Stale Flux Field**: If you modify rock properties or well configurations after solving pressure but before computing TOF, the flux field will not reflect the changes. Always re-solve pressure before computing diagnostics.
- **Disconnected Cells**: Cells with zero transmissibility to all neighbors (e.g., inactive cells, sealing faults) will have `TOF = Inf`. This is correct behavior, not a bug. Filter these before computing sweep efficiency.
- **Well Specification Mismatch**: `computeTOFandTracer` expects the same well structure `W` used in the pressure solve. Passing a different well configuration will produce nonsensical tracer partitions.

### Tracer Partitions

**Invariant**: Forward tracers partition cells by controlling injector; backward tracers partition by draining producer. The partition is a soft assignment (concentration values between 0 and 1 per well) for steady-state problems.

**Framework Trap**: Do not treat tracer concentrations as saturations. They represent volumetric influence fractions, not fluid phase fractions.

## 2. Upscaling Invariants

### `upscalePerm` vs `upscaleTrans`

**Invariant**: These two functions solve fundamentally different problems:
- `upscalePerm`: Computes an **effective permeability tensor** for each coarse block by solving local flow problems with specified boundary conditions.
- `upscaleTrans`: Computes **coarse-scale transmissibilities** directly between coarse block pairs.

**Framework Traps**:
- **Boundary Condition Sensitivity**: `upscalePerm` results depend strongly on the choice of boundary conditions (sealed, linear pressure, periodic). The default (sealed sides, pressure drop across the block) can significantly underestimate cross-flow in heterogeneous media.
- **Coarse Grid Generation Order**: You must call `generateCoarseGrid(G, partition)` *after* partitioning. The coarse grid object `CG` contains the block-to-cell mapping needed by both upscaling functions.
- **Validation Gap**: Always compare fine-scale and coarse-scale solutions on a representative test case. Upscaling can introduce large errors in channelized or highly heterogeneous reservoirs.

## 3. Multiscale MsRSB Invariants

### Matrix Assembly

**Invariant**: The function `getIncomp1PhMatrix` assembles the single-phase incompressible system matrix from grid `G` and transmissibility `T`. This matrix is the algebraic representation of the discrete pressure equation.
- **Signature Flexibility**: Accepts either 2 arguments `A = getIncomp1PhMatrix(G, T)` (which internally defaults `state` and single-phase `fluid`) or 4 arguments `A = getIncomp1PhMatrix(G, T, state, fluid)`.

**Framework Traps**:
- **Transmissibility Source**: `T` must come from `computeTrans(G, rock)` using the *fine-scale* rock properties. Do not pass upscaled transmissibilities.
- **Matrix Size**: The matrix is `G.cells.num × G.cells.num`. For grids with >100K cells, direct factorization of this matrix is the bottleneck that MsRSB is designed to avoid.

### Basis Function Computation

**Invariant**: `getMultiscaleBasis(CG, A, 'type', 'msrsb')` computes restricted smoothed basis functions. The basis functions approximate the fine-scale solution within each coarse block.

**Framework Trap**: The coarse grid `CG` must be topologically valid — every coarse block must be connected (no disconnected sub-regions within a single block). Use `compressPartition` and `processPartition` to clean up partitions before generating the coarse grid.
