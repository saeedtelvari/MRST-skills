import json
from pathlib import Path
from collections import Counter

for enc in ("utf-8-sig", "utf-16", "utf-8"):
    try:
        content = Path("graphify-out/.graphify_detect.json").read_text(encoding=enc)
        result = json.loads(content)
        break
    except Exception:
        continue

scan_root = result.get("scan_root", str(Path("database/MRST-main").resolve()))
all_files = []
for cat, lst in result.get("files", {}).items():
    all_files.extend(lst)

# Filter out graphify-out
graphify_out = scan_root + "/graphify-out/"
all_files = [f for f in all_files if not f.startswith(graphify_out)]

# Get first path component relative to scan_root
counter = Counter()
for f in all_files:
    rel = f
    if rel.startswith(scan_root):
        rel = rel[len(scan_root):].lstrip("/\\")
    parts = Path(rel).parts
    if parts:
        counter[parts[0]] += 1
    else:
        counter["(root)"] += 1

print("Top subdirectories by file count:")
for name, count in counter.most_common(10):
    print(f"  {name}: {count} files")
