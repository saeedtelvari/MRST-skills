"""
Book Chunker: Parses MRST textbook Markdown files into semantic, hierarchical chunks.
"""
import re
import json
from pathlib import Path
from dataclasses import dataclass, field, asdict
from typing import List, Dict, Any, Optional

@dataclass
class BookChunk:
    chunk_id: str
    book_id: str
    book_title: str
    chapter_num: str
    chapter_title: str
    section_num: str
    section_title: str
    header_path: str
    content: str
    code_blocks: List[str] = field(default_factory=list)
    equations: List[str] = field(default_factory=list)
    start_line: int = 1
    end_line: int = 1
    word_count: int = 0

    def to_dict(self) -> Dict[str, Any]:
        d = asdict(self)
        return d

def clean_title(title: str) -> str:
    title = re.sub(r"^[#\s\*]+", "", title).strip()
    title = re.sub(r"\[\d+\]", "", title).strip()
    return title

def parse_book_markdown(file_path: str | Path, book_id: str, book_title: str) -> List[BookChunk]:
    path = Path(file_path)
    if not path.exists():
        raise FileNotFoundError(f"Book file not found: {path}")

    text = path.read_text(encoding="utf-8")
    lines = text.splitlines()

    chunks: List[BookChunk] = []
    
    current_chapter_num = "0"
    current_chapter_title = "Front Matter"
    current_section_num = ""
    current_section_title = "Overview"
    
    current_lines = []
    current_start_line = 1
    in_code_block = False
    
    def flush_chunk(end_idx: int):
        nonlocal current_lines, current_start_line
        content = "\n".join(current_lines).strip()
        if not content:
            current_lines = []
            current_start_line = end_idx + 1
            return

        words = len(content.split())
        if words < 15 and not any(l.startswith("```") for l in current_lines):
            # Skip tiny headers/metadata if negligible
            current_lines = []
            current_start_line = end_idx + 1
            return

        # Extract code blocks
        code_blocks = re.findall(r"```(?:matlab|octave|text)?(.*?)```", content, re.DOTALL)
        code_blocks = [c.strip() for c in code_blocks if c.strip()]

        # Extract display equations
        equations = re.findall(r"\$\$(.*?)\$\$|\\\[(.*?)\\\]", content, re.DOTALL)
        eq_list = []
        for eq_tuple in equations:
            eq = eq_tuple[0] or eq_tuple[1]
            if eq and eq.strip():
                eq_list.append(eq.strip())

        # Generate slug ID
        sec_slug = re.sub(r"[^a-z0-9]+", "_", (current_section_title or current_chapter_title).lower()).strip("_")
        if not sec_slug:
            sec_slug = "section"
        sec_slug = sec_slug[:35]
        
        ch_slug = f"ch{current_chapter_num}" if current_chapter_num != "0" else "front"
        chunk_idx = len(chunks) + 1
        chunk_id = f"{book_id}_{ch_slug}_{chunk_idx:04d}_{sec_slug}"

        header_path = f"{current_chapter_title}"
        if current_section_title and current_section_title != current_chapter_title:
            header_path += f" > {current_section_title}"

        chunk = BookChunk(
            chunk_id=chunk_id,
            book_id=book_id,
            book_title=book_title,
            chapter_num=str(current_chapter_num),
            chapter_title=current_chapter_title,
            section_num=str(current_section_num),
            section_title=current_section_title,
            header_path=header_path,
            content=content,
            code_blocks=code_blocks,
            equations=eq_list,
            start_line=current_start_line,
            end_line=end_idx,
            word_count=words
        )
        chunks.append(chunk)
        current_lines = []
        current_start_line = end_idx + 1

    for idx, line in enumerate(lines, start=1):
        stripped = line.strip()

        # Handle code block toggle
        if stripped.startswith("```"):
            in_code_block = not in_code_block
            current_lines.append(line)
            continue

        if in_code_block:
            current_lines.append(line)
            continue

        # Check for Chapter heading (e.g. # 1 Introduction, # Chapter 2, # Preface)
        if stripped.startswith("# ") and not stripped.startswith("## "):
            title_text = clean_title(stripped)
            # Skip title repeats of book name if at very beginning
            if idx < 50 and any(kw in title_text.upper() for kw in ["AN INTRODUCTION", "ADVANCED MODELING", "CAMBRIDGE"]):
                current_lines.append(line)
                continue

            flush_chunk(idx - 1)
            
            # Match chapter number if present
            m_ch = re.match(r"^(\d+)\s+(.*)", title_text)
            if m_ch:
                current_chapter_num = m_ch.group(1)
                current_chapter_title = f"Chapter {current_chapter_num}: {m_ch.group(2).strip()}"
            else:
                current_chapter_num = str(len(chunks) // 20 + 1)
                current_chapter_title = title_text
            
            current_section_num = ""
            current_section_title = current_chapter_title
            current_lines.append(line)
            continue

        # Check for Section heading (## 1.1 ..., ## 2.3 ...)
        if stripped.startswith("## ") and not stripped.startswith("### "):
            title_text = clean_title(stripped)
            flush_chunk(idx - 1)
            
            m_sec = re.match(r"^(\d+\.\d+)\s+(.*)", title_text)
            if m_sec:
                current_section_num = m_sec.group(1)
                current_section_title = f"Section {current_section_num}: {m_sec.group(2).strip()}"
            else:
                current_section_num = ""
                current_section_title = title_text

            current_lines.append(line)
            continue

        # Check for Sub-section heading (### 1.1.1 ...)
        if stripped.startswith("### "):
            title_text = clean_title(stripped)
            # If current chunk has grown enough (>400 words), break at sub-section
            if len("\n".join(current_lines).split()) > 400:
                flush_chunk(idx - 1)
                m_subsec = re.match(r"^(\d+\.\d+\.\d+)\s+(.*)", title_text)
                if m_subsec:
                    current_section_num = m_subsec.group(1)
                    current_section_title = f"{m_subsec.group(1)} {m_subsec.group(2).strip()}"
                else:
                    current_section_title = title_text

            current_lines.append(line)
            continue

        # Normal text line
        current_lines.append(line)

        # If chunk exceeds max size (>1000 words), split at paragraph break
        if not stripped and len("\n".join(current_lines).split()) > 850:
            flush_chunk(idx)

    # Final chunk
    flush_chunk(len(lines))

    return chunks

def load_all_books(base_dir: str | Path = "D:/MRST-skills/database") -> List[BookChunk]:
    base = Path(base_dir)
    intro_path = base / "An_Introduction_to_Reservoir_Simulation_Using_MATLAB_GNU_Octave.md"
    adv_path = base / "Advanced_Modeling_with_the_MATLAB_Reservoir_Simulation_Toolbox.md"

    all_chunks = []
    if intro_path.exists():
        c_intro = parse_book_markdown(
            intro_path,
            book_id="intro_book",
            book_title="An Introduction to Reservoir Simulation Using MATLAB/GNU Octave"
        )
        print(f"Parsed Introduction Book: {len(c_intro)} chunks")
        all_chunks.extend(c_intro)

    if adv_path.exists():
        c_adv = parse_book_markdown(
            adv_path,
            book_id="adv_book",
            book_title="Advanced Modeling with the MATLAB Reservoir Simulation Toolbox"
        )
        print(f"Parsed Advanced Modeling Book: {len(c_adv)} chunks")
        all_chunks.extend(c_adv)

    return all_chunks

if __name__ == "__main__":
    chunks = load_all_books()
    print(f"Total book chunks generated: {len(chunks)}")
    if chunks:
        sample = chunks[15]
        print("\nSample chunk:")
        print(f"  ID: {sample.chunk_id}")
        print(f"  Header: {sample.header_path}")
        print(f"  Words: {sample.word_count}")
        print(f"  Code blocks: {len(sample.code_blocks)}")
        print(f"  Equations: {len(sample.equations)}")
        print(f"  Preview: {sample.content[:200]}...")
