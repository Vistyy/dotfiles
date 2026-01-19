---
description: Brainstorm a work item, resolve implementation uncertainties, then write an actionable implementation plan (plan.md) next to the work-item spec.md.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** treat `$ARGUMENTS` as the *work item link* (or work-item path) that identifies what to plan.

Example argument:
```text
persistence-layer/price-storage/schema-implementation
```

## Goal

Create a high-confidence, immediately executable implementation plan for the referenced work item by:

1. Brainstorming to surface unknowns and design choices
2. Settling (resolving) all material implementation details and uncertainties
   - Treat explicit, unambiguous decisions (in `spec.md`, existing `plan.md`, ADRs, etc.) as **confirmed**. Do not re-confirm them in chat.
   - Only raise a decision for user confirmation if:
     - Sources conflict (e.g., `spec.md` vs ADR/design doc), or
     - The decision text is unclear/underspecified and you would otherwise need to make an assumption to proceed.
   - When you raise a decision:
     - State the conflict/ambiguity and likely impact.
     - Propose a **Recommended** option (plus 1–2 other options when useful).
     - Ask the user to confirm using **Question Format (MANDATORY)**.
3. Using the `superpowers:writing-plans` skill to produce the final plan
4. Writing the plan to `plan.md` **in the same directory as** the work item’s `spec.md` **only after** all material uncertainties are resolved
5. Ensuring the plan is “code-monkey executable”: a junior engineer can follow it end-to-end without second-guessing, extra research, or “checking around”

Do **not** implement code in this run.

This task is **interactive**: if you need clarification, you MUST ask and wait. It is acceptable that writing `plan.md` happens in a later turn after questions are resolved.

## Interaction Default (Important)

Default behavior is **ledger-then-gate**:

- In your **first** response, you MUST:
  1. Provide the **Context Read Ledger** (docs read + delivery-map wave/related slugs + related work-item specs opened), THEN
  2. Do **exactly one** of:
     - Ask **ONE** question using **Question Format (MANDATORY)**, OR
     - If there is no material uncertainty, state **“No open questions remain”** and provide the required **Decision Confirmation Table**.

If the user explicitly says “skip questions” / “assume defaults”, you MAY proceed without asking a question, but you MUST still obey Hard Gate (A/B).

## Related Prompts (Optional)

If you discover that the problem is upstream (bad slicing / missing spec), prefer using:
- `planning-intake` — when you’re starting from a fuzzy goal (“I want something done”) and need to update `roadmap.md` / `delivery-map.md` and create the right initiative/feature/work-item scaffolding first
- `feature-plan` — when the feature needs re-slicing into work items
- `work-item-spec` — when `spec.md` is missing/weak and must be repaired before planning

This prompt (`work-item-plan`) is for producing a **code-monkey executable** `plan.md` once the work item is properly specified.

## Spec vs Plan Responsibilities (Non-Negotiable)

This prompt operates at the **work item implementation plan** level.

- `spec.md` may contain **non-blocking** Open Questions (explicitly listed) when they do not affect implementation feasibility.
- `plan.md` MUST NOT contain open questions that would require the implementer to “figure it out”. If an open question affects any material implementation step, you MUST resolve it before writing `plan.md`.

If you encounter an unresolved decision that impacts the plan:
- Ask **exactly one** Question Format question (Hard Gate B) and STOP.
- Do not write or “half-write” `plan.md` with TODOs for the implementer.

## Spec Backfill Rule (Non-Negotiable)

This prompt treats `spec.md` as the durable source of truth for **Decisions**.

If you make a decision during this planning session that differs from what’s currently written in `spec.md` (or any referenced ADR/design doc), you MUST:

1. **Make the change explicit** (in chat): state what the spec/ADR says vs the proposed new decision.
2. **Get confirmation** (Decision Confirmation Rule / Hard Gate).
3. **Backfill the work item spec**: update `WORK_ITEM_SPEC` so its **Decisions** reflect the new, confirmed decision (and remove or rewrite any now-contradictory text).

The goal is that the work item folder is self-contained and future planning/execution does not rediscover the same “fixed” ambiguity.

When backfilling, prefer updating the existing **Decisions** section (and any contradictory prose) rather than adding new “history/changelog” sections unless the work-item docs already use one.

## Documentation Stewardship (Non-Negotiable)

After Hard Gate (A) is satisfied and before making any edits under `docs-ai/docs/`, you MUST use the `documentation-stewardship` skill and follow its “STOP - Before You Edit” checklist.

If `documentation-stewardship` conflicts with this prompt, you MUST treat that as a blocking issue and ask the user for clarification before editing.

When you write `plan.md`, you MUST explicitly restate this rule in the plan (e.g., in an “Execution Rules” section and/or in any Task that touches `docs-ai/docs/`).

## Plan Clarity Bar (Non-Negotiable)

The plan you write to `plan.md` MUST be clear and specific enough that an implementer can execute it without having to infer missing steps, hunt for “where” something lives, or guess what “good” looks like.

Required qualities:

- **No-guesswork steps**: every step includes the exact file path(s) to touch, what to change, and how to verify it worked.
- **Atomic ordering**: steps are small, sequential, and unambiguous (an implementer should not have to decide “what to do next”).
- **Concrete actions**: avoid vague instructions like “update accordingly”, “wire it up”, “ensure”, “refactor as needed”, “etc.”. Replace with explicit edits and commands.
- **Local pointers**: when referencing existing code, point to the concrete symbol/file/route/config key to use (not just “the existing X”).
- **Acceptance criteria**: include a short “Done / Verification” checklist with exact commands to run and expected outcomes (tests, lint, manual checks).
- **No hidden assumptions**: if a step depends on missing/unknown information, treat that as a material uncertainty and trigger Hard Gate (B) rather than writing a hand-wavy plan.

## Task Quality + Commit Rules (Non-Negotiable)

Your `plan.md` MUST be written as a sequence of numbered **Tasks** that can be executed end-to-end without pausing between them.

**Requirements:**

- Each Task MUST end with a **Task Verification** block that includes exact commands to run and the expected outcome (`PASS` / “green” / expected `FAIL`).
  - Choose the *lightest* verification that matches the Task’s intent (don’t cargo-cult full-suite checks on every step).
  - If the Task is a **GREEN checkpoint** (repo should be healthy / ready to proceed), the verification MUST include `just quality` and it MUST be green before starting the next Task.
  - If the Task is intentionally **RED** (an intermediate step that may leave tests failing), the verification MUST make that explicit (expected `FAIL`) and MUST NOT require `just quality` until a later Task returns the repo to green.
  - For non-code Tasks (docs-only, refactoring notes, etc.), do not require `just quality` by default; prefer doc-appropriate verification when available (docs build, markdown lint, link check, etc.).
- **Execution rules (must be stated in plan.md):**
  - After each Task, run the Task Verification commands and ensure the result matches the stated expectation.
  - Run `just quality` at each GREEN checkpoint and always at the very end before committing.
- **Commit rule (must be stated in plan.md):** do **not** commit after each Task. Make **one** commit at the very end, after all Tasks are complete and `just quality` is green.
  - Final completion (example): `git status` → `just quality` → `git add -A && git commit -m "<work item>: <short summary>"`

## Output Constraint (Non-Negotiable)

Do NOT print the full plan content in the chat.

- In chat: provide only a brief outline (max 10 bullets), plus the required **Decision Confirmation Table** when asserting **“No open questions remain”**, plus the single pending question (if any).
- The full plan (with detailed steps/snippets) must only be written to `plan.md` after the Hard Gate is satisfied.
- Do not “preview” `plan.md` content in the response. Either (A) confirm no open questions and then write `plan.md`, or (B) ask the single Question Format question and stop.

## Chat Length Limit

In chat responses:

- No more than 200 lines total.
- No code blocks longer than 20 lines.
- Prefer references to file paths over inlining content.

## What counts as “material uncertainty” (triggers)

A decision is **MATERIAL** if it affects any of:
- Public API shape (method signatures, endpoints, response payloads)
- Query semantics (grouping, filtering, ordering, tie-breaks)
- Transaction boundaries / consistency guarantees
- Schema invariants (constraints, nullability, cascades)
- Data returned to downstream systems/features (pipelines, integrations, analytics)

Noting a choice in chat is NOT a substitute for user confirmation when the decision is underspecified or scope-affecting.

## Decision Confirmation Rule (Non-Negotiable)

A material decision is **NOT resolved** unless it is either:

1) Explicitly stated in `spec.md` (or a referenced ADR/design doc) with no ambiguity, OR
2) Confirmed by the user in this thread (A/B/C or “yes”).

If a material decision is merely “implied”, “common sense”, or “a reasonable default”, it counts as an **open question** and you MUST choose Hard Gate (B).

## Hard Gate (Non-Negotiable)

Before writing/updating `plan.md`, you MUST either:
- (A) State **“No open questions remain”** AND provide a **Decision Confirmation Table** (respecting **Chat Length Limit**) where every material decision includes:
  - Decision
  - Chosen option
  - Source: (`spec.md` line / ADR / design doc) OR “user-confirmed in chat”
- (B) STOP and ask **ONE** question (using **Question Format (MANDATORY)**). Do NOT write/modify `plan.md` until the user answers.

If any **material uncertainty** exists, you MUST choose (B).

### Hard Gate Extension (Non-Negotiable)

If you encounter conflicting sources for a material decision (e.g., `spec.md` vs ADR/design doc), you MUST ask a Question Format question **immediately** (Hard Gate B). You may not defer the question until after presenting a plan draft or after stating “No open questions remain”.

If ANY material decision’s source is not one of: (`spec.md` line / ADR / design doc) OR “user-confirmed in chat” (i.e., it’s your inference/default), you MUST choose (B).

While you are waiting for the user to answer your pending Question Format question, the user may ask clarifying questions. You MUST answer those clarifications directly (normal prose), then re-state your pending **single** Question Format question and continue waiting for the user’s A/B/C (or “yes”).

## Question Format (MANDATORY)

This format is **ONLY** for questions **you** ask the user in order to proceed (i.e., when you need the user to make a choice or confirm a decision).

You MUST NOT ask your first **Question Format** question until after you have completed the **Context Read Ledger** (see Execution Step 2).

If the **user asks you a clarifying question**, you MUST answer it directly in normal prose (do **not** wrap your answer in Question Format). After answering, if you still need a user decision, re-ask your pending **single** decision question using Question Format.

Whenever you need to ask the user a question, you MUST:

1. Present **2–5 options** in a table
2. State the **Question** being asked (1 sentence)
3. Lead with a **Recommended** option and **1–2 sentences of reasoning**
4. Ask for a reply using only the option letter (or “yes” to accept the recommendation)

Use this exact structure:

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

### 1. Resolve the Work Item Directory and spec.md

Resolve `$ARGUMENTS` to a single `WORK_ITEM_DIR`:

- **Preferred**: `initiative/feature/work-item` (e.g., `persistence-layer/price-storage/schema-implementation`)
  - Map to: `docs-ai/docs/initiatives/<initiative>/features/<feature>/work-items/<work-item>/`
- **Also acceptable**: a direct path to a `spec.md` file
- **Also acceptable**: a URL or external work item link (GitHub/Linear/etc.)
  - Use repo search (branch name, issue key, slug text) to locate the matching work-item folder

Then:

1. Locate `WORK_ITEM_SPEC = WORK_ITEM_DIR/spec.md` and confirm it exists.
2. If multiple candidates exist, STOP and ask the user to choose the correct one.
3. Define `WORK_ITEM_PLAN = WORK_ITEM_DIR/plan.md` (this is the file you will create/update).
4. If `WORK_ITEM_DIR` lives under `docs-ai/docs/initiatives/<initiative>/features/<feature>/work-items/<work-item>/`, also define:
   - `FEATURE_DIR = docs-ai/docs/initiatives/<initiative>/features/<feature>/`
   - `INITIATIVE_DIR = docs-ai/docs/initiatives/<initiative>/`

#### Spec Readiness Check (Required)

If `WORK_ITEM_SPEC` is missing any of the following, treat it as a blocking upstream issue:
- clear **Scope** (in/out)
- concrete, checkable **Acceptance Criteria**
- explicit **Decisions** vs **Open Questions**

In that case, STOP and ask **one** Question Format question:
- either to run `work-item-spec` first, or
- to explicitly confirm the missing decision(s) in chat before proceeding.

### 2. Load Planning Context (Progressive Disclosure)

You MUST read `WORK_ITEM_SPEC` first.

Then you MUST locate and read the *parent* docs that define the work item’s boundaries and integration context:

- **Parent Feature docs** (required when they exist):
  - `FEATURE_DIR/overview.md`
  - `FEATURE_DIR/design.md`
- **Parent Initiative docs** (required when they exist):
  - `INITIATIVE_DIR/overview.md`
  - `INITIATIVE_DIR/integration/overview.md` (or, if missing, scan `INITIATIVE_DIR/integration/` for the relevant integration docs)
- **Delivery map** (required when it exists):
  - Prefer `docs-ai/docs/initiatives/delivery-map.md`, otherwise try `docs-ai/initiatives/delivery-map.md`
  - You MUST identify the wave/section that this work item belongs to, and list the other work-item slugs in that same wave/section as “Related (same wave)”.
  - If the matched wave/section references a wave brief doc (e.g., a `waves/<wave>.md` file path or link), you MUST read it and treat it as the durable requirements anchor for this plan.

“Locate” means: derive the parent directories from the work-item path **or** use repo search to find them. If you cannot unambiguously identify the parent feature and initiative, STOP and ask the user to choose the correct parent(s) using **Question Format (MANDATORY)**.

Then, you MUST load *directly related* lower-level docs:

- **Related work items**: if `WORK_ITEM_SPEC` (or parent docs) link to other work items, you MUST open those work item `spec.md` files too (at minimum, read the Scope/Acceptance Criteria/Decisions sections).
- **Cross-cutting integration**: if this work item changes integration behavior that spans 2+ features, you MUST read the relevant initiative integration doc(s) first and treat them as the source of truth; the work-item plan must link to them rather than reinventing them.
- **Same wave**: if `delivery-map.md` lists other work items in the same wave/section, you MUST read those work item `spec.md` files too (at minimum, read Scope/Acceptance Criteria/Decisions) to ensure the plan is compatible and sequenced correctly.

#### Context Read Ledger (Required)

Before Step 3, you MUST provide a **Context Read Ledger** in chat that includes:

1. **Docs read**: file paths only, plus a 1-line note for each about why it matters (do NOT paste contents).
2. **Delivery map placement** (when `delivery-map.md` exists): the wave/section you matched, plus a short “Related (same wave)” list of work-item slugs.
3. **Related work-item specs opened**: list the work-item `spec.md` paths you opened (including “same wave” work items).

### 3. Settle Implementation Details and Uncertainties

Use `superpowers:brainstorming` to identify and resolve decision points that materially affect implementation.

If you must ask the user anything, ask **exactly one** question at a time using **Question Format (MANDATORY)**.

If multiple material uncertainties exist, you MUST ask about the **single highest-impact** one first (public API / query semantics / consistency / schema invariants), and list the others as “Pending (will ask next)” without resolving them.

### 4. Hard Gate: Confirm No Open Questions Remain

Before writing/updating `WORK_ITEM_PLAN`, either:
- Explicitly state **“No open questions remain”** and provide the required **Decision Confirmation Table** in chat (respecting **Chat Length Limit**), or
- STOP and ask **ONE** question (using **Question Format (MANDATORY)**). Do NOT write/modify `plan.md` until the user answers.

### 4a. Backfill `spec.md` With Confirmed Decision Changes (Required)

If any decisions were changed during this session, you MUST update `WORK_ITEM_SPEC` **before** writing/updating `WORK_ITEM_PLAN`:

1. Run `documentation-stewardship` (required for edits under `docs-ai/docs/`).
2. Update `WORK_ITEM_SPEC` so its **Decisions** reflect the confirmed outcome(s).
   - Rewrite or remove any contradictory prose in Scope/Acceptance Criteria if needed.
   - Keep edits minimal and factual; do not expand scope without explicit confirmation.
   - Do not add a new “Decision History” / changelog section unless the work-item docs already use one.
3. In chat, briefly list what you changed in `spec.md` (paths + 1-line summary per decision). Do not paste large diffs.

### 5. Write `plan.md` Next to `spec.md`

Use `superpowers:writing-plans` to generate the plan and write/update `WORK_ITEM_PLAN`.

If `plan.md` already exists, update it rather than starting over; preserve any content that is still correct and remove contradictions.

### 5a. Task Verification Self-Audit (Required Before Writing plan.md)

Before writing/updating `WORK_ITEM_PLAN`, do a task “fit” pass:

- Every Task has a clear “Outcome/Deliverable” statement.
- Every Task ends with **Task Verification** commands (exact commands, expected outcome).
- Any **GREEN checkpoint** Task includes `just quality` with an expected `PASS` outcome.
- Any intentionally **RED** Task clearly states the expected `FAIL` outcome and there is a later GREEN checkpoint that returns the repo to green.
- The plan includes a final “Done / Verification” checklist that re-runs `just quality` and ends with a single commit.
- The plan explicitly restates the Documentation Stewardship rule for edits under `docs-ai/docs/`.
- No Task requires “figure out what to do next”; each has atomic steps with file paths.

After writing/updating `WORK_ITEM_PLAN`, do NOT paste or preview its contents in chat. In chat, only confirm that `plan.md` was written and provide a brief outline (max 10 bullets).
