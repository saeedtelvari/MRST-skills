---
name: mrst-wells-facilities
description: Build advanced well architectures, Multi-Segment Wells (MSW), VFP tables, and group controls in MRST.
---

# MRST Wells and Facilities Skill

This skill provides the knowledge and workflow for building advanced well controls and modeling wellbore lift curves (VFP) and multi-segment completions (MSW) in MRST. 

## Prerequisites

> Before using this skill, ensure you've consulted:
> - `mrst-gridding` — for setting up the basic grid geometries
> - `mrst-ad-oo` — for basic Automatic Differentiation and Object-Oriented (AD-OO) setup

## Core Paradigms

The wells and facilities framework relies on these core components:
1. **`FacilityModel`**: Often wrapped implicitly, but explicitly instantiated as `GenericFacilityModel` to couple wells and groups to the reservoir.
2. **Multi-Segment Wells (`convert2MSWell`)**: Represents well segments as separate nodes, allowing simulation of frictional pressure drops and inflow control devices/valves.
3. **VFP Tables (`VFPTable`)**: Used for representing Vertical Flow Performance. Can be attached to a `SimpleWell` object to model complex wellbore hydraulics instead of explicit segment modeling.
4. **Group Controls**: Allowing an entire group of wells to operate under a shared constraint (e.g., maximum field production).

## Agent Instructions: Initialization

Whenever you write a MATLAB script for advanced wells or group controls, you **MUST** include the following initialization sequence at the top of your script:

```matlab
% Initialize MRST Setup
run('database/MRST-main/startup.m');

% Add required modules for wells and facilities
mrstModule add ad-core ad-props ad-blackoil
% For group controls and advanced limits:
mrstModule add geothermal
% For VFP tables and MSW:
mrstModule add deckformat
```

## Agent Instructions: Reference Documentation & Examples

Always consult the curated reference documentation and verified examples in this skill rather than guessing API parameters:

1. **Curated Reference Guide**:
   Read `skills/mrst-wells-facilities/references/wells_best_practices.md` (Wells & Facilities Best Practices) for exact function signatures, physics formulations, and gotchas.

2. **Executable Examples**:
   Refer to verified, runnable scripts in `skills/mrst-wells-facilities/examples/` for canonical setups and workflows.
## Standard Workflows

### 1. Multi-Segment Wells (MSW)
Instead of treating the well as a single node with an instantaneous PI-based pressure drop, you can define nodes along the trajectory.

```matlab
% Base well
prodS = addWell([], G, rock, cells, 'name', 'prod', 'type', 'rate', 'val', -8e5*meter^3/day);

% Convert to Multi-Segment Well
% (topo, cell2node, lengths, diam, and vols must be defined)
prodMS = convert2MSWell(prodS, 'cell2node', cell2node, 'topo', topo, 'G', G, 'vol', vols, ...
                   'nodeDepth', depths, 'segLength', lengths, 'segDiam', diam);

% Apply friction or valve models to segments
prodMS.segments.flowModel = @(v, rho, mu) [...
    wellBoreFriction(v(wbix), rho(wbix), mu(wbix), prodMS.segments.diam(wbix), ...
                     prodMS.segments.length(wbix), 1e-4, 'massRate'); ...
    nozzleValve(v(vix)/30, rho(vix), 0.0025, 0.7, 'massRate')];
```

### 2. Group Controls
You can configure a network of wells that operate under a collective constraint (like a shared pipeline capacity).

```matlab
% 1. Create standard wells
W = addWell([], G, rock, 1, 'type', 'bhp', 'val', 100*barsa, 'name', 'PROD1');
W = addWell(W,  G, rock, 2, 'type', 'bhp', 'val', 100*barsa, 'name', 'PROD2');

% 2. Create the facility group
groups = addFacilityGroup([], {'PROD1', 'PROD2'}, 'name', 'ProdGroup');

% 3. Delegate well control in the schedule
ctrl = struct('W', W);
[ctrl.W.type] = deal('group'); % Hands over control to the group

% 4. Assign limits to the group
ctrl.groups = groups;
ctrl.groups(1).type = 'rate';
ctrl.groups(1).val = 20 * (meter^3/day);
ctrl.groups(1).sign = -1; % -1 for production

schedule.control = ctrl;
```

## Cross-References

- **Downstream**: `mrst-optimization`, `mrst-co2-storage`, `mrst-geothermal`
