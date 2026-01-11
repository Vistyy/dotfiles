---
description: Execute an interactive work item plan (plan.interactive.md) created by work-item-plan by facilitating one human decision at a time (Question Format), then applying the plan steps between gates.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** treat `$ARGUMENTS` as the *work item link* (or work-item path) that identifies what to execute.

Example arguments:
```text
user-apps/app-foundation/cross-app-user-requirements
docs-ai/docs/initiatives/user-apps/features/app-foundation/work-items/cross-app-user-requirements
docs-ai/docs/initiatives/user-apps/features/app-foundation/work-items/cross-app-user-requirements/plan.interactive.md
```

## Goal

Execute an already-written **interactive** plan for the referenced work item by:

1. Locating the correct `WORK_ITEM_DIR` and its `plan.interactive.md`
2. Loading and critically reviewing `plan.interactive.md` for missing gates/risks before starting
3. Facilitating the work item **one human decision at a time** using **Question Format (MANDATORY)**
4. Executing the plan’s non-gate Tasks between decisions, with verification as specified by the plan
5. Never inventing requirements/decisions on the user’s behalf

## Expected Inputs

Preferred:
- A work item slug: `initiative/feature/work-item` (e.g., `user-apps/app-foundation/cross-app-user-requirements`)
- A direct path to a work item folder containing `spec.md` and `plan.interactive.md`
- A direct path to `plan.interactive.md`

If `$ARGUMENTS` is empty, STOP and ask for the work item slug/path.

## Critical Rules (Non-Negotiable)

- You MUST treat `plan.interactive.md` as the single source of truth for what to do and how to verify it.
- You MUST NOT “fill in” missing requirements, priorities, or decisions. If it isn’t in the plan/spec or user-confirmed in chat, it’s unknown.
- You MUST proceed via explicit **Human Input Gates**:
  - When you reach a Task whose title starts with `HUMAN INPUT GATE — ...`, you MUST STOP and ask the gate’s question using **Question Format (MANDATORY)**.
  - Ask **exactly one** gate question per message, then WAIT for the user’s answer.
- After a user answers a gate, you MUST:
  - Record the answer in the plan’s decision log (or the file/section specified by the plan), and
  - Proceed to the next Task(s) until you reach the next gate.
- If any Task instruction is unclear, missing required file paths, or cannot be executed safely, STOP and ask the user.
- If the plan includes instructions to use other skills (e.g., documentation stewardship), you MUST invoke and follow them at the moment they become relevant.

## Interaction Default (Important)

Default behavior is **ledger-then-question**:

- In your **first** response, you MUST:
  1. Provide the **Context Read Ledger** (file paths only, plus 1-line “why this matters” per doc), THEN
  2. Ask the **first** Human Input Gate question using **Question Format (MANDATORY)**.
- Only skip the initial question if the user explicitly says “skip gates” / “assume defaults” (and if doing so would not create hidden assumptions).

After the user answers:
- Execute the next non-gate Task(s) that depend on that decision.
- STOP again at the next Human Input Gate (one question per message).

## Context Read Ledger (Required)

In the first response, include:

1. **Docs read**: file paths only, plus a 1-line “why this matters” per doc (do NOT paste contents).
2. **Gate starting point**: which Human Input Gate Task you are starting from (Task number + title).

## Question Format (MANDATORY)

Use this format ONLY for questions you ask the user to proceed at a Human Input Gate.

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

## Execution Steps

### 1) Resolve `WORK_ITEM_DIR` and locate `plan.interactive.md`

Resolve `$ARGUMENTS` to a single `WORK_ITEM_DIR`:

- If it’s a path to `plan.interactive.md`, use its parent directory.
- If it’s a path to a work-item directory, use it directly.
- If it’s a slug like `initiative/feature/work-item`, map to:
  - `docs-ai/docs/initiatives/<initiative>/features/<feature>/work-items/<work-item>/`
- If it’s a URL/external work item link (GitHub/Linear/etc.), use repo search (branch name, issue key, slug text) to locate the matching work-item folder.

Then:
- Confirm `WORK_ITEM_SPEC = WORK_ITEM_DIR/spec.md` exists (for context).
- Confirm `WORK_ITEM_PLAN = WORK_ITEM_DIR/plan.interactive.md` exists (required to execute).

If `plan.interactive.md` does not exist:
- STOP and recommend using the `work-item-plan` prompt to generate it.

If `plan.autonomous.md` exists but `plan.interactive.md` does not:
- STOP and recommend using `work-item-execute` instead.

### 2) Load and review `plan.interactive.md`

Read `WORK_ITEM_PLAN` and check for:
- Missing/ambiguous file paths
- Missing verification commands where the plan expects them
- Missing Human Input Gates for any decision-driving content

If you have material concerns, STOP and raise them before starting execution.

### 3) Execute by iterating gates → tasks → next gate

Loop:
1. Identify the next `HUMAN INPUT GATE — ...` Task that has not been answered in this thread.
2. Ask that gate question using **Question Format (MANDATORY)** and WAIT.
3. After the user answers, execute the dependent non-gate Task(s) (edits + verification) until you reach the next gate.
4. Repeat until the plan is complete.

