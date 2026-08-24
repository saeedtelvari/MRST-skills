%% Basic Incompressible Procedural Example
% This script demonstrates the standard procedural workflow for a basic 
% incompressible simulation in MRST, adhering to the initialization rules 
% defined in SKILL.md.

% 1. Initialize MRST Setup
run('database/MRST-main/startup.m');

% 2. Add required modules for core procedural simulations
mrstModule add incomp

%% Create Geometry and Petrophysics
% Create a 10x10x10 Cartesian grid
G = cartGrid([10, 10, 10], [1000, 1000, 100]*meter);
G = computeGeometry(G);

% Constant rock properties
rock = makeRock(G, 100*milli*darcy, 0.3);

%% Define Fluid and Initial State
% Two-phase water-oil fluid (procedural fluid struct)
fluid = initSimpleFluid('mu' , [1, 10]*centi*poise, ...
                        'rho', [1000, 800]*kilogram/meter^3, ...
                        'n'  , [2, 2]);

% Initial state: 100 bar pressure, fully saturated with oil (S_w=0, S_o=1)
state = initResSol(G, 100*barsa, [0, 1]);

%% Set up Wells
% Injector at the origin (Water)
W = addWell([], G, rock, 1, 'Type', 'bhp', 'Val', 200*barsa, ...
            'comp_i', [1, 0], 'Sign', 1, 'name', 'Inj');

% Producer at the opposite corner
W = addWell(W, G, rock, G.cells.num, 'Type', 'bhp', 'Val', 50*barsa, ...
            'comp_i', [0, 1], 'Sign', -1, 'name', 'Prod');

%% Run the Simulation
% Pre-compute transmissibilities for the TPFA solver
T = computeTrans(G, rock);

num_steps = 10;
dt = 100*day;

disp('Starting procedural time-stepping...');
for i = 1:num_steps
    % 1. Solve pressure equation to get fluxes (v) and pressures (pressure)
    state = incompTPFA(state, G, T, fluid, 'wells', W);
    
    % 2. Solve transport equation to update saturations (s)
    state = implicitTransport(state, G, dt, rock, fluid, 'wells', W);
    
    fprintf('Step %d/%d completed.\n', i, num_steps);
end

disp('Simulation completed successfully!');
