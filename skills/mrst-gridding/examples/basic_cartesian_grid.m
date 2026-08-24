% basic_cartesian_grid.m
% Example script demonstrating the creation of a simple Cartesian grid.

% 1. Standard initialization
run('database/MRST-main/startup.m');

% 2. Create a 10x10x10 Cartesian grid with physical dimensions 100x100x100
G = cartGrid([10, 10, 10], [100, 100, 100]);

% 3. Compute geometry (volumes, centroids, face normals, areas)
G = computeGeometry(G);

% 4. Assign homogeneous rock properties (100 mD permeability, 0.2 porosity)
rock = makeRock(G, 100*milli*darcy, 0.2);

% 5. Plot the grid
figure;
plotGrid(G);
title('10x10x10 Cartesian Grid');
view(3);
axis tight;
