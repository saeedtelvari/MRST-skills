% basic_dfm_fracture.m
run('database/MRST-main/startup.m');
mrstModule add dfm incomp

% Create Cartesian grid
G = cartGrid([10, 10], [10, 10]);
G = computeGeometry(G);

% Define fracture at x = 5 (middle)
fracFaces = find(G.faces.centroids(:,1) == 5);
G.faces.tags = zeros(G.faces.num, 1);
G.faces.tags(fracFaces) = 1;

% Assign aperture
aperture = 0.001;
apt = zeros(G.faces.num, 1);
apt(fracFaces) = aperture;

% Add hybrid cells for DFM
G = addhybrid(G, G.faces.tags > 0, apt);
G = computeGeometry(G);

rock = makeRock(G, 10*milli*darcy, 0.2);
hybridInd = find(G.cells.hybrid);
rock.perm(hybridInd, :) = aperture^2/12;
rock.poro(hybridInd) = 0.5;

fluid = initSimpleFluid('mu', [1, 1]*centi*poise, 'rho', [1000, 1000]*kilogram/meter^3, 'n', [1, 1]);

% Compute TPFA and hybrid transmissibilities
T = computeTrans_DFM(G, rock, 'hybrid', true);
[G, T2] = computeHybridTrans(G, T);

% Add wells
W = addWell([], G, rock, 1, 'type', 'rate', 'val', 1, 'comp_i', [1 0]);
W = addWell(W, G, rock, G.cells.num, 'type', 'rate', 'val', -1, 'comp_i', [0 1]);

state = initState(G, W, 0, [0 1]);
state = incompTPFA_DFM(state, G, T, fluid, 'wells', W, 'c2cTrans', T2);
