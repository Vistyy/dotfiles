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
   - Treat any existing “ready-made” decisions (in `spec.md`, existing `plan.md`, ADRs, etc.) as *provisional inputs*, not unquestionable truth.
   - If you spot a decision you don’t fully agree with (e.g., it seems risky, inconsistent, underspecified, or you see a clearly better option), you MUST surface it explicitly:
     - State the issue and likely impact.
     - Propose a **Recommended** alternative (plus 1–2 other options when useful).
     - Record the outcome in the decision log.
     - If changing the decision would alter scope/requirements, ask the user to confirm using **Question Format (MANDATORY)** — do not quietly accept the original decision.
3. Using the `superpowers:writing-plans` skill to produce the final plan
4. Writing the plan to `plan.md` **in the same directory as** the work item’s `spec.md` **only after** all material uncertainties are resolved

Do **not** implement code in this run.

This task is **interactive**: if you need clarification, you MUST ask and wait. It is acceptable that writing `plan.md` happens in a later turn after questions are resolved.

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

Recording a choice in a **Decision Log** is NOT a substitute for user confirmation when the decision is underspecified or scope-affecting.

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

If you have a recommendation *because you disagree or are not fully convinced* by a provisional input, you MUST ask a Question Format question **immediately** (Hard Gate B). You may not defer the question until after presenting a plan draft or after stating “No open questions remain”.

If ANY material decision’s source is not one of: (`spec.md` line / ADR / design doc) OR “user-confirmed in chat” (i.e., it’s your inference/default), you MUST choose (B).

While you are waiting for the user to answer your pending Question Format question, the user may ask clarifying questions. You MUST answer those clarifications directly (normal prose), then re-state your pending **single** Question Format question and continue waiting for the user’s A/B/C (or “yes”).

## Question Format (MANDATORY)

This format is **ONLY** for questions **you** ask the user in order to proceed (i.e., when you need the user to make a choice or confirm a decision).

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

### 2. Load Planning Context (Progressive Disclosure)

Read `WORK_ITEM_SPEC` first, then only load additional context as needed to settle uncertainties.

### 3. Settle Implementation Details and Uncertainties

Use `superpowers:brainstorming` to identify and resolve decision points that materially affect implementation.

If you must ask the user anything, ask **exactly one** question at a time using **Question Format (MANDATORY)**.

If multiple material uncertainties exist, you MUST ask about the **single highest-impact** one first (public API / query semantics / consistency / schema invariants), and list the others as “Pending (will ask next)” without resolving them.

### 4. Hard Gate: Confirm No Open Questions Remain

Before writing/updating `WORK_ITEM_PLAN`, either:
- Explicitly state **“No open questions remain”** and provide the required **Decision Confirmation Table** in chat (respecting **Chat Length Limit**), or
- STOP and ask **ONE** question (using **Question Format (MANDATORY)**). Do NOT write/modify `plan.md` until the user answers.

### 5. Write `plan.md` Next to `spec.md`

Use `superpowers:writing-plans` to generate the plan and write/update `WORK_ITEM_PLAN`.

If `plan.md` already exists, update it rather than starting over; preserve any content that is still correct and remove contradictions.

After writing/updating `WORK_ITEM_PLAN`, do NOT paste or preview its contents in chat. In chat, only confirm that `plan.md` was written and provide a brief outline (max 10 bullets).
