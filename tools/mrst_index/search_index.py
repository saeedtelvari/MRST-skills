"""
Search Index: High-performance CLI for querying the unified MRST knowledge database.
"""
import sys
import json
import sqlite3
import argparse
from pathlib import Path
from typing import List, Dict, Any, Optional

DB_PATH = Path("D:/MRST-skills/output/mrst_knowledge/mrst_knowledge.sqlite")

def get_db_connection(db_path: Path = DB_PATH) -> sqlite3.Connection:
    if not db_path.exists():
        raise FileNotFoundError(f"Database not found at {db_path}. Please run build_index.py first.")
    conn = sqlite3.connect(str(db_path))
    conn.row_factory = sqlite3.Row
    return conn

def search_keyword(query: str, limit: int = 10, source_filter: Optional[str] = None) -> List[Dict[str, Any]]:
    conn = get_db_connection()
    cursor = conn.cursor()

    # Format query for FTS5 (escape special chars, handle multi-word)
    safe_query = " ".join([f'"{w}"' for w in query.replace('"', '').split() if w])
    if not safe_query:
        return []

    sql = """
        SELECT fts.chunk_id, fts.source_type, fts.title, fts.header, 
               snippet(chunks_fts, 4, '[MATCH]', '[/MATCH]', '...', 25) as snippet,
               bm25(chunks_fts) as rank
        FROM chunks_fts fts
        WHERE chunks_fts MATCH ?
    """
    params = [safe_query]

    if source_filter in ("book", "source"):
        sql += " AND fts.source_type = ?"
        params.append(source_filter)

    sql += " ORDER BY rank LIMIT ?"
    params.append(limit)

    cursor.execute(sql, params)
    rows = cursor.fetchall()
    
    results = []
    for r in rows:
        cid = r["chunk_id"]
        stype = r["source_type"]
        
        detail = {}
        if stype == "book":
            cursor.execute("SELECT book_title, chapter_title, section_title, start_line, end_line FROM book_chunks WHERE chunk_id = ?", (cid,))
            brow = cursor.fetchone()
            if brow:
                detail = dict(brow)
        else:
            cursor.execute("SELECT symbol_name, symbol_type, module_name, file_path, signature FROM source_chunks WHERE source_id = ?", (cid,))
            srow = cursor.fetchone()
            if srow:
                detail = dict(srow)

        results.append({
            "chunk_id": cid,
            "source_type": stype,
            "title": r["title"],
            "header": r["header"],
            "snippet": r["snippet"],
            "rank": r["rank"],
            "detail": detail
        })

    conn.close()
    return results

def lookup_symbol(symbol_name: str) -> List[Dict[str, Any]]:
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT * FROM source_chunks WHERE symbol_name = ? COLLATE NOCASE
        ORDER BY line_count DESC;
    """, (symbol_name,))
    
    s_rows = [dict(r) for r in cursor.fetchall()]
    
    # Also find book chunks explaining this symbol
    for sc in s_rows:
        cursor.execute("""
            SELECT bc.chunk_id, bc.book_title, bc.header_path, bc.content
            FROM relations r
            JOIN book_chunks bc ON r.source_id = bc.chunk_id
            WHERE r.target_id = ? AND r.relation_type = 'explains_code'
            LIMIT 5;
        """, (sc["source_id"],))
        sc["explained_in_books"] = [dict(r) for r in cursor.fetchall()]

    conn.close()
    return s_rows

def explain_concept(concept_query: str) -> Dict[str, Any]:
    conn = get_db_connection()
    cursor = conn.cursor()

    # 1. Search books for concept explanations
    book_results = search_keyword(concept_query, limit=3, source_filter="book")
    
    # 2. Search source code for implementations
    source_results = search_keyword(concept_query, limit=3, source_filter="source")
    
    # 3. Find related graph relations
    related_relations = []
    if book_results:
        top_cid = book_results[0]["chunk_id"]
        cursor.execute("""
            SELECT r.rel_id, r.relation_type, r.context, 
                   sc.symbol_name, sc.file_path, sc.signature
            FROM relations r
            JOIN source_chunks sc ON r.target_id = sc.source_id
            WHERE r.source_id = ?
            LIMIT 6;
        """, (top_cid,))
        related_relations = [dict(r) for r in cursor.fetchall()]

    conn.close()
    return {
        "concept": concept_query,
        "book_theory": book_results,
        "source_implementations": source_results,
        "direct_code_links": related_relations
    }

def print_keyword_results(results: List[Dict[str, Any]]):
    print(f"\n=== Found {len(results)} Matches ===")
    for i, r in enumerate(results, start=1):
        stype = r["source_type"].upper()
        print(f"\n[{i}] [{stype}] {r['header']}")
        print(f"    ID: {r['chunk_id']}")
        if stype == "BOOK":
            print(f"    Citation: {r['detail'].get('book_title')} (Lines {r['detail'].get('start_line')}-{r['detail'].get('end_line')})")
        else:
            print(f"    File: {r['detail'].get('file_path')} | Signature: {r['detail'].get('signature')}")
        print(f"    Snippet: {r['snippet']}")

def print_explain_results(res: Dict[str, Any]):
    print(f"\n=======================================================")
    print(f" EXPLANATION & IMPLEMENTATION: {res['concept'].upper()}")
    print(f"=======================================================\n")
    
    print("--- 1. Canonical Textbook Theory & Formulation ---")
    for b in res["book_theory"]:
        print(f"\n* {b['header']} ({b['detail'].get('book_title')})")
        print(f"  Snippet: {b['snippet']}")
        
    print("\n--- 2. MRST Source Code Implementations ---")
    for s in res["source_implementations"]:
        print(f"\n* {s['detail'].get('symbol_name')} in {s['detail'].get('file_path')}")
        print(f"  Signature: {s['detail'].get('signature')}")
        print(f"  Snippet: {s['snippet']}")

    if res["direct_code_links"]:
        print("\n--- 3. Direct Symbol Links in Textbook ---")
        for l in res["direct_code_links"]:
            print(f"  -> {l['symbol_name']} ({l['file_path']}): {l['signature']}")

def main():
    parser = argparse.ArgumentParser(description="MRST Knowledge Database Search Tool")
    subparsers = parser.add_subparsers(dest="command", help="Search command")

    # keyword command
    p_kw = subparsers.add_parser("keyword", help="Full-text search")
    p_kw.add_argument("query", type=str, help="Search query")
    p_kw.add_argument("--limit", type=int, default=8, help="Max results")
    p_kw.add_argument("--type", choices=["all", "book", "source"], default="all", help="Filter source type")

    # lookup command
    p_lk = subparsers.add_parser("lookup", help="Lookup symbol or chunk")
    p_lk.add_argument("--function", type=str, help="Function or class name")
    p_lk.add_argument("--chunk", type=str, help="Chunk ID")

    # explain command
    p_ex = subparsers.add_parser("explain", help="Explain concept with paired theory & code")
    p_ex.add_argument("concept", type=str, help="Concept or method name to explain")

    # hybrid command
    p_hy = subparsers.add_parser("hybrid", help="Hybrid retrieval")
    p_hy.add_argument("query", type=str, help="Search query")
    p_hy.add_argument("--prefer", choices=["source", "books", "paired"], default="paired", help="Preference")
    p_hy.add_argument("--limit", type=int, default=8, help="Max results")

    args = parser.parse_args()

    if args.command == "keyword":
        stype = None if args.type == "all" else args.type
        results = search_keyword(args.query, limit=args.limit, source_filter=stype)
        print_keyword_results(results)

    elif args.command == "lookup":
        if args.function:
            symbols = lookup_symbol(args.function)
            if not symbols:
                print(f"No function or class matching '{args.function}' found.")
            else:
                for s in symbols:
                    print(f"\n=== {s['symbol_name']} ({s['symbol_type']}) ===")
                    print(f"  File: {s['file_path']} (Lines: {s['line_count']})")
                    print(f"  Signature: {s['signature']}")
                    print(f"  H1 Doc: {s['h1_doc']}")
                    print(f"  Full Help:\n{s['full_doc']}")
                    if s.get("explained_in_books"):
                        print("\n  Explained in Textbooks:")
                        for b in s["explained_in_books"]:
                            print(f"    - {b['header_path']} ({b['book_title']}) [Chunk: {b['chunk_id']}]")
        elif args.chunk:
            conn = get_db_connection()
            c = conn.cursor()
            c.execute("SELECT * FROM book_chunks WHERE chunk_id = ?", (args.chunk,))
            r = c.fetchone()
            if r:
                print(f"\n=== Book Chunk: {r['chunk_id']} ===")
                print(f"Book: {r['book_title']}")
                print(f"Header: {r['header_path']}")
                print(f"Lines: {r['start_line']} - {r['end_line']}")
                print(f"\nContent:\n{r['content']}")
            else:
                c.execute("SELECT * FROM source_chunks WHERE source_id = ?", (args.chunk,))
                r = c.fetchone()
                if r:
                    print(f"\n=== Source Chunk: {r['source_id']} ===")
                    print(f"Symbol: {r['symbol_name']} ({r['symbol_type']})")
                    print(f"File: {r['file_path']}")
                    print(f"Signature: {r['signature']}")
                    print(f"\nPreview:\n{r['code_preview']}")
            conn.close()

    elif args.command == "explain":
        res = explain_concept(args.concept)
        print_explain_results(res)

    elif args.command == "hybrid":
        stype = "source" if args.prefer == "source" else ("book" if args.prefer == "books" else None)
        if args.prefer == "paired":
            res = explain_concept(args.query)
            print_explain_results(res)
        else:
            results = search_keyword(args.query, limit=args.limit, source_filter=stype)
            print_keyword_results(results)

    else:
        parser.print_help()

if __name__ == "__main__":
    main()
