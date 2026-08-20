# Handoff: graphify knowledge graph builds on MRST codebase

**Date:** 2026-06-29
**Working directory:** `c:\MyFiles\MRST-skills`
**Model:** switched to `claude-sonnet-5` at end of session (was on `claude-sonnet-4-6` for the work described below)

## What this session did

Ran `/graphify` four times, incrementally growing a knowledge graph over MRST
(MATLAB Reservoir Simulation Toolbox) modules at `database/MRST-main/`:

1. `core` + `autodiff` + `solvers` → 2,288 nodes, 1,260 edges
2. + `multiscale` → 2,683 nodes, 1,139 edges, 2,183 communities
3. + `co2lab` → 3,013 nodes, 1,260 edges, 2,457 communities
4. + `visualization` (**current graph**) → **3,045 nodes, 1,292 edges, 2,461 communities**

All outputs live in `c:\MyFiles\MRST-skills\graphify-out\`:
- `graph.json` — raw graph data (GraphRAG-ready)
- `graph.html` — interactive visualization
- `GRAPH_REPORT.md` — full audit report (god nodes, surprising connections, hyperedges, all 2,461 communities with cohesion scores)
- `.graphify_labels.json` — the 43 largest communities' human-readable labels (C0–C42)
- `cost.json` — 6 runs total, all through subagent-dispatched semantic extraction (no Gemini key set, so $0 token cost recorded — cost tracking under-reports because subagent token usage isn't wired into `input_tokens`/`output_tokens`)
- `.graphify_python`, `.graphify_root` — pinned interpreter (`C:\Users\st4014\AppData\Roaming\uv\tools\graphifyy\Scripts\python.exe`) and scan root (`C:\MyFiles\MRST-skills\database\MRST-main`)

## Key findings surfaced in Run 4

**God nodes (unchanged across runs 3→4):** `TensorComp` (29), `Graph` (21), `Options` (21), `amg_opts` (17), `BasicAD` (17), `EVProblem` (14), `solver_opts` (14), DFM Module (14), `EVProblem` (13), `solve_cpr()` (12).

**New in Run 4 — surprising connection:** `Discrete Fracture Model (DFM) Module` (solvers/dfm) semantically links to `EDFM Alternative Codes` (solvers/hfm/edfm-hw) — two different fracture-discretization approaches that don't call each other but solve the same problem. This surfaced only after `visualization` was added and communities re-clustered.

**visualization module added 32 nodes / 0 new code entities.** All 204 `.m` files in `visualization/` (diagnostics, mrst-gui, streamlines) were AST-extracted but contributed no new symbol nodes — they're purely compositional (call into existing core/autodiff abstractions to render results). The only new nodes came from 32 previously-uncached `mrst-gui/icons/*.gif|png` toolbar icon images, semantically extracted into 8 new small communities (C18, C23, C24, C29(shifted), C36, C38, C39, C41 — see labels file) describing GUI toolbar button groups (playback controls, IJK grid nav, colormap/scale, 3D slicing tools, etc.).

**Last action before this handoff was requested:** the four-section summary (God Nodes / Surprising Connections / new communities / Suggested Questions) had just been presented to the user, ending with an offer to trace:

> "Why do `DFM` (Discrete Fracture Model) and `HFM/EDFM` (Embedded Discrete Fracture Model) connect — are they competing implementations of the same physical model, or complementary?"

**The user has not yet responded to that offer.** This is the natural next step if they want to continue exploring — run `graphify query "..."` on that question and walk the path.

## Process notes / gotchas hit this session (useful if rebuilding again)

- **PowerShell here-strings via `-c @'...'@` inline in `Bash`/`PowerShell` tool calls fail** — the tool's here-string handling doesn't like it embedded in a single command string. Workaround used: write the Python script to a `.py` file in the scratchpad dir with `Write`, then invoke `& $py script.py`.
- **Background `Start-Job` breaks graphify's AST extraction** — `graphify.extract.extract()` uses `concurrent.futures.ProcessPoolExecutor`, and spawning that from inside a `Start-Job` child process fails with a multiprocessing spawn error (`FileNotFoundError` chased back to a `runpy` frozen-module issue). Fix: run AST extraction as a normal (non-job) foreground/background **Bash/PowerShell tool call** (using the tool's own `run_in_background: true`), never nest it inside a PowerShell `Start-Job`.
- **`graphify.export` has no `visualize` module.** The skill's own instructions say `graphify export html`, but the CLI wasn't resolving cleanly in this environment; ended up calling `graphify.export.to_html(G, communities, output_path, community_labels=...)` directly — signature is `(G, communities, output_path, community_labels=None, member_counts=None, node_limit=None)`.
- Detection/cache/AST steps all use **absolute paths** (`C:/MyFiles/MRST-skills/...`) inside the Python scripts rather than relative — this session's cwd handling was inconsistent between the interactive shell and background jobs, so absolute paths avoided a class of `FileNotFoundError`.
- The multi-path merge pattern (detect each module path separately, concatenate `files` dict, sum `total_files`/`total_words`, keep `scan_root` = common parent) has now been used cleanly across all 4 runs — reuse it verbatim for future module additions.

## Suggested skills for the next session

- **`graphify`** — if the user wants to (a) trace the DFM/HFM question via `graphify query`, (b) add more MRST modules (remaining untouched top-level dirs under `database/MRST-main/` not yet globbed — check `ls database/MRST-main` for anything outside {core, autodiff, solvers, multiscale, co2lab, visualization}), or (c) ask any codebase question — the graph already exists at `graphify-out/graph.json`, so per the skill's own fast-path rule, jump straight to `## For /graphify query` and skip rebuild steps entirely unless the user names new paths.
- **`caveman`** — only if the user explicitly asks for terser responses; not indicated by anything in this session.
- No other skill is obviously relevant; this was a single-tool (`graphify`) session.

## Do NOT re-run

Do not re-run detection/AST/semantic extraction for `core`, `autodiff`, `solvers`, `multiscale`, `co2lab`, or `visualization` — all are cached (both in graphify's semantic cache keyed by file hash under `root=database/MRST-main`, and structurally in `graph.json`). A fresh `/graphify` invocation naming the same paths again will hit near-100% cache and just rebuild communities/report — cheap, but unnecessary unless the user wants a `--update` or is adding a genuinely new path.
