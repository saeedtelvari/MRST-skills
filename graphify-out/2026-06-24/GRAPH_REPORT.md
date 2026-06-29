# Graph Report - .  (2026-06-24)

## Corpus Check
- cluster-only mode — file stats not available

## Summary
- 1608 nodes · 438 edges · 1397 communities (1394 shown, 3 thin omitted)
- Extraction: 90% EXTRACTED · 10% INFERRED · 0% AMBIGUOUS · INFERRED: 45 edges (avg confidence: 0.9)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `8257df4b`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- [[_COMMUNITY_MEX Multi-Eigenvalue Solvers|MEX Multi-Eigenvalue Solvers]]
- [[_COMMUNITY_MRST Core Concepts & Datasets|MRST Core Concepts & Datasets]]
- [[_COMMUNITY_MEX Matrix Inversion & LSQ|MEX Matrix Inversion & LSQ]]
- [[_COMMUNITY_Symmetric Eigenvalue Computation|Symmetric Eigenvalue Computation]]
- [[_COMMUNITY_MD5 Hash MEX Utility|MD5 Hash MEX Utility]]
- [[_COMMUNITY_MEX 1D Interpolation|MEX 1D Interpolation]]
- [[_COMMUNITY_lMultdiag.m|lMultdiag.m]]
- [[_COMMUNITY_camproj.m|camproj.m]]
- [[_COMMUNITY_displayEndOfDemoMessage.m|displayEndOfDemoMessage.m]]
- [[_COMMUNITY_isprop.m|isprop.m]]
- [[_COMMUNITY_ls.m|ls.m]]
- [[_COMMUNITY_Community 909|Community 909]]
- [[_COMMUNITY_Community 910|Community 910]]
- [[_COMMUNITY_Community 911|Community 911]]
- [[_COMMUNITY_Community 912|Community 912]]
- [[_COMMUNITY_Community 913|Community 913]]

## God Nodes (most connected - your core abstractions)
1. `MRST Dataset Manager` - 20 edges
2. `EVProblem` - 14 edges
3. `EVProblem` - 13 edges
4. `MRST Core Module` - 12 edges
5. `mexFunction()` - 11 edges
6. `BlockBoundaries` - 11 edges
7. `solveEigenProblem()` - 11 edges
8. `Array` - 10 edges
9. `Array` - 10 edges
10. `MEXResult` - 10 edges

## Surprising Connections (you probably didn't know these)
- `BedModel2 - Layered Geological Reservoir Grid (3D)` --references--> `MRST Dataset Manager`  [INFERRED]
  utils/dataset_manager/datasets/img/bedmodel2.png → README.txt
- `BedModels1 - Structured 3D Reservoir Grid with Heterogeneous Properties` --references--> `MRST Dataset Manager`  [INFERRED]
  utils/dataset_manager/datasets/img/bedmodels1.png → README.txt
- `BlackOilPolymer2D - 3D Structured Grid with Injector and Producer Wells` --references--> `MRST Dataset Manager`  [INFERRED]
  utils/dataset_manager/datasets/img/blackoilpolymer2d.png → README.txt
- `CaseB4 - Pair of Faulted Reservoir Grid Models` --references--> `MRST Dataset Manager`  [INFERRED]
  utils/dataset_manager/datasets/img/caseb4.png → README.txt
- `Egg Model - Ensemble Reservoir Model with Injectors and Producers` --references--> `MRST Dataset Manager`  [INFERRED]
  utils/dataset_manager/datasets/img/egg.png → README.txt

## Import Cycles
- None detected.

## Communities (1397 total, 3 thin omitted)

### Community 0 - "MEX Multi-Eigenvalue Solvers"
Cohesion: 0.10
Nodes (25): BlockSizes, EigenResults, idx_type, divergenceJacBlock(), mexFunction(), mwSignedIndex, ProblemCharacteristics, T (+17 more)

### Community 1 - "MRST Core Concepts & Datasets"
Cohesion: 0.09
Nodes (34): MRST Dataset Manager, Norwegian Continental Shelf CO2 Storage Formations, SPE Comparative Solution Project Benchmark Datasets, Automatic Differentiation Library (Sparse/Coupled PDEs), Drive Mechanisms (Wells, BCs), ECLIPSE Input Data Reading/Parsing/Writing, Geological Description (Grids), Grid Factory Routines (+26 more)

### Community 2 - "MEX Matrix Inversion & LSQ"
Cohesion: 0.15
Nodes (25): indexType, args_ok(), extract_block_sizes(), invert_dense_matrices(), mexFunction(), accumulate_size(), args_ok(), create_lls_structure() (+17 more)

### Community 3 - "Symmetric Eigenvalue Computation"
Cohesion: 0.12
Nodes (17): BlockID, size_t, SizeType, SizeVector, args_ok(), BlockBoundaries, construct(), EVProblem (+9 more)

### Community 4 - "MD5 Hash MEX Utility"
Cohesion: 0.56
Nodes (8): md5_byte_t, md5_state_t, md5_append(), md5_append_array(), md5_finish(), md5_init(), md5_process(), mexFunction()

### Community 5 - "MEX 1D Interpolation"
Cohesion: 0.43
Nodes (6): mexFunction(), binary_search(), interp1_binary_search(), interp1_binned_search(), interp1_binning(), interp1_equal_width_search()

### Community 7 - "lMultdiag.m"
Cohesion: 0.67
Nodes (3): diagMult(), mexFunction(), V_type

### Community 10 - "isprop.m"
Cohesion: 0.83
Nodes (3): faceAverage(), inputCheck(), mexFunction()

### Community 11 - "ls.m"
Cohesion: 0.83
Nodes (3): faceGradient(), inputCheck(), mexFunction()

### Community 909 - "Community 909"
Cohesion: 0.19
Nodes (15): Black-Oil Equations (Multiphase Flow), ad-blackoil Module, Fully Implicit Solver, SPE Benchmark Cases (SPE1, SPE9), ad-core Module (AD-OO Framework), Automatic Differentiation (AD-OO), ad-eor Module (Enhanced Oil Recovery), Enhanced Oil Recovery (EOR) (+7 more)

### Community 910 - "Community 910"
Cohesion: 0.24
Nodes (10): logic_type, copyElements(), inputCheck(), mexFunction(), upwindJac(), upwindJacMain(), zeroElements(), inputCheck() (+2 more)

### Community 911 - "Community 911"
Cohesion: 0.43
Nodes (6): index_t, copyFaceData(), divergenceJac(), divergenceJacMain(), inputCheck(), mexFunction()

### Community 912 - "Community 912"
Cohesion: 0.47
Nodes (3): dimensionCheck(), inputCheck(), mexFunction()

## Knowledge Gaps
- **27 isolated node(s):** `x_`, `A_`, `E_`, `C_`, `max_` (+22 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **3 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `mexFunction()` connect `Community 913` to `MEX Matrix Inversion & LSQ`?**
  _High betweenness centrality (0.004) - this node is a cross-community bridge._
- **Why does `mexFunction()` connect `Community 911` to `MEX Matrix Inversion & LSQ`?**
  _High betweenness centrality (0.003) - this node is a cross-community bridge._
- **Why does `mexFunction()` connect `Symmetric Eigenvalue Computation` to `MEX Matrix Inversion & LSQ`?**
  _High betweenness centrality (0.003) - this node is a cross-community bridge._
- **Are the 20 inferred relationships involving `MRST Dataset Manager` (e.g. with `MRST Core Module` and `BedModel2 - Layered Geological Reservoir Grid (3D)`) actually correct?**
  _`MRST Dataset Manager` has 20 INFERRED edges - model-reasoned connections that need verification._
- **What connects `x_`, `A_`, `E_` to the rest of the system?**
  _27 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `MEX Multi-Eigenvalue Solvers` be split into smaller, more focused modules?**
  _Cohesion score 0.09745293466223699 - nodes in this community are weakly interconnected._
- **Should `MRST Core Concepts & Datasets` be split into smaller, more focused modules?**
  _Cohesion score 0.0873440285204991 - nodes in this community are weakly interconnected._