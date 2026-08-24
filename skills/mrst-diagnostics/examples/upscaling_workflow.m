% upscaling_workflow.m
% Example script demonstrating permeability upscaling

run('database/MRST-main/startup.m');
mrstModule add upscaling coarsegrid incomp

%% 1. Build Fine Grid and Heterogeneous Rock
G = cartGrid([20, 20, 1], [20, 20, 1]);
G = computeGeometry(G);
perm = exp(randn(G.cells.num, 1)) * 100 * milli*darcy;
rock = makeRock(G, perm, 0.2);

%% 2. Partition into Coarse Blocks
p = partitionUI(G, [4, 4, 1]);
CG = generateCoarseGrid(G, p);
CG = coarsenGeometry(CG);

%% 3. Upscale Permeability
% Upscale permeability onto the coarse grid
rock_c = struct('poro', 0.2*ones(CG.cells.num, 1));
rock_c.perm = upscalePerm(G, CG, rock);

%% 4. Setup Solvers to compare (optional)
fluid = initSingleFluid('mu', 1*centi*poise, 'rho', 1000*kilogram/meter^3);
% Just showing the initialization of the coarse model
T_c = computeTrans(CG, rock_c);

fprintf('Upscaling completed. Coarse grid has %d cells.\n', CG.cells.num);
