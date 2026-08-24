## Question

How do we reliably inject `run('database/MRST-main/startup.m')` and `mrstModule add ...` into the AI's generated MATLAB code?
If an AI agent is working on an MRST problem, it often forgets the setup blocks or module loads. Should we provide a standard Python script `scripts/run_mrst.py` that prepends these lines and invokes `matlab -batch`, or just rely on strict instructions in the `SKILL.md`?

We need to prototype a robust MATLAB runner execution hook.

**Labels**: `wayfinder:prototype`
**Blocks**: None yet
