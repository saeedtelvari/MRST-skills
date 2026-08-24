% optimize_well_controls.m
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
state0 = initResSol(G, 200*barsa, [0, 1]); % Sw=0, So=1

W = [];
% Injector at (1,1)
W = addWell(W, G, rock, 1, 'Type', 'rate', 'Val', 100*meter^3/day, 'Name', 'I1', 'comp_i', [1 0], 'Sign', 1);
% Producer at (Nx,Ny)
W = addWell(W, G, rock, G.cells.num, 'Type', 'bhp', 'Val', 150*barsa, 'Name', 'P1', 'comp_i', [0 1], 'Sign', -1);

% Schedule: 4 steps of 100 days
schedule.step.val = [100, 100, 100, 100]' * day;
schedule.step.control = [1, 2, 3, 4]';
[schedule.control(1:4).W] = deal(W);

% Run baseline
disp('Running baseline simulation...');
[wellSols_base, states_base] = simulateScheduleAD(state0, model, schedule);

% 2. Optimization setup
li = [0, 200]/day;        % Injector rate limits
lp = [100, 250]*barsa;    % Producer BHP limits
scaling.boxLims = [li; lp];
scaling.obj = 1e6;

u_base = schedule2control(schedule, scaling);

% 3. Define objective function
npvopts = {'OilPrice', 60/stb, 'WaterProductionCost', 6/stb, 'WaterInjectionCost', 6/stb, 'DiscountFactor', 0.05};
obj = @(model, states, schedule, varargin) NPVOW(model, states, schedule, varargin{:}, npvopts{:});
f = @(u) evalObjective(u, obj, state0, model, schedule, scaling);

% 4. Optimize
disp('Running optimization (L-BFGS + Adjoint Gradients)...');
[v, u_opt, history] = unitBoxBFGS(u_base, f);

schedule_opt = control2schedule(u_opt, schedule, scaling);

% 5. Run optimized schedule for comparison
disp('Running optimized simulation...');
[wellSols_opt, states_opt] = simulateScheduleAD(state0, model, schedule_opt);

% Compare NPV
val_base = sum(cell2mat(obj(model, states_base, schedule)));
val_opt  = sum(cell2mat(obj(model, states_opt, schedule_opt)));

fprintf('Baseline NPV:  $%.2e\n', val_base);
fprintf('Optimized NPV: $%.2e\n', val_opt);

% Plot Results
figure;
subplot(1,2,1);
plot(val_base * ones(1, numel(history.val)), '--k', 'LineWidth', 2); hold on;
plot(history.val * scaling.obj, '-o', 'LineWidth', 2);
title('NPV Optimization History');
xlabel('BFGS Iteration');
ylabel('NPV ($)');
legend('Baseline', 'Optimized', 'Location', 'SouthEast');

subplot(1,2,2);
inj_base = arrayfun(@(c) c.W(1).val, schedule.control);
inj_opt  = arrayfun(@(c) c.W(1).val, schedule_opt.control);
bar([inj_base', inj_opt'] * day);
title('Injector Rates');
xlabel('Control Step');
ylabel('Rate (m^3/d)');
legend('Baseline', 'Optimized');
