Type: task
Status: resolved
Blocked by:

## Question

Create the `mrst-visualization` skill to teach agents how to use MRST's specific visualization APIs (`mrst-gui` module) for unstructured grids, 3D slicing, well rendering, and production curves, bypassing standard MATLAB plotting limitations.

**Labels**: `wayfinder:task`

## Specification

### Deliverables

1. `skills/mrst-visualization/SKILL.md`
   - **Core Paradigms**: `plotGrid` (transparency, edges), `plotCellData` (logical masking/slicing), `plotWell` (3D well trajectories), `plotWellSols` (time-series production data), and `plotToolbar` (interactive time-scrubbing).
2. `skills/mrst-visualization/examples/advanced_plotting.m`
   - A complete script that runs a lightning-fast mini simulation, then creates multiple figures demonstrating:
     - A 3D sliced grid with well overlays.
     - Production curves (BHP, rates) using `plotWellSols`.
     - An interactive toolbar setup.

### Rationale
Agents frequently fail when attempting to use standard MATLAB `surf` or `plot3` on MRST's unstructured `G` structs. A dedicated visualization skill ensures results are presented correctly.
