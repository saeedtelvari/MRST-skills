## Question

How should skills instruct the AI to leverage `graphify-out/`?

**Resolution**:
We will follow the global `AGENTS.md` rule: The SKILL.md will instruct agents to use `graphify query "<question>"` for codebase questions first, `graphify path "<A>" "<B>"` for relationships, and `graphify explain "<concept>"` for focused concepts. Agents should also invoke `skill: "graphify"` if they need deeper navigation tools.
