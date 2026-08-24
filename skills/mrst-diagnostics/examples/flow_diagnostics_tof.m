% flow_diagnostics_tof.m
% Example script demonstrating TOF, tracer computation, and sweep efficiency

run('database/MRST-main/startup.m');
mrstModule add diagnostics incomp

%% 1. Set up Grid and Rock
G = cartGrid([30, 30, 1], [30, 30, 1]);
G = computeGeometry(G);
rock = makeRock(G, 100*milli*darcy, 0.2);

%% 2. Set up Fluid and Wells
fluid = initSingleFluid('mu', 1*centi*poise, 'rho', 1000*kilogram/meter^3);
W = addWell([], G, rock, 1, 'Type', 'bhp', 'Val', 200*barsa, 'Radius', 0.1);
W = addWell(W, G, rock, G.cells.num, 'Type', 'bhp', 'Val', 100*barsa, 'Radius', 0.1);

%% 3. Solve Incompressible Flow
T = computeTrans(G, rock);
state = initResSol(G, 150*barsa);
state = incompTPFA(state, G, T, fluid, 'wells', W);

%% 4. Compute Flow Diagnostics
% Compute Time of Flight and Tracer
D = computeTOFandTracer(state, G, rock, 'wells', W);

% Compute well pairs
WP = computeWellPairs(state, G, rock, W, D);

% Compute F and Phi, then sweep efficiency
pv = poreVolume(G, rock);
[F, Phi] = computeFandPhi(pv, D.tof);
[Ev, tD] = computeSweep(F, Phi);
Lc = computeLorenz(F, Phi);

fprintf('Lorenz coefficient: %.3f\n', Lc);

%% 5. Plot Results
figure;
subplot(1,3,1);
plotCellData(G, D.tof);
title('Time of Flight (TOF)');
colorbar;

subplot(1,3,2);
plot(Phi, F, 'LineWidth', 2);
title('F-Phi Curve');
xlabel('Storage Capacity (\Phi)');
ylabel('Flow Capacity (F)');

subplot(1,3,3);
plot(tD, Ev, 'LineWidth', 2);
title('Sweep Efficiency');
xlabel('Dimensionless Time (PVI)');
ylabel('Sweep Efficiency (Ev)');
