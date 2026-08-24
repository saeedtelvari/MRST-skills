% pebi_grid_with_faults.m
% Example script demonstrating the creation of a 2D PEBI/Voronoi grid 
% that conforms to fault and well constraints.

% 1. Standard initialization
run('database/MRST-main/startup.m');
mrstModule add upr

% 2. Define physical domain [xmax, ymax] and base resolution
pdims = [1000, 1000];
resGridSize = 100;

% 3. Define structural constraints (faults, wells)
% cellConstraints accepts a struct where each field is an array of coordinates
% defining a line (e.g., fault) or a point (e.g., well).
constraints = struct();
constraints.fault = [200, 200; 800, 800]; % Line constraint
constraints.well  = [500, 200];           % Point constraint

% 4. Generate 2D PEBI grid
G = pebiGrid2D(resGridSize, pdims, 'cellConstraints', constraints);

% 5. Compute geometry (volumes, centroids, etc.)
G = computeGeometry(G);

% 6. Plot the grid and overlay constraints
figure;
plotGrid(G);
hold on;
plot(constraints.fault(:,1), constraints.fault(:,2), 'r-', 'LineWidth', 2);
plot(constraints.well(1), constraints.well(2), 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 8);
title('2D PEBI Grid conforming to Fault and Well Constraints');
legend('PEBI Grid', 'Fault Constraint', 'Well Constraint', 'Location', 'best');
axis equal tight;
