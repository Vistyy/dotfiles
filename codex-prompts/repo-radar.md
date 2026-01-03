---
description: Audit the current repository for high-leverage, large-scale improvement opportunities and produce an evidence-based report (report-only; no file writes).
---

## User Input

```text
$ARGUMENTS
```

Treat `$ARGUMENTS` as optional context (free-form prose), not a directive language.

Helpful examples:
- What you care about most (speed, test reliability, architecture boundaries, docs drift, developer ergonomics)
- Known pain points (“onboarding is hard”, “tests are flaky”, “refactors are scary”, “build is slow”)
- Constraints (“don’t touch API shape”, “no new deps”, “must stay incremental”)

If the input is empty or vague, proceed with the baseline audit.

## Goal

Produce an evidence-based “repo radar” report that surfaces **large-scale** improvements and investments (architecture boundaries, hotspots, duplication patterns, coupling, churn, inconsistent conventions, complexity concentration).

This is not limited to “things that are broken”. Include proactive improvements that:
- reduce long-term maintenance cost / cognitive load
- improve developer experience (tooling, tests, build/lint speed, ergonomics)
- reduce risk (footguns, unclear invariants, weak boundaries)
- create a cleaner foundation for likely upcoming work

Avoid micro-nits like renaming variables or merging two tests unless they are symptoms of a broader structural issue.

## Operating Constraints (Non-Negotiable)

- **Evidence-first**: Do not speculate. Every recommendation must cite concrete evidence:
  - `file/path:line` references when pointing at code, and/or
  - the exact command(s) run and a short excerpted result summary.
- **No code edits**: Do not modify product code in this run.
- **No file writes**: Do not create or modify any files in this run (including under `docs/`). Report in chat only.
- **Prefer leverage**: Focus on changes that reduce ongoing cost (maintenance, cognitive load, defects) across multiple files/modules.
- **Scope tasks**: Each task must be independently implementable, timeboxable, and have clear success criteria.
- **Avoid preference-nits**: Do not propose changes that are primarily stylistic or taste-based unless they prevent real drift or recurring confusion with concrete downstream cost.
- **Cap doc-only work**: Propose at most **one** docs-only task, and only if it prevents drift or mis-implementation.

## Baseline Defaults (Static)

Use these defaults unless the user explicitly asks otherwise (in natural language):

- **Time window**: last ~180 days of git history (for churn/hotspots)
- **Output limit**: up to 8 proposed tasks (prefer fewer if confidence is low)
- **Leverage bar**: high (skip weak “maybe” suggestions)
- **Mode**: include both problems + opportunities

If user input implies a different time window or focus area, apply it as a soft hint — do not invent a directive system.

## Execution Steps

### 1) Gather repo-level signals (fast, lightweight)

Run a small set of commands to ground the analysis:
- Repo/branch context: `git rev-parse --show-toplevel`, `git status --porcelain`, `git branch --show-current`
- Recent intent: `git log --oneline -n 30`
- File inventory: `git ls-files | wc -l`
- Largest files/dirs (pick one approach that works in the repo):
  - `git ls-files -z | xargs -0 wc -l | sort -nr | head`
  - or, if large, sample only top directories first

Summarize results briefly; do not dump huge command output.

### 2) Identify hotspots (high churn, high responsibility concentration)

Compute top-changed files over the baseline window:
- `git log --since="180 days ago" --name-only --pretty=format: | sed '/^$/d' | sort | uniq -c | sort -nr | head -n 30`

For the top ~10 candidates, open and inspect:
- Are these “god modules”, cross-cutting helpers, or unstable interfaces?
- Are tests tightly coupled to internals?
- Is there config/flag sprawl, duplicated patterns, or mixed responsibilities?

### 3) Look for structural smells that imply big wins

Depending on what you find (and the user’s stated concerns, if any), probe with targeted searches (use `rg` where appropriate):
- **Layering violations**: imports that go “the wrong direction”, shared modules depending on feature modules, circular-ish dependency patterns
- **API sprawl**: overly-wide public exports/re-exports, many parameters, many call sites for unstable helpers
- **Duplication clusters**: near-identical helpers/config blocks/validation logic across folders
- **Test brittleness**: repeated setup fixtures, slow integration patterns used everywhere, snapshot sprawl, coupled mocks
- **Docs drift**: multiple partial sources-of-truth, stale README sections compared to current usage
- **Architecture change candidates** (only if justified by symptoms/evidence):
  - “Async boundary confusion”: blocking I/O inside async paths, mixed sync/async stacks
  - “Lifecycle sprawl”: inconsistent initialization/cleanup patterns, duplicated composition roots, scattered wiring
  - “Boundary leaks”: domain/app layers importing framework details, “reach-through” into internals
  - “Pattern pressure”: repeated hand-rolled factories/service-locators/registries that indicate a missing or wrong abstraction

Be explicit about what you searched for and why.

### 4) Synthesize into a prioritized improvement list

Create **up to 8** task candidates. Prefer fewer, higher-confidence items over many weak ones.

Apply a strict impact bar: include only items that are plausibly **multiplicative** (reduce future change cost across multiple modules or remove a recurring footgun). Drop anything that reads like a preference nit.

If fewer than ~3 tasks clear the bar, explicitly say “No additional high-leverage items found in this pass” and do not pad the list with weaker items.

Each proposed task must include:
- Title (short, specific)
- Priority: `P0` / `P1` / `P2`
- Type: `Problem` (something hurts / is risky) or `Opportunity` (not broken, but worth improving)
- Statement:
  - If `Problem`: what hurts today / what risk exists
  - If `Opportunity`: what could be better and why it is worth doing now
- Evidence (paths + commands)
- Proposed solution (directional, not over-designed)
  - If proposing an architectural refactor (pattern/lifecycle/async), include:
    - 2–3 options with trade-offs (including “do nothing” if appropriate)
    - a migration plan (pilot → incremental rollout → cleanup)
    - a measurable success signal (runtime, testability, coupling reduction, defect class eliminated)
- Success criteria (how to know it’s done)
- Estimated impact radius (what areas touched)
- Effort estimate: `S` / `M` / `L`
- Expected payoff: 1–2 line ROI summary
- Risk/mitigation (migration steps, rollout, tests)

Extra guardrail: if the proposal is primarily “decouple from framework X” or “introduce pattern Y”, it must cite a concrete driver (current pain, measurable limitation, or an upcoming planned change). If no driver is found, drop it (or label explicitly as exploratory and keep it `P2`).

## Output Format

### Repo Radar Report (in chat)

1) **Context**: branch, time window used, repo size quick stats, and any user-stated constraints
2) **Top Hotspots**: top churn list (brief) + 2–5 “why this is hot” notes
3) **Findings** (numbered, ordered by leverage): each tagged with `P0`/`P1`/`P2` and `Problem`/`Opportunity`, plus a 1-line “why now”
4) **Proposed Tasks**: the final curated list (<= 8)
5) **Next Actions**: the single best “start here” task + what to check next run to track progress

End the report with one simple question:
“Want me to turn any of these into scoped task docs (or an issue-ready checklist) in a follow-up message?”
