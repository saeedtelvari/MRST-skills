%% Basic Geothermal Doublet Example
run('database/MRST-main/startup.m');
mrstModule add ad-core ad-props compositional geothermal

% Grid & Petrophysics
G = cartGrid([20, 10, 5], [1000, 500, 100]*meter);
G = computeGeometry(G);
rock = makeRock(G, 100*milli*darcy, 0.2);
rock = addThermalRockProps(rock, 'lambdaR', 2.0, 'rhoR', 2600, 'CpR', 1000);

% Fluid
fluid = initSimpleADIFluid('phases', 'W', 'mu', 1*centi*poise, 'rho', 1000*kilogram/meter^3);
fluid = addThermalFluidProps(fluid, 'Cp', 4.2e3, 'lambdaF', 0.6);

% Model
model = GeothermalModel(G, rock, fluid);

% Initial State
state0 = initResSol(G, 100*barsa, 1.0);
state0.T = repmat(363.15, G.cells.num, 1); % 90 C (in K)

% Wells & Schedule
W = addWell([], G, rock, 1, 'Type', 'rate', 'Val', 0.01, 'Sign', 1, 'name', 'Inj');
W = addWell(W, G, rock, G.cells.num, 'Type', 'bhp', 'Val', 50*barsa, 'Sign', -1, 'name', 'Prod');
W = addThermalWellProps(W, G, rock, fluid, 'T', [293.15; 363.15]);

schedule.control = struct('W', W);
schedule.step.val = repmat(1*year, 10, 1);
schedule.step.control = ones(10, 1);

% Simulation
disp('Running Geothermal Doublet Simulation...');
solver = NonLinearSolver();
[wellSols, states, report] = simulateScheduleAD(state0, model, schedule, 'NonLinearSolver', solver);
disp('Geothermal Doublet Simulation complete!');
