# MRST-Skills: Autonomous Reservoir Simulation Agentic Ecosystem

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Skills: 19](https://img.shields.io/badge/Skills-19%20Standardized-green.svg)](skills_manifest.yaml)
[![Python: >=3.9](https://img.shields.io/badge/Python->=3.9-blue.svg)](pyproject.toml)
[![MRST: 2026+](https://img.shields.io/badge/MRST-Main-orange.svg)](database/MRST-main)

**MRST-Skills** is a production-grade agentic knowledge graph and skill ecosystem for the **MATLAB Reservoir Simulation Toolbox (MRST)**. It enables autonomous AI coding assistants (**Claude Code**, **OpenAI Codex / ChatGPT**, **Google Antigravity**, **Cursor**, **Windsurf**, and **GitHub Copilot**) to design, construct, debug, and optimize complex reservoir simulations without human intervention or framework traps.

---

## ⚡ Quick Installation

### Option 1: Install CLI Package via Pip
```bash
git clone https://github.com/saeedtelvari/MRST-skills.git
cd MRST-skills
pip install -e .
```

### Option 2: Install Skills into your AI Assistant

#### For Anthropic Claude Code:
```bash
# Global install (available across all your projects):
mrst-skills install --target claude --global

# Local project install:
mrst-skills install --target claude
```

#### For Google Antigravity / Gemini CLI:
```bash
mrst-skills install --target antigravity --global
```

#### For Cursor / Windsurf / GitHub Copilot:
```bash
# Configures .cursor/rules/mrst.mdc, .windsurfrules, and .github/copilot-instructions.md
mrst-skills install --target all
```

#### For ChatGPT / OpenAI Codex / Web Agents:
```bash
# Bundles the entire 19-skill ecosystem into a single uploadable/pastable markdown file:
mrst-skills bundle --output mrst_single_prompt.md
```

---

## 🗺️ The 19 Skills Catalog

The ecosystem is organized into monolithic, paradigm-based skills categorized by domain cluster:

| Domain Cluster | Skill | Core MRST Module | Description & Capabilities |
|----------------|-------|------------------|----------------------------|
| **Core & Foundation** | [`mrst-gridding`](skills/mrst-gridding/SKILL.md) | `core`, `deckformat`, `upr` | Cartesian, corner-point, PEBI grids, Eclipse `.DATA` deck import, geometry lifecycle. |
| | [`mrst-core-procedural`](skills/mrst-core-procedural/SKILL.md) | `incomp` | Incompressible single/two-phase flow using procedural TPFA and IMPES solvers. |
| | [`mrst-ad-oo`](skills/mrst-ad-oo/SKILL.md) | `ad-core`, `ad-props`, `ad-blackoil`, `compositional` | Fully implicit AD black-oil and compositional EOS reservoir simulations. |
| **Energy Transition & Storage** | [`mrst-co2-storage`](skills/mrst-co2-storage/SKILL.md) | `co2lab`, `ad-core` | CO₂ sequestration in saline aquifers using Vertical Equilibrium (VE) models. |
| | [`mrst-hydrogen-storage`](skills/mrst-hydrogen-storage/SKILL.md) | `compositional`, `h2store` | Underground Hydrogen Storage (UHS) with cushion gas mixing, methanation & hysteresis. |
| | [`mrst-geothermal`](skills/mrst-geothermal/SKILL.md) | `geothermal`, `ad-core` | Geothermal doublet simulations, heat extraction, and coupled thermo-hydro models. |
| **Advanced & Coupled Physics** | [`mrst-eor`](skills/mrst-eor/SKILL.md) | `ad-eor` | Enhanced Oil Recovery (Polymer and Surfactant flooding, Todd-Longstaff, adsorption). |
| | [`mrst-fractured-reservoirs`](skills/mrst-fractured-reservoirs/SKILL.md) | `dfm`, `shale` (pEDFM) | Discrete Fracture Models (DFM), Embedded DFM (pEDFM), and Non-Neighboring Connections. |
| | [`mrst-geomechanics`](skills/mrst-geomechanics/SKILL.md) | `ad-mechanics`, `vemmech`, `fvbiot` | Coupled poroelasticity, Biot compaction, subsidence, VEM mechanics, caprock integrity. |
| **Solver Stack & Optimization** | [`mrst-linear-solvers`](skills/mrst-linear-solvers/SKILL.md) | `linearsolvers` | Iterative CPR preconditioners, AMG, GMRES, and direct solver acceleration. |
| | [`mrst-optimization`](skills/mrst-optimization/SKILL.md) | `optimization` | Adjoint gradient sensitivity analysis, NPV maximization, and `unitBoxBFGS` well controls. |
| | [`mrst-diagnostics`](skills/mrst-diagnostics/SKILL.md) | `diagnostics`, `upscaling`, `msrsb` | Time-of-flight (TOF), sweep efficiency, Lorenz coefficients, permeability upscaling, MsRSB. |
| **Developer Frameworks** | [`mrst-ad-scripting`](skills/mrst-ad-scripting/SKILL.md) | `ad-core` (ADI) | Raw automatic differentiation (`initVariablesADI`) for rapid custom PDE prototyping. |
| | [`mrst-custom-physics`](skills/mrst-custom-physics/SKILL.md) | `ad-core` (OO) | Subclassing `PhysicalModel` and `StateFunction` for custom non-Newtonian or multi-physics. |
| **Tooling & QA** | [`mrst-wells-facilities`](skills/mrst-wells-facilities/SKILL.md) | `ad-core` | Multisegment wells, group controls, cross-flow, and surface facilities. |
| | [`mrst-visualization`](skills/mrst-visualization/SKILL.md) | `mrst-gui` | 3D reservoir slicing, well curves (`plotWellSols`), and interactive time scrubbers (`plotToolbar`). |
| | [`mrst-debugging`](skills/mrst-debugging/SKILL.md) | (Diagnostics) | 4-phase miniaturization debug loop (<10s iteration) and preconditioner isolation. |
| | [`mrst-testing`](skills/mrst-testing/SKILL.md) | `matlab.unittest` | CI/CD testing framework and finite-difference Jacobian verification tests. |
| **Router** | [`mrst`](skills/mrst/SKILL.md) | (Meta-Router) | Master intent-matching router mapping user goals to skill DAG recipes. |

---

## 📋 The Execution Contract (Invariants)

Every autonomous agent writing or running MRST simulations must adhere to the **5 Core Invariants**:

1. **Explicit Startup**: Standalone scripts must start with:
   ```matlab
   run('database/MRST-main/startup.m');
   mrstModule add <modules>  % e.g. ad-core ad-props ad-blackoil
   ```
2. **SI Units Enforcement**: All MRST operations run strictly in SI units internally ($m, Pa, s, kg$). Use MRST conversion constants (`barsa`, `milli*darcy`, `day`, `centi*poise`, `meter`). Never write raw field-unit numbers.
3. **Geometry Lifecycle**: Calling `computeGeometry(G)` is mandatory after grid construction or deformation.
4. **StateFunctions Grouping**: Primary variable dependencies in custom state functions must declare the `'state'` grouping:
   ```matlab
   gp = gp.dependsOn({'pressure'}, 'state');
   ```
5. **Polymer Initial State**: EOR models with adsorption strictly require:
   ```matlab
   state0.cpmax = zeros(G.cells.num, 1);
   ```

---

## 📚 Self-Contained Knowledge Architecture

Every skill in the ecosystem is packaged with full domain knowledge, eliminating external heavy database or indexing dependencies:

1. **Curated Reference Guides (`references/*_best_practices.md`)**:
   Every skill directory contains exhaustive documentation of mathematical formulations, MRST function APIs, architectural invariants, and critical gotchas (e.g., AD variable groupings, geometry lifecycles, and preconditioner tuning).
2. **Executable Reference Examples (`examples/*.m`)**:
   Complete, standalone, minimal simulation scripts demonstrating canonical setup, solver invocation, and post-processing without external boilerplate.
3. **Declarative Skill Taxonomy & Router (`skills_manifest.yaml` & `skills/mrst/SKILL.md`)**:
   Structured metadata graph mapping high-level user simulation intents directly to prerequisite dependency DAGs.

---

## 🛠️ Multi-Skill Workflows (Recipes)

- **Import Eclipse Model & Run**: `mrst-gridding` ➔ `mrst-ad-oo`
- **CO₂ Plume Migration & NPV Optimization**: `mrst-gridding` ➔ `mrst-co2-storage` ➔ `mrst-optimization`
- **Complex Naturally Fractured Reservoir (Fast)**: `mrst-gridding` ➔ `mrst-fractured-reservoirs` ➔ `mrst-linear-solvers`
- **Fast Heterogeneity Characterization**: `mrst-gridding` ➔ `mrst-core-procedural` ➔ `mrst-diagnostics`
- **Polymer EOR Optimization**: `mrst-gridding` ➔ `mrst-ad-oo` ➔ `mrst-eor` ➔ `mrst-optimization`
- **Custom Physical Equations & Testing**: `mrst-ad-oo` ➔ `mrst-custom-physics` ➔ `mrst-testing`

---

## 📦 Developer Guide: Extending the Ecosystem

To add or modify skills:
1. Update [`skills_manifest.yaml`](skills_manifest.yaml) with your skill metadata, cluster, and prerequisites.
2. Validate and synchronize cross-references:
   ```bash
   python update_skills.py
   ```

---

## 📄 License
MRST-Skills is released under the **GNU General Public License v3.0 or later (GPL-3.0-or-later)** in accordance with the underlying MATLAB Reservoir Simulation Toolbox.
