# Graph Report - database/MRST-main  (2026-06-24)

## Corpus Check
- 2243 files · ~1,261,934 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 2683 nodes · 1139 edges · 2183 communities (2179 shown, 4 thin omitted)
- Extraction: 92% EXTRACTED · 8% INFERRED · 0% AMBIGUOUS · INFERRED: 89 edges (avg confidence: 0.81)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_MEX Mixed Operator Functions|MEX Mixed Operator Functions]]
- [[_COMMUNITY_MEX Sparse Array Types|MEX Sparse Array Types]]
- [[_COMMUNITY_C++ Boost  STL Types|C++ Boost / STL Types]]
- [[_COMMUNITY_Symmetric Eigenvalue Problem|Symmetric Eigenvalue Problem]]
- [[_COMMUNITY_AD Module Documentation|AD Module Documentation]]
- [[_COMMUNITY_Multi-Eigenvalue Solver|Multi-Eigenvalue Solver]]
- [[_COMMUNITY_MsRSB Accelerated Basis Solver|MsRSB Accelerated Basis Solver]]
- [[_COMMUNITY_Multiscale Grid Coarsening + DFM Docs|Multiscale Grid Coarsening + DFM Docs]]
- [[_COMMUNITY_MEX Block Matrix Utilities|MEX Block Matrix Utilities]]
- [[_COMMUNITY_BasicAD Autodiff Core|BasicAD Autodiff Core]]
- [[_COMMUNITY_MEX Function Interface|MEX Function Interface]]
- [[_COMMUNITY_Upwind Discretization Operators|Upwind Discretization Operators]]
- [[_COMMUNITY_MD5 Checksum Utility|MD5 Checksum Utility]]
- [[_COMMUNITY_DFM Simulation Visualization|DFM Simulation Visualization]]
- [[_COMMUNITY_1D Interpolation MEX|1D Interpolation MEX]]
- [[_COMMUNITY_Discrete Divergence Operator|Discrete Divergence Operator]]
- [[_COMMUNITY_Face Average Operators|Face Average Operators]]
- [[_COMMUNITY_Two-Point Gradient Operator|Two-Point Gradient Operator]]
- [[_COMMUNITY_Relative Permeability Upscaling Data|Relative Permeability Upscaling Data]]
- [[_COMMUNITY_Black-Oil and SPE Benchmark Datasets|Black-Oil and SPE Benchmark Datasets]]
- [[_COMMUNITY_CO2 Storage Datasets|CO2 Storage Datasets]]
- [[_COMMUNITY_Geological Heterogeneity Test Images|Geological Heterogeneity Test Images]]
- [[_COMMUNITY_Geological Reservoir Models|Geological Reservoir Models]]
- [[_COMMUNITY_Diagonal Multiply MEX|Diagonal Multiply MEX]]
- [[_COMMUNITY_Diagonal Sparse Jacobian MEX|Diagonal Sparse Jacobian MEX]]
- [[_COMMUNITY_Group 25|Group 25]]
- [[_COMMUNITY_Group 26|Group 26]]
- [[_COMMUNITY_Group 27|Group 27]]
- [[_COMMUNITY_Group 28|Group 28]]
- [[_COMMUNITY_Group 29|Group 29]]

## God Nodes (most connected - your core abstractions)
1. `TensorComp` - 29 edges
2. `Graph` - 21 edges
3. `Options` - 21 edges
4. `amg_opts` - 17 edges
5. `BasicAD` - 17 edges
6. `EVProblem` - 14 edges
7. `solver_opts` - 14 edges
8. `Discrete Fracture Matrix (DFM) Module for MRST` - 14 edges
9. `EVProblem` - 13 edges
10. `solve_cpr()` - 12 edges

## Surprising Connections (you probably didn't know these)
- `Automatic Differentiation Library (Core)` --semantically_similar_to--> `AD-Core Module (AD-OO Framework)`  [INFERRED] [semantically similar]
  core/README.txt → autodiff/ad-core/README.txt
- `Pressure-Transport Operator Splitting` --semantically_similar_to--> `solveMSFV_TPFA_Incomp_DFM`  [INFERRED] [semantically similar]
  autodiff/sequential/README.txt → solvers/dfm/msfv_dfm/examples/html/dfmMsFV.html
- `Grid Coarsening by Amalgamation` --conceptually_related_to--> `Conforming Grid for Fracture Discretization`  [INFERRED]
  multiscale/agglom/INFO.txt → solvers/dfm/Implementation_Notes.pdf
- `mexFunction()` --calls--> `interp1_equal_width_search()`  [INFERRED]
  core/utils/mex/mexInterp1.cpp → core/utils/mex/mexInterpolation.cpp
- `Discrete Fracture Model (DFM) Module` --semantically_similar_to--> `EDFM Alternative Codes - Uniform Scaling Factor`  [INFERRED] [semantically similar]
  solvers/dfm/msfv_dfm/examples/html/dfmMsFV.html → solvers/hfm/edfm-hw/Fracture-Matrix Intersection Proprocessing/NNC Processing/Alternative EDFM codes/Readme.txt

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **AD-OO Module Inheritance Chain (ad-core -> ad-blackoil -> ad-eor)** — ad_core_readme_ad_core, ad_blackoil_readme_ad_blackoil, ad_eor_readme_ad_eor [EXTRACTED 1.00]
- **AD Framework for Optimization (ad-core, ad-blackoil, optimization)** — ad_core_readme_ad_core, ad_blackoil_readme_ad_blackoil, optimization_readme_optimization [EXTRACTED 1.00]
- **DFM-MsFV Pressure-Transport Solver Workflow** — dfmmsfv_html_solvemsfv_tpfa_incomp_dfm, dfmmsfv_html_implicit_transport_dfm, dfmmsfv_html_grid_hierarchy [EXTRACTED 1.00]
- **Fluvial Bed Reservoir Model Dataset Family** — img_bedmodel2, img_bedmodels1 [INFERRED 0.95]
- **Norwegian CO2 Storage and Sequestration Datasets** — img_co2atlas, img_co2atlasbarentssea, img_co2atlasnorwegiansea, img_sleipner, img_sleipnerplumes, img_johansen [INFERRED 0.95]
- **MRST Reservoir Simulation Benchmark and Test Datasets** — img_bedmodel2, img_bedmodels1, img_blackoilpolymer2d, img_caseb4, img_egg, img_norne, img_saigup, img_spe1, img_spe3, img_spe9, img_spe10 [INFERRED 0.85]
- **IGEMS Geological Grid and Surface Dataset Family** — img_igemsgrids, img_igemssurfaces [EXTRACTED 1.00]
- **SPE Comparative Solution Project Benchmark Datasets** — img_spe1, img_spe3, img_spe9, img_spe10 [INFERRED 0.95]
- **DFM Fracture Network Mesh Representation (Fine Triangular Grid with Explicit Fractures)** — dfm_fracturesimillustration, html_dfmmsfv_01 [INFERRED 0.85]
- **MSFV-DFM Pressure and Saturation Field Comparison (Reference vs Inexact/MSFV)** — msfv_dfm_examples_msfv_dfm, html_dfmmsfv_02, html_dfmmsfv_04 [INFERRED 0.95]
- **DFM MsFV Sequential Example Workflow (Steps 01-06)** — html_dfmmsfv_01, html_dfmmsfv_02, html_dfmmsfv_03, html_dfmmsfv_04, html_dfmmsfv_05, html_dfmmsfv_06 [EXTRACTED 1.00]
- **Conforming vs Non-Conforming Coarse Grid Accuracy and Convergence Study** — html_dfmmsfv_03, html_dfmmsfv_05, html_dfmmsfv_06 [INFERRED 0.95]
- **DFM Control Volume Discretization Using TPFA and MPFA** — dfm_impl_notes_control_volume_discretization, dfm_impl_notes_tpfa, dfm_impl_notes_mpfa [EXTRACTED 1.00]
- **Fracture Gridding: Conforming Grid, Lower-Dimensional Representation, and Tagging** — dfm_impl_notes_conforming_grid, dfm_impl_notes_lower_dimensional_fracture_representation, dfm_impl_notes_fracture_tags [INFERRED 0.85]
- **Rock Upscaling Example: Sw, Krw, Kro, J-function Data** — examples_rockdata_water_saturation, examples_rockdata_krw, examples_rockdata_kro [EXTRACTED 1.00]
- **Geological Heterogeneity Inputs for Multiscale Solvers** — data_facies1, data_facies2, data_facies3, examples_perm_mono, examples_inclusions [INFERRED 0.85]
- **Agglomeration Example Facies Dataset** — data_facies1, data_facies2, data_facies3 [EXTRACTED 1.00]
- **Multiscale Solver Heterogeneous Test Cases** — examples_perm_mono, examples_inclusions [INFERRED 0.85]

## Communities (2183 total, 4 thin omitted)

### Community 0 - "MEX Mixed Operator Functions"
Cohesion: 0.06
Nodes (60): getd(), mexFunction(), Edge, IDX, IdxFunc, IVec, map, METIS_NOPTIONS (+52 more)

### Community 1 - "MEX Sparse Array Types"
Cohesion: 0.07
Nodes (61): array, ArrayDimensions, CellArray, CharArray, dot2(), length(), mexFunction(), sqr() (+53 more)

### Community 2 - "C++ Boost / STL Types"
Cohesion: 0.05
Nodes (66): matrix_type, mwIndex, ptree, rhs_type, shared_ptr, tuple, mexFunction(), solve_block_system() (+58 more)

### Community 3 - "Symmetric Eigenvalue Problem"
Cohesion: 0.10
Nodes (20): BlockID, mwSignedIndex, size_t, SizeType, SizeVector, args_ok(), Array, x_ (+12 more)

### Community 4 - "AD Module Documentation"
Cohesion: 0.06
Nodes (33): AD Black-Oil Module, Black-Oil Flow Equations, SPE Benchmark Cases (SPE1, SPE9), AD-Core Module (AD-OO Framework), AD Enhanced Oil Recovery Module, Polymer Simulation (EOR), Surfactant Simulation (EOR), AD Properties Module (+25 more)

### Community 5 - "Multi-Eigenvalue Solver"
Cohesion: 0.12
Nodes (17): BlockSizes, EigenResults, ProblemCharacteristics, args_ok(), Array, x_, blockSizes(), EVProblem (+9 more)

### Community 6 - "MsRSB Accelerated Basis Solver"
Cohesion: 0.24
Nodes (19): computeBasis(), getBasis(), openFlatFile(), readBasisOperator(), readConnMatrix(), readInfo(), renormalize(), setupCoarseMapping() (+11 more)

### Community 7 - "Multiscale Grid Coarsening + DFM Docs"
Cohesion: 0.15
Nodes (19): Agglomeration-Based Grid Coarsening Module, Grid Coarsening by Amalgamation, Conforming Grid for Fracture Discretization, Control Volume Discretization of Fractured Media, Discrete Fracture Matrix (DFM) Module for MRST, MRST Core Files Modified with _DFM Suffix, Fracture Face and Cell Tagging System (G.faces.tags, G.cells.tags), Lower-Dimensional Fracture Representation (+11 more)

### Community 8 - "MEX Block Matrix Utilities"
Cohesion: 0.23
Nodes (14): args_ok(), extract_block_sizes(), invert_dense_matrices(), mexFunction(), accumulate_size(), args_ok(), create_lls_structure(), destroy_lls_structure() (+6 more)

### Community 9 - "BasicAD Autodiff Core"
Cohesion: 0.17
Nodes (7): BasicAD, deriv_ixs_, deriv_vals_, num_derivs_, operator+(), write(), ostream

### Community 10 - "MEX Function Interface"
Cohesion: 0.24
Nodes (6): ArgumentList, check_adi(), mex::Function, MexFunction, MexFunction, matlabPtr

### Community 11 - "Upwind Discretization Operators"
Cohesion: 0.24
Nodes (10): logic_type, copyElements(), inputCheck(), mexFunction(), upwindJac(), upwindJacMain(), zeroElements(), inputCheck() (+2 more)

### Community 12 - "MD5 Checksum Utility"
Cohesion: 0.56
Nodes (8): md5_byte_t, md5_state_t, md5_append(), md5_append_array(), md5_finish(), md5_init(), md5_process(), mexFunction()

### Community 13 - "DFM Simulation Visualization"
Cohesion: 0.31
Nodes (9): Fracture Simulation Illustration (DFM Triangular Mesh Pressure Field), DFM MsFV Example - Convergence Plot (Concentration vs PVI), DFM MsFV Example Step 1 - Fracture Network on Fine Triangular Mesh, DFM MsFV Example Step 2 - Saturation and Pressure Reference vs MSFV Comparison, DFM MsFV Example Step 3 - Coarse Grid Partitioning on Triangular Mesh, DFM MsFV Example Step 4 - Saturation and Pressure Reference vs MSFV (Later Timestep), DFM MsFV Example Step 5 - Concentration vs PVI: Reference vs Conforming vs Non-Conforming Grid, DFM MsFV Example Step 6 - GMRES Residuals: Conforming vs Non-Conforming Coarse Grid (+1 more)

### Community 14 - "1D Interpolation MEX"
Cohesion: 0.43
Nodes (6): mexFunction(), binary_search(), interp1_binary_search(), interp1_binned_search(), interp1_binning(), interp1_equal_width_search()

### Community 15 - "Discrete Divergence Operator"
Cohesion: 0.43
Nodes (6): index_t, copyFaceData(), divergenceJac(), divergenceJacMain(), inputCheck(), mexFunction()

### Community 16 - "Face Average Operators"
Cohesion: 0.47
Nodes (3): dimensionCheck(), inputCheck(), mexFunction()

### Community 18 - "Relative Permeability Upscaling Data"
Cohesion: 0.40
Nodes (6): Leverett J-Function (Capillary Pressure Correlation), Oil Relative Permeability (Kro), Water Relative Permeability (Krw), Relative Permeability and J-Function Data Table, Water Saturation (Sw), Rock Dataset Index File (rocklist.txt)

### Community 19 - "Black-Oil and SPE Benchmark Datasets"
Cohesion: 0.53
Nodes (6): Black Oil Polymer 2D - Injection/Production Well Simulation, Case B4 - Dual-Block Faulted Reservoir Grid, SPE1 - SPE Comparative Solution Project Case 1 Black Oil Benchmark, SPE10 - SPE 10th Comparative Solution Project Heterogeneous Permeability Benchmark, SPE3 - SPE Comparative Solution Project Case 3 Gas Injection Benchmark, SPE9 - SPE 9th Comparative Solution Project Multi-Well Black Oil Benchmark

### Community 20 - "CO2 Storage Datasets"
Cohesion: 0.47
Nodes (6): CO2 Atlas - Norwegian Continental Shelf Aquifer Formations Map, CO2 Atlas Barents Sea - Norwegian CO2 Storage Aquifer Outlines, CO2 Atlas Norwegian Sea - Norwegian CO2 Storage Formation Outlines, Johansen Formation - Norwegian North Sea CO2 Storage Saline Aquifer, Sleipner CO2 - North Sea CO2 Injection Caprock Depth Surface, Sleipner CO2 Plumes - Time-Series CO2 Plume Thickness Observations 1999-2010

### Community 21 - "Geological Heterogeneity Test Images"
Cohesion: 0.80
Nodes (5): Facies Map 1 (Agglomeration Example Data), Facies Map 2 (Agglomeration Example Data), Multi-Facies Distribution Map (Agglomeration Example Data), Circular Inclusions Heterogeneity Map (MsRSB Example), Permeability Field for Monotone MsFVM Example

### Community 22 - "Geological Reservoir Models"
Cohesion: 0.40
Nodes (5): BedModel2 - Layered Fluvial Bed Reservoir Model, BedModels1 - Structured Grid Bed Geometry Model, Egg Model - Stochastic Channelized Reservoir with Injector/Producer Wells, Norne Field - Full-Field Norwegian Sea Oil Reservoir with Wells, SAIGUP - Geostatistical Sensitivity Study Shallow Marine Reservoir

### Community 23 - "Diagonal Multiply MEX"
Cohesion: 0.67
Nodes (3): diagMult(), mexFunction(), V_type

### Community 24 - "Diagonal Sparse Jacobian MEX"
Cohesion: 0.50
Nodes (3): indexType, jac_to_sparse(), mexFunction()

### Community 26 - "Group 26"
Cohesion: 0.83
Nodes (3): faceAverage(), inputCheck(), mexFunction()

### Community 27 - "Group 27"
Cohesion: 0.83
Nodes (3): faceGradient(), inputCheck(), mexFunction()

## Knowledge Gaps
- **109 isolated node(s):** `x_`, `A_`, `E_`, `C_`, `max_` (+104 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **4 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Array` connect `Symmetric Eigenvalue Problem` to `MEX Sparse Array Types`?**
  _High betweenness centrality (0.002) - this node is a cross-community bridge._
- **Why does `Graph` connect `MEX Mixed Operator Functions` to `MEX Sparse Array Types`?**
  _High betweenness centrality (0.002) - this node is a cross-community bridge._
- **Why does `mexFunction()` connect `Multi-Eigenvalue Solver` to `MEX Mixed Operator Functions`?**
  _High betweenness centrality (0.002) - this node is a cross-community bridge._
- **What connects `x_`, `A_`, `E_` to the rest of the system?**
  _109 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `MEX Mixed Operator Functions` be split into smaller, more focused modules?**
  _Cohesion score 0.05760905760905761 - nodes in this community are weakly interconnected._
- **Should `MEX Sparse Array Types` be split into smaller, more focused modules?**
  _Cohesion score 0.07171171171171171 - nodes in this community are weakly interconnected._
- **Should `C++ Boost / STL Types` be split into smaller, more focused modules?**
  _Cohesion score 0.05359937402190924 - nodes in this community are weakly interconnected._