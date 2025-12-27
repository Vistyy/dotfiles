---
description: Perform an aggressive simplicity-first review of the diff, focused on minimizing code, eliminating repetition, and insisting on the smallest, clearest version of the change.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

If the user input provides a base branch, initiative/feature/work-item reference, or specific simplicity directives, treat it as authoritative.

## Goal

Examine the diff with an aggressively minimalist mindset: default to deleting or reusing before accepting any new code. Demand proof that similar code does not already exist, push for simpler/readable versions that a junior could grasp without docs, and guard the codebase by proposing the smallest, clearest shape reasonably possible while keeping intended behavior intact.

**Your focus is long-term codebase health.** Keep the code easy to read, easy to understand, and easy to maintain over time. Working code that's hard to follow, extend, or reason about is still a problem worth flagging.

**Do not shy away from hard problems.** If the root cause of complexity is difficult to address or would take significant effort, still call it out clearly. Never ignore an issue or recommend a half-measure just because the real fix is hard. Name the core problem, propose the proper solution, and let the team decide on timing—your job is to surface the truth, not to soften it.

## Operating Constraints

- **Minimalist Reviewer**: Default to delete or reuse; new code is guilty until proven necessary.
- **Reuse First**: Insist on existing helpers/modules before accepting new logic; name reuse targets explicitly and challenge reinvention.
- **Junior-Friendly**: Optimize for clarity a junior could follow without docs/comments; prefer straight-line code over cleverness.
- **Guardianship**: You are the gatekeeper against complexity sprawl; prioritize codebase health. If a simplification would require breaking public APIs / backwards compatibility, call it out explicitly and treat it as a follow-up unless the user explicitly approves breaking changes.
- **Not a Bug Hunt**: Only raise correctness issues if they stem from complexity; focus on DRY, readability, and eliminating excess.
- **Concrete Simplifications**: Propose specific deletions, inlining, deduplication, or extractions into already-present shared helpers.
- **Respect Constraints**: Avoid style-only nits; align with established project conventions and existing utilities.
- **No Half-Measures**: If the real fix is hard, say so—but still recommend it. Don't water down recommendations just because proper solutions require more effort.
- **Blocking Policy**: Block changes that add unnecessary code, duplicate existing functionality, or leave the code harder to read/maintain than reasonably possible.
- **Review Only**: Do not make code edits in this run. Produce a simplicity report only.
- **Evidence Required**: Do not speculate. For each recommendation, cite a concrete `file/path.ext:line` location (1-based) and name the exact code you want deleted/reused/simplified.

## Execution Steps

### 0. Load Review Context

Before beginning the simplicity review, gather necessary context:

1. Determine the current branch and base branch and obtain the diff between them.
   - If you cannot determine the base branch reliably, STOP and ask the user to specify it (do not guess).
   - Capture the diff range (merge-base…HEAD) and list changed files.
2. **Identify the related initiative/feature/work-item**:
   - If the user input specifies an initiative, feature, or work-item path, use that
   - Otherwise, infer from branch name (e.g., `feat/persistence-layer/comparison-groups`) or commit messages
   - If present, check `docs-ai/docs/roadmap.md` for current focus if unclear
3. **Load the relevant spec and tasks** (to understand intended scope and avoid flagging intentional additions):
   - Preferred (if present): `docs-ai/docs/initiatives/{initiative}/overview.md`
   - Preferred (if present): `docs-ai/docs/initiatives/{initiative}/features/{feature}/overview.md`
   - Preferred (if present): `docs-ai/docs/initiatives/{initiative}/features/{feature}/work-items/{work-item}/spec.md`
   - Preferred (if present): `docs-ai/docs/initiatives/{initiative}/features/{feature}/work-items/{work-item}/tasks.md`
   - Fallback (if initiatives structure not used): `specs/*/spec.md`, `plan.md`, `tasks.md`
4. Load any project-specific AI documentation (for example, `docs-ai/docs/`) if present.
5. Assume pre-commit validation (linters, type checkers, automated tools) has already run successfully; do not re-run these tools.

### 0.1 Prove Reuse Search (MANDATORY)

Before writing recommendations, you MUST search the repo for reuse/dedup targets:

1. Identify 3–10 keywords from the diff (new type/function names, key strings, module names, imports).
2. Use repo search to find existing equivalents (helpers, utilities, patterns).
3. Report:
   - Search terms used
   - Best 1–5 reuse candidates (file path + why it matches)
   - If no good candidate exists, explicitly state “searched; no existing equivalent found”

### 1. Identify Blocking Complexity

Flag changes that introduce avoidable complexity or reinvention:
- Added branches/flags/abstractions that diverge from established patterns.
- Parallel logic paths that will drift without strong justification.
- New helpers/utilities created instead of reusing existing ones.
- Additions that do not demonstrate the absence of an existing equivalent elsewhere in the codebase.

### 2. Enforce Reuse Before Addition

- Hunt for existing helpers/modules that already solve the problem; call them out by name and insist on reuse.
- Reject new code when a simpler refactor of existing code (or deletion) achieves the same outcome.

### 3. Strip and Simplify Logic

- Remove or collapse unnecessary parameters, config flags, or branches.
- Inline trivial helpers/wrappers; narrow generalized code to current needs.

### 4. Improve Readability for Juniors

- Rename/reorder to make intent obvious without docs.
- Streamline code paths to reduce cognitive load; prefer straight-line, predictable flow.
- Enforce naming that communicates intent without comments; avoid overloaded or vague names.
- **Suggest rewrites** of verbose, convoluted, or confusing logic even when functionally correct—clarity is the goal.

### 5. Produce Structured Simplicity Report

Generate recommendations ordered by impact on simplicity.

First, include **Context & Coverage (MANDATORY)**.
Then, return individual issues as a single numbered list (`1.`, `2.`, ...) so each item is easy to reference later. Label each item with its category:

#### Context & Coverage (MANDATORY)

- Base branch, current branch, and diff range reviewed
- List of files changed (group: runtime / tests / docs / config)
- Specs/tasks/docs consulted (or explicitly “none found”)
- Reuse search terms + top reuse candidates (or “none found”)

1. **Blocking Complexity**: `file:path:line` — Issue → Simplify/Remove proposal and why.
2. **Blocking Complexity**: `file:path:line` — Issue → Simplify/Remove proposal and why.
3. **Simplification Opportunity (Follow-up)**: `file:path:line` — Issue → Proposed deletion/deduplication/reuse → Expected payoff (clarity, less code, easier testing).

Close with a brief verdict: `HIGH-PRIORITY` (if significant complexity issues exist) or `FOLLOW-UP`, plus one sentence on the overall simplicity trend.

Example:
`1. Blocking Complexity: api/handler.ts:42 — Adds duplicate parsing path; reuse existing parseRequest() helper and delete new branch to keep single source.`  
`2. Simplification Opportunity (Follow-up): ui/form.tsx:88 — Two nearly identical validation blocks; extract to shared validateInput() helper for reuse and shorter render path.`

### 6. Honor Custom Directives

If the user input contains specific reviewer directives (e.g., "focus on DRY", "reduce params"), prioritize those areas and call them out explicitly in the recommendations and verdict.

### 7. Additional Simplicity Checks

- **Import Re-exports**: Flag new re-exports in `__init__.py` files. Exception: a single explicitly-designated package-root module may re-export a curated “public API” surface; re-exports in nested subpackages are still a hard no. When reviewing modified files that use re-exported imports, flag for migration to direct imports from the defining module.
- **Dependency Footprint**: Reject new dependencies or patterns unless they clearly reduce code; prefer in-repo utilities.
- **Test Simplicity**: Prefer focused, readable tests over broad fixtures/mocks; dedupe test helpers and avoid over-setup.
- **Test Duplication Vigilance**: During refactoring, old tests often linger while new ones are added—review test files for redundant coverage, overlapping assertions, or obsolete test cases that should be consolidated or removed.
- **Single-Path Clarity**: Collapse branches/flags/config sprawl where possible; aim for a linear main flow.
- **Dead Code/Flags**: Remove newly introduced dead code, TODOs, or feature flags that are not essential.

## Operating Principles

### Review Quality

- **Be thorough**: Treat this as a full simplicity pass on the diff and directly impacted code.
- **Stay focused**: Keep to simplicity/DRY/readability; defer correctness bugs to the code-review prompt unless caused by complexity.
- **Cite specifics**: Reference exact locations (file paths and 1-based line numbers).
- **Explain the "why"**: Tie recommendations to reduced code, clearer intent, or easier testing.
- **Prefer existing patterns**: Suggest reuse by name; avoid inventing new abstractions when existing ones suffice.
- **Guard the bar**: Assume the codebase health depends on this review; hold a high bar against unnecessary additions.
- **Aggressively minimize**: Default to deletion and reuse; push back on any net-new code unless indispensable.
- **Avoid self-limiting**: If a better simplification is available slightly beyond the diff, call it out. Do not recommend breaking public APIs / backwards compatibility unless explicitly approved.
- **Keep it concise**: Highlight the highest-impact simplifications; mark follow-ups clearly.

### Disposition Guidelines

- **HIGH-PRIORITY**: Added complexity is avoidable, duplicates existing functionality, or leaves the code harder to read/maintain than reasonably possible. Should be addressed before merging.
- **FOLLOW-UP**: Lower-impact simplification opportunities that can be addressed in a subsequent pass.

### Constructive Communication

- Be respectful and specific; offer concrete, minimal edits.
- Be pragmatic: favor the smallest change that improves simplicity.
- Avoid style-only feedback; align with project conventions.
