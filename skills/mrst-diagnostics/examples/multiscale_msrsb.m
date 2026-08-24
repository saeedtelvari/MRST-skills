% multiscale_msrsb.m
% Example script demonstrating the MsRSB multiscale solver

run('database/MRST-main/startup.m');
mrstModule add msrsb coarsegrid incomp

%% 1. Build Fine Grid, Rock, and Fluid
G = cartGrid([30, 30, 1], [30, 30, 1]);
G = computeGeometry(G);
rock = makeRock(G, 100*milli*darcy, 0.2);
fluid = initSingleFluid('mu', 1*centi*poise, 'rho', 1000*kilogram/meter^3);

W = addWell([], G, rock, 1, 'Type', 'bhp', 'Val', 200*barsa, 'Radius', 0.1);
W = addWell(W, G, rock, G.cells.num, 'Type', 'bhp', 'Val', 100*barsa, 'Radius', 0.1);

T = computeTrans(G, rock);

%% 2. Domain Coarsening
p = partitionUI(G, [6, 6, 1]);
CG = generateCoarseGrid(G, p);
CG = coarsenGeometry(CG);
% Required for MsRSB basis generation
CG = storeInteractionRegionCart(CG);

%% 3. Global Matrix Assembly and Basis Functions
state = initResSol(G, 150*barsa);
A = getIncomp1PhMatrix(G, T, state, fluid);
basis = getMultiscaleBasis(CG, A, 'type', 'msrsb');

%% 4. Multiscale Solver
[state_ms, report] = incompMultiscale(state, CG, T, fluid, basis, 'wells', W);

%% 5. Compare with Direct Solver
state_fs = incompTPFA(state, G, T, fluid, 'wells', W);

% Plot pressure
figure;
subplot(1,2,1);
plotCellData(G, state_fs.pressure);
title('Fine-Scale Pressure');
colorbar;
subplot(1,2,2);
plotCellData(G, state_ms.pressure);
title('Multiscale Pressure');
colorbar;
