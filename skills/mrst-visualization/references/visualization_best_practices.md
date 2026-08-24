# Visualization Best Practices: MRST Plotting Invariants

This document outlines structural invariants and framework traps when using MRST's visualization API. MRST uses unstructured grids, so standard MATLAB plotting functions (`surf`, `contourf`) will not work.

## 1. `plotCellData` Cell Selection

**Invariant**: `plotCellData(G, data, cells)` accepts the third argument as either:
- A **numeric vector** of cell indices (e.g., `[1, 5, 10]`)
- A **logical vector** of size `G.cells.num × 1` (e.g., `G.cells.centroids(:,1) > 500`)

Both forms are valid. The function internally converts logical masks to index vectors via `find()`.

**Framework Traps**:
- **Data Size Mismatch**: If `data` has `G.cells.num` rows, it will be indexed by the selected cells. If `data` has `numel(cells)` rows, it is used as-is for the subset. Passing a data vector of the wrong size will error. Always ensure `size(data, 1)` is either `G.cells.num` or `numel(cells)`.
- **Empty Selection**: Passing an empty `cells` vector triggers a warning and produces no graphical output (returns `h = -1`). This is not an error, but the agent should check that the selection is non-empty.

## 2. `plotToolbar` and State Cell Arrays

**Invariant**: `plotToolbar(G, states)` expects `states` to be a **cell array** of state structs (as returned by `simulateScheduleAD`). Each state must contain the same fields.

**Framework Traps**:
- **Single State**: If you pass a single state struct instead of a cell array, `plotToolbar` will error. Wrap it: `plotToolbar(G, {state})`.
- **Missing Fields**: If states from different time steps have different fields (e.g., one step converged and produced `FlowProps` while another didn't), the toolbar will error when switching to the step with missing fields.

## 3. `plotWellSols` Time Vector

**Invariant**: `plotWellSols(wellSols, time)` expects `time` as a vector of **cumulative** times in seconds, not time-step sizes.

**Framework Trap**: Passing `schedule.step.val` directly (which contains time-step *sizes*, not cumulative times) will produce an incorrect x-axis. Use `cumsum(schedule.step.val)`.

## 4. Color and Axis Conventions

**Invariant**: MRST sets `'ZDir', 'reverse'` automatically for 3D grids (depth increases downward, matching reservoir engineering convention).

**Framework Trap**: If you manually set `axis` properties after `plotCellData`, you may inadvertently reset `ZDir` to `'normal'`, causing the reservoir to appear upside-down. Apply axis customizations *before* calling MRST plotting functions, or re-set `ZDir` afterward.
