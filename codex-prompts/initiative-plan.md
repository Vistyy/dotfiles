---
description: Investigate and align on an initiative, resolve uncertainties, then update the initiative overview.md (and roadmap linkages when needed).
---

## User Input

```text
$ARGUMENTS
```

You **MUST** treat `$ARGUMENTS` as the *initiative link* (or initiative slug/path) that identifies what to plan.

Example arguments:
```text
persistence-layer
docs-ai/docs/initiatives/persistence-layer
```

## Goal

Create a coherent, actionable initiative-level “north star” that makes feature planning and work-item slicing safe by:

1. Investigating the current initiative state (docs + folder structure)
2. Surfacing and resolving material uncertainties (scope, boundaries, dependencies)
3. Updating `overview.md` for the initiative so it is consistent and junior-friendly
4. Ensuring initiative-level status/links align with `docs-ai/docs/roadmap.md` (single source of truth for project-wide status)

Do **not** implement code in this run.

This task is **interactive**: if you need clarification, you MUST ask and wait.

## Decision Granularity (Non-Negotiable)

This prompt operates at the **initiative** level.

You MUST lock down only initiative-level decisions:
- scope boundaries (what is in/out)
- the feature map and ownership boundaries
- cross-initiative dependencies and sequencing constraints
- cross-cutting decisions that truly span multiple features

You MUST NOT lock down work-item implementation details (exact file edits, algorithms, schema column choices, endpoint shapes) unless that detail is required to define initiative boundaries.
If you encounter lower-level uncertainty, record it explicitly as an **Open Question** to be resolved at the feature/work-item level.

## Interaction Default (Important)

Default behavior is **question-first**:

- In your **first** response, ask **ONE** question using **Question Format (MANDATORY)**.
- Only skip the initial question if the user explicitly says “skip questions” / “go straight to updates” / “assume defaults”.

If you have not asked the user at least one question in this thread, you must not edit docs yet.

## Output Constraint (Non-Negotiable)

Do NOT paste full `overview.md` content in chat.

- In chat: provide only a brief outline (max 10 bullets), plus the required **Decision Confirmation Table** when asserting **“No blocking questions remain”**, plus the single pending question (if any).
- Write changes directly to the initiative `overview.md` only after Hard Gate (A) is satisfied.

## Documentation Stewardship (Non-Negotiable)

After Hard Gate (A) is satisfied and before making any edits under `docs-ai/docs/`, you MUST use the `documentation-stewardship` skill and follow its “STOP - Before You Edit” checklist.

If `documentation-stewardship` conflicts with this prompt, you MUST treat that as a blocking issue and ask the user for clarification before editing.

## What counts as “material uncertainty”

A decision is **MATERIAL** if it affects any of:
- Initiative scope boundaries (what is explicitly in/out)
- Cross-initiative dependencies (what must ship first)
- Public surface area expectations (APIs, contracts, schema ownership)
- Operational posture (security/privacy constraints, rollout expectations)
- The feature map (which features exist, and what they own)

If any material uncertainty exists, you MUST ask the user (one question at a time) before editing docs.

## What counts as “blocking” for initiative docs

An open question is **BLOCKING** only if it prevents writing a coherent initiative `overview.md` that can guide feature planning, for example:
- we can’t say what’s in/out without risking rework
- we can’t say which feature owns what
- we don’t know a hard dependency that gates sequencing

Non-blocking uncertainties MUST be captured under an **Open Questions** section, but they do not prevent updating `overview.md`.

## Decision Confirmation Rule (Non-Negotiable)

A material decision is **NOT resolved** unless it is either:

1) Explicitly stated in existing initiative docs / `roadmap.md`, OR
2) Confirmed by the user in this thread (A/B/C or “yes”).

If a material decision would rely on a default, assumption, “common sense”, or guess, it counts as an **open question** and you MUST trigger Hard Gate (B).

## Hard Gate (Non-Negotiable)

Before writing/updating the initiative `overview.md`, you MUST either:

- (A) State: **“No blocking questions remain”** and include a small **Decision Confirmation Table** (initiative-level only):
  - Decision
  - Chosen option
  - Source: “roadmap.md” / “initiative docs” / “user-confirmed in chat”

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

### 1) Resolve initiative directory + overview.md

Resolve `$ARGUMENTS` to a single `INITIATIVE_DIR`:

- Preferred slug form: `{initiative}` (e.g., `persistence-layer`)
  - Map to: `docs-ai/docs/initiatives/<initiative>/`
- Also acceptable: direct path to `docs-ai/docs/initiatives/<initiative>/`

Then define:
- `INITIATIVE_OVERVIEW = INITIATIVE_DIR/overview.md`

If multiple candidates exist, STOP and ask the user to choose the correct one.

### 2) Load minimal context (progressive disclosure)

1. Read `docs-ai/docs/roadmap.md` first.
2. Read `INITIATIVE_OVERVIEW` (if it exists).
3. Inspect `INITIATIVE_DIR/features/` (feature list) and compare to:
   - the initiative overview feature table (if present)
   - the initiative table in `roadmap.md`

### 3) Produce initiative updates (when Hard Gate A is satisfied)

Update `INITIATIVE_OVERVIEW` to make it coherent and complete:
- Goal (1–2 paragraphs)
- Scope (in/out)
- Feature map (feature list + ownership boundaries)
- Cross-cutting decisions (only decisions that truly span multiple features)
- Dependencies (other initiatives/services)
- Links to the most relevant deeper docs (feature overviews/designs, ADRs)
- Open Questions (explicit list, tagged as blocking vs non-blocking when useful)

Keep it concise; link to deeper docs instead of duplicating details.

If roadmap status or initiative listings are inconsistent, propose the minimal consistent change set and (if needed) update `docs-ai/docs/roadmap.md` as part of the same change.

## Cross-Doc Impact (Non-Negotiable)

When you edit an initiative doc, you MUST check and update any directly affected documents, not just the single file you started from. Typical impacted docs include:
- `docs-ai/docs/roadmap.md` initiative table + status lines
- the initiative `overview.md` feature map vs the actual `features/` folders
- any initiative-level integration docs (when they exist)

Prefer links over duplication, and remove/replace outdated text rather than appending competing guidance.
