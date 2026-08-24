"""
Inspect Chunk: Detailed inspector for book & source chunks with provenance citations and relations.
"""
import sys
import json
import sqlite3
import argparse
from pathlib import Path

DB_PATH = Path("D:/MRST-skills/output/mrst_knowledge/mrst_knowledge.sqlite")

def inspect(chunk_id: str):
    if not DB_PATH.exists():
        print(f"Error: {DB_PATH} not found. Run build_index.py first.")
        return

    conn = sqlite3.connect(str(DB_PATH))
    conn.row_factory = sqlite3.Row
    c = conn.cursor()

    # Check book chunk
    c.execute("SELECT * FROM book_chunks WHERE chunk_id = ?", (chunk_id,))
    brow = c.fetchone()
    if brow:
        print(f"================================================================")
        print(f" BOOK CHUNK: {brow['chunk_id']}")
        print(f"================================================================")
        print(f"Book:         {brow['book_title']}")
        print(f"Hierarchy:    {brow['header_path']}")
        print(f"Chapter:      {brow['chapter_title']}")
        print(f"Section:      {brow['section_title']}")
        print(f"Line Span:    Lines {brow['start_line']} - {brow['end_line']}")
        print(f"Word Count:   {brow['word_count']} words")
        
        code_blocks = json.loads(brow["code_blocks_json"]) if brow["code_blocks_json"] else []
        equations = json.loads(brow["equations_json"]) if brow["equations_json"] else []
        print(f"Code Blocks:  {len(code_blocks)}")
        print(f"Equations:    {len(equations)}")
        
        # Relations
        c.execute("""
            SELECT r.relation_type, r.context, sc.symbol_name, sc.file_path, sc.signature
            FROM relations r
            JOIN source_chunks sc ON r.target_id = sc.source_id
            WHERE r.source_id = ?
        """, (chunk_id,))
        rels = c.fetchall()
        if rels:
            print(f"\n--- Linked MRST Code Symbols ({len(rels)}) ---")
            for r in rels:
                print(f"  * [{r['relation_type']}] {r['symbol_name']} ({r['file_path']})")
                print(f"    Signature: {r['signature']}")
        
        print(f"\n--- Chunk Text Content ---")
        print(brow["content"])
        conn.close()
        return

    # Check source chunk
    c.execute("SELECT * FROM source_chunks WHERE source_id = ?", (chunk_id,))
    srow = c.fetchone()
    if srow:
        print(f"================================================================")
        print(f" SOURCE CHUNK: {srow['source_id']}")
        print(f"================================================================")
        print(f"Symbol Name:  {srow['symbol_name']}")
        print(f"Symbol Type:  {srow['symbol_type']}")
        print(f"Module:       {srow['module_name']}")
        print(f"File Path:    {srow['file_path']}")
        print(f"Line Count:   {srow['line_count']}")
        print(f"Signature:    {srow['signature']}")
        print(f"H1 Help:      {srow['h1_doc']}")
        
        c.execute("""
            SELECT r.relation_type, bc.book_title, bc.header_path, bc.chunk_id
            FROM relations r
            JOIN book_chunks bc ON r.source_id = bc.chunk_id
            WHERE r.target_id = ?
        """, (chunk_id,))
        rels = c.fetchall()
        if rels:
            print(f"\n--- Explained In Textbooks ({len(rels)}) ---")
            for r in rels:
                print(f"  * {r['header_path']} ({r['book_title']}) [Chunk: {r['chunk_id']}]")

        print(f"\n--- Full MATLAB Docstring ---")
        print(srow["full_doc"] or "(No docstring)")
        print(f"\n--- Code Preview ---")
        print(srow["code_preview"])
        conn.close()
        return

    print(f"Chunk '{chunk_id}' not found in database.")
    conn.close()

def main():
    parser = argparse.ArgumentParser(description="Inspect MRST Knowledge Base Chunk")
    parser.add_argument("chunk_id", type=str, help="Chunk ID to inspect")
    args = parser.parse_args()
    inspect(args.chunk_id)

if __name__ == "__main__":
    main()
