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
- You MUST assume “proceed by default”: do not pause and wait for approval between Tasks or checkpoints unless the user explicitly asks you to.
- If any Task instruction is unclear, missing required file paths, or cannot be executed safely, STOP and ask the user.
- If the plan includes instructions to use other skills (e.g., documentation stewardship), you MUST invoke and follow them at the moment they become relevant.

## Interaction Default (Important)

This prompt is **checkpointed** for reporting only (not approval-gated):

- Before starting implementation, present a brief **Plan Review** (risks/concerns only), then start Task 1 immediately.
- Execute Tasks in batches (default batch size: 3 Tasks) and report results + verification output after each batch, then continue to the next batch automatically.
- The only times you should STOP are: you need clarification, verification fails repeatedly, you hit a safety issue, or the user explicitly requests a pause.

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

### 2) Load and review `plan.md`

Read `WORK_ITEM_PLAN` and check for:
- Missing/ambiguous file paths
- Missing verification commands
- Task ordering hazards (a later Task depends on earlier work that isn’t specified)
- Any instructions that appear unsafe or inconsistent with repo conventions

If you have material concerns, STOP and raise them before starting implementation.

### 3) Execute using `superpowers:executing-plans`

Invoke `superpowers:executing-plans` and follow it.

In particular:
- Create an `update_plan` checklist that mirrors the plan’s numbered Tasks
- Execute the first batch (default: first 3 Tasks) exactly as written
- Run the plan’s verification commands for each Task and ensure they pass before moving to the next Task
- Continue executing subsequent batches automatically until the entire plan is complete (do not wait for approval at checkpoints unless the user requests a pause)

### 4) Checkpoint reporting

After completing each batch:
- Summarize what changed (files/systems touched, high-level behavior only)
- Include the verification outputs/results required by the plan
- Ask for feedback (but keep going unless the user asks you to pause)

### 5) Finish

After all Tasks are complete and all verifications are green, follow the `superpowers:executing-plans` guidance for completion (including using `superpowers:finishing-a-development-branch` when appropriate).
