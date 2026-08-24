---
name: mrst-visualization
description: Render 3D unstructured grids, well trajectories, slices, time-series production data, and interactive toolbars using the mrst-gui module.
---

# MRST Visualization & Plotting

MRST uses unstructured grids (`G`), meaning standard MATLAB plotting functions (`surf`, `contourf`, `plot3`) **will fail**. You must use MRST's dedicated visualization API, primarily found in the `mrst-gui` module.

## Prerequisites

> Before using this skill, ensure you've consulted:
> - `mrst-gridding` — for grid structures
> - `mrst-ad-oo` or `mrst-core-procedural` — to generate `states` and `wellSols`

## Core Paradigms

### 1. 3D Grid & Cell Data (`plotGrid`, `plotCellData`)
- **`plotGrid(G)`**: Renders the skeleton/edges of the grid. Use `'FaceAlpha'` and `'EdgeAlpha'` for transparency.
- **`plotCellData(G, data, mask)`**: Renders cell values. The optional `mask` is a logical array (size `G.cells.num x 1`) to slice open 3D models and look inside.

### 2. Wells (`plotWell`, `plotWellSols`)
- **`plotWell(G, W)`**: Renders 3D well trajectories in the grid.
- **`plotWellSols(wellSols, time)`**: Opens a highly customized, interactive figure for time-series production data (BHP, FOPR, Water Cut).

### 3. Interactive Viewing (`plotToolbar`)
- **`plotToolbar(G, states)`**: Creates an interactive UI allowing the user to scrub through simulation time-steps and toggle between different variables (Pressure, Saturation) with drop-down menus.

---

## Agent Instructions: Initialization

Always include the `mrst-gui` module:
```matlab
run('database/MRST-main/startup.m');
mrstModule add mrst-gui
```

## Standard Workflows

### Sliced 3D Reservoir with Wells
```matlab
figure;
% Plot the outer grid with transparency
plotGrid(G, 'FaceAlpha', 0.1, 'EdgeAlpha', 0.1);
hold on;

% Slice the reservoir: only show cells where X > 500
mask = G.cells.centroids(:,1) > 500;
plotCellData(G, state.s(:,1), mask);
colorbar;

% Overlay well trajectories
plotWell(G, W, 'color', 'r', 'linewidth', 2);
view(3); camlight;
```

### Plotting Production Curves
If you ran `simulateScheduleAD`, you have `wellSols` (a cell array of structs). Plotting is a one-liner:
```matlab
% time_steps is an array of cumulative time in seconds
plotWellSols(wellSols, cumsum(schedule.step.val));
```

### Interactive Time-Scrubber
```matlab
figure;
plotToolbar(G, states);
view(3);
```

## Cross-References
- `mrst-diagnostics`: Contains specialized visualization like `interactiveDiagnostics`.
- **References**:
  - [Visualization Best Practices: MRST Plotting Invariants](references/visualization_best_practices.md)
