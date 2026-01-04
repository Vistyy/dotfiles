---
description: Define or repair a work item spec (spec.md) so it is small, unambiguous, and ready for work-item-plan to generate plan.md.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** treat `$ARGUMENTS` as the *work item link* (or intended work-item path) that identifies what to specify.

Example arguments:
```text
persistence-layer/ingestion-pipeline/parser-regression-sync
docs-ai/docs/initiatives/persistence-layer/features/ingestion-pipeline/work-items/parser-regression-sync
```

## Goal

Create or update a high-quality `spec.md` for the referenced work item such that:

1. The work item is clearly scoped (in/out), small, and implementable
2. Material decisions are explicit or tracked as open questions
3. Acceptance criteria are concrete (checkboxes) and testable
4. The feature `overview.md` Work Items table is updated to include this work item (row + status)
5. The work item is ready for `work-item-plan` to generate `plan.md`

Do **not** create `plan.md` in this run.
Do **not** implement code in this run.

This task is **interactive**: if you need clarification, you MUST ask and wait.

## Interaction Default (Important)

Default behavior is **question-first**:

- In your **first** response, ask **ONE** question using **Question Format (MANDATORY)**.
- Only skip the initial question if the user explicitly says “skip questions” / “assume defaults”.

If you have not asked the user at least one question in this thread, you must not write `spec.md` yet.

## Status Convention (Non-Negotiable)

Work item status MUST use this exact vocabulary everywhere it appears (spec header + feature Work Items table):

- `planned` — intended, not started
- `in-progress` — actively being worked on
- `done` — completed and verified
- `deferred` — explicitly post-MVP or intentionally out-of-scope for now

Do not put qualifiers like “(post-mvp)” or “(merged into …)” in the Status value.
Put qualifiers in the Description or in the body of `spec.md`.

## Decision Granularity (Non-Negotiable)

This prompt operates at the **work item spec** level.

You MUST lock down enough to make the work item:
- clearly scoped (in/out)
- verifiable (acceptance criteria)
- slice-stable (no hidden dependencies that would invalidate the work item)

You MUST NOT lock down full implementation details that belong in `plan.md` (exact file edits, step-by-step commands), unless the detail is required to make acceptance criteria meaningful or to avoid rework (e.g., a public API shape).

## Existing Docs Compatibility (Important)

When touching an existing feature `overview.md`, make the smallest coherent change:
- Do not “mass normalize” historical rows/status values unless the user explicitly asks.
- If you encounter legacy status strings in the Work Items table, fix only the row(s) you add/change, and call out the mismatch for follow-up.

## Output Constraint (Non-Negotiable)

Do NOT paste full `spec.md` content in chat.

- In chat: provide only a brief outline (max 10 bullets), plus the required **Decision Confirmation Table** when asserting **“No blocking questions remain”**, plus the single pending question (if any).
- Write changes to `spec.md` only after Hard Gate (A) is satisfied.

## Plan-ability Bar (Non-Negotiable)

The `spec.md` MUST be specific enough that `work-item-plan` can produce an executable `plan.md` without guessing:

- Clear boundaries (what is in/out)
- Concrete acceptance criteria (verifiable)
- Identified touchpoints (exact file paths/symbols if known; otherwise explicit open questions)
- No “we’ll figure it out during implementation” for material decisions

If the requested scope is too large, you MUST propose a split into multiple work items and ask for confirmation rather than writing an overbroad spec.

## What counts as “material uncertainty”

A decision is **MATERIAL** if it affects any of:
- Public API shape (endpoints, payloads, contract models)
- Query semantics (filtering/ordering/tie-breaks)
- Transaction boundaries / consistency guarantees
- Schema invariants (constraints, nullability, cascades)
- Data returned to downstream systems/features

If any material uncertainty exists, you MUST ask the user (one question at a time) before writing `spec.md`.

## What counts as “blocking” for spec.md

An open question is **BLOCKING** only if it prevents writing a useful work item spec, for example:
- we can’t state a stable goal or scope boundaries
- we can’t write verifiable acceptance criteria
- we can’t tell whether this is one work item vs should be split

Non-blocking uncertainties MUST be captured under an **Open Questions** section in `spec.md`, but they do not prevent writing/updating `spec.md`.

## Decision Confirmation Rule (Non-Negotiable)

A material decision is **NOT resolved** unless it is either:

1) Explicitly stated in a referenced design/ADR, OR
2) Confirmed by the user in this thread (A/B/C or “yes”).

If a material decision would rely on a default, assumption, “common sense”, or guess, it counts as an **open question** and you MUST trigger Hard Gate (B).

## Hard Gate (Non-Negotiable)

Before writing/updating `spec.md`, you MUST either:

- (A) State: **“No blocking questions remain”** and include a small **Decision Confirmation Table** (spec-level only):
  - Decision
  - Chosen option
  - Source: “design/ADR” / “user-confirmed in chat”

OR

- (B) STOP and ask **ONE blocking** question (using **Question Format (MANDATORY)**). Do not edit files until the user answers.

## Question Format (MANDATORY)

Use this format ONLY for questions you ask the user to proceed.

```md
**Question:** <the single question you need answered>

**Recommended:** Option A — <1–2 sentence reasoning>

| Option | Description |
|--------|-------------|
| A | ... |
| B | ... |
| C | ... |

Reply with A/B/C, or say “yes” to accept the recommendation.
```

Only ask **ONE** question per message. If multiple uncertainties exist, ask about the single highest-impact one first and list the others as “Pending (will ask next)”.

## Execution Steps

### 1) Resolve work item directory + spec.md

Resolve `$ARGUMENTS` to a single `WORK_ITEM_DIR`:

- Preferred slug form: `{initiative}/{feature}/{work-item}`
  - Map to: `docs-ai/docs/initiatives/<initiative>/features/<feature>/work-items/<work-item>/`
- Also acceptable: direct path to the work-item directory

Then define:
- `WORK_ITEM_SPEC = WORK_ITEM_DIR/spec.md`
- `FEATURE_OVERVIEW = docs-ai/docs/initiatives/<initiative>/features/<feature>/overview.md`

If multiple candidates exist, STOP and ask the user to choose the correct one.

### 2) Load minimal context (progressive disclosure)

Read in this order:
1. `docs-ai/docs/roadmap.md`
2. initiative `overview.md`
3. feature `overview.md` (and `design.md` if needed)
4. any referenced ADR/design links from those docs

### 3) Write/update spec.md (when Hard Gate A is satisfied)

Ensure `spec.md` contains, at minimum:
- Status + Feature
- Goal (what this delivers)
- Scope (included/excluded)
- Acceptance criteria (checkboxes)
- Decisions (what is locked in)
- Open questions (what is not locked in)
- Dependencies / references (links, not duplicated details)

Also ensure the feature Work Items table includes this work item (row + status).

When adding/updating the work item row in the feature `overview.md`, the table MUST use this exact shape:

```md
| Work Item | Description | Status |
|-----------|-------------|--------|
| some-work-item-slug | One-line description | planned |
```
