%% Basic CO2 Vertical Equilibrium (VE) Example
% This script demonstrates the standard workflow for CO2 storage using 
% the Vertical Equilibrium (VE) framework in MRST's co2lab.

% 1. Initialize MRST Setup
run('database/MRST-main/startup.m');

% 2. Add required modules
mrstModule add co2lab ad-core ad-blackoil

%% Create 3D Grid and Extract Top Surface
% Create a 3D sloped aquifer grid
G = cartGrid([50, 50, 10], [5000, 5000, 100]*meter);
% Add an upward slope in the x-direction
G.nodes.coords(:, 3) = G.nodes.coords(:, 3) - 0.1 * G.nodes.coords(:, 1);
G = computeGeometry(G);

rock = makeRock(G, 100*milli*darcy, 0.3);

% Extract the 2D top-surface grid for the VE assumption
Gt = topSurfaceGrid(G);
rock2D = averageRock(rock, Gt);

%% Trap Analysis
% Identify structural traps where CO2 can accumulate
traps = trapAnalysis(Gt, false);

%% Fluid and Model setup
% Create VE fluid for CO2 and brine at reservoir conditions
fluid = makeVEFluid(Gt, rock2D, 'sharp_interface_simple');

% Create the VE black-oil type model
model = CO2VEBlackOilTypeModel(Gt, rock2D, fluid);

%% Schedule and Initial State
% Injector well at the deeper end (Injecting Phase 2 - CO2)
W = addWell([], Gt, rock2D, 1, 'Type', 'rate', 'Val', 10*kilogram/second, ...
            'comp_i', [0, 1], 'name', 'Inj');

schedule.control = struct('W', W);
schedule.step.val = repmat(1*year, 10, 1);
schedule.step.control = ones(10, 1);

% Initial state: Brine filled (Phase 1=Brine, Phase 2=CO2)
state0 = initResSol(Gt, 200*barsa, [1, 0]);
state0.sGmax = state0.s(:, 2);

%% Simulation
solver = NonLinearSolver();
disp('Simulating CO2 migration using VE model...');
[wellSols, states, report] = simulateScheduleAD(state0, model, schedule, ...
                                                'NonLinearSolver', solver);
disp('CO2 Simulation complete!');
