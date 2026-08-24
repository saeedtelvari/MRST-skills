## Question

How exactly will an MRST skill instruct the AI to query the SQLite knowledge database (`mrst_knowledge.sqlite`) and Graphify map? 
Do we embed raw python commands in the SKILL.md (e.g., "Run `python -m tools.mrst_index.search_index keyword <term>`"), or do we write a wrapper script (e.g., `scripts/query_mrst.py`) bundled with every skill that simplifies this?

We need to prototype a lookup workflow for one specific topic (e.g. `incompTPFA`) to see what yields the best results for an agent.

**Labels**: `wayfinder:prototype`
