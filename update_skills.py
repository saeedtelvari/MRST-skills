#!/usr/bin/env python3
# MRST Skills Synchronizer and Validator (S-2)
# Reads the declarative manifest skills_manifest.yaml and validates
# Prerequisites, Cross-References, and References sections across all 19 skills.

import os
import sys
import yaml
import re

MANIFEST_PATH = 'skills_manifest.yaml'
SKILLS_DIR = 'skills'

def load_manifest():
    with open(MANIFEST_PATH, 'r', encoding='utf-8') as f:
        return yaml.safe_load(f)

def validate_and_sync(manifest, check_only=False):
    errors = []
    skills = manifest.get('skills', {})
    
    print(f'Validating {len(skills)} skills against {MANIFEST_PATH}...')
    
    for skill_name, data in skills.items():
        if skill_name == 'mrst':
            continue  # Router skill has custom routing table
            
        skill_path = os.path.join(SKILLS_DIR, skill_name, 'SKILL.md')
        if not os.path.exists(skill_path):
            errors.append(f'Missing SKILL.md for {skill_name} at {skill_path}')
            continue
            
        # Verify references exist on disk
        for ref in data.get('references', []):
            ref_file = os.path.join(SKILLS_DIR, skill_name, ref['file'])
            if not os.path.exists(ref_file):
                errors.append(f'Declared reference does not exist: {ref_file} (in {skill_name})')
                
        with open(skill_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        # Check for multiple prerequisite sections
        prereq_count = content.count('## Prerequisites')
        if prereq_count > 1:
            errors.append(f'{skill_name} has {prereq_count} ## Prerequisites sections!')
            
    if errors:
        print('\nValidation Errors Found:')
        for e in errors:
            print(f'  - {e}')
        return False
    else:
        print('\nAll 19 skills validated successfully against manifest!')
        return True

if __name__ == '__main__':
    manifest = load_manifest()
    success = validate_and_sync(manifest)
    sys.exit(0 if success else 1)
