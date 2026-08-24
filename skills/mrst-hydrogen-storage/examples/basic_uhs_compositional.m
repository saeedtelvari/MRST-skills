%% Basic Underground Hydrogen Storage (UHS) Example
% Demonstrates a basic compositional setup for H2 injection into a CH4 reservoir.

% 1. Initialize MRST Setup
run('database/MRST-main/startup.m');

% 2. Add required modules
mrstModule add ad-core ad-props compositional

%% Grid and Rock
G = cartGrid([20, 1, 10], [1000, 50, 100]*meter);
G = computeGeometry(G);
rock = makeRock(G, 100*milli*darcy, 0.25);

%% Compositional Mixture Setup
disp('Setting up Compositional Mixture for H2-CH4...');
names = {'H2', 'CH4'};
Tc = [33.145, 190.56]; % Critical temp (K)
Pc = [12.96, 45.99]*barsa; % Critical pressure
omega = [-0.219, 0.011]; % Acentric factor
mw = [0.002016, 0.01604]; % Molar mass (kg/mol)
Vc = [0.065, 0.098]; % Critical volume (placeholder)

mixture = CompositionalMixture(names, Tc, Pc, Vc, omega, mw);
mixture.bic = [0 0; 0 0]; % Binary interaction coeffs (zeros for ideal mixing)

% Define an underlying flow fluid for relperms
flowfluid = initSimpleADIFluid('phases', 'G', 'n', 2);

%% Model
% Use NaturalVariablesCompositionalModel for multi-component gas flow
model = NaturalVariablesCompositionalModel(G, rock, flowfluid, mixture, 'water', false);

%% Initial State (CH4 Filled)
% 100 bars, 300 K, purely gas phase (S_g=1), composition z0 = [0.0 H2, 1.0 CH4]
s0 = 1.0;
z0 = [0.0, 1.0];
state0 = initCompositionalState(model, 100*barsa, 300, s0, z0);

%% Schedule (Cyclic Injection/Production)
% Injector/Producer at one end
W = addWell([], G, rock, 1, 'Type', 'bhp', 'Val', 120*barsa, ...
            'comp_i', [1.0], 'name', 'InjProd'); % comp_i here just tracks phase (100% gas)
W(1).components = [1.0, 0.0]; % Injection composition (100% H2, 0% CH4)

% 1. Charge cycle (Inject H2)
step1.val = repmat(10*day, 3, 1);
step1.control = ones(3, 1);

% 2. Discharge cycle (Produce mixture)
W_prod = W;
W_prod(1).val = 80*barsa; % Lower BHP to produce

step2.val = repmat(10*day, 3, 1);
step2.control = 2 * ones(3, 1);

schedule.control = [struct('W', W), struct('W', W_prod)];
schedule.step.val = [step1.val; step2.val];
schedule.step.control = [step1.control; step2.control];

%% Simulation
disp('Running UHS cyclic simulation...');
solver = NonLinearSolver();
[wellSols, states, report] = simulateScheduleAD(state0, model, schedule, 'NonLinearSolver', solver);
disp('UHS Simulation complete!');
