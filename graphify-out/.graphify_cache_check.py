import json, sys
from graphify.cache import check_semantic_cache
from pathlib import Path

detect = json.loads(open("graphify-out/.graphify_detect.json", encoding="utf-8").read())
all_files = [f for cat in ("document", "paper", "image") for f in detect["files"].get(cat, [])]
scan_root = detect.get("scan_root", str(Path("database/MRST-main/core").resolve()))

cached_nodes, cached_edges, cached_hyperedges, uncached = check_semantic_cache(all_files, root="database/MRST-main/core")

if cached_nodes or cached_edges or cached_hyperedges:
    import json
    Path("graphify-out/.graphify_cached.json").write_text(
        json.dumps({"nodes": cached_nodes, "edges": cached_edges, "hyperedges": cached_hyperedges}, ensure_ascii=False),
        encoding="utf-8"
    )
else:
    Path("graphify-out/.graphify_cached.json").unlink(missing_ok=True)

Path("graphify-out/.graphify_uncached.txt").write_text("\n".join(uncached), encoding="utf-8")
print(f"Cache: {len(all_files)-len(uncached)} files hit, {len(uncached)} files need extraction")
print("Uncached files:")
for f in uncached:
    print(" ", f)
