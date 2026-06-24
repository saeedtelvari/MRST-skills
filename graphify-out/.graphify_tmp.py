import json
from graphify.detect import detect
from pathlib import Path
result = detect(Path("database/MRST-main/core"))
with open("graphify-out/.graphify_detect.json", "w", encoding="utf-8") as f:
    json.dump(result, f, ensure_ascii=False)
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
