% coupled_flow_mechanics.m
% Example of reservoir depletion causing compaction (subsidence) using MRST.

% Initialize MRST
run('database/MRST-main/startup.m');

% Add necessary modules
mrstModule add ad-mechanics vemmech ad-core ad-props ad-blackoil
gravity on;

% 1. Build Grid (3D Block)
G = cartGrid([10, 10, 5], [1000, 1000, 100]);
G.nodes.coords(:,3) = G.nodes.coords(:,3) + 2000; % Depth of 2000m
G = computeGeometry(G);
G = createAugmentedGrid(G); % Required for VEM mechanics
Nc = G.cells.num;

% 2. Define Material Properties
E = 3 * giga * Pascal; % Young's modulus of reservoir rock
nu = 0.25;             % Poisson's ratio
alpha = 1.0;           % Biot coefficient
perm = 100 * milli * darcy;
poro = 0.2;

rock = struct('perm', perm * ones(Nc, 1), ...
              'poro', poro * ones(Nc, 1), ...
              'alpha', alpha * ones(Nc, 1));

fluid = initSimpleADIFluid('phases', 'W', ...
                           'mu'    , 1 * centi * poise, ...
                           'rho'   , 1000 * kilogram / meter^3, ...
                           'c'     , 4e-10 / Pascal, ...
                           'cR'    , 1e-10 / Pascal, ...
                           'pRef'  , 200 * barsa);

% 3. Mechanical Boundary Conditions
% Fixed bottom boundary (no movement)
bottom_nodes = find(G.nodes.coords(:,3) == max(G.nodes.coords(:,3)));
el_bc.disp_bc.nodes = bottom_nodes;
el_bc.disp_bc.uu = zeros(numel(bottom_nodes), 3);
el_bc.disp_bc.mask = true(numel(bottom_nodes), 3);

% Roller boundaries on the sides (can move vertically but not horizontally)
side_nodes = find(G.nodes.coords(:,1) == 0 | G.nodes.coords(:,1) == max(G.nodes.coords(:,1)) | ...
                  G.nodes.coords(:,2) == 0 | G.nodes.coords(:,2) == max(G.nodes.coords(:,2)));
side_nodes = setdiff(side_nodes, bottom_nodes);
el_bc.disp_bc.nodes = [el_bc.disp_bc.nodes; side_nodes];
el_bc.disp_bc.uu = [el_bc.disp_bc.uu; zeros(numel(side_nodes), 3)];
el_bc.disp_bc.mask = [el_bc.disp_bc.mask; repmat([true, true, false], numel(side_nodes), 1)];

% Overburden weight applied to top faces
top_faces = find(G.faces.centroids(:,3) == min(G.faces.centroids(:,3)));
overburden_stress = 2000 * 9.81 * 2000; % rho * g * h
el_bc.force_bc.faces = top_faces;
el_bc.force_bc.force = repmat([0, 0, overburden_stress], numel(top_faces), 1);

% Body force (gravity)
rock_density = 2500; % kg/m3
load_fn = @(x) repmat([0, 0, rock_density * 9.81], size(x, 1), 1);

mech_problem = struct('E'    , E * ones(Nc, 1) , ...
                      'nu'   , nu * ones(Nc, 1), ...
                      'el_bc', el_bc, ...
                      'load' , load_fn);

% 4. Create Coupled Model
% Using MechFluidFixedStressSplitModel for stable sequential solving
model = MechFluidFixedStressSplitModel(G, rock, fluid, mech_problem);

% 5. Initial State
num_mech_unknowns = sum(~model.mechModel.operators.isdirdofs);
initState = struct('pressure', 200 * barsa * ones(Nc, 1), ...
                   'xd', zeros(num_mech_unknowns, 1));
initState = addDerivedQuantities(model.mechModel, initState);

% 6. Well and Schedule
% Add a producer well in the center
W = addWell([], G, rock, ceil(Nc/2), 'Type', 'bhp', 'Val', 50 * barsa, 'comp_i', 1, 'name', 'PROD');

% Simulate for 5 years
time_steps = repmat(365 * day, 5, 1);
schedule = simpleSchedule(time_steps, 'W', W);

% 7. Simulate
[wellSols, states, report] = simulateScheduleAD(initState, model, schedule);

% 8. Results
top_node = find(G.nodes.coords(:,3) == min(G.nodes.coords(:,3)), 1);
w_top = cellfun(@(s) s.uu(top_node, 3), states);
fprintf('Max subsidence at top after 5 years: %f meters\n', w_top(end) - w_top(1));
