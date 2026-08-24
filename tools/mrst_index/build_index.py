"""
Build Index: Constructs the canonical SQLite FTS5 database and JSONL bundles for MRST knowledge base.
"""
import sys
import json
import sqlite3
import time
from pathlib import Path
from datetime import datetime, timezone

from .book_chunker import load_all_books, BookChunk
from .source_indexer import index_mrst_source, SourceChunk
from .entity_linker import link_entities_and_relations

def create_sqlite_database(
    db_path: Path,
    book_chunks: list,
    source_chunks: list,
    entities: list,
    relations: list
):
    db_path.parent.mkdir(parents=True, exist_ok=True)
    if db_path.exists():
        db_path.unlink()

    conn = sqlite3.connect(str(db_path))
    cursor = conn.cursor()

    # Enable fast performance Pragmas
    cursor.execute("PRAGMA journal_mode = WAL;")
    cursor.execute("PRAGMA synchronous = NORMAL;")

    # 1. Books table
    cursor.execute("""
        CREATE TABLE books (
            book_id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            authors TEXT NOT NULL,
            year INTEGER NOT NULL,
            total_chunks INTEGER NOT NULL
        );
    """)

    # 2. Book Chunks table
    cursor.execute("""
        CREATE TABLE book_chunks (
            chunk_id TEXT PRIMARY KEY,
            book_id TEXT NOT NULL,
            book_title TEXT NOT NULL,
            chapter_num TEXT,
            chapter_title TEXT,
            section_num TEXT,
            section_title TEXT,
            header_path TEXT,
            content TEXT NOT NULL,
            code_blocks_json TEXT,
            equations_json TEXT,
            start_line INTEGER,
            end_line INTEGER,
            word_count INTEGER,
            FOREIGN KEY (book_id) REFERENCES books(book_id)
        );
    """)

    # 3. Source Chunks table
    cursor.execute("""
        CREATE TABLE source_chunks (
            source_id TEXT PRIMARY KEY,
            symbol_name TEXT NOT NULL,
            symbol_type TEXT NOT NULL,
            module_name TEXT NOT NULL,
            file_path TEXT NOT NULL,
            signature TEXT,
            h1_doc TEXT,
            full_doc TEXT,
            code_preview TEXT,
            line_count INTEGER
        );
    """)

    # 4. Entities table
    cursor.execute("""
        CREATE TABLE entities (
            entity_id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            entity_type TEXT NOT NULL,
            description TEXT,
            source_ref TEXT
        );
    """)

    # 5. Relations table
    cursor.execute("""
        CREATE TABLE relations (
            rel_id TEXT PRIMARY KEY,
            source_id TEXT NOT NULL,
            target_id TEXT NOT NULL,
            relation_type TEXT NOT NULL,
            confidence REAL NOT NULL,
            context TEXT
        );
    """)

    # 6. FTS5 Unified Full-Text Search Table
    cursor.execute("""
        CREATE VIRTUAL TABLE chunks_fts USING fts5(
            chunk_id UNINDEXED,
            source_type,
            title,
            header,
            content,
            symbols,
            tokenize = 'porter unicode61'
        );
    """)

    # Populate books
    cursor.executemany("""
        INSERT OR REPLACE INTO books (book_id, title, authors, year, total_chunks)
        VALUES (?, ?, ?, ?, ?);
    """, [
        ("intro_book", "An Introduction to Reservoir Simulation Using MATLAB/GNU Octave", "Knut-Andreas Lie", 2019, len([c for c in book_chunks if c.book_id == 'intro_book'])),
        ("adv_book", "Advanced Modeling with the MATLAB Reservoir Simulation Toolbox", "Knut-Andreas Lie, Olav Moyner", 2021, len([c for c in book_chunks if c.book_id == 'adv_book'])),
    ])

    # Populate book chunks
    b_rows = []
    fts_rows = []
    for bc in book_chunks:
        b_rows.append((
            bc.chunk_id,
            bc.book_id,
            bc.book_title,
            bc.chapter_num,
            bc.chapter_title,
            bc.section_num,
            bc.section_title,
            bc.header_path,
            bc.content,
            json.dumps(bc.code_blocks, ensure_ascii=False),
            json.dumps(bc.equations, ensure_ascii=False),
            bc.start_line,
            bc.end_line,
            bc.word_count
        ))
        fts_rows.append((
            bc.chunk_id,
            "book",
            bc.book_title,
            bc.header_path,
            bc.content,
            f"{bc.chapter_title} {bc.section_title}"
        ))

    cursor.executemany("""
        INSERT OR REPLACE INTO book_chunks VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
    """, b_rows)

    # Populate source chunks
    s_rows = []
    for sc in source_chunks:
        s_rows.append((
            sc.source_id,
            sc.symbol_name,
            sc.symbol_type,
            sc.module_name,
            sc.file_path,
            sc.signature,
            sc.h1_doc,
            sc.full_doc,
            sc.code_preview,
            sc.line_count
        ))
        fts_rows.append((
            sc.source_id,
            "source",
            sc.file_path,
            f"{sc.module_name} > {sc.symbol_name} ({sc.symbol_type})",
            f"{sc.signature}\n\n{sc.full_doc}\n\n{sc.code_preview}",
            sc.symbol_name
        ))

    cursor.executemany("""
        INSERT OR REPLACE INTO source_chunks VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
    """, s_rows)

    # Deduplicate and populate entities
    seen_e = set()
    e_rows = []
    for e in entities:
        if e["entity_id"] not in seen_e:
            seen_e.add(e["entity_id"])
            e_rows.append((e["entity_id"], e["name"], e["entity_type"], e["description"], e["source_ref"]))
    
    cursor.executemany("""
        INSERT OR REPLACE INTO entities VALUES (?, ?, ?, ?, ?);
    """, e_rows)

    # Populate relations
    r_rows = [(r["rel_id"], r["source_id"], r["target_id"], r["relation_type"], r["confidence"], r["context"]) for r in relations]
    cursor.executemany("""
        INSERT OR REPLACE INTO relations VALUES (?, ?, ?, ?, ?, ?);
    """, r_rows)

    # Populate FTS
    cursor.executemany("""
        INSERT INTO chunks_fts (chunk_id, source_type, title, header, content, symbols)
        VALUES (?, ?, ?, ?, ?, ?);
    """, fts_rows)

    # Indices for blazing-fast lookups
    cursor.execute("CREATE INDEX idx_book_chunks_book ON book_chunks(book_id);")
    cursor.execute("CREATE INDEX idx_source_chunks_symbol ON source_chunks(symbol_name);")
    cursor.execute("CREATE INDEX idx_source_chunks_module ON source_chunks(module_name);")
    cursor.execute("CREATE INDEX idx_relations_source ON relations(source_id);")
    cursor.execute("CREATE INDEX idx_relations_target ON relations(target_id);")

    conn.commit()
    conn.close()
    print(f"Successfully constructed SQLite database at: {db_path} ({db_path.stat().st_size / (1024*1024):.2f} MB)")

def build_mrst_knowledge_base():
    t0 = time.time()
    out_dir = Path("D:/MRST-skills/output/mrst_knowledge")
    out_dir.mkdir(parents=True, exist_ok=True)
    db_path = out_dir / "mrst_knowledge.sqlite"

    print("=== Step 1: Loading & Chunking Textbooks ===")
    book_chunks = load_all_books()

    print("\n=== Step 2: Indexing MRST Source Code Tree ===")
    source_chunks = index_mrst_source()

    print("\n=== Step 3: Extracting Entities & Building Relations ===")
    entities, relations = link_entities_and_relations(book_chunks, source_chunks)

    print("\n=== Step 4: Building SQLite Database & FTS5 Index ===")
    create_sqlite_database(db_path, book_chunks, source_chunks, entities, relations)

    print("\n=== Step 5: Exporting JSONL Bundles & Manifest ===")
    # Export book chunks jsonl
    with open(out_dir / "chunks.jsonl", "w", encoding="utf-8") as f:
        for bc in book_chunks:
            f.write(json.dumps(bc.to_dict(), ensure_ascii=False) + "\n")

    # Export source chunks jsonl
    with open(out_dir / "source_chunks.jsonl", "w", encoding="utf-8") as f:
        for sc in source_chunks:
            f.write(json.dumps(sc.to_dict(), ensure_ascii=False) + "\n")

    # Export manifest
    manifest = {
        "built_at": datetime.now(timezone.utc).isoformat(),
        "total_book_chunks": len(book_chunks),
        "total_source_chunks": len(source_chunks),
        "total_entities": len(entities),
        "total_relations": len(relations),
        "database_size_bytes": db_path.stat().st_size if db_path.exists() else 0,
        "books": [
            {"id": "intro_book", "title": "An Introduction to Reservoir Simulation Using MATLAB/GNU Octave", "chunks": len([c for c in book_chunks if c.book_id == 'intro_book'])},
            {"id": "adv_book", "title": "Advanced Modeling with the MATLAB Reservoir Simulation Toolbox", "chunks": len([c for c in book_chunks if c.book_id == 'adv_book'])}
        ]
    }
    (out_dir / "manifest.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")
    
    t1 = time.time()
    print(f"\n Knowledge database build complete in {t1 - t0:.2f}s!")
    print(f"  - Book chunks: {len(book_chunks):,}")
    print(f"  - Source chunks: {len(source_chunks):,}")
    print(f"  - Entities: {len(entities):,}")
    print(f"  - Relations: {len(relations):,}")
    print(f"  - SQLite DB: {db_path}")

if __name__ == "__main__":
    build_mrst_knowledge_base()
