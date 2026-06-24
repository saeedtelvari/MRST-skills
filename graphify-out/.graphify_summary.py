import json
from pathlib import Path
# Read with multiple encoding attempts
for enc in ("utf-8-sig", "utf-16", "utf-8"):
    try:
        content = Path("graphify-out/.graphify_detect.json").read_text(encoding=enc)
        result = json.loads(content)
        break
    except Exception:
        continue
print("total_files:", result.get("total_files", 0))
print("total_words:", result.get("total_words", 0))
files = result.get("files", {})
for cat, lst in files.items():
    if lst:
        exts = set()
        for f in lst[:10]:
            exts.add(Path(f).suffix)
        exts_str = " ".join(sorted(exts))
        print(f"  {cat}: {len(lst)} files ({exts_str})")
