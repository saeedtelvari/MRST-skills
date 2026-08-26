#!/usr/bin/env python3
"""
MRST-Skills Multi-Platform Installer & Distribution Engine
Installs and configures MRST agentic skills for Claude Code, Antigravity,
Cursor, Windsurf, GitHub Copilot, and OpenAI Codex.
"""

import os
import sys
import shutil
import argparse
import yaml
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
SKILLS_DIR = REPO_ROOT / 'skills'
MANIFEST_PATH = REPO_ROOT / 'skills_manifest.yaml'

def load_manifest():
    if not MANIFEST_PATH.exists():
        print(f'Error: Manifest not found at {MANIFEST_PATH}')
        sys.exit(1)
    with open(MANIFEST_PATH, 'r', encoding='utf-8') as f:
        return yaml.safe_load(f)

def get_home_dir():
    return Path.home()

def copy_skills_to(target_dir, dry_run=False):
    target_dir = Path(target_dir)
    print(f'\n[+] Installing 19 skills into: {target_dir}')
    if not dry_run:
        target_dir.mkdir(parents=True, exist_ok=True)
    
    for skill_path in sorted(SKILLS_DIR.iterdir()):
        if not skill_path.is_dir():
            continue
        dest = target_dir / skill_path.name
        if dry_run:
            print(f'  [DRY-RUN] Copy {skill_path.name} -> {dest}')
        else:
            if dest.exists():
                shutil.rmtree(dest)
            shutil.copytree(skill_path, dest)
            print(f'  Installed skill: {skill_path.name}')
    print(f'[OK] Successfully installed skills to {target_dir}')

def generate_claude_instructions():
    manifest = load_manifest()
    skills = manifest.get('skills', {})
    lines = [
        '# MRST Simulation Guidelines for Claude Code',
        '',
        '## 1. Startup & Execution Contract',
        'When running or writing MRST (MATLAB Reservoir Simulation Toolbox) scripts:',
        '- **Always** initialize with the workspace startup file:',
        '  ```matlab',
        "  run('database/MRST-main/startup.m');",
        '  ```',
        '- **Always** explicitly load required modules using `mrstModule add ...` (e.g., `mrstModule add ad-core ad-props ad-blackoil`).',
        '- **Never** assume unit conversions: All MRST internal calculations use standard SI units (m, Pa, s, kg). Use MRST unit constants (`barsa`, `milli*darcy`, `day`, `centi*poise`).',
        '',
        '## 2. Skill Catalog & Routing Table',
        '',
        '| Domain Cluster | Specialist Skill | Primary Intent / Keywords | Prerequisites |',
        '|----------------|------------------|---------------------------|---------------|'
    ]
    
    clusters = {c['id']: c['name'] for c in manifest.get('clusters', [])}
    for name, data in skills.items():
        if name == 'mrst':
            continue
        cluster_name = clusters.get(data.get('cluster', ''), 'Core')
        prereqs = ', '.join([p.split('—')[0].strip() for p in data.get('upstream', [])]) if data.get('upstream') else 'None (root)'
        lines.append(f"| {cluster_name} | `{name}` | {data.get('description', '')} | {prereqs} |")
        
    lines.extend([
        '',
        '## 3. Multi-Skill Workflows (Recipes)',
        '- **Deck Import & Simulation**: `mrst-gridding` -> `mrst-ad-oo`',
        '- **CO2 Sequestration + Optimization**: `mrst-gridding` -> `mrst-co2-storage` -> `mrst-optimization`',
        '- **Fractured Reservoir + Fast Solvers**: `mrst-gridding` -> `mrst-fractured-reservoirs` -> `mrst-linear-solvers`',
        '- **Diagnostics & Sweep**: `mrst-gridding` -> `mrst-core-procedural` -> `mrst-diagnostics`',
        '- **EOR (Polymer/Surfactant)**: `mrst-gridding` -> `mrst-ad-oo` -> `mrst-eor`',
        '- **Custom Physics & Equations**: `mrst-ad-oo` -> `mrst-custom-physics` -> `mrst-testing`',
        '- **Debugging & Triage**: `mrst-debugging` (max 3 miniaturized fix cycles)',
        '',
        '## 4. Knowledge Retrieval',
        'To lookup exact MRST functions and invariants from the knowledge base:',
        '```bash',
        'python -m tools.mrst_index.search_index keyword "<functionName>"',
        '```'
    ])
    return '\n'.join(lines) + '\n'

def generate_cursor_rule():
    claude_md = generate_claude_instructions()
    header = "---\ndescription: MRST (MATLAB Reservoir Simulation Toolbox) Rules and Autonomous Skill Routing\nglobs: *.m, *.DATA, *.GRDECL, *.mat\n---\n\n"
    return header + claude_md

def generate_codex_system_prompt():
    manifest = load_manifest()
    skills = manifest.get('skills', {})
    lines = [
        '# MRST Autonomous Reservoir Simulation Assistant - System Prompt',
        '',
        'You are an expert AI Reservoir Simulation Engineer specializing in the MATLAB Reservoir Simulation Toolbox (MRST).',
        '',
        '## Fundamental Rules:',
        "1. **Initialization**: Every standalone MRST script MUST start with `run('database/MRST-main/startup.m');` followed by explicit `mrstModule add <modules>`.",
        '2. **SI Units**: MRST operates strictly in SI units internally (meters, Pascals, seconds, kg). Always use MRST unit conversion constants (`barsa`, `milli*darcy`, `day`, `centi*poise`, `meter`). Never treat raw numbers as field units.',
        '3. **Geometry Lifecycle**: After generating or altering grid coordinates, always call `G = computeGeometry(G);`. Stale geometry causes silent physical errors.',
        "4. **StateFunctions in Custom Physics**: In custom `StateFunction` implementations, declare primary variable dependencies with grouping: `gp = gp.dependsOn({'pressure'}, 'state');`.",
        "5. **Polymer Adsorption**: Irreversible adsorption models require `state0.cpmax = zeros(G.cells.num, 1);` in the initial state.",
        '',
        '## Domain Capabilities & Skill Routing:',
    ]
    for name, data in skills.items():
        if name == 'mrst':
            continue
        lines.append(f"- **{name}** ({data.get('title', '')}): {data.get('description', '')}")
        
    lines.extend([
        '',
        '## Debugging Discipline:',
        '- Miniaturize failure cases to tiny grids (e.g. `cartGrid([3, 3, 1])`) and short timesteps before debugging.',
        '- Swap preconditioners with `BackslashSolverAD()` to isolate linear solver preconditioner failures from nonlinear physics divergence.',
        '- Test custom StateFunction derivatives against numerical central finite differences.'
    ])
    return '\n'.join(lines) + '\n'

def install_claude(is_global=False, dry_run=False):
    if is_global:
        dest = get_home_dir() / '.claude' / 'skills'
    else:
        dest = Path.cwd() / '.claude' / 'skills'
    copy_skills_to(dest, dry_run=dry_run)
    
    claude_file = Path.cwd() / 'CLAUDE.md' if not is_global else get_home_dir() / '.claude' / 'CLAUDE.md'
    content = generate_claude_instructions()
    if dry_run:
        print(f'  [DRY-RUN] Write CLAUDE.md -> {claude_file}')
    else:
        claude_file.parent.mkdir(parents=True, exist_ok=True)
        with open(claude_file, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f'[OK] Configured Claude Code instructions at {claude_file}')

def install_antigravity(is_global=False, dry_run=False):
    if is_global:
        dest = get_home_dir() / '.gemini' / 'config' / 'skills'
    else:
        dest = Path.cwd() / '.gemini' / 'config' / 'skills'
    copy_skills_to(dest, dry_run=dry_run)

def install_cursor(dry_run=False):
    rules_dir = Path.cwd() / '.cursor' / 'rules'
    rule_file = rules_dir / 'mrst.mdc'
    cursorrules_file = Path.cwd() / '.cursorrules'
    content = generate_cursor_rule()
    if dry_run:
        print(f'  [DRY-RUN] Write Cursor rule -> {rule_file} and {cursorrules_file}')
    else:
        rules_dir.mkdir(parents=True, exist_ok=True)
        with open(rule_file, 'w', encoding='utf-8') as f:
            f.write(content)
        with open(cursorrules_file, 'w', encoding='utf-8') as f:
            f.write(generate_claude_instructions())
        print(f'[OK] Configured Cursor IDE rules at {rule_file} and {cursorrules_file}')

def install_windsurf(dry_run=False):
    windsurf_file = Path.cwd() / '.windsurfrules'
    content = generate_claude_instructions()
    if dry_run:
        print(f'  [DRY-RUN] Write Windsurf rule -> {windsurf_file}')
    else:
        with open(windsurf_file, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f'[OK] Configured Windsurf rules at {windsurf_file}')

def install_copilot(dry_run=False):
    copilot_dir = Path.cwd() / '.github'
    copilot_file = copilot_dir / 'copilot-instructions.md'
    content = generate_claude_instructions()
    if dry_run:
        print(f'  [DRY-RUN] Write GitHub Copilot instructions -> {copilot_file}')
    else:
        copilot_dir.mkdir(parents=True, exist_ok=True)
        with open(copilot_file, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f'[OK] Configured GitHub Copilot instructions at {copilot_file}')

def install_codex(dry_run=False):
    codex_file = Path.cwd() / 'CODEX.md'
    content = generate_codex_system_prompt()
    if dry_run:
        print(f'  [DRY-RUN] Write OpenAI Codex prompt -> {codex_file}')
    else:
        with open(codex_file, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f'[OK] Generated OpenAI Codex / ChatGPT System Prompt at {codex_file}')

def bundle_skills(output_path):
    output_path = Path(output_path)
    print(f'\n[+] Bundling all 19 skills into single document: {output_path}')
    
    sections = [
        '# MRST Agentic Skills: Complete Unified Ecosystem Bundle',
        '',
        'This document contains the consolidated knowledge, invariants, paradigms, and workflows for all 19 MRST specialist skills.',
        ''
    ]
    
    sections.append(generate_codex_system_prompt())
    sections.append('\n---\n')
    
    for skill_path in sorted(SKILLS_DIR.iterdir()):
        if not skill_path.is_dir():
            continue
        skill_file = skill_path / 'SKILL.md'
        if skill_file.exists():
            with open(skill_file, 'r', encoding='utf-8') as f:
                content = f.read()
            sections.append(f'# Skill: {skill_path.name}\n\n' + content + '\n\n---\n')
            
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(sections))
    print(f'[OK] Bundle written ({output_path.stat().st_size / 1024:.1f} KB): {output_path}')

def list_skills():
    manifest = load_manifest()
    skills = manifest.get('skills', {})
    clusters = {c['id']: c['name'] for c in manifest.get('clusters', [])}
    
    print('\n=== MRST-Skills Ecosystem Catalog (19 Skills) ===\n')
    print(f'{"Skill Name":<28} | {"Cluster":<28} | {"Description"}')
    print('-' * 95)
    for name, data in skills.items():
        cluster_name = clusters.get(data.get('cluster', ''), data.get('cluster', ''))
        desc = data.get('description', '')
        if len(desc) > 40:
            desc = desc[:37] + '...'
        print(f'{name:<28} | {cluster_name:<28} | {desc}')
    print('\n')

def main():
    parser = argparse.ArgumentParser(
        prog='mrst-skills',
        description='MRST-Skills Multi-Platform Installer and Ecosystem Manager'
    )
    subparsers = parser.add_subparsers(dest='command', help='Commands')
    
    install_parser = subparsers.add_parser('install', help='Install skills into target AI assistant')
    install_parser.add_argument(
        '--target', '-t',
        choices=['claude', 'antigravity', 'cursor', 'windsurf', 'copilot', 'codex', 'all'],
        required=True,
        help='Target AI assistant platform'
    )
    install_parser.add_argument(
        '--global', '-g',
        dest='is_global',
        action='store_true',
        help='Install globally into user home directory (for Claude / Antigravity)'
    )
    install_parser.add_argument(
        '--dry-run',
        action='store_true',
        help='Preview installation actions without making changes'
    )
    
    subparsers.add_parser('list', help='List all 19 skills and clusters')
    
    bundle_parser = subparsers.add_parser('bundle', help='Bundle all skills into a single prompt markdown')
    bundle_parser.add_argument(
        '--output', '-o',
        default='mrst_single_prompt.md',
        help='Output markdown file path (default: mrst_single_prompt.md)'
    )
    
    args = parser.parse_args()
    
    if args.command == 'list' or len(sys.argv) == 1:
        list_skills()
    elif args.command == 'bundle':
        bundle_skills(args.output)
    elif args.command == 'install':
        target = args.target
        dry_run = args.dry_run
        is_global = args.is_global
        
        if target in ('claude', 'all'):
            install_claude(is_global, dry_run)
        if target in ('antigravity', 'all'):
            install_antigravity(is_global, dry_run)
        if target in ('cursor', 'all'):
            install_cursor(dry_run)
        if target in ('windsurf', 'all'):
            install_windsurf(dry_run)
        if target in ('copilot', 'all'):
            install_copilot(dry_run)
        if target in ('codex', 'all'):
            install_codex(dry_run)
            
        print('\n[OK] All requested target installations completed!')
    else:
        parser.print_help()

if __name__ == '__main__':
    main()
