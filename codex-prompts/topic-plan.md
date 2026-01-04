---
description: Brainstorm any topic, resolve uncertainties, then produce a concrete, executable plan (in chat by default).
---

## User Input

```text
$ARGUMENTS
```

Treat `$ARGUMENTS` as the topic/request to plan.

If `$ARGUMENTS` looks like a readable file path in this repo, read it and treat it as a **provisional input** (a hypothesis / idea / guideline), not as source of truth.

You MUST validate or refute it with repo evidence (code/docs reality) before you lock down material decisions. Otherwise treat `$ARGUMENTS` as plain text.

## Goal

Create a high-confidence, immediately executable plan for the topic by:

1. Brainstorming to surface unknowns and design choices
2. Settling all material decisions and uncertainties (ask the user when needed)
3. Producing a concrete, step-by-step plan with verification steps

Do **not** implement code in this run.

This task is **interactive**: if you need clarification, you MUST ask and wait. It is acceptable that the final plan is produced in a later turn after questions are resolved.

## Decision Granularity (Non-Negotiable)

This prompt is for planning **disjoint tasks** (not part of the initiative/feature/work-item workflow), e.g. repo improvement items under `docs/improvements/`.

- You MUST lock down enough detail to produce an executable plan (what to change, where, and how to verify).
- You MUST NOT prematurely lock down decisions that depend on unknown repo context. Treat missing context as an open question or as a discovery step in the plan.

## Interaction Default (Important)

Default behavior is **question-first**:

- In your **first** response, ask **ONE** question using **Question Format (MANDATORY)**.
- Only skip the initial question if the user explicitly says “skip questions” / “go straight to a plan” / “assume defaults”.

If you have not asked the user at least one question in this thread, you must not present a final plan.

## Planning Bar (Non-Negotiable)

The plan must be specific enough that an implementer can execute it without guessing:

- **No-guesswork steps**: include the exact file path(s) to touch (when applicable), what to change, and how to verify it worked.
- **Atomic ordering**: small sequential steps; no “then do whatever makes sense”.
- **Concrete actions**: avoid “update accordingly”, “wire it up”, “ensure”, “etc.”.
- **Acceptance criteria**: include a short “Done / Verification” checklist with exact commands and expected outcomes (tests, lint, manual checks).
- **No hidden assumptions**: if a step depends on unknown information, that’s an open question (see Hard Gate).

## What counts as “material uncertainty”

A decision is **MATERIAL** if it affects any of:
- External interface shape (CLI flags, endpoints, schemas, file formats)
- Data semantics (filtering/ordering/tie-breaks, invariants, consistency)
- Security/privacy/safety posture
- Deployment/rollout expectations
- Scope (what is explicitly in/out)

If any material uncertainty exists, you MUST ask the user (one question at a time) before finalizing the plan.

## What counts as “blocking” for the plan

An open question is **BLOCKING** only if it prevents writing a safe, executable plan, for example:
- we can’t define scope boundaries (in/out)
- we can’t choose an interface/semantic that determines downstream work
- we can’t choose a verification strategy (tests vs lint vs manual checks) and that choice impacts what we build

Non-blocking uncertainties MUST be captured explicitly in the final plan under “Open Questions / Assumptions”, but they do not prevent producing a plan.

## Decision Confirmation Rule (Non-Negotiable)

A material decision is **NOT resolved** unless it is either:

1) Confirmed by repo evidence (code/docs reality), OR
2) Confirmed by the user in this thread (A/B/C or “yes”).

Notes:
- A context file (e.g., an improvements item) is a useful starting point, but it is NOT automatically evidence.
- If the context file asserts something factual (“X is broken”, “Y is slow”), you MUST attempt to verify it (or identify what would verify it) before treating it as resolved.

If a material decision would rely on a default, assumption, “common sense”, or guess, it counts as an **open question** and you MUST trigger Hard Gate (B).

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

## Hard Gate (Non-Negotiable)

Before presenting the final plan, you MUST either:

- (A) State: **“No blocking questions remain”** and include a small **Decision Confirmation Table**:
  - Decision
  - Chosen option
  - Source: “user-confirmed in chat” / “provided context file” / “repo evidence”

OR

- (B) STOP and ask **ONE blocking** question (using **Question Format (MANDATORY)**). Do not present the final plan until the user answers.

## Execution Steps

### 1) Establish baseline context

Briefly summarize:
- What you believe the user wants (1–3 sentences)
- Success criteria / “done means…”
- Constraints (from user input + context file, if any)

If any of these are unclear and material, trigger Hard Gate (B).

### 2) Gather minimal repo signals (only what you need)

If a repository exists (typical case), inspect just enough to choose realistic verification and integration points:
- Identify project type / build system (e.g., `justfile`, `Makefile`, `package.json`, `pyproject.toml`, `Cargo.toml`, etc.)
- Identify where changes would likely live (top-level folders, existing modules)

Be evidence-based: cite file paths and commands you ran, and distinguish clearly between:
- **Hypotheses** (from the input file / user note)
- **Observed evidence** (what you verified in the repo)

### 3) Produce the plan (when Hard Gate A is satisfied)

Output the plan in chat as a numbered sequence of **Tasks**. Each Task must include:
- Outcome/Deliverable
- Concrete edits (file paths + what changes)
- Verification (commands + expected result)

Verification commands should match the repo’s conventions:
- Prefer an existing “umbrella” command if present (e.g., `just`, `make`, `npm/pnpm/yarn` scripts).
- If no standard exists, propose the simplest credible checks (unit tests + lint + a minimal manual smoke test).

End with:
- a short “Done / Verification” checklist
- an “Open Questions / Assumptions” section (only non-blocking items)

### 4) Optional: write it to a file (ONLY if asked)

Do not write any files unless the user explicitly asks you to (e.g., “write the plan to `plan.md`”).
