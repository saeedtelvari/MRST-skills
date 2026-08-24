% sensitivity_analysis.m
run('database/MRST-main/startup.m');
mrstModule add ad-core ad-props ad-blackoil optimization

% 1. Set up forward simulation
G = cartGrid([20, 20, 1], [200, 200, 10]);
G = computeGeometry(G);
rock = makeRock(G, 100*milli*darcy, 0.2);

fluid = initSimpleADIFluid('mu', [1, 5, 0]*centi*poise, ...
                           'rho', [1000, 800, 0]*kilogram/meter^3, ...
                           'n', [2, 2, 0]);
c = 1e-5/barsa;
p_ref = 200*barsa;
fluid.bO = @(p) exp((p - p_ref)*c);

model = GenericBlackOilModel(G, rock, fluid, 'gas', false);
state0 = initResSol(G, 200*barsa, [0, 1]);

W = [];
W = addWell(W, G, rock, 1, 'Type', 'rate', 'Val', 100*meter^3/day, 'Name', 'I1', 'comp_i', [1 0], 'Sign', 1);
W = addWell(W, G, rock, G.cells.num, 'Type', 'bhp', 'Val', 150*barsa, 'Name', 'P1', 'comp_i', [0 1], 'Sign', -1);

schedule.step.val = [100, 100, 100, 100]' * day;
schedule.step.control = [1, 2, 3, 4]';
[schedule.control(1:4).W] = deal(W);

% Run forward simulation
disp('Running forward simulation...');
[wellSols, states] = simulateScheduleAD(state0, model, schedule);

% 2. Define Objective (Cumulative Oil Production)
% By setting OilPrice=1 and costs/discounts=0, NPVOW calculates dt * (-1 * qOs),
% which is exactly the cumulative oil production (since qOs is negative for producers).
npvopts = {'OilPrice', 1, 'WaterProductionCost', 0, 'WaterInjectionCost', 0, 'DiscountFactor', 0};
obj = @(model, states, schedule, varargin) NPVOW(model, states, schedule, varargin{:}, npvopts{:});

% 3. Compute Adjoint Gradients
disp('Computing adjoint gradients backward in time...');
objh = @(tstep, m, st) obj(m, states, schedule, 'ComputePartials', true, 'tStep', tstep, 'state', st);
g = computeGradientAdjointAD(state0, states, model, schedule, objh);

% `g` is a cell array (one cell per control step) containing the gradient wrt each well's control.
% Let's extract the sensitivity w.r.t the injector rate (well 1).
sens_I1 = cellfun(@(v) v(1), g); % Gradient of CumOil wrt Injector Rate

% 4. Visualize
figure;
bar(sens_I1);
title('Sensitivity of Cumulative Oil Production to Injection Rate');
xlabel('Control Step');
ylabel('Gradient (d(CumOil) / d(q_{inj}))');

disp('Interpretation: Control steps with higher gradients indicate periods');
disp('where increasing the injection rate has the largest impact on total oil recovery.');
