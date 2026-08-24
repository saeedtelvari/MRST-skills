classdef TestCustomPhysics < matlab.unittest.TestCase
    
    properties
        G
        rock
        fluid
        model
        state
        schedule
    end
    
    methods(TestClassSetup)
        function initializeMRST(testCase) %#ok<MANU>
            % Run MRST startup and load modules ONCE per test class,
            % not per test method (constructor runs per-method).
            run('database/MRST-main/startup.m');
            mrstModule add ad-core ad-props ad-blackoil
            
            % Add path to custom physics example so it can be loaded
            addpath(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'mrst-custom-physics', 'examples'));
        end
    end
    
    methods(TestMethodSetup)
        function setupEnvironment(testCase)
            % Initialize minimal grid, rock, and fluid to keep memory overhead low
            testCase.G = cartGrid([3, 3, 1], [30, 30, 10]);
            testCase.G = computeGeometry(testCase.G);
            
            testCase.rock = makeRock(testCase.G, 100*milli*darcy, 0.2);
            testCase.fluid = initSimpleADIFluid('phases', 'WO', 'mu', [1, 5]*centi*poise, 'rho', [1000, 850]);
            
            % Initialize the custom physical model
            testCase.model = CustomTwoPhaseModel(testCase.G, testCase.rock, testCase.fluid);
            
            % Setup initial state
            testCase.state = initState(testCase.G, [], 100*barsa, [0.2, 0.8]);
            
            % Set up a basic schedule
            W = addWell([], testCase.G, testCase.rock, 1, 'Type', 'bhp', 'Val', 200*barsa, 'Radius', 0.1, 'comp_i', [1, 0]);
            W = addWell(W, testCase.G, testCase.rock, 9, 'Type', 'bhp', 'Val', 50*barsa, 'Radius', 0.1, 'comp_i', [0, 1]);
            testCase.schedule = simpleSchedule(1*day, 'W', W);
        end
    end
    
    methods(TestMethodTeardown)
        function teardownEnvironment(testCase)
            % Explicitly clear heavy MRST objects to avoid memory leaks
            testCase.G = [];
            testCase.rock = [];
            testCase.fluid = [];
            testCase.model = [];
            testCase.state = [];
            testCase.schedule = [];
        end
    end
    
    methods(Test)
        function testModelInitialization(testCase)
            % Verify the model is of the correct class
            testCase.verifyClass(testCase.model, 'CustomTwoPhaseModel');
            
            % Check that Viscosity state function is correctly injected
            viscFnc = testCase.model.PVTPropertyFunctions.Viscosity;
            testCase.verifyClass(viscFnc, 'PressureDependentViscosity');
        end
        
        function testSimulationExecution(testCase)
            % Verify that the model can run a simple simulation schedule without errors
            solver = NonLinearSolver();
            try
                [~, states, ~] = simulateScheduleAD(testCase.state, testCase.model, testCase.schedule, 'NonLinearSolver', solver);
                testCase.verifyNotEmpty(states);
                testCase.verifyEqual(length(states), 1);
            catch e
                testCase.verifyFail(['Simulation failed with error: ', e.message]);
            end
        end
        
        function testNumericalTolerances(testCase)
            % Example of checking state using tolerance constraints
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.RelativeTolerance
            
            % Initialize state and step forward once using basic execution
            solver = NonLinearSolver();
            [~, states, ~] = simulateScheduleAD(testCase.state, testCase.model, testCase.schedule, 'NonLinearSolver', solver);
            
            % Assert final pressure remains physically realistic
            maxP = max(states{1}.pressure);
            minP = min(states{1}.pressure);
            
            % The pressure shouldn't exceed our maximum injector BHP or fall below producer BHP
            % We add a slight margin of error for numerical iterations
            testCase.verifyLessThanOrEqual(maxP, 200*barsa + 1);
            testCase.verifyGreaterThanOrEqual(minP, 50*barsa - 1);
        end
        
        function testJacobianAccuracy(testCase)
            % Verify AD-computed Jacobians against numerical finite-differences.
            % This ensures custom StateFunctions and equations calculate exact derivatives.
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.RelativeTolerance
            
            % 1. Test custom StateFunction derivative directly
            viscFnc = testCase.model.PVTPropertyFunctions.Viscosity;
            p_val = 100 * barsa;
            
            % Evaluate with AD variable (1 independent variable)
            p_ad = initVariablesADI(p_val);
            st_ad.pressure = p_ad;
            mu_ad = viscFnc.evaluateOnDomain(testCase.model, st_ad);
            
            % AD Jacobian for water and oil viscosity w.r.t. pressure
            dmuW_dp_ad = mu_ad{1}.jac{1};
            dmuO_dp_ad = mu_ad{2}.jac{1};
            
            % Numerical finite difference perturbation
            dp = 1e-4 * barsa;
            st_plus.pressure = p_val + dp;
            st_minus.pressure = p_val - dp;
            mu_plus = viscFnc.evaluateOnDomain(testCase.model, st_plus);
            mu_minus = viscFnc.evaluateOnDomain(testCase.model, st_minus);
            
            dmuW_dp_fd = (mu_plus{1} - mu_minus{1}) / (2 * dp);
            dmuO_dp_fd = (mu_plus{2} - mu_minus{2}) / (2 * dp);
            
            % Assert AD Jacobian matches central finite difference within 1e-5 relative tolerance
            testCase.verifyThat(full(dmuW_dp_ad), IsEqualTo(dmuW_dp_fd, 'Within', RelativeTolerance(1e-5)));
            testCase.verifyThat(full(dmuO_dp_ad), IsEqualTo(dmuO_dp_fd, 'Within', RelativeTolerance(1e-5)));
        end
    end
end
