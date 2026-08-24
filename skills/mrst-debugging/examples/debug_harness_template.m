%% MRST Minimal Debug Harness Template
% Use this template to miniaturize and isolate simulation errors in <10 seconds.
% Phase 1 of the MRST Debugging Loop: Isolate -> Miniaturize -> Verify Red.

clear; close all; clc;

%% 1. Initialize MRST and Load Core Modules
run('database/MRST-main/startup.m');

% Load standard modules (add custom/specialist modules as needed for your case)
mrstModule add ad-core ad-props ad-blackoil mrst-gui

% Enable verbose diagnostic logs
mrstVerbose(true);

%% 2. Miniaturized Grid & Petrophysics (< 10 cells for instantaneous turnaround)
nx = 3; ny = 3; nz = 1;
G = cartGrid([nx, ny, nz], [30, 30, 10]*meter);
G = computeGeometry(G);

rock = makeRock(G, 100*milli*darcy, 0.25);

%% 3. Standard Minimal Fluid & Model
fluid = initSimpleADIFluid('phases', 'WO', ...
                           'mu'    , [1, 5]*centi*poise, ...
                           'rho'   , [1000, 850]*kilogram/meter^3, ...
                           'n'     , [2, 2]);

% --- Replace with your custom model subclass or model configuration here ---
model = TwoPhaseOilWaterModel(G, rock, fluid);

%% 4. Initial Reservoir State
% Inspect: Are initial pressures/saturations physically valid?
p0 = 100 * barsa;
s0 = [0.2, 0.8]; % [Water, Oil]
state0 = initResSol(G, p0, s0);

% State size and invariant assertions (catch dimension errors early)
assert(numel(state0.pressure) == G.cells.num, 'Pressure dimension mismatch');
assert(size(state0.s, 1) == G.cells.num, 'Saturation dimension mismatch');
assert(all(abs(sum(state0.s, 2) - 1.0) < 1e-8), 'Saturations must sum to 1');

%% 5. Minimal Well Configuration and Schedule
% 1 Injector at cell 1, 1 Producer at cell G.cells.num
W = addWell([], G, rock, 1, 'Type', 'bhp', 'Val', 150*barsa, 'Radius', 0.1, 'comp_i', [1, 0], 'Sign', 1);
W = addWell(W, G, rock, G.cells.num, 'Type', 'bhp', 'Val', 50*barsa, 'Radius', 0.1, 'comp_i', [0, 1], 'Sign', -1);

% Single short timestep (1 day) to test immediate step convergence
schedule = simpleSchedule(1*day, 'W', W);

%% 6. Validate Model Setup
forces = getValidDrivingForces(model, 'W', W);
try
    model = model.validateModel(forces);
    disp('Model validation: PASSED.');
catch err
    fprintf('Model validation FAILED with message:
%s
', err.message);
    rethrow(err);
end

%% 7. Configure NonLinear & Linear Solvers
% Technique: Swap to direct solver (BackslashSolverAD) to isolate whether failure
% is caused by physics/discretization vs preconditioner/CPR issues.
solver = NonLinearSolver('verbose', true, 'maxIterations', 25);
solver.LinearSolver = BackslashSolverAD(); 
% solver.LinearSolver = CPRSolverAD(); % Uncomment to test iterative CPR solver

%% 8. Run Miniaturized Simulation
fprintf('
--- Running Minimal Debug Simulation ---
');
try
    [wellSols, states, report] = simulateScheduleAD(state0, model, schedule, 'NonLinearSolver', solver);
    fprintf('
=== Miniaturized simulation completed successfully! ===
');
catch e
    fprintf('
[DEBUG HARNESS CAUGHT FAILURE]
');
    fprintf('Error Identifier: %s
', e.identifier);
    fprintf('Error Message:    %s
', e.message);
    fprintf('Stack Trace Top:  %s (Line %d)
', e.stack(1).file, e.stack(1).line);
end
