% pedfm_embedded_fractures.m
run('database/MRST-main/startup.m');
mrstModule add shale ad-core ad-props upr incomp

% Create Cartesian matrix grid
G = cartGrid([10, 10, 1], [100, 100, 10]);
G = computeGeometry(G);
G.rock = makeRock(G, 1*milli*darcy, 0.1);

% Define fracture
fracplanes = struct;
fracplanes(1).points = [20, 20, 0; 80, 80, 0; 80, 80, 10; 20, 20, 10];
fracplanes(1).aperture = 0.01;
fracplanes(1).poro = 0.5;
fracplanes(1).perm = 10*darcy;

% Pre-process grid for pEDFM
tol = 1e-5;
[G, fracplanes] = EDFMshalegrid(G, fracplanes, 'Tolerance', tol);
G = fracturematrixShaleNNC3D(G, tol);
[G, fracplanes] = fracturefractureShaleNNCs3D(G, fracplanes, tol);
G = pMatFracNNCs3D(G, tol); % pEDFM specific NNCs

% Setup operators
ops = setupPEDFMOpsTPFA(G, G.rock, tol);
% At this point, ops contains NNC transmissibilities that can be used by an AD solver
