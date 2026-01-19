---
description: Execute an existing work item implementation plan (plan.md) created by work-item-plan, implementing Tasks in order with verification checkpoints.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** treat `$ARGUMENTS` as the *work item link* (or work-item path) that identifies what to execute.

Example arguments:
```text
persistence-layer/price-storage/schema-implementation
docs-ai/docs/initiatives/persistence-layer/features/price-storage/work-items/schema-implementation
docs-ai/docs/initiatives/persistence-layer/features/price-storage/work-items/schema-implementation/plan.md
```

## Goal

Execute an already-written `plan.md` for the referenced work item by:

1. Locating the correct `WORK_ITEM_DIR` and its `plan.md`
2. Loading and critically reviewing `plan.md` for gaps/risks before starting
3. Using the `superpowers:executing-plans` skill to implement the plan’s Tasks in order, end-to-end (checkpoints are for reporting, not approval gates)
4. Running every verification command specified by the plan (including `just quality` after each Task when the plan requires it)
5. Stopping to ask for clarification instead of guessing when the plan is ambiguous or verification fails repeatedly

## Expected Inputs

Preferred:
- A work item slug: `initiative/feature/work-item` (e.g., `persistence-layer/price-storage/schema-implementation`)
- A direct path to a work item folder containing `spec.md` and `plan.md`
- A direct path to a `plan.md`

If `$ARGUMENTS` is empty, STOP and ask for the work item slug/path.

## Critical Rules (Non-Negotiable)

- You MUST treat `plan.md` as the single source of truth for what to implement and how to verify it.
- You MUST use `superpowers:executing-plans` before implementing.
- You MUST follow Tasks in order and run the plan’s verification steps exactly.
- You MUST determine `EXECUTION_MODE` (interactive vs autonomous) before starting Task 1:
  - Prefer `WORK_ITEM_SPEC` `**Type:**` when present.
  - Also accept `WORK_ITEM_PLAN` `**Execution mode:**` when present.
- If `EXECUTION_MODE = interactive`:
  - You MUST NOT invent “taste” values (copy, naming, art direction, tone, aesthetic rules, etc.).
  - You MUST ask the user for missing/subjective inputs and wait (one question per message, Question Format).
  - You MUST be approval-gated before Task 1 and between batches.
- If `EXECUTION_MODE = autonomous`:
  - You MUST assume “proceed by default”: do not pause and wait for approval between Tasks or checkpoints unless the user explicitly asks you to.
  - You MUST still STOP and ask the user before inventing any “taste” values; if that situation arises, treat it as a signal that the work item should be executed interactively.
- If any Task instruction is unclear, missing required file paths, or cannot be executed safely, STOP and ask the user.
- If the plan includes instructions to use other skills (e.g., documentation stewardship), you MUST invoke and follow them at the moment they become relevant.
- If a Task includes a potentially destructive/irreversible action (e.g., deleting data, applying migrations, removing files, rewriting history), you MUST explicitly call it out and ask for confirmation before executing that step, even if it is mid-batch.

## Interaction Default (Important)

This prompt has **two modes** depending on `EXECUTION_MODE`.

### Mode 1: Autonomous execution (default)

This prompt is **checkpointed** for reporting only (not approval-gated):

- Before starting implementation, present a brief **Plan Review** (risks/concerns only), then start Task 1 immediately.
- Execute Tasks in batches (default batch size: 3 Tasks) and report results + verification output after each batch, then continue to the next batch automatically.
- The only times you should STOP are: you need clarification, verification fails repeatedly, you hit a safety issue, or the user explicitly requests a pause.

### Mode 2: Interactive execution (when `EXECUTION_MODE = interactive`)

Default behavior is **ledger-then-review-then-gate**:

- In your **first** response, you MUST:
  1. Provide a **Context Read Ledger** (Required), THEN
  2. Present a brief **Plan Review** (risks/concerns only), THEN
  3. Propose a **default batch size** (Recommended: 1 Task per batch), THEN
  4. Ask for approval to start using **Question Format (MANDATORY)**.

After each completed batch:
- Report results (what changed + required verification outputs/results).
- Ask **one** Question Format question: proceed to the next batch, adjust batch size, or stop.
- Do not continue until the user responds.

If the user explicitly says “proceed by default / no need to ask between batches”, you MAY switch back to Autonomous execution.

## Question Format (MANDATORY)

Use this format ONLY for questions you ask the user to proceed during interactive execution.

You MUST NOT ask your first **Question Format** question until after you have included the **Context Read Ledger** in your first response.

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

### 1) Resolve `WORK_ITEM_DIR` and locate `plan.md`

Resolve `$ARGUMENTS` to a single `WORK_ITEM_DIR`:

- If it’s a path to `plan.md`, use its parent directory.
- If it’s a path to a work-item directory, use it directly.
- If it’s a slug like `initiative/feature/work-item`, map to:
  - `docs-ai/docs/initiatives/<initiative>/features/<feature>/work-items/<work-item>/`
- If it’s a URL/external work item link (GitHub/Linear/etc.), use repo search (branch name, issue key, slug text) to locate the matching work-item folder.

Then:
- Confirm `WORK_ITEM_SPEC = WORK_ITEM_DIR/spec.md` exists (for context).
- Confirm `WORK_ITEM_PLAN = WORK_ITEM_DIR/plan.md` exists (required to execute).

If `plan.md` does not exist, STOP and recommend using the `work-item-plan` prompt to generate it.

If multiple candidates exist, STOP and ask the user to choose the correct one (Question Format when interactive; otherwise normal prose is OK).

### 2) Load and review `plan.md`

Read `WORK_ITEM_PLAN` and check for:
- Missing/ambiguous file paths
- Missing verification commands
- Task ordering hazards (a later Task depends on earlier work that isn’t specified)
- Any instructions that appear unsafe or inconsistent with repo conventions

If you have material concerns, STOP and raise them before starting implementation.

#### Determine `EXECUTION_MODE` (Required)

Read `WORK_ITEM_SPEC` (for context) and determine `EXECUTION_MODE` before starting Task 1:

- If `WORK_ITEM_SPEC` contains `**Type:** interactive`, then `EXECUTION_MODE = interactive`.
- Else if `WORK_ITEM_PLAN` contains `**Execution mode:** interactive`, then `EXECUTION_MODE = interactive`.
- Otherwise, `EXECUTION_MODE = autonomous`.

#### Context Read Ledger (Required in interactive mode)

When `EXECUTION_MODE = interactive`, include a **Context Read Ledger** in your first response (before asking to start):
- the resolved `WORK_ITEM_DIR`
- the docs you read (at minimum: `WORK_ITEM_PLAN`, and `WORK_ITEM_SPEC` if present)
- any other docs you opened because the plan references them

### 3) Execute using `superpowers:executing-plans`

Invoke `superpowers:executing-plans` and follow it.

In particular:
- Create an `update_plan` checklist that mirrors the plan’s numbered Tasks
- Execute the first batch exactly as written (default: 3 Tasks in autonomous mode; 1 Task in interactive mode)
- Run the plan’s verification commands for each Task and ensure they pass before moving to the next Task
- Continue executing subsequent batches until the entire plan is complete:
  - Autonomous mode: continue automatically (do not wait for approval at checkpoints unless the user requests a pause)
  - Interactive mode: ask for approval between batches (Question Format)

### 4) Checkpoint reporting

After completing each batch:
- Summarize what changed (files/systems touched, high-level behavior only)
- Include the verification outputs/results required by the plan
- Ask for feedback (but keep going unless the user asks you to pause)

### 5) Finish

After all Tasks are complete and all verifications are green, follow the `superpowers:executing-plans` guidance for completion (including using `superpowers:finishing-a-development-branch` when appropriate).
