---
name: mrst-testing
description: Establish a CI/CD-ready testing framework for custom MRST simulators using matlab.unittest.
---

# MRST Testing Skill

This skill outlines how to establish a robust, CI/CD-ready testing framework for custom MRST simulators, utilizing MATLAB's built-in `matlab.unittest` framework. Writing unit tests is crucial for verifying Jacobian gradients, mass conservation, and physical model behavior as you extend MRST.

## Prerequisites

> Before using this skill, ensure you've consulted:
> - `mrst-ad-oo` — for understanding the Automatic Differentiation and Object-Oriented simulation paradigms.
> - `mrst-custom-physics` — for understanding how custom `PhysicalModel` subclasses are built.

## Core Paradigms

MRST testing centers around creating subclassed `matlab.unittest.TestCase` suites. These suites should run assertions against smaller, self-contained setups of MRST's models and solvers.

1. **TestCase Classes**: Create test suites using `classdef MyTest < matlab.unittest.TestCase`.
2. **Setup and Teardown**: Use `TestClassSetup` to initialize MRST and modules once per suite, and `TestMethodSetup`/`TestMethodTeardown` to initialize and clear minimal test grids and physical models.
3. **Jacobian Gradient Verification**: Verify AD derivatives against numerical finite-difference perturbations to guarantee that custom `StateFunction` or model equations calculate exact derivatives.
4. **Tolerance-Based Assertions**: Due to floating-point arithmetic in AD variables and solvers, use numerical tolerance constraints rather than exact matching for states and gradients.

## Agent Instructions: Initialization

Whenever you write a MATLAB script or test suite that uses MRST testing features, you **MUST** ensure the MRST environment is correctly loaded. For `classdef` files, place this initialization within a `TestClassSetup` block (never in the constructor, which runs once per test method and incurs massive overhead):

```matlab
% Initialize MRST Setup (can also be done outside the test if executed interactively)
run('database/MRST-main/startup.m');

% Add required modules
mrstModule add ad-core ad-props ad-blackoil
```

## Agent Instructions: Reference Documentation & Examples

Always consult the curated reference documentation and verified examples in this skill rather than guessing API parameters:

1. **Curated Reference Guide**:
   Read `skills/mrst-testing/references/matlab_unittest_best_practices.md` (MATLAB Unit Testing Best Practices) for exact function signatures, physics formulations, and gotchas.

2. **Executable Examples**:
   Refer to verified, runnable scripts in `skills/mrst-testing/examples/` for canonical setups and workflows.
## Standard Workflows

A standard testing workflow involves writing a test suite and executing it:

1. **Write the Test Suite**: Create an `.m` file containing the `classdef` for your test suite. Set up small, simple grids (e.g., `cartGrid([3, 3, 1])`), initialize the model, and write `Test` methods to verify properties, state initialization, and schedule execution.
2. **Execute Tests**: Tests can be run programmatically or from the MATLAB CLI.
   ```matlab
   results = runtests('TestCustomPhysics.m');
   assert(all([results.Passed]));
   ```

## Best Practices

See `references/matlab_unittest_best_practices.md` for timeless guidance on memory management, structural invariants, and numerical tolerances.

## Cross-References

- **Upstream**: `mrst-custom-physics`, `mrst-ad-oo`
- **Downstream**: None
