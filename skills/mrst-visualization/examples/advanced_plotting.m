% Example: Advanced Plotting in MRST
% Demonstrates 3D grid slicing, well rendering, and production curve plotting.

run('database/MRST-main/startup.m');
mrstModule add ad-core ad-blackoil ad-props mrst-gui

%% 1. Fast Setup (Grid, Fluid, Wells)
G = computeGeometry(cartGrid([10, 10, 5], [1000, 1000, 100]*meter));
rock = makeRock(G, 100*milli*darcy, 0.2);

fluid = initSimpleADIFluid('phases', 'WO', 'mu', [1, 5]*centi*poise, 'rho', [1000, 800]*kilogram/meter^3);
model = TwoPhaseOilWaterModel(G, rock, fluid);

% Injector at corner 1, Producer at opposite corner
W = addWell([], G, rock, 1:5, 'Type', 'rate', 'Val', 500*meter^3/day, 'comp_i', [1, 0], 'Name', 'INJ');
W = addWell(W, G, rock, G.cells.num-4:G.cells.num, 'Type', 'bhp', 'Val', 100*barsa, 'comp_i', [0, 1], 'Name', 'PROD');

state0 = initResSol(G, 200*barsa, [0, 1]); % Initially 100% oil
schedule = simpleSchedule(repmat(100*day, 5, 1), 'W', W); % 500 days

%% 2. Run Fast Simulation
disp('Running simulation...');
[wellSols, states] = simulateScheduleAD(state0, model, schedule);

%% 3. Visualization: Sliced 3D Grid with Wells
figure('Name', '3D Reservoir Slice', 'Position', [100, 100, 800, 600]);
% Plot faint outer grid
plotGrid(G, 'FaceAlpha', 0.05, 'EdgeAlpha', 0.1);
hold on;

% Create a slice mask (e.g., cut out a corner to look inside)
mask = G.cells.centroids(:,1) > 200 & G.cells.centroids(:,2) > 200;

% Plot water saturation at the final timestep
plotCellData(G, states{end}.s(:,1), mask);
colorbar;
clim([0 1]);
title('Final Water Saturation (Sliced View)');

% Overlay the wells
plotWell(G, W, 'color', 'r', 'linewidth', 3);
view(3); camlight; 
axis tight off;

%% 4. Visualization: Production Curves
figure('Name', 'Production Curves');
% plotWellSols creates a robust UI for rates, BHP, and totals
time = cumsum(schedule.step.val);
plotWellSols(wellSols, time);

%% 5. Visualization: Interactive Toolbar
figure('Name', 'Interactive Time Scrubber');
plotToolbar(G, states);
view(3); axis tight off;
disp('Figures generated successfully!');
