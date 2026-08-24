# Linear Solvers Best Practices in MRST

This document focuses on the structural configurations and framework invariants for linear solvers in MRST, specifically regarding the CPR (Constrained Pressure Residual) preconditioner and block-ILU structures for multiphase systems.

## CPR Preconditioner Structural Configurations

The CPR preconditioner is a two-stage method that decouples the pressure and transport equations. When configuring CPR in MRST, maintain these structural invariants:

1. **Pressure Extraction Coupling**:
   - The CPR solver structurally expects a two-stage approach. The primary stage extracts a scalar pressure equation (the "elliptic" part) from the coupled multiphase system. 
   - **Invariant**: The pressure system size must strictly correspond to the number of active cells in the grid. If block or local grid refinement (LGR) is used, the mapping between the global linear system and the extracted pressure subsystem must be rigorously preserved.

2. **Elliptic Solver Delegation**:
   - The extracted pressure equation is typically symmetric positive definite (SPD) or close to it. It is structurally delegated to an algebraic multigrid (AMG) solver. 
   - **Trap**: Using generic GMRES or block-ILU for the extracted pressure system defeats the purpose of CPR. The sub-solver for the pressure part must be optimal for elliptic problems (e.g., AGMG, BoomerAMG).
   - **Invariant**: The inner elliptic solver should have looser tolerances than the outer GMRES solver. Over-solving the pressure equation in the preconditioner wastes computational effort without improving outer convergence.

3. **System Ordering and Sub-blocks**:
   - CPR algorithms typically require the Jacobian matrix to have a specific block structure, often ordered with pressure equations first or grouped by cell.
   - **Trap**: MRST's AD framework dynamic ordering can sometimes obfuscate the primary pressure variable. Ensure the CPR configuration correctly identifies the pressure variable index among the coupled unknowns (e.g., pressure, saturations, dissolved gas).

## Block-ILU Structures for Multiphase Systems

In multiphase systems, the equations at each grid cell are strongly coupled (e.g., pressure, saturations).

1. **Cell-Wise Block Structure and Ordering**:
   - **Invariant**: The equations in MRST are typically assembled in an equation-major (variable-major) ordering by default. While block-ILU (or cell-major point-ILU) is the ideal structural baseline to capture tight coupling between variables in the same cell, standard point-ILU(0) on the equation-major system is natively used in MRST's `CPRSolverAD`.
   - For optimal performance with compiled solvers (like AMGCL), the system is explicitly reordered to a cell-major ordering (e.g., via `getCellMajorReordering`) before applying the preconditioner.

2. **Coupling with CPR (The Second Stage)**:
   - In CPR, after the pressure correction is applied, the full coupled system (or the remaining transport part) is preconditioned. 
   - **Invariant**: The second stage of CPR uses an ILU(0) approach on the full system. In MRST's native `CPRSolverAD`, this is implemented as a global point-ILU(0) (`ilu(A, struct('type', 'nofill'))`).
   - While specialized external solvers (like AMGCL) may employ block-ILU to better handle hyperbolic/transport components, MRST demonstrates that a standard global point-ILU is sufficient for many configurations, contradicting the assumption that it inevitably leads to stagnation.

3. **Memory and Sparsity Pattern Preservation**:
   - The sparsity pattern of the Jacobian in AD-OO MRST remains fixed during Newton iterations for a given time step, provided the grid and active connections don't change.
   - **Invariant**: For compiled or external solvers (like AMGCL), the preconditioner's setup phase (symbolic factorization) should be allocated once and reused across Newton iterations (e.g., using `solver.reuseMode`).
   - **Trap**: While reusing symbolic factorization is an HPC best practice, MATLAB's built-in `ilu` function does not natively support separating symbolic and numeric factorization. Consequently, native MATLAB solvers like `CPRSolverAD` must recompute the entire ILU factorization for every Newton iteration.
