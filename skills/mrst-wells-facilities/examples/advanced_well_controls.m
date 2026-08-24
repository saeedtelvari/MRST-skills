% Initialize MRST Setup
run('database/MRST-main/startup.m');

% Add required modules
mrstModule add ad-core ad-props ad-blackoil
mrstVerbose on;

% 1. Setup a tiny grid
G = cartGrid([5, 5, 1], [50, 50, 10]);
G = computeGeometry(G);
rock = makeRock(G, 100*milli*darcy, 0.2);
fluid = initSimpleADIFluid('phases', 'WO', 'mu', [1, 5]*centi*poise, 'rho', [1000, 800]);

% 2. Setup the model
model = TwoPhaseOilWaterModel(G, rock, fluid);

% 3. Set up well and schedule with LIMIT SWITCHING
W = [];
% Add an injector with a rate control, but a BHP limit
W = addWell(W, G, rock, 1, 'type', 'rate', 'val', 50 * (meter^3/day), 'comp_i', [1, 0], 'name', 'INJ');
W(1).lims.bhp = 200*barsa; % If BHP exceeds 200 bar, switch to BHP control

% Add a producer with a rate control, but a BHP minimum limit
W = addWell(W, G, rock, 25, 'type', 'rate', 'val', -50 * (meter^3/day), 'comp_i', [0, 1], 'name', 'PROD');
W(2).lims.bhp = 50*barsa; % If BHP drops below 50 bar, switch to BHP control

% Define schedule control
schedule = struct();
schedule.step = struct('val', ones(5,1)*10*day, 'control', ones(5,1));
schedule.control = struct('W', W);

% 4. Run simulation
% Initialize reservoir state
state0 = initState(G, [], 150*barsa, [0.1, 0.9]);
            
[wellSols, states, report] = simulateScheduleAD(state0, model, schedule);

% 5. Print Success
fprintf('\nPASSED: advanced_well_controls\n');
