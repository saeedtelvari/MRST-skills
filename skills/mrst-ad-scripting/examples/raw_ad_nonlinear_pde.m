% Example: Solving a nonlinear PDE using raw AD variables
% We solve: div( (1 + p.^2) * grad(p) ) = q

% Initialize MRST Setup
run('database/MRST-main/startup.m');

% Add required modules
mrstModule add ad-core mrst-gui

%% 1. Set up Grid and Geometry
% Create a 10x10 Cartesian grid
G = computeGeometry(cartGrid([10 10],[1 1]));
nc = G.cells.num;

%% 2. Define Discrete Operators
% Extract interior face neighbors
N = G.faces.neighbors;
N = N(all(N ~= 0, 2), :);
nf = size(N, 1);

% Build connection matrix C
% C maps cell values to face differences
C = sparse([(1:nf)'; (1:nf)'], N, ones(nf,1)*[-1 1], nf, nc);

% Gradient (cell to face) and Divergence (face to cell)
grad = @(x) C * x;
div  = @(x) -C' * x;

% Arithmetic average operator (cell to face)
avg = @(x) 0.5 * abs(C) * x;

%% 3. Setup Initial Conditions and Source Terms
p0 = zeros(nc, 1);
q = zeros(nc, 1);
q(1) = 1;            % Source at cell 1
q(nc) = -1;          % Sink at the last cell

% Initialize AD variable
p = initVariablesADI(p0);

%% 4. Newton-Raphson Loop
max_iter = 20;
tol = 1e-6;
err = inf;
iter = 0;

disp('Starting Newton-Raphson iterations:');
while err > tol && iter < max_iter
    iter = iter + 1;
    
    % Evaluate pressure on faces (averaging)
    face_p = avg(p);
    
    % Nonlinear transmissibility coefficient: K = 1 + p^2
    K = 1 + face_p.^2;
    
    % Assemble equation: div( K * grad(p) ) + q = 0
    eq = div( K .* grad(p) ) + q;
    
    % Anchor pressure at one point to make solution unique
    % (Only necessary if pure Neumann BCs, which is the case here)
    eq(1) = eq(1) + p(1);
    
    % Calculate residual
    err = norm(eq.val, inf);
    fprintf('  Iteration %d, Residual: %e\n', iter, err);
    
    if err < tol
        break;
    end
    
    % Update primary variables using the AD Jacobian
    % eq.jac{1} is the derivative of the equation w.r.t the first AD variable (p)
    p = p - eq.jac{1} \ eq.val; 
end

if err <= tol
    disp('Converged successfully!');
else
    disp('Failed to converge within max iterations.');
end

%% 5. Visualize Results
% Extract numerical values from AD variable
p_val = p.val;

clf;
plotCellData(G, p_val);
colorbar;
title('Solution of Nonlinear PDE: div((1+p^2)grad(p)) = q');
