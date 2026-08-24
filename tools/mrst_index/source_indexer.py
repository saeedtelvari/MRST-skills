"""
Source Indexer: Scans MRST-main codebase to extract MATLAB functions, classes, signatures, and docstrings.
"""
import re
import json
from pathlib import Path
from dataclasses import dataclass, asdict
from typing import List, Dict, Any, Optional

@dataclass
class SourceChunk:
    source_id: str
    symbol_name: str
    symbol_type: str
    module_name: str
    file_path: str
    signature: str
    h1_doc: str
    full_doc: str
    code_preview: str
    line_count: int

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)

def parse_m_file(file_path: Path, root_path: Path) -> Optional[SourceChunk]:
    rel_path = file_path.relative_to(root_path).as_posix()
    try:
        content = file_path.read_text(encoding="utf-8", errors="replace")
    except Exception:
        return None

    lines = content.splitlines()
    if not lines:
        return None

    # Derive module name from parent folders
    parts = list(file_path.relative_to(root_path).parts)
    module_name = "/".join(parts[:-1]) if len(parts) > 1 else "(root)"

    symbol_name = file_path.stem
    symbol_type = "script"
    signature = ""
    h1_doc = ""
    doc_lines = []
    
    # Check for function or classdef definition
    in_doc = False
    for line in lines:
        stripped = line.strip()
        
        # Check function
        m_func = re.match(r"^function\s+(?:(\[.*?\]|\w+)\s*=\s*)?([a-zA-Z0-9_]+)(?:\((.*?)\))?", stripped)
        if m_func:
            symbol_type = "function"
            symbol_name = m_func.group(2)
            signature = stripped
            in_doc = True
            continue

        # Check classdef
        m_class = re.match(r"^classdef\s+(?:\(.*?\)\s+)?([a-zA-Z0-9_]+)", stripped)
        if m_class:
            symbol_type = "classdef"
            symbol_name = m_class.group(1)
            signature = stripped
            in_doc = True
            continue

        # Capture help comments right below function/classdef or at top of file
        if stripped.startswith("%"):
            comment_text = stripped.lstrip("%").strip()
            if not h1_doc and comment_text:
                h1_doc = comment_text
            doc_lines.append(comment_text)
        elif stripped and not stripped.startswith("%") and (signature or doc_lines):
            # End of header comment block
            break

    full_doc = "\n".join(doc_lines).strip()
    code_preview = "\n".join(lines[:45])
    
    # Normalize ID
    path_slug = re.sub(r"[^a-z0-9_]+", "_", rel_path.lower().replace(".m", "")).strip("_")
    source_id = f"src_{path_slug}"

    return SourceChunk(
        source_id=source_id,
        symbol_name=symbol_name,
        symbol_type=symbol_type,
        module_name=module_name,
        file_path=rel_path,
        signature=signature or f"% {symbol_name}",
        h1_doc=h1_doc,
        full_doc=full_doc,
        code_preview=code_preview,
        line_count=len(lines)
    )

def index_mrst_source(source_root: str | Path = "D:/MRST-skills/database/MRST-main") -> List[SourceChunk]:
    root = Path(source_root)
    if not root.exists():
        raise FileNotFoundError(f"MRST root not found: {root}")

    source_chunks: List[SourceChunk] = []
    all_m_files = sorted(root.rglob("*.m"))
    
    for f in all_m_files:
        chunk = parse_m_file(f, root)
        if chunk:
            source_chunks.append(chunk)

    print(f"Indexed MRST source tree: {len(source_chunks)} MATLAB files processed.")
    return source_chunks

if __name__ == "__main__":
    src_chunks = index_mrst_source()
    if src_chunks:
        print(f"Sample source chunk: {src_chunks[10]}")
