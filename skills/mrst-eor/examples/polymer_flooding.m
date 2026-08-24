% A basic example of a 2D polymer flood using the ad-eor module.
% This script demonstrates how to set up the OilWaterPolymerModel manually
% without needing to load an external deck.

% Initialize MRST Setup
run('database/MRST-main/startup.m');

% Add required modules for AD-OO and EOR
mrstModule add ad-core ad-props ad-blackoil ad-eor

%% Geometry & Petrophysics
% Set up a simple 20x20x1 Cartesian grid
nx = 20; ny = 20; nz = 1;
G = cartGrid([nx, ny, nz], [200, 200, 10]);
G = computeGeometry(G);

% Rock properties
rock = makeRock(G, 100*milli*darcy, 0.2);

%% Fluid & Polymer Properties
% Initialize a standard two-phase oil/water fluid
fluid = initSimpleADIFluid('phases', 'WO', ...
                           'mu', [1, 10]*centi*poise, ...
                           'rho', [1000, 850], ...
                           'n' , [2, 2]);

% Add EOR specific polymer properties
fluid.cpmax = 5.0;                         % Maximum polymer concentration (kg/m^3)
fluid.mixPar = 1.0;                        % Todd-Longstaff mixing parameter (fully mixed)
fluid.dps = 0.0;                           % Dead pore space (inaccessible pore volume fraction)
fluid.rhoR = 2000;                         % Rock density (kg/m^3)
fluid.adsInx = 2;                          % 2 means irreversible adsorption
fluid.adsMax = 1e-5;                       % Max adsorption limit (kg polymer / kg rock)
fluid.ads = @(c) 1e-5 * (c / 5.0);         % Linear adsorption isotherm up to max
fluid.rrf = 1.0;                           % Residual resistance factor (permeability reduction)

% Viscosity multiplier as a function of concentration
% muW_eff = muW * muWMult(c)
% We use a simple table look-up or function handle.
fluid.muWMult = @(c) 1 + 9 * (c / 5.0);    % Up to 10x more viscous at max concentration

%% Setup the Model
model = OilWaterPolymerModel(G, rock, fluid);

%% Initial State
state0 = initResSol(G, 100*barsa, [0.1, 0.9]);
state0.cp = zeros(G.cells.num, 1);
state0.cpmax = zeros(G.cells.num, 1);

%% Wells and Schedule
% Injector at the corner (1, 1), Producer at the opposite corner (nx, ny)
rate = 0.5 * sum(rock.poro .* G.cells.volumes) / (1000 * day); % ~0.5 PVI per 1000 days

% 1. Water pre-flush (no polymer)
W1 = addWell([], G, rock, 1, 'Type', 'rate', 'Val', rate, ...
            'comp_i', [1, 0], 'name', 'INJ');
W1 = addWell(W1, G, rock, G.cells.num, 'Type', 'bhp', 'Val', 50*barsa, ...
            'comp_i', [0, 1], 'name', 'PROD');
[W1.cp] = deal(0.0);
        
% 2. Polymer slug injection
W2 = addWell([], G, rock, 1, 'Type', 'rate', 'Val', rate, ...
            'comp_i', [1, 0], 'name', 'INJ');
W2 = addWell(W2, G, rock, G.cells.num, 'Type', 'bhp', 'Val', 50*barsa, ...
            'comp_i', [0, 1], 'name', 'PROD');
W2(1).cp = 5.0;
W2(2).cp = 0.0;

% 3. Water post-flush (no polymer)
W3 = W1;

% Schedule definition
% 1. Water flood for 100 days
% 2. Polymer slug for 500 days
% 3. Water chase for 400 days
schedule = struct();
schedule.control = struct('W', {W1, W2, W3});
schedule.step.val = [repmat(20*day, 5, 1); repmat(50*day, 10, 1); repmat(50*day, 8, 1)];
schedule.step.control = [repmat(1, 5, 1); repmat(2, 10, 1); repmat(3, 8, 1)];

%% Simulation
disp('Running AD-EOR polymer simulation...');
solver = NonLinearSolver();
[wellSols, states, report] = simulateScheduleAD(state0, model, schedule, 'NonLinearSolver', solver);

disp('Simulation complete.');

%% Plotting the polymer concentration at the end of the polymer slug
% Find the state corresponding to the end of step 15 (end of polymer injection)
poly_state = states{15};
figure;
plotCellData(G, poly_state.cp);
colorbar;
title('Polymer Concentration (kg/m^3) at End of Slug');
view([0, 90]);
