% basic_compositional_eos.m
% A minimal 3-component compositional simulation using Peng-Robinson EOS
% Demonstrates: CompositionalMixture, NaturalVariablesCompositionalModel, 
%               initCompositionalState, simulateScheduleAD

run('database/MRST-main/startup.m');
mrstModule add ad-core ad-props compositional

% Grid and rock
G = cartGrid([20, 1, 1], [1000, 10, 10]*meter);
G = computeGeometry(G);
rock = makeRock(G, 100*milli*darcy, 0.2);

% Define 3-component mixture (light oil system)
mixture = CompositionalMixture({'Methane', 'nPentane', 'nDecane'});

% Fluid
fluid = initSimpleADIFluid('phases', 'OG', ...
    'mu', [1, 0.05]*centi*poise, ...
    'rho', [700, 100]*kilogram/meter^3);

% Model (Natural Variables formulation)
model = NaturalVariablesCompositionalModel(G, rock, fluid, mixture);

% Initial state: 200 bar, 350 K, fully liquid, composition [0.3, 0.4, 0.3]
state0 = initCompositionalState(G, 200*barsa, 350, [1 0], ...
    [0.3, 0.4, 0.3], model);

% Wells
W = [];
W = addWell(W, G, rock, 1, 'Type', 'rate', 'Val', 1e-3, ...
    'Comp_i', [1, 0], 'Name', 'Inj');
W = addWell(W, G, rock, G.cells.num, 'Type', 'bhp', 'Val', 100*barsa, ...
    'Comp_i', [0, 1], 'Name', 'Prod');

% Schedule
schedule = simpleSchedule(repmat(30*day, 1, 12), 'W', W);

% Simulate
[wellSols, states, report] = simulateScheduleAD(state0, model, schedule);
