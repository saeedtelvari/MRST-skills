% Example: Custom Physics Model
% This script demonstrates how to define and use a custom PhysicalModel
% and StateFunction in MRST's AD-OO framework.

% Initialize MRST Setup
run('database/MRST-main/startup.m');

% Add required modules for AD-OO
mrstModule add ad-core ad-props ad-blackoil mrst-gui

% 1. Geometry & Petrophysics
dims = [5, 5, 10];
G = cartGrid(dims, [1, 1, 5]*meter);
G = computeGeometry(G);
rock = makeRock(G, 100*milli*darcy, 0.2);

% 2. Fluid Setup
fluid = initSimpleADIFluid('phases', 'WO', ...
                           'mu', [1, 10]*centi*poise, ...
                           'rho', [1000, 800]*kilogram/meter^3);

% 3. Model & State Setup
% We use the CustomTwoPhaseModel defined at the end of the script
model = CustomTwoPhaseModel(G, rock, fluid);

% Initialize state. Gravity segregation example: dense fluid at top.
sW = zeros(G.cells.num, 1);
[~, ~, kk] = gridLogicalIndices(G);
sW(kk <= 5) = 1.0; % Water in top half
s = [sW, 1 - sW];
state0 = initResSol(G, 100*barsa, s);

% 4. Schedule
% No wells, just closed boundaries and gravity segregation
dt = repmat(10*day, 10, 1);
% Add a boundary condition at the bottom to fix the pressure
bc = pside([], G, 'ZMax', 100*barsa, 'sat', [0, 1]);
schedule = simpleSchedule(dt, 'bc', bc);

% 5. Solver & Execution
solver = NonLinearSolver();
[wellSols, states, report] = simulateScheduleAD(state0, model, schedule, 'NonLinearSolver', solver);

% Plot results
figure;
plotCellData(G, states{end}.s(:,1));
colorbar;
title('Final Water Saturation (Gravity Segregation)');
view(3);
