# MRST Knowledge Database Handoff

## Purpose

The user wants a reusable, portable MRST knowledge database built from two MRST textbook PDFs plus the local MRST source tree. The database will be used by future agents for multiple purposes, including creating MRST-specific skills later. It should not be skill-specific in v1. CLI tools are acceptable mainly as probes, tests, and debugging interfaces.

The user asked to avoid detailed trivial questions; ask only high-level questions that materially affect architecture or implementation.

## Workspace Context

Workspace: `C:\MyFiles\MRST-skills`

Important corpus files:

- `database\Advanced_Modeling_with_the_MATLAB_Reservoir_Simulation_Toolbox.pdf`
  - 626 pages
  - about 30 MB
  - embedded text extraction works
- `database\An_Introduction_to_Reservoir_Simulation_Using_MATLAB_GNU_Octave.pdf`
  - 678 pages
  - about 59 MB
  - embedded text extraction works
- `database\MRST-main\`
  - local MRST source tree
  - about 4,011 `.m` files found
  - includes function files, multi-function files, scripts, and `classdef` files

Observed environment facts:

- Bundled Python exists at `C:\Users\st4014\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe`.
- Bundled Python has `pypdf`, `sqlite3`, and `numpy` available.
- `torch`, `marker`, `sentence_transformers`, `faiss`, `chromadb`, `qdrant_client`, and `neo4j` were not installed in the bundled Python.
- Marker CLI was not found.
- `nvidia-smi` was not found; GPU availability is unknown.
- `docker.exe` is installed, but Docker daemon was not running.
- No visible API env vars were set for OpenAI, Anthropic, Voyage, Cohere, LlamaCloud, Gemini, or Hugging Face.
- Git commands hit a safe-directory/dubious-ownership warning for this repo; avoid relying on git status until safe.directory is configured or user approves.

## Decisions Already Locked

- Primary deliverable: reusable portable knowledge database.
- Local-first policy: prefer local processing; cloud alternatives allowed only when clearly useful/faster/better, ideally on small benchmark samples.
- Corpus scope: index both books and the full MRST source tree.
- Truth policy:
  - MRST source is canonical for current API/behavior.
  - Books are canonical for explanation and pedagogy.
  - Retrieval should pair book explanations with source implementation when possible.
- Parser strategy:
  - Primary parser candidate: Marker.
  - Include Unstructured.io in the parser bake-off, especially `partition_pdf` with `hi_res` and possibly `fast`.
  - LlamaParse is optional cloud benchmark/fallback only, not primary, because the user prefers local-first.
- LlamaIndex strategy:
  - Useful as compatibility/consumer layer, not source-of-truth.
  - Keep SQLite/JSONL as the canonical portable bundle.
  - Optionally emit LlamaIndex-compatible `nodes.jsonl` and README.
- Context headers: deterministic first, not LLM-generated.
- Book chunking: section-aware semantic chunks with page spans; also retain page-level raw text for audit/debug.
- Source chunking: MATLAB-aware source chunks with function/class metadata and book-to-source mention links.
- Quality target: retrieval quality plus auditable citations, not perfect book reconstruction.
- Figures/tables: capture captions and page references; do not attempt full figure/table understanding in v1.
- Retrieval modes for CLI/bundle:
  - keyword
  - semantic
  - hybrid
  - lookup
  - explain
  - deterministic reranking first; cross-encoder deferred.
- Lightweight graph layer:
  - Store MRST-specific entities/relations in SQLite tables, not Neo4j in v1.
  - Entities: functions/classes/scripts, modules/folders, concepts, equations/snippets.
  - Relations: mentions, defined_in, calls, belongs_to_module, explained_by_book_chunk, implemented_by_source_chunk.
- Retrieval preference:
  - Automatic intent detection plus explicit corpus preference flags.
  - Flags should allow `source`, `books`, and `paired` preferences.
- Bundle layout locked:

```text
tools/mrst_index/
  build_index.py
  search_index.py
  inspect_chunk.py
  config.toml

output/mrst_knowledge/
  manifest.json
  mrst_knowledge.sqlite
  chunks.jsonl
  pages.jsonl
  source_chunks.jsonl
  embeddings/
  parser_reports/
```

- Dependency isolation: create a dedicated workspace-local Python environment for parser/indexer dependencies, e.g. `.venv-mrst-index/`.
- Local embeddings:
  - Default: `Qwen/Qwen3-Embedding-0.6B`.
  - Fallback: `BAAI/bge-m3`.
- Parser benchmark gate:
  - Use a fixed 12-page gold set before full indexing.
  - Include contents/preface, equation-heavy pages, code-heavy pages, AD-OO pages, figure/caption pages, and source-link pages.
  - Automatically and manually check code block preservation, equations, headings, page numbers, captions, and column ordering.
- Fallback policy:
  - Do not block whole bundle if Marker fails individual pages/sections.
  - Use per-page/section fallback and mark `parse_engine`, `parse_quality`, and `needs_review`.

## Parser Tool Notes

Marker looked like the strongest primary parser for these books because its README claims Markdown/JSON/chunks output plus support for equations, inline math, code blocks, header/footer artifact removal, images, tables, and CPU/GPU/MPS operation. It also supports page ranges and output formats, useful for the 12-page benchmark.

Unstructured.io is valuable as a comparator and possible fallback because it partitions into elements, supports PDF strategies (`fast`, `hi_res`, `ocr_only`), and has section-aware chunking (`by_title`). Caution: docs note `hi_res` can have ordering difficulty with multi-column documents, which is exactly a risk for these textbooks.

LlamaParse is potentially high-quality and agentic, but cloud/API-based. Use only if user approves and only for benchmark or rescue pages unless the user changes the local-first preference.

LlamaIndex should not own the canonical data. Use it to export/consume nodes and experiment with retrievers/query engines later.

## Concrete Benchmark Candidates Already Found

From pypdf text scans, useful pages include:

Advanced Modeling PDF:

- Pages 9-11: contents with AD-OO and black-oil headings.
- Pages 41-42: `cartGrid` mentions / grid examples.
- Pages 113-118: `simulateScheduleAD` examples and figures.
- Page 145: `div(` math-heavy result.
- Page 151: AD-OO / automatic differentiation and multiscale code.
- Page 165: `simulateScheduleAD`, AD-OO, black-oil.

Introduction PDF:

- Page 16: preface with AD-OO description.
- Pages 33-34: first MRST encounter, Darcy equation, `initSingleFluid`.
- Pages 58-59: `cartGrid` and property modeling.
- Pages 109-110: grid structure tables/text.
- Page 154: `div(` / `grad(` mathematical model page.

The exact 12-page set can be finalized during implementation, but should include a mix from the above.

## Suggested Implementation Shape

Build a local Python package or scripts under `tools/mrst_index/` with these major stages:

1. `setup/check-env`
   - Verify local venv, parser CLIs/libraries, model availability, disk space, and optional Docker/API state.
   - Do not require Docker for v1.

2. `benchmark-parsers`
   - Run Marker on the gold page set.
   - Run Unstructured on the same pages.
   - Optionally run LlamaParse only if configured and approved.
   - Emit parser reports under `output/mrst_knowledge/parser_reports/`.
   - Choose primary/fallback per page/category based on objective checks and spot review.

3. `parse-books`
   - Produce page records and section-aware chunks.
   - Preserve code blocks and equations as well as possible.
   - Remove or mark repeated headers/footers.
   - Store page spans and parser quality metadata.

4. `index-source`
   - Parse all `.m` files.
   - Split into function/class/script/local-function chunks.
   - Capture module/path, signature, help comments, class/function name, and lightweight calls/references.

5. `link-entities`
   - Extract MRST-specific entities and relations.
   - Link book mentions to source chunks where symbols match.

6. `embed`
   - Use `Qwen/Qwen3-Embedding-0.6B` by default.
   - Fallback to `BAAI/bge-m3`.
   - Store vectors locally under `output/mrst_knowledge/embeddings/` and metadata in SQLite/JSONL.

7. `build-sqlite`
   - Create canonical SQLite database with FTS tables, metadata tables, chunks, pages, source chunks, entities, relations, embeddings metadata, and quality reports.

8. `search/inspect CLI`
   - `search_index.py keyword "..."`
   - `search_index.py semantic "..."`
   - `search_index.py hybrid "..." --prefer source|books|paired`
   - `search_index.py lookup --page ...` / `--function ...` / `--chunk ...`
   - `inspect_chunk.py <chunk_id>` for audit trail and citations.

9. Optional compatibility export
   - `output/mrst_knowledge/llamaindex/nodes.jsonl`
   - Minimal README explaining how to load nodes in LlamaIndex.

## Acceptance Criteria

- The bundle can be copied and searched without running a server.
- Keyword search finds exact MRST functions/symbols such as `cartGrid`, `initSingleFluid`, `simulateScheduleAD`, `div(`, `grad(`.
- Conceptual search finds book explanations for MRST paradigms such as procedural/incompressible flow and AD-OO/fully implicit simulation.
- Source lookup resolves current implementation chunks for functions/classes where present.
- Hybrid retrieval can return paired book/source results.
- Every result has auditable citation metadata:
  - book title + page span for book chunks
  - file path + function/class/script span for source chunks
  - parse engine + parse quality for book chunks
- The 12-page parser benchmark passes before full parse/index.
- If parser quality is weak on some pages, those chunks are still searchable but explicitly marked `needs_review`.

## Suggested Skills For Next Agent

- `grill-me`: if more architectural pressure-testing is needed, but keep questions high-level.
- `pdf`: for PDF parsing/rendering/inspection workflows.
- `diagnose` or `superpowers:systematic-debugging`: if parser/install failures appear.
- `tdd` or `superpowers:test-driven-development`: for building CLI/indexer tests first.
- `skill-creator` or `write-a-skill`: later, when the reusable database is used to create MRST skills. Do not use this for v1 database construction unless the user explicitly asks to build the skill.
- `handoff`: if transferring again.

## User Preferences

- Prefer local-first processing.
- Open to faster/better alternatives if benchmarked.
- Wants a reusable knowledge database for many purposes, not a single MRST skill yet.
- CLI tools are fine as testing/exploration tools.
- Avoid asking detailed trivial questions; ask only high-level, architecture-shaping questions.