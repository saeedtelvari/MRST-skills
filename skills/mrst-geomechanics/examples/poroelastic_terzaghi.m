% poroelastic_terzaghi.m
% Example of the classic Terzaghi consolidation problem using MRST's
% coupled mechanics and fluid flow solvers.

% Initialize MRST
run('database/MRST-main/startup.m');

% Add necessary modules
mrstModule add ad-mechanics vemmech ad-core ad-props ad-blackoil
gravity off; % Ignore gravity for the analytic problem setup

% 1. Build Grid (1D Vertical Column)
layers = 20;
L = 10; % 10 meters tall
G = cartGrid([1, 1, layers], [1, 1, L]);
G = computeGeometry(G);
G = createAugmentedGrid(G); % Required for VEM mechanics
Nc = G.cells.num;

% 2. Define Material Properties
E = 5 * giga * Pascal; % Young's modulus
nu = 0.3;              % Poisson's ratio
K = E / (3 * (1 - 2*nu));
alpha = 0.9;           % Biot Willis coefficient
perm = 300 * milli * darcy;
poro = 0.25;
Kf = 1.96 * giga * Pascal; % fluid bulk modulus
pRef = 0;

rock = struct('perm', perm * ones(Nc, 1), ...
              'poro', poro * ones(Nc, 1), ...
              'alpha', alpha * ones(Nc, 1));

pvMult = (1-alpha) * (alpha-poro) / poro / K; 
fluid = initSimpleADIFluid('phases', 'W', ...
                           'mu'    , 1 * centi * poise, ...
                           'rho'   , 1000 * kilogram / meter^3, ...
                           'c'     , 1 / Kf, ...
                           'cR'    , pvMult, ...
                           'pRef'  , pRef);

% 3. Mechanical Boundary Conditions
% Fix bottom nodes in all directions (locked)
bottom_nodes = find(G.nodes.coords(:,3) == max(G.nodes.coords(:,3)));
% Roller side boundaries (no horizontal movement)
side_nodes = find(sqrt(sum(G.nodes.coords(:,1:2).^2, 2)) > 1e-5);
side_nodes = setdiff(side_nodes, bottom_nodes);

Nb = numel(bottom_nodes);
Ns = numel(side_nodes);

el_bc.disp_bc.nodes = [bottom_nodes; side_nodes];
el_bc.disp_bc.uu = repmat([0, 0, 0], Nb + Ns, 1);
el_bc.disp_bc.mask = [repmat([true, true, true], Nb, 1); ... % locked bottom
                      repmat([true, true, false], Ns, 1)];   % roller side

% Force applied to top faces
top_faces = find(G.faces.centroids(:,3) == min(G.faces.centroids(:,3)));
top_force = 1e7 * Pascal;
el_bc.force_bc.faces = top_faces;
el_bc.force_bc.force = repmat([0, 0, top_force], numel(top_faces), 1);

load_fn = @(x) zeros(size(x, 1), 3); % no body forces

mech_problem = struct('E'    , E * ones(Nc, 1) , ...
                      'nu'   , nu * ones(Nc, 1), ...
                      'el_bc', el_bc, ...
                      'load' , load_fn);

% 4. Create Coupled Model
model = MechFluidFixedStressSplitModel(G, rock, fluid, mech_problem);

% 5. Initial State
num_mech_unknowns = sum(~model.mechModel.operators.isdirdofs);
initState = struct('pressure', pRef * ones(Nc, 1), ...
                   'xd', zeros(num_mech_unknowns, 1));
initState = addDerivedQuantities(model.mechModel, initState);

% 6. Schedule (Fluid Boundary Condition at top)
bc.face  = top_faces;
bc.type  = repmat({'pressure'}, 1, numel(top_faces));
bc.value = repmat(pRef, numel(top_faces), 1);
bc.sat   = ones(numel(top_faces), 1);

c_diff = perm / (fluid.muW(pRef) * 1e-10); % rough estimate for tau scaling
tau = c_diff / L^2;
tsteps = [1e-4; 1e-3; 1e-2; 0.1; 0.5; 1.0] * L^2 / c_diff;

schedule = struct('step', struct('val', tsteps, 'control', ones(numel(tsteps), 1)), ...
                  'control', struct('W', [], 'bc', bc));

% 7. Simulate
[~, states, report] = simulateScheduleAD(initState, model, schedule);

% 8. Plot Results
top_node = find(G.nodes.coords(:,3) == 0, 1);
w_top = cellfun(@(s) s.uu(top_node, 3), states);
disp('Vertical displacement at top over time (meters):');
disp(w_top);
