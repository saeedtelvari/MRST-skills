%% Basic Linear Solver (CPR) Example
% This script demonstrates how to configure and inject a CPR iterative
% solver into the standard AD-OO workflow for performance.

% 1. Initialize MRST Setup
run('database/MRST-main/startup.m');

% 2. Add required modules
mrstModule add linearsolvers ad-core ad-props ad-blackoil

%% Geometry, Rock, and Fluid (Standard AD-OO Setup)
G = cartGrid([20, 20, 5], [2000, 2000, 50]*meter);
G = computeGeometry(G);
rock = makeRock(G, 100*milli*darcy, 0.3);

fluid = initSimpleADIFluid('phases', 'WO', ...
                           'mu'    , [1, 10]*centi*poise, ...
                           'rho'   , [1000, 800]*kilogram/meter^3, ...
                           'n'     , [2, 2]);

model = TwoPhaseWaterOilModel(G, rock, fluid);

%% Schedule and Initial State
W = addWell([], G, rock, 1, 'Type', 'bhp', 'Val', 200*barsa, 'comp_i', [1, 0], 'Sign', 1);
W = addWell(W, G, rock, G.cells.num, 'Type', 'bhp', 'Val', 100*barsa, 'comp_i', [0, 1], 'Sign', -1);

schedule.control = struct('W', W);
schedule.step.val = repmat(30*day, 5, 1);
schedule.step.control = ones(5, 1);

state0 = initResSol(G, 150*barsa, [0, 1]);

%% Linear Solver Setup
disp('Configuring CPR Iterative Solver...');

% Instantiate CPRSolverAD directly. It acts as a LinearSolverAD with GMRES 
% and a two-stage CPR preconditioner.
linsolve = CPRSolverAD('tolerance', 1e-3, 'maxIterations', 50);

% Pass it to the NonLinearSolver
solver = NonLinearSolver('LinearSolver', linsolve);

%% Simulation
disp('Running simulation with CPR...');
[wellSols, states, report] = simulateScheduleAD(state0, model, schedule, ...
                                                'NonLinearSolver', solver);
disp('Simulation with Iterative Solvers completed successfully!');
