%% Basic Black-Oil AD-OO Example
% This script demonstrates the standard AD-OO workflow for a basic black-oil
% simulation in MRST, adhering to the initialization rules defined in SKILL.md.

% 1. Initialize MRST Setup
run('database/MRST-main/startup.m');

% 2. Add required modules for AD-OO
mrstModule add ad-core ad-props ad-blackoil

%% Create Geometry and Petrophysics
% Create a 10x10x10 Cartesian grid
G = cartGrid([10, 10, 10], [1000, 1000, 100]*meter);
G = computeGeometry(G);

% Constant rock properties
rock = makeRock(G, 100*milli*darcy, 0.3);

%% Define Fluid and Physics Model
% Two-phase water-oil fluid
fluid = initSimpleADIFluid('phases', 'WO', ...
                           'mu'    , [1, 10]*centi*poise, ...
                           'rho'   , [1000, 800]*kilogram/meter^3, ...
                           'n'     , [2, 2]);

% Create the object-oriented physical model
model = TwoPhaseWaterOilModel(G, rock, fluid);

%% Set up Wells and Schedule
% Injector at the origin (Water)
W = addWell([], G, rock, 1, 'Type', 'bhp', 'Val', 200*barsa, ...
            'comp_i', [1, 0], 'Sign', 1, 'name', 'Inj');

% Producer at the opposite corner (Oil & Water)
W = addWell(W, G, rock, G.cells.num, 'Type', 'bhp', 'Val', 100*barsa, ...
            'comp_i', [0, 1], 'Sign', -1, 'name', 'Prod');

% Define the schedule: 10 steps of 100 days
schedule.control = struct('W', W);
schedule.step.val = repmat(100*day, 10, 1);
schedule.step.control = ones(10, 1);

%% Initialize State and Solver
% Initial state: 150 bar pressure, fully saturated with oil
state0 = initResSol(G, 150*barsa, [0, 1]);

% Instantiate the generalized NonLinearSolver
solver = NonLinearSolver();

%% Run the Simulation
% The core driver steps through the schedule using the model and solver
[wellSols, states, report] = simulateScheduleAD(state0, model, schedule, ...
                                                'NonLinearSolver', solver);

disp('Simulation completed successfully!');
