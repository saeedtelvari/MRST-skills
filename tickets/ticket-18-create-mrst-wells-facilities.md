Type: task
Status: resolved
Blocked by: 

## Question

Create the `mrst-wells-facilities` skill. Focus on `facility`, `ad-vfp`, Multi-Segment Wells (MSW), and group controls. 

**Labels**: `wayfinder:task`, `engineering`

## Specification

1. **`SKILL.md`**: Core instructions on setting up advanced well architectures beyond simple bhp/rate controls.
2. **`references/vfp_and_msw.md`**: Detailed reference on how Vertical Flow Performance (VFP) tables are formatted and interpolated in MRST, and the API for setting up friction in Multi-Segment Wells.
3. **`examples/advanced_well_controls.m`**: A script showing a well under group control limits or utilizing a VFP table for lift performance.

## Answer
Created the `mrst-wells-facilities` skill, containing:
1. `SKILL.md` mapping the `FacilityModel`, `VFPTable`, and `convert2MSWell` paradigms.
2. `references/wells_best_practices.md` detailing the structural invariants, specifically how VFP units work and how group limits structurally override individual constraints via `W(i).type = 'group'`.
3. `examples/advanced_well_controls.m` implementing a minimal two-phase AD simulation with two producers operating under a shared `rate` group limit, implemented via the `geothermal` module's `addFacilityGroup` logic.
