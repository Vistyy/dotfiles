---
description: Periodically audit the current repository for high-leverage, large-scale improvement opportunities and (optionally) write scoped follow-up task documents under docs/improvements/.
---

## User Input

```text
$ARGUMENTS
```

Treat `$ARGUMENTS` as optional directives. Common patterns:
- `write` / `--write`: Write run artifacts under `docs/improvements/` (default is report-only).
- `write=report|items|both`: What to write (default `both` when `write` is set).
- `since=90d` / `since=6m` / `since=1y`: Limit git-churn analysis window (default `180d`).
- `limit=10`: Max number of task candidates to produce (default `12`).
- `focus=<area>`: e.g. `focus=architecture`, `focus=tests`, `focus=tooling`, `focus=docs`.
- `mode=both|problems|opportunities`: What to prioritize (default `both`).
- `outdir=docs/improvements`: Where to write the per-run folder (default `docs/improvements`).
- `run=<id>`: Optional run folder name override (default is generated).
- `bar=high|medium|low`: How strict to be about only surfacing high-leverage items (default `high`).
- `repeats=summary|include|hide`: How to handle tasks that match prior run items (default `summary`).

If directives are ambiguous, ask the user for clarification before proceeding.

## Goal

Produce an evidence-based “repo radar” report that surfaces **large-scale** improvements and investments (architecture boundaries, hotspots, duplication patterns, coupling, churn, inconsistent conventions, complexity concentration).

This is not limited to “things that are broken”. Include proactive improvements that:
- reduce long-term maintenance cost / cognitive load
- improve developer experience (tooling, tests, build/lint speed, ergonomics)
- reduce risk (footguns, unclear invariants, weak boundaries)
- create a cleaner foundation for likely upcoming work

Avoid micro-nits like renaming variables or merging two tests unless they are symptoms of a broader structural issue.

If the user requested `write` / `--write`, also materialize the best candidates into **scoped task documents** that can be implemented later.

## Operating Constraints

- **Evidence-first**: Do not speculate. Every recommendation must cite concrete evidence:
  - `file/path:line` references when pointing at code, and/or
  - the exact command(s) run and a short excerpted result summary.
- **No code edits**: Do not modify product code in this run. Output report only, plus optional docs under `docs/improvements/`.
- **Prefer leverage**: Focus on changes that reduce ongoing cost (maintenance, cognitive load, defects) across multiple files/modules.
- **Scope tasks**: Each task must be independently implementable, timeboxable, and have clear success criteria.
- **Avoid preference-nits**: Do not propose changes that are primarily stylistic, taste-based, or “nice-to-have wording” unless they prevent real drift or recurring confusion with concrete downstream cost.
- **Cap doc-only work**: Unless `focus=docs` was requested, propose at most **one** docs-only task, and only if it prevents drift or mis-implementation. Prefer engineering-facing improvements.

## Execution Steps

### 0) Parse directives

Determine:
- `WRITE_DOCS`: true if user requested `write` / `--write`
- `WRITE_WHAT`: one of `report|items|both` (default `both` when `WRITE_DOCS`)
- `SINCE`: default `180d`
- `LIMIT`: default `12`
- `FOCUS`: optional
- `MODE`: default `both`
- `OUTDIR`: default `docs/improvements`
- `RUN_ID`: per-run folder name
- `BAR`: default `high`
- `REPEATS`: default `summary`

If `WRITE_DOCS` is false, ignore `WRITE_WHAT` and `OUTDIR`.

If `WRITE_DOCS` is true:
- If the user provided `run=<id>`, use it as `RUN_ID` (must be filesystem-safe).
- Otherwise generate a `RUN_ID`:
  - Prefer date-based for easy browsing: `YYYY-MM-DD`
  - If `OUTDIR/YYYY-MM-DD` already exists, append a short suffix to avoid collisions, e.g. `YYYY-MM-DD-02`, `YYYY-MM-DD-03`.

### 1) Gather repo-level signals (fast, lightweight)

Run a small set of commands to ground the analysis:
- Repo/branch context: `git rev-parse --show-toplevel`, `git status --porcelain`, `git branch --show-current`
- Recent intent: `git log --oneline -n 30`
- File inventory: `git ls-files | wc -l`
- Largest files/dirs (pick one approach that works in the repo):
  - `git ls-files -z | xargs -0 wc -l | sort -nr | head`
  - or, if large, sample only top directories first

Summarize results briefly; do not dump huge command output.

### 1.5) Check for existing improvement backlog (avoid duplicates)

If `OUTDIR` exists, scan prior runs to avoid duplicating work:
- Find recent prior repo radar reports (if any) and note what was already proposed.
- If a newly proposed task substantially matches an existing task in a previous run:
  - Always include a link/path to the earlier item doc.
  - Prefer adding “what changed since last run” rather than rewriting the same rationale.
  - Apply `REPEATS`:
    - `summary` (default): Do not count repeats toward `LIMIT`; put them in a short “Previously Identified (Still Open)” section at the end.
    - `include`: Treat repeats like normal tasks and count toward `LIMIT`.
    - `hide`: Omit repeats unless new evidence makes it materially more urgent.

### 2) Identify “hotspots” (high churn, high complexity concentration)

Compute top-changed files over `SINCE`:
- `git log --since="$SINCE" --name-only --pretty=format: | sed '/^$/d' | sort | uniq -c | sort -nr | head -n 30`

For the top ~10 candidates, open and inspect:
- Are these “god modules”, cross-cutting helpers, or unstable interfaces?
- Are tests tightly coupled to internals?
- Is there config/flag sprawl, duplicated patterns, or mixed responsibilities?

### 3) Look for structural “smells” that imply big wins

Depending on what you find (and `FOCUS` if provided), probe with targeted searches:
- **Layering violations**: imports that go “the wrong direction”, circular-ish dependency patterns, shared modules that depend on feature modules
- **API sprawl**: overly-wide public exports / re-exports, many parameters, many call sites for unstable functions
- **Duplication clusters**: near-identical helpers/config blocks/validation logic across folders
- **Test brittleness**: repeated setup fixtures, slow integration patterns used everywhere, snapshot sprawl, coupled mocks
- **Docs drift**: multiple partial sources-of-truth, stale README sections compared to current usage
- **Architecture change candidates** (only if justified by symptoms/evidence):
  - “Async boundary confusion”: blocking I/O inside async paths, ad-hoc threadpool usage, mixed sync/async stacks
  - “Lifecycle sprawl”: inconsistent initialization/cleanup patterns, duplicated composition roots, scattered wiring
  - “Boundary leaks”: domain/app layers importing framework details, cross-package private imports, “reach-through” into internals
  - “Pattern pressure”: repeated hand-rolled factories/service-locators/registries that indicate a missing or wrong abstraction

Be explicit about what you searched for and why.

### 4) Synthesize into a prioritized improvement list

Create **at most `LIMIT`** task candidates. Prefer fewer, higher-confidence items over many weak ones.

Apply an explicit impact bar:
- If `BAR=high` (default): include only items that are plausibly **multiplicative** (reduce future change cost across multiple modules or remove a recurring footgun). Drop anything that reads like a preference nit.
- If `BAR=medium`: allow some “cleanup with payoff” items, but keep them bounded and evidence-based.
- If `BAR=low`: allow exploratory opportunities and design spikes; clearly label as such.

If `BAR=high` and fewer than ~3 tasks clear the bar, explicitly say “No additional high-leverage items found in this pass” and do not pad the list with weaker items.

Each task must include:
- Title (short, specific)
- Type: `Problem` (something hurts / is risky) or `Opportunity` (not broken, but worth improving)
- Statement:
  - If `Problem`: what hurts today / what risk exists
  - If `Opportunity`: what could be better and why it is worth doing now
- Evidence (paths + commands)
- Proposed solution (directional, not over-designed). If proposing an architectural refactor (pattern/lifecycle/async), include:
  - 2–3 options with trade-offs (including “do nothing” if appropriate)
  - a migration plan (pilot → incremental rollout → cleanup)
  - a measurable success signal (runtime, testability, coupling reduction, defect class eliminated)

Extra guardrail: if the proposal is primarily “decouple from framework X” or “introduce pattern Y”, it must cite a concrete driver (current pain, measurable limitation, or an upcoming planned change). If no driver is found, drop it (or downgrade to `P2`/`BAR=low` exploratory).
- Success criteria (how to know it’s done)
- Estimated impact radius (what areas touched)
- Effort estimate: `S` / `M` / `L` (relative, based on repo conventions and risk)
- Expected payoff: a 1–2 line ROI summary (what cost goes down / what gets faster / what becomes safer)
- Risk/mitigation (migration steps, rollout, tests)

## Output Format

### Repo Radar Report

1) **Context**: branch, `SINCE`, `FOCUS`, repo size quick stats
2) **Top Hotspots**: top churn list (brief) + 2–5 “why this is hot” notes
3) **Findings** (numbered, ordered by leverage):
   - `P0` = high leverage + high confidence
   - `P1` = high leverage but needs validation
   - `P2` = nice-to-have / opportunistic
   - Tag each finding as `Problem` or `Opportunity` and include a 1-line “why now”.
4) **Proposed Tasks**: the final curated list (<= `LIMIT`)
5) **Previously Identified (Still Open)** (only if `REPEATS=summary`): short list of repeats + pointer to prior item docs + “what changed since last run”
6) **Next Run Suggestions**: what to measure/check next time to track progress

### Optional: Write Task Docs (only if `WRITE_DOCS`)

Create:
- A per-run folder: `OUTDIR/RUN_ID/`
- `OUTDIR/RUN_ID/repo-radar.md` (the report) if `WRITE_WHAT` is `report` or `both`
- `OUTDIR/RUN_ID/items/<NN>-<kebab-title>.md` for each proposed task if `WRITE_WHAT` is `items` or `both`

Each item doc should be copy-pasteable into an issue later (clear scope + acceptance criteria).

Do not write any other files unless the user explicitly asks.
