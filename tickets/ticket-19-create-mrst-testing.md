Type: task
Status: resolved
Blocked by: 

## Question

Create the `mrst-testing` skill. Focus on establishing a CI/CD-ready testing framework for custom MRST simulators using `matlab.unittest`.

**Labels**: `wayfinder:task`, `software-engineering`

## Specification

1. **`SKILL.md`**: Instructions on how to write unit tests for MRST classes, focusing on verifying Jacobian gradients and mass conservation.
2. **`references/matlab_unittest_guide.md`**: Best practices for writing `matlab.unittest.TestCase` specifically tailored for reservoir simulation matrices and tolerances.
3. **`examples/TestCustomPhysics.m`**: A test suite that runs assertions against the `CustomTwoPhaseModel` we built in `mrst-custom-physics`, proving that testing is robust.

## Answer
The `mrst-testing` skill has been successfully created. The implementation details are as follows:
- Created `SKILL.md` which includes prerequisite links to `mrst-ad-oo` and `mrst-custom-physics`, explains core paradigms of testing subclasses, knowledge retrieval agent instructions, and standard workflows.
- Created `references/matlab_unittest_best_practices.md` with explicit structures for `TestSetup`, `TestTeardown` for memory management of massive objects (like grids `G`), and guidelines on relative numerical tolerances for simulation iterations.
- Created `examples/TestCustomPhysics.m` mapping out a full `matlab.unittest.TestCase` structure that initializes the MRST runtime inside the class's constructor, verifies the custom model properties properly instantiated, executes `simulateScheduleAD`, and validates numeric results.
