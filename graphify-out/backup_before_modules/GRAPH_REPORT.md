# Graph Report - C:\MyFiles\MRST-skills\database\MRST-main  (2026-06-29)

## Corpus Check
- 2770 files · ~1,588,620 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 3045 nodes · 1292 edges · 2461 communities (2455 shown, 6 thin omitted)
- Extraction: 89% EXTRACTED · 11% INFERRED · 0% AMBIGUOUS · INFERRED: 139 edges (avg confidence: 0.82)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_MEX Mixed Operator Functions|MEX Mixed Operator Functions]]
- [[_COMMUNITY_MEX Sparse Array Types|MEX Sparse Array Types]]
- [[_COMMUNITY_MEX Block Matrix Storage Types|MEX Block Matrix Storage Types]]
- [[_COMMUNITY_Multi-Eigenvalue Solver|Multi-Eigenvalue Solver]]
- [[_COMMUNITY_VEmex MATLAB-C++ Struct Bridge|VEmex MATLAB-C++ Struct Bridge]]
- [[_COMMUNITY_AD Module Documentation|AD Module Documentation]]
- [[_COMMUNITY_Symmetric Multi-Eigenvalue MEX|Symmetric Multi-Eigenvalue MEX]]
- [[_COMMUNITY_MsRSB Accelerated Basis Solver|MsRSB Accelerated Basis Solver]]
- [[_COMMUNITY_Multiscale Grid Coarsening + DFM Docs|Multiscale Grid Coarsening + DFM Docs]]
- [[_COMMUNITY_BasicAD Autodiff Core|BasicAD Autodiff Core]]
- [[_COMMUNITY_AMG Solver Options|AMG Solver Options]]
- [[_COMMUNITY_MEX Function Interface|MEX Function Interface]]
- [[_COMMUNITY_Upwind Discretization Operators|Upwind Discretization Operators]]
- [[_COMMUNITY_Least Squares SVD MEX|Least Squares SVD MEX]]
- [[_COMMUNITY_MD5 Checksum Utility|MD5 Checksum Utility]]
- [[_COMMUNITY_DFM Simulation Visualization|DFM Simulation Visualization]]
- [[_COMMUNITY_VEmex CO2 Transport Build System|VEmex CO2 Transport Build System]]
- [[_COMMUNITY_1D Interpolation MEX|1D Interpolation MEX]]
- [[_COMMUNITY_MRST GUI 3D Geometry & Slicing Icons|MRST GUI 3D Geometry & Slicing Icons]]
- [[_COMMUNITY_Discrete Divergence Jacobian MEX|Discrete Divergence Jacobian MEX]]
- [[_COMMUNITY_Face Average Diagonal Jacobian MEX|Face Average Diagonal Jacobian MEX]]
- [[_COMMUNITY_Two-Point Gradient Diagonal Jacobian MEX|Two-Point Gradient Diagonal Jacobian MEX]]
- [[_COMMUNITY_Relative Permeability Upscaling Data|Relative Permeability Upscaling Data]]
- [[_COMMUNITY_MRST GUI Data Display Controls|MRST GUI Data Display Controls]]
- [[_COMMUNITY_MRST GUI Playback & Grid Icons|MRST GUI Playback & Grid Icons]]
- [[_COMMUNITY_Black-Oil and SPE Benchmark Datasets|Black-Oil and SPE Benchmark Datasets]]
- [[_COMMUNITY_CO2 Atlas and Norwegian Storage Sites|CO2 Atlas and Norwegian Storage Sites]]
- [[_COMMUNITY_Geological Heterogeneity Test Images|Geological Heterogeneity Test Images]]
- [[_COMMUNITY_HFM DistMesh Segment MEX|HFM DistMesh Segment MEX]]
- [[_COMMUNITY_CO2 Spillpoint GUI Toolbar - View Controls|CO2 Spillpoint GUI Toolbar - View Controls]]
- [[_COMMUNITY_Geological Reservoir Models|Geological Reservoir Models]]
- [[_COMMUNITY_Diagonal Sparse Jacobian MEX|Diagonal Sparse Jacobian MEX]]
- [[_COMMUNITY_Diagonal Multiply MEX|Diagonal Multiply MEX]]
- [[_COMMUNITY_Discrete Divergence Value MEX|Discrete Divergence Value MEX]]
- [[_COMMUNITY_Face Average Value MEX|Face Average Value MEX]]
- [[_COMMUNITY_Two-Point Gradient Value MEX|Two-Point Gradient Value MEX]]
- [[_COMMUNITY_MRST GUI Data Filter Icons|MRST GUI Data Filter Icons]]
- [[_COMMUNITY_CO2 Spillpoint GUI Toolbar - Simulation Controls|CO2 Spillpoint GUI Toolbar - Simulation Controls]]
- [[_COMMUNITY_MRST GUI IJK Grid Navigation|MRST GUI IJK Grid Navigation]]
- [[_COMMUNITY_MRST GUI Colormap & Scale Icons|MRST GUI Colormap & Scale Icons]]
- [[_COMMUNITY_CO2 Atlas Grid Conversion|CO2 Atlas Grid Conversion]]
- [[_COMMUNITY_MRST GUI Navigation Controls|MRST GUI Navigation Controls]]
- [[_COMMUNITY_IGEMS Geological Surfaces|IGEMS Geological Surfaces]]

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
- **Rock Upscaling Example: Sw, Krw, Kro, J-function Data** — examples_rockdata_water_saturation, examples_rockdata_krw, examples_rockdata_kro [EXTRACTED 1.00]
- **VACORESS build system: VACORESS root project orchestrates VESimulatorCPU and VETransportCPU MEX interface, both sharing OpenMP and MATLAB dependencies** — vemex_cmakeliststxt_vacoress, vesimulator_cmakeliststxt_vesimulator_cpu, mexinterface_cmakeliststxt_vetransportcpu, vemex_cmakeliststxt_openmp, vemex_cmakeliststxt_matlab [EXTRACTED 1.00]
- **DFM Control Volume Discretization Using TPFA and MPFA** — dfm_impl_notes_control_volume_discretization, dfm_impl_notes_tpfa, dfm_impl_notes_mpfa [EXTRACTED 1.00]
- **Fracture Gridding: Conforming Grid, Lower-Dimensional Representation, and Tagging** — dfm_impl_notes_conforming_grid, dfm_impl_notes_lower_dimensional_fracture_representation, dfm_impl_notes_fracture_tags [INFERRED 0.85]
- **Fluvial Bed Reservoir Model Dataset Family** — img_bedmodel2, img_bedmodels1 [INFERRED 0.95]
- **Norwegian CO2 Storage and Sequestration Datasets** — img_co2atlas, img_co2atlasbarentssea, img_co2atlasnorwegiansea, img_sleipner, img_sleipnerplumes, img_johansen [INFERRED 0.95]
- **MRST Reservoir Simulation Benchmark and Test Datasets** — img_bedmodel2, img_bedmodels1, img_blackoilpolymer2d, img_caseb4, img_egg, img_norne, img_saigup, img_spe1, img_spe3, img_spe9, img_spe10 [INFERRED 0.85]
- **IGEMS Geological Grid and Surface Dataset Family** — img_igemsgrids, img_igemssurfaces [EXTRACTED 1.00]
- **SPE Comparative Solution Project Benchmark Datasets** — img_spe1, img_spe3, img_spe9, img_spe10 [INFERRED 0.95]
- **DFM Fracture Network Mesh Representation (Fine Triangular Grid with Explicit Fractures)** — dfm_fracturesimillustration, html_dfmmsfv_01 [INFERRED 0.85]
- **MSFV-DFM Pressure and Saturation Field Comparison (Reference vs Inexact/MSFV)** — msfv_dfm_examples_msfv_dfm, html_dfmmsfv_02, html_dfmmsfv_04 [INFERRED 0.95]
- **DFM MsFV Sequential Example Workflow (Steps 01-06)** — html_dfmmsfv_01, html_dfmmsfv_02, html_dfmmsfv_03, html_dfmmsfv_04, html_dfmmsfv_05, html_dfmmsfv_06 [EXTRACTED 1.00]
- **Conforming vs Non-Conforming Coarse Grid Accuracy and Convergence Study** — html_dfmmsfv_03, html_dfmmsfv_05, html_dfmmsfv_06 [INFERRED 0.95]
- **Agglomeration Example Facies Dataset** — data_facies1, data_facies2, data_facies3 [EXTRACTED 1.00]
- **Geological Heterogeneity Inputs for Multiscale Solvers** — data_facies1, data_facies2, data_facies3, examples_perm_mono, examples_inclusions [INFERRED 0.85]
- **Multiscale Solver Heterogeneous Test Cases** — examples_perm_mono, examples_inclusions [INFERRED 0.85]
- **MRST GUI Data Display Control Icons** — icons_10, icons_abs, icons_adjust, icons_alpha [INFERRED 0.85]
- **MRST GUI View and Navigation Control Icons** — icons_1d, icons_centersel, icons_adjust [INFERRED 0.80]
- **MRST GUI Toolbar Icon Set** — icons_10, icons_1d, icons_abs, icons_adjust, icons_alpha, icons_centersel [INFERRED 0.95]
- **Playback Control Icons** — icons_ic_play, icons_ic_playreverse, icons_ic_pause, icons_ic_stop [INFERRED 0.95]
- **MRST GUI Visualization Toolbar Icons** — icons_grid_outline, icons_hist, icons_ic_play, icons_ic_playreverse, icons_ic_pause, icons_ic_stop [INFERRED 0.85]
- **IJK Grid Navigation and Display Icons** — icons_ijk, icons_ijkgrid, icons_left [INFERRED 0.85]
- **Colormap and Data Scale Display Controls** — icons_lockcaxis, icons_log10, icons_light [INFERRED 0.80]
- **MRST GUI Toolbar Icons - Chunk 03** — icons_ijk, icons_ijkgrid, icons_left, icons_light, icons_lockcaxis, icons_log10 [INFERRED 0.95]
- **Data Filtering and Display Control Icons** — icons_marker, icons_nonzero, icons_minmax, icons_outline [INFERRED 0.85]
- **Playback and Session Control Icons** — icons_right, icons_reset [INFERRED 0.75]
- **MRST GUI Toolbar Icons - Chunk 4** — icons_marker, icons_minmax, icons_nonzero, icons_outline, icons_reset, icons_right [INFERRED 0.95]
- **Cross-Sectional Slicing and Geometry Tools** — icons_slice, icons_sliceplane, icons_surf, icons_z_minus, icons_z_plus [INFERRED 0.90]
- **MRST GUI Toolbar Icons** — icons_select, icons_slice, icons_sliceplane, icons_surf, icons_tight, icons_vfield, icons_z_minus, icons_z_plus [INFERRED 0.95]
- **Vertical Depth Navigation Controls** — icons_z_minus, icons_z_plus [INFERRED 0.95]
- **3D Visualization and Rendering Tools** — icons_surf, icons_vfield, icons_sliceplane, icons_slice [INFERRED 0.85]

## Communities (2461 total, 6 thin omitted)

### Community 0 - "MEX Mixed Operator Functions"
Cohesion: 0.05
Nodes (66): getd(), mexFunction(), Edge, IDX, IdxFunc, IVec, map, METIS_NOPTIONS (+58 more)

### Community 1 - "MEX Sparse Array Types"
Cohesion: 0.07
Nodes (56): array, ArrayDimensions, CellArray, CharArray, idx_type, Index, Indexable, istream (+48 more)

### Community 2 - "MEX Block Matrix Storage Types"
Cohesion: 0.07
Nodes (54): matrix_type, mwIndex, getBlocksFromSparse(), mexFunction(), ptree, rhs_type, shared_ptr, tuple (+46 more)

### Community 3 - "Multi-Eigenvalue Solver"
Cohesion: 0.10
Nodes (24): BlockSizes, EigenResults, mwSignedIndex, ProblemCharacteristics, args_ok(), Array, x_, blockSizes() (+16 more)

### Community 4 - "VEmex MATLAB-C++ Struct Bridge"
Cohesion: 0.09
Nodes (31): BC, cells_t, columns_t, faces_t, Fluid, Grid2D, nodes_t, opt_t (+23 more)

### Community 5 - "AD Module Documentation"
Cohesion: 0.06
Nodes (33): AD Black-Oil Module, Black-Oil Flow Equations, SPE Benchmark Cases (SPE1, SPE9), AD-Core Module (AD-OO Framework), AD Enhanced Oil Recovery Module, Polymer Simulation (EOR), Surfactant Simulation (EOR), AD Properties Module (+25 more)

### Community 6 - "Symmetric Multi-Eigenvalue MEX"
Cohesion: 0.15
Nodes (13): BlockID, size_t, SizeType, SizeVector, args_ok(), BlockBoundaries, construct(), mexFunction() (+5 more)

### Community 7 - "MsRSB Accelerated Basis Solver"
Cohesion: 0.24
Nodes (19): computeBasis(), getBasis(), openFlatFile(), readBasisOperator(), readConnMatrix(), readInfo(), renormalize(), setupCoarseMapping() (+11 more)

### Community 8 - "Multiscale Grid Coarsening + DFM Docs"
Cohesion: 0.15
Nodes (19): Agglomeration-Based Grid Coarsening Module, Grid Coarsening by Amalgamation, Conforming Grid for Fracture Discretization, Control Volume Discretization of Fractured Media, Discrete Fracture Matrix (DFM) Module for MRST, MRST Core Files Modified with _DFM Suffix, Fracture Face and Cell Tagging System (G.faces.tags, G.cells.tags), Lower-Dimensional Fracture Representation (+11 more)

### Community 9 - "BasicAD Autodiff Core"
Cohesion: 0.17
Nodes (7): BasicAD, deriv_ixs_, deriv_vals_, num_derivs_, operator+(), write(), ostream

### Community 10 - "AMG Solver Options"
Cohesion: 0.13
Nodes (15): amg_opts, aggr_eps_strong, aggr_over_interp, aggr_relax, coarse_enough, coarsen_id, direct_coarse, max_levels (+7 more)

### Community 11 - "MEX Function Interface"
Cohesion: 0.26
Nodes (5): ArgumentList, mex::Function, MexFunction, MexFunction, matlabPtr

### Community 12 - "Upwind Discretization Operators"
Cohesion: 0.24
Nodes (10): logic_type, copyElements(), inputCheck(), mexFunction(), upwindJac(), upwindJacMain(), zeroElements(), inputCheck() (+2 more)

### Community 13 - "Least Squares SVD MEX"
Cohesion: 0.38
Nodes (10): accumulate_size(), args_ok(), create_lls_structure(), destroy_lls_structure(), extract_block_sizes(), mexFunction(), prepare_lls_problem(), solve_all_lls_problems() (+2 more)

### Community 14 - "MD5 Checksum Utility"
Cohesion: 0.56
Nodes (8): md5_byte_t, md5_state_t, md5_append(), md5_append_array(), md5_finish(), md5_init(), md5_process(), mexFunction()

### Community 15 - "DFM Simulation Visualization"
Cohesion: 0.31
Nodes (9): Fracture Simulation Illustration (DFM Triangular Mesh Pressure Field), DFM MsFV Example - Convergence Plot (Concentration vs PVI), DFM MsFV Example Step 1 - Fracture Network on Fine Triangular Mesh, DFM MsFV Example Step 2 - Saturation and Pressure Reference vs MSFV Comparison, DFM MsFV Example Step 3 - Coarse Grid Partitioning on Triangular Mesh, DFM MsFV Example Step 4 - Saturation and Pressure Reference vs MSFV (Later Timestep), DFM MsFV Example Step 5 - Concentration vs PVI: Reference vs Conforming vs Non-Conforming Grid, DFM MsFV Example Step 6 - GMRES Residuals: Conforming vs Non-Conforming Coarse Grid (+1 more)

### Community 16 - "VEmex CO2 Transport Build System"
Cohesion: 0.36
Nodes (9): extractStructs.cpp MEX Common Source, mexInterface CMake Project, VETransportCPU MEX Shared Library, MATLAB Dependency, OpenMP Dependency, VACORESS CMake Project, Doxygen Documentation Target, VESimulator CMake Project (+1 more)

### Community 17 - "1D Interpolation MEX"
Cohesion: 0.43
Nodes (6): mexFunction(), binary_search(), interp1_binary_search(), interp1_binned_search(), interp1_binning(), interp1_equal_width_search()

### Community 18 - "MRST GUI 3D Geometry & Slicing Icons"
Cohesion: 0.32
Nodes (8): Select Tool Icon, Slice Tool Icon, Slice Plane Tool Icon, Surface Rendering Tool Icon, Tight Layout / Fit View Icon, Vector Field Visualization Icon, Z-Axis Decrease (Navigate Deeper) Icon, Z-Axis Increase (Navigate Shallower) Icon

### Community 19 - "Discrete Divergence Jacobian MEX"
Cohesion: 0.43
Nodes (6): index_t, copyFaceData(), divergenceJac(), divergenceJacMain(), inputCheck(), mexFunction()

### Community 20 - "Face Average Diagonal Jacobian MEX"
Cohesion: 0.47
Nodes (3): dimensionCheck(), inputCheck(), mexFunction()

### Community 22 - "Relative Permeability Upscaling Data"
Cohesion: 0.40
Nodes (6): Leverett J-Function (Capillary Pressure Correlation), Oil Relative Permeability (Kro), Water Relative Permeability (Krw), Relative Permeability and J-Function Data Table, Water Saturation (Sw), Rock Dataset Index File (rocklist.txt)

### Community 23 - "MRST GUI Data Display Controls"
Cohesion: 0.47
Nodes (6): 10 (Superscript Zero) - Logarithmic Scale Icon, 1D - One-Dimensional View Toggle Icon, Absolute Value (|x|) - Absolute Value Display Icon, Adjust - Triangle/Colormap Range Adjustment Icon, Alpha (α) - Transparency/Alpha Channel Control Icon, Center Selection - Zoom/Focus on Selection Icon

### Community 24 - "MRST GUI Playback & Grid Icons"
Cohesion: 0.53
Nodes (6): Grid Outline Toggle, Histogram / Data Distribution Chart, Pause Playback, Play Forward, Play Reverse / Rewind, Stop Playback

### Community 25 - "Black-Oil and SPE Benchmark Datasets"
Cohesion: 0.53
Nodes (6): Black Oil Polymer 2D - Injection/Production Well Simulation, Case B4 - Dual-Block Faulted Reservoir Grid, SPE1 - SPE Comparative Solution Project Case 1 Black Oil Benchmark, SPE10 - SPE 10th Comparative Solution Project Heterogeneous Permeability Benchmark, SPE3 - SPE Comparative Solution Project Case 3 Gas Injection Benchmark, SPE9 - SPE 9th Comparative Solution Project Multi-Well Black Oil Benchmark

### Community 26 - "CO2 Atlas and Norwegian Storage Sites"
Cohesion: 0.47
Nodes (6): CO2 Atlas - Norwegian Continental Shelf Aquifer Formations Map, CO2 Atlas Barents Sea - Norwegian CO2 Storage Aquifer Outlines, CO2 Atlas Norwegian Sea - Norwegian CO2 Storage Formation Outlines, Johansen Formation - Norwegian North Sea CO2 Storage Saline Aquifer, Sleipner CO2 - North Sea CO2 Injection Caprock Depth Surface, Sleipner CO2 Plumes - Time-Series CO2 Plume Thickness Observations 1999-2010

### Community 27 - "Geological Heterogeneity Test Images"
Cohesion: 0.80
Nodes (5): Facies Map 1 (Agglomeration Example Data), Facies Map 2 (Agglomeration Example Data), Multi-Facies Distribution Map (Agglomeration Example Data), Circular Inclusions Heterogeneity Map (MsRSB Example), Permeability Field for Monotone MsFVM Example

### Community 28 - "HFM DistMesh Segment MEX"
Cohesion: 0.70
Nodes (4): dot2(), length(), mexFunction(), sqr()

### Community 29 - "CO2 Spillpoint GUI Toolbar - View Controls"
Cohesion: 1.00
Nodes (5): Color Path Visualization Button, Contour Lines Display Toggle Button, Lighting Control Button, Reset View Button, CO2 Spillpoint Analysis GUI Toolbar

### Community 30 - "Geological Reservoir Models"
Cohesion: 0.40
Nodes (5): BedModel2 - Layered Fluvial Bed Reservoir Model, BedModels1 - Structured Grid Bed Geometry Model, Egg Model - Stochastic Channelized Reservoir with Injector/Producer Wells, Norne Field - Full-Field Norwegian Sea Oil Reservoir with Wells, SAIGUP - Geostatistical Sensitivity Study Shallow Marine Reservoir

### Community 31 - "Diagonal Sparse Jacobian MEX"
Cohesion: 0.50
Nodes (3): indexType, jac_to_sparse(), mexFunction()

### Community 34 - "Face Average Value MEX"
Cohesion: 0.83
Nodes (3): faceAverage(), inputCheck(), mexFunction()

### Community 35 - "Two-Point Gradient Value MEX"
Cohesion: 0.83
Nodes (3): faceGradient(), inputCheck(), mexFunction()

### Community 36 - "MRST GUI Data Filter Icons"
Cohesion: 0.50
Nodes (4): Marker Icon, Min-Max Scale Icon, Non-Zero Filter Icon, Grid Outline / Wireframe Icon

### Community 37 - "CO2 Spillpoint GUI Toolbar - Simulation Controls"
Cohesion: 1.00
Nodes (4): Simulate Action Button (Run CO2 Simulation), Spill/Flow Visualization Action Button, Stop Simulation Action Button, Structural Traps Display Action Button

### Community 38 - "MRST GUI IJK Grid Navigation"
Cohesion: 0.67
Nodes (3): IJK Cell Coordinate Display Toggle, IJK Grid Overlay Toggle, Navigate Backward / Previous Step Button

### Community 39 - "MRST GUI Colormap & Scale Icons"
Cohesion: 0.67
Nodes (3): 3D Scene Lighting Controls, Lock Color Axis / Colormap Range, Logarithmic Base-10 Scale Toggle

## Knowledge Gaps
- **124 isolated node(s):** `x_`, `A_`, `E_`, `C_`, `max_` (+119 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **6 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Array` connect `Multi-Eigenvalue Solver` to `MEX Sparse Array Types`, `Symmetric Multi-Eigenvalue MEX`?**
  _High betweenness centrality (0.002) - this node is a cross-community bridge._
- **Why does `Graph` connect `MEX Mixed Operator Functions` to `MEX Sparse Array Types`?**
  _High betweenness centrality (0.002) - this node is a cross-community bridge._
- **Why does `mexFunction()` connect `Multi-Eigenvalue Solver` to `MEX Mixed Operator Functions`?**
  _High betweenness centrality (0.002) - this node is a cross-community bridge._
- **What connects `x_`, `A_`, `E_` to the rest of the system?**
  _124 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `MEX Mixed Operator Functions` be split into smaller, more focused modules?**
  _Cohesion score 0.053069420539300055 - nodes in this community are weakly interconnected._
- **Should `MEX Sparse Array Types` be split into smaller, more focused modules?**
  _Cohesion score 0.0691333982473223 - nodes in this community are weakly interconnected._
- **Should `MEX Block Matrix Storage Types` be split into smaller, more focused modules?**
  _Cohesion score 0.06830601092896176 - nodes in this community are weakly interconnected._