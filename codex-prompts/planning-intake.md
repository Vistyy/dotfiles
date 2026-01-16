---
description: Start from a fuzzy goal, interview to lock requirements, then update roadmap.md + delivery-map.md and create/extend initiative/feature/work-item docs (writes files after explicit confirmation).
---

## User Input

```text
$ARGUMENTS
```

Treat `$ARGUMENTS` as a **fuzzy intent** (“I want something done”) unless it clearly points at an existing initiative/feature/work-item path/slug.

Examples:
```text
make staging deployments boring and safe
hosting-delivery/delivery-pipeline
docs-ai/docs/initiatives/hosting-delivery/features/delivery-pipeline
```

## Goal

Turn a fuzzy request into **work-ahead planning** that is captured in:

1. `docs-ai/docs/roadmap.md` (high-level sequencing / initiatives / feature map)
2. `docs-ai/docs/initiatives/delivery-map.md` (near-term waves + work-item queue)
3. Initiative/feature/work-item docs under `docs-ai/docs/initiatives/**` (living documentation / details)

This prompt is **interactive** and may span multiple turns.

Do **not** implement product code in this run.

## What this prompt is (and is not)

- This is the **front door** for planning when the user starts with: “I want X done”.
- The user should **not** be required to choose between `initiative-plan`, `feature-plan`, or `work-item-spec` up front.
- You are responsible for:
  - interviewing to nail down “what X is”
  - creating new initiatives/features/work-items when needed
  - adding work-ahead items to `delivery-map.md` (waves)
  - keeping `roadmap.md` consistent

## Non-Negotiables

### 1) Interview-first (no premature doc edits)

You MUST interview the user to lock down requirements before writing files.

- Ask **one question per message**, using **Question Format (MANDATORY)**.
- Prefer multiple-choice options, and include a **Recommended** option when possible.

### 2) Anti-hyperfocus: second-order requirements sweep (non-checklist)

Before you propose waves/work items, you MUST run a **second-order requirements sweep** to avoid planning only “the obvious” work while missing what makes it actually shippable/boring to operate.

This is intentionally **not** a fixed checklist: you must adapt it to the topic and the repo.

Concretely:
- Identify the most likely “missing-but-required” work around the core goal (the kind of thing that would otherwise be discovered mid-implementation).
- If you believe “nothing else is required”, say so explicitly and briefly justify why.
- If any potentially-missing area would materially change scope/slicing/acceptance criteria, you MUST ask the user (one question at a time, across turns).

This sweep MUST also consider the **experience bar**: whether the outcome should be modern, nice to use, and simple (not merely functional).

### 3) Minimal edits to existing living docs

When extending an existing initiative/feature with many historical items:

- Do **not** rewrite large sections to “re-plan everything”.
- Prefer **append-only** updates:
  - add new Work Items rows
  - add a short dated “Amendments / Additions” note (optional)
- Never change `in-progress` / `done` work-item intent or boundaries unless the user explicitly requests it.

### 4) Documentation stewardship (mandatory)

Before making **any** edit under `docs-ai/docs/`, you MUST use the `documentation-stewardship` skill and follow its “STOP - Before You Edit” checklist.

If that skill conflicts with this prompt, STOP and ask the user how to proceed.

### 5) Output constraints

Do NOT paste full doc contents in chat.

In chat, provide only:
- a short outline (<= 10 bullets)
- a “Proposed Change Set” list (file ops + new slugs)
- the single pending question (if any)

## File locations (resolution rules)

Try these in order; if a required file does not exist, you MUST ask the user before creating a new convention.

- `ROADMAP = docs-ai/docs/roadmap.md`
- `DELIVERY_MAP = docs-ai/docs/initiatives/delivery-map.md`
  - Fallback: `docs-ai/initiatives/delivery-map.md`

Wave briefs (durable requirements; referenced from `DELIVERY_MAP`):

- Preferred: `WAVES_DIR = docs-ai/docs/initiatives/waves/`
  - `WAVE_BRIEF = WAVES_DIR/<wave>.md`

Initiatives/features/work items (preferred structure):

- `INITIATIVE_DIR = docs-ai/docs/initiatives/<initiative>/`
- `FEATURE_DIR = docs-ai/docs/initiatives/<initiative>/features/<feature>/`
- `WORK_ITEM_DIR = docs-ai/docs/initiatives/<initiative>/features/<feature>/work-items/<work-item>/`
  - `WORK_ITEM_SPEC = WORK_ITEM_DIR/spec.md`

If the repo uses a different structure, you MUST detect and follow it, and record the convention you observed.

## Hard gates

### Gate (A): Requirements ready enough to propose a wave

Before proposing new wave(s) / work items, you must have:
- a 1–2 sentence objective
- a “Definition of Done” (end-to-end outcome)
- at least 3 concrete scenarios/use-cases (can be short)
- at least 3 constraints/non-goals (or “none” explicitly confirmed)

If not, ask questions and STOP.

When Gate (A) is satisfied, you MUST plan to capture these requirements durably in one `WAVE_BRIEF` per proposed wave (rather than expanding `DELIVERY_MAP` content).

### Gate (B): Explicit user approval before writing files

Before any file edits, you MUST:

1) Present a **Proposed Change Set** summary including:
   - new/updated initiative(s)
   - new/updated feature(s)
   - proposed wave name(s) in `delivery-map.md`
   - `WAVE_BRIEF` file path(s) to create/update (one per proposed wave)
   - work-item slugs to add (with 1-line descriptions)
   - file operations you will perform (create/update)
2) Provide a **Decision Confirmation Table** (material decisions only):
   - Decision
   - Chosen option
   - Source: “user-confirmed in chat” / “existing docs”
3) Ask for approval using **Question Format (MANDATORY)**:
   - Option A: “Yes, apply the change set”
   - Option B/C: “Adjust first / stop”

Do not write files until the user approves.

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

Ask **ONE** question per message. If multiple uncertainties exist, list the rest as “Pending (will ask next)”.

## Execution steps

### 1) Load minimal repo context (progressive disclosure)

Read only what you need to avoid contradictions:

1. `ROADMAP`
2. `DELIVERY_MAP`
3. If `$ARGUMENTS` hints at an existing initiative/feature, open:
   - `INITIATIVE_DIR/overview.md` (if exists)
   - `FEATURE_DIR/overview.md` and `FEATURE_DIR/design.md` (if exists)
4. If proposing changes inside a feature, scan:
   - `FEATURE_DIR/work-items/` (existing slugs)
   - any `spec.md` files for `in-progress` items you might interact with

### 2) Context Read Ledger (required in first response)

In your first response, list the files you opened (paths only) and a 1-line “why it matters”.
Do NOT paste doc content.

### 3) Interview loop (requirements-first)

Run the interview one question at a time, prioritizing:

1) Objective + Definition of Done
2) Scenarios (happy path + failure path)
3) Constraints / non-goals (what must NOT happen)
4) Second-order requirements sweep (anti-hyperfocus)
5) Scope boundaries (what is explicitly out)

To keep the interview grounded (and avoid “functional but annoying” outcomes), you SHOULD ensure the interview elicits:
- **Default path**: what does “first successful use” look like for a fresh user/machine, step-by-step (short narrative)?
- **Failure story**: how does this fail, and what should the UX/operator experience be when it fails?
- **Annoyance check**: what would make the result feel annoying or high-friction if we shipped it as-is?

### 4) Slicing + wave proposal (after Gate A)

Propose:
- 1–N wave(s) with short names (follow existing delivery-map style)
- the `WAVE_BRIEF` file path for each wave (requirements live there; `DELIVERY_MAP` should reference it)
- a set of work items per wave (small, focused, independently verifiable)
- any required new initiative/feature containers (only when necessary)

### 5) Apply changes (after Gate B approval)

After approval:
- Use `documentation-stewardship` before editing `docs-ai/docs/**`
- Update `ROADMAP` and `DELIVERY_MAP` (ensure each proposed wave line in `DELIVERY_MAP` references its `WAVE_BRIEF`, preferably via a short relative path or markdown link)
- Create/update `WAVE_BRIEF` files (objective, DoD, scenarios, constraints, and any integration notes)
- Create any missing initiative/feature/work-item folders and stub docs
- Update feature Work Items tables to include the new work items

Then stop. Do not start `work-item-plan` here; instead, recommend which work item to specify next via `work-item-spec`.
