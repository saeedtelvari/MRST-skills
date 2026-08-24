# MATLAB Unit Testing Best Practices for MRST

When writing tests for MRST classes (like custom physical models, operators, or properties), rely on MATLAB's built-in `matlab.unittest.TestCase` framework. The framework ensures structured setup/teardown and rigorous assertions.

## Structural Pattern

A standard test class for an MRST model inherits from `matlab.unittest.TestCase` and organizes methods into `TestSetup`, `TestMethod`, and `TestTeardown` blocks.

```matlab
classdef TestCustomPhysics < matlab.unittest.TestCase
    
    properties
        % Store reusable test fixtures here
        G
        rock
        fluid
        model
    end
    
    methods(TestClassSetup)
        function initializeMRST(testCase) %#ok<MANU>
            % IMPORTANT: Use TestClassSetup, NOT the constructor.
            % The constructor runs once per test METHOD, but TestClassSetup
            % runs once per test CLASS — avoiding repeated startup overhead.
            run('database/MRST-main/startup.m');
            mrstModule add ad-core ad-props ad-blackoil
        end
    end
    
    methods(TestMethodSetup)
        function setupGridAndModel(testCase)
            % Initialize minimal grid, rock, and fluid
            testCase.G = cartGrid([3, 3, 1]);
            testCase.G = computeGeometry(testCase.G);
            
            testCase.rock = makeRock(testCase.G, 100*milli*darcy, 0.2);
            testCase.fluid = initSimpleADIFluid('phases', 'WOG');
            
            % Initialize the model to be tested
            testCase.model = CustomTwoPhaseModel(testCase.G, testCase.rock, testCase.fluid);
        end
    end
    
    methods(TestMethodTeardown)
        function clearMemory(testCase)
            % Explicitly clear heavy MRST objects to prevent memory leaks across test suites
            testCase.G = [];
            testCase.rock = [];
            testCase.fluid = [];
            testCase.model = [];
        end
    end
    
    methods(Test)
        function testModelInitialization(testCase)
            % Verify the model initializes without error and has correct properties
            testCase.verifyClass(testCase.model, 'CustomTwoPhaseModel');
            testCase.verifyEqual(testCase.model.water, true);
        end
    end
end
```

## Memory Management

MRST grids (`G`), states, and AD variables can be extremely memory-intensive. 
- **Always** use a `TestMethodTeardown` block to explicitly nullify heavy objects (`testCase.G = [];`).
- Do not instantiate a large realistic reservoir model (like SPE10) inside a unit test. Use minimal grid configurations (e.g., `cartGrid([3, 3, 3])`) to keep test execution fast and memory overhead low.

## Numerical Tolerances

Simulation matrices and non-linear iterations operate with floating-point arithmetic. Exact equality (`verifyEqual`) is often inappropriate for numerical vectors.

- Use `matlab.unittest.constraints.IsEqualTo` with a specified `AbsoluteTolerance` or `RelativeTolerance`.
- For standard simulation state variables (like pressure or saturation), a typical `RelativeTolerance` is `1e-6` to `1e-8`.
- For linear solver residuals, an `AbsoluteTolerance` of `1e-8` to `1e-12` is common, depending on the solver.

Example:
```matlab
import matlab.unittest.constraints.IsEqualTo
import matlab.unittest.constraints.RelativeTolerance

actualSaturation = state.s;
expectedSaturation = [0.2; 0.8];
testCase.verifyThat(actualSaturation, IsEqualTo(expectedSaturation, 'Within', RelativeTolerance(1e-6)));
```

## Jacobian Gradient Verification

When writing custom `StateFunction` implementations or overriding `getModelEquations`, validating that "the simulation runs" is insufficient. A subtle typo in chain-rule multiplication or indexing can result in an incorrect Jacobian while the residual still evaluates to zero at initialization.

**Invariant**: All AD-computed derivatives MUST match numerical finite-difference perturbations to within standard relative tolerances ($10^{-5}$ to $10^{-6}$ for central differences).

**Verification Pattern**:
```matlab
% 1. Evaluate StateFunction or model equations with AD variable
p_val = 100 * barsa;
p_ad = initVariablesADI(p_val);
state_ad.pressure = p_ad;
mu_ad = viscFnc.evaluateOnDomain(model, state_ad);
jac_ad = mu_ad{1}.jac{1}; % AD Jacobian

% 2. Evaluate with finite-difference perturbations
dp = 1e-4 * barsa;
state_plus.pressure = p_val + dp;
state_minus.pressure = p_val - dp;
mu_plus = viscFnc.evaluateOnDomain(model, state_plus);
mu_minus = viscFnc.evaluateOnDomain(model, state_minus);
jac_fd = (mu_plus{1} - mu_minus{1}) / (2 * dp); % Central difference

% 3. Assert match
testCase.verifyThat(full(jac_ad), IsEqualTo(jac_fd, 'Within', RelativeTolerance(1e-5)));
```

