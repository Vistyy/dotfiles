---
description: Perform a functional code review of the diff between the current branch and the base branch, acting as a gatekeeper for correctness, stability, and spec/task alignment. Defer non-functional simplicity/readability/DRY feedback to the code-simplicity prompt.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

If the user input provides a base branch, initiative/feature/work-item reference, or specific reviewer directives, treat it as authoritative.

## Goal

Critically review the diff between the current branch and the base branch to identify functional issues, behavioral regressions, design/architectural misalignments that affect correctness, and spec/task gaps before merging. Provide actionable feedback that protects correctness and stability. Non-functional simplicity/readability/DRY improvements should be handled via the code-simplicity prompt.

## Operating Constraints

**Reviewer Mindset**: Adopt the perspective of a seasoned code-review gatekeeper—thorough, skeptical, and protective of correctness and stability while staying constructive.

**Review Scope**: Review the changes in the diff while considering how they interact with and impact the surrounding codebase. Reference specific file paths and 1-based line numbers.

**Scope Boundary**: Keep findings focused on correctness, stability, spec/task alignment, and risk. Route non-functional simplicity/readability/DRY suggestions to the code-simplicity prompt. **Approach-level alternatives are in-scope** only when the current approach plausibly increases risk, locks in a hard-to-reverse constraint (API shape / execution model / boundary), or materially misaligns with the intended outcome; otherwise keep them brief and non-blocking.

**Review Only**: Do not make code edits in this run. Produce a review report only.

**Evidence Required**: Do not speculate. For each finding, cite a concrete `file/path.ext:line` location (1-based) and describe the specific observed behavior/risk in the diff or directly impacted code.

**Severity-Ordered Reporting**: Present findings ordered by severity (CRITICAL → HIGH → MEDIUM → LOW), with clear explanations of risk/impact and concrete follow-up actions.

**Numbered Findings**: Return issues as a numbered list (`1.`, `2.`, ...) so each item can be referenced unambiguously in follow-up discussion and tasks.

## Execution Steps

### 0. Load Review Context

Before beginning the review, gather necessary context:

1. Determine the current branch and base branch and obtain the diff between them.
   - If you cannot determine the base branch reliably, STOP and ask the user to specify it (do not guess).
   - Capture the diff range (merge-base…HEAD) and list changed files.
2. **Identify the related initiative/feature/work-item**:
   - If the user input specifies an initiative, feature, or work-item path, use that
   - Otherwise, infer from branch name (e.g., `feat/persistence-layer/comparison-groups`) or commit messages
   - If present, check `docs-ai/docs/roadmap.md` for current focus if unclear
3. **Load the relevant spec and tasks**:
   - Preferred (if present): `docs-ai/docs/initiatives/{initiative}/overview.md`
   - Preferred (if present): `docs-ai/docs/initiatives/{initiative}/features/{feature}/overview.md`
   - Preferred (if present): `docs-ai/docs/initiatives/{initiative}/features/{feature}/work-items/{work-item}/spec.md`
   - Preferred (if present): `docs-ai/docs/initiatives/{initiative}/features/{feature}/work-items/{work-item}/tasks.md`
   - Fallback (if initiatives structure not used): `specs/*/spec.md`, `plan.md`, `tasks.md`
4. Load any project-specific AI documentation (for example, `docs-ai/docs/`) if present.
5. Assume pre-commit validation (linters, type checkers, automated tools) has already run successfully; do not re-run these tools.

### 0.1 Establish Review Coverage (MANDATORY)

Before writing findings, explicitly identify:

1. **Entry points / public surfaces changed**: exported functions, public APIs, handlers, CLI entrypoints, migrations, config, etc.
2. **Directly impacted call paths**: at minimum, identify at least one caller and one callee for each changed public surface (use repo search/navigation).
3. **Line-number accuracy**: when citing a finding, confirm 1-based line numbers from the file contents (not just diff hunk offsets).

### 0.2 Intent & Approach Snapshot (MANDATORY)

Before writing findings, extract what the PR is *trying* to accomplish, then sanity-check whether the chosen route is the right one.

1. **Intent (1–2 sentences)**: State the PR’s goal and the approach taken (“This PR aims to X by doing Y”).
2. **Irreversible decisions (max 3 bullets)**: Call out decisions that will be expensive to unwind later and cite where they are introduced:
   - New/changed public API shape
   - New dependency / vendor integration surface
   - New boundary/layering choice (domain vs infra vs transport)
   - Execution model assumptions (sync-only vs non-blocking / event-loop style runtime)
3. **Approach-level check (loose trigger)**: If anything in the diff looks like it will calcify into a recurring pattern or create future cost, include an **Approach Alternatives** subsection in the findings:
   - Keep this bounded: **at most 2 alternatives**.
   - Each alternative must be justified by a concrete driver visible in the diff/impact radius (e.g., pattern pressure/duplication, execution-model mismatch, boundary leak, operational risk).
   - Treat as **Must-fix before merge** only when the current approach plausibly increases correctness/stability risk or bakes in a hard-to-reverse constraint; otherwise mark as **Follow-up / Nice-to-have**.
   - Report each alternative as a normal numbered finding (with severity, location(s), impact, and recommendation), not as a free-form essay.

### 1. Review Functional Correctness

Examine the diff for:
- **Hidden bugs**: Logic errors, off-by-one errors, null/undefined handling
- **Risky assumptions**: Unvalidated inputs, missing error cases, race conditions
- **Edge cases**: Boundary conditions, empty states, concurrent access patterns
- **Behavioral changes**: Unintended side effects or breaking changes
- **Spec/task alignment**: Compare implemented behavior against the current `tasks.md` (if available / specified by the user input); flag missing tasks, over-implementation, and behavior that does not clearly correspond to a useful task or product outcome.

### 2. Assess Design Quality

Evaluate design choices through a correctness lens:
- **Cohesive abstractions**: Clear boundaries that avoid mixing concerns in ways that risk bugs
- **Appropriate patterns**: Patterns used correctly (no misuse that could cause incorrect behavior)

### 3. Boundary Typing Sanity

Spot-check new/changed public surfaces (APIs, handlers, exported functions) for correctness, not style:
- **Explicit contracts**: Signatures and returned shapes are typed and match actual behavior (no widening just to appease the linter).
- **Nullability/Union truth**: Optionals/unions reflect real runtime cases; no papering over missing handling with `Any`/`unknown`.
- **No ad-hoc structs**: Avoid untyped dicts/records sneaking in at boundaries when a typed shape exists.

### 4. Validate Architectural Alignment

Confirm changes respect system boundaries and layering:
- **Responsibility boundaries**: Logic placed in the correct layer/module
- **Cross-package impacts**: Dependencies properly managed, no circular references
- **Separation of concerns**: Business logic, data access, presentation properly isolated
- **Coupling analysis**: Changes don't introduce tight coupling or hidden dependencies
- **Execution model alignment**: If the runtime model expects non-blocking behavior, flag blocking I/O or sync-only interfaces introduced on hot paths (even if they “work” today) as a potential correctness/stability risk due to backpressure, latency, or deadlock/starvation failure modes.

### 5. Evaluate Tests and Behavioral Coverage

Assess test quality and completeness for the changes:
- **Behavioral coverage**: Key contracts implied by the spec/tasks are covered by tests.
- **Missing edge cases**: Untested boundary conditions, error paths, and state transitions.
- **Inadequate assertions**: Weak or missing validations in test cases.
- **Test-implementation discrepancies**: Tests not matching intended behavior or not updated to reflect changes.

### 6. Verify Status Updates

If the changes complete a work item, feature, or significant milestone:

1. **Check roadmap.md**: Verify `docs-ai/docs/roadmap.md` was updated to reflect progress
   - Work item completion → feature progress count updated
   - Feature completion → feature status set to `complete`
   - If status update is missing, flag as a finding

2. **Check tasks.md**: If a tasks.md exists for this work item, verify completed tasks are marked `[x]`

**Finding template if status not updated:**
- **[MEDIUM] Roadmap status not updated**
- **Location**: `docs-ai/docs/roadmap.md`
- **Issue**: Changes complete work on {work-item/feature} but roadmap.md was not updated
- **Impact**: Progress tracking becomes inaccurate; other agents won't know current state
- **Recommendation**: Update roadmap.md to reflect completion status
- **Disposition**: `Must-fix before merge`

### 7. Produce Structured Review Report

Generate a findings report with the following structure:

#### Context & Coverage (MANDATORY)

- Base branch, current branch, and diff range reviewed
- List of files changed (group: runtime / tests / docs / config)
- Specs/tasks/docs consulted (or explicitly “none found”)
- Public surfaces / entry points reviewed

#### Findings Summary

| Severity | Count |
|----------|-------|
| CRITICAL | N     |
| HIGH     | N     |
| MEDIUM   | N     |
| LOW      | N     |

#### Detailed Findings

List findings as a numbered list ordered by severity, with each item using this format:

1. **[SEVERITY] Finding Title**
   - **Location**: `file/path.ext:line` or `file/path.ext:line-range`
   - **Issue**: Description of the problem and why it matters
   - **Impact**: Risk or consequence if not addressed
   - **Recommendation**: Concrete action to resolve (prefer reuse of existing patterns where possible)
   - **Disposition**: `Must-fix before merge` or `Follow-up / Nice-to-have`

#### Overall Assessment and Verdict

Provide a brief summary covering:
- Overall code quality trend (improving/maintaining/degrading)
- Top 3 risks or themes across the findings
- Remaining risks after review
- Manual verification steps required after fixes are applied (integration testing, system testing, etc.)
- **Overall Verdict**: `BLOCK`, `NON-BLOCKING`, or `APPROVE`, with a short justification (e.g., "BLOCK due to 2 CRITICAL issues affecting data integrity")

#### Open Questions (If Any)

List any questions that block correctness/spec alignment. If there are none, state “None.”

### 8. Honor Custom Directives

If the user input contains specific reviewer directives (e.g., "focus on security", "check performance", "verify accessibility"), prioritize those areas and call them out explicitly in the findings, top risks, and verdict.

## Operating Principles

### Review Quality

- **Be thorough**: Treat every review as a full, in-depth review of the diff and directly impacted code, not a quick skim.
- **Stay focused**: Review what changed and its immediate context, avoiding unrelated code unless necessary to understand risk.
- **Keep scope tight**: Reserve non-functional simplicity/DRY/readability recommendations for the code-simplicity prompt.
- **Cite specific instances**: Reference exact locations (file paths and 1-based line numbers), not vague patterns.
- **Explain the "why"**: Don't just point out issues—explain their impact on correctness, users, operations, or risk.
- **Suggest concrete actions**: Provide actionable remediation steps, with enough context that another engineer or automated agent could implement them.
- **Prefer existing patterns**: When proposing changes, prefer patterns and abstractions already present in the codebase; if deviating, briefly justify the benefit.
- **Clarify ambiguity**: When requirements or behavior are unclear, explicitly list clarifying questions instead of guessing intent.
- **Report zero issues gracefully**: If no problems found, state that clearly with confidence while noting any areas you paid particular attention to.

### Severity Guidelines

Use these heuristics to assign severity:

- **CRITICAL**: Security vulnerabilities, data loss risks, breaking changes, production-blocking bugs
- **HIGH**: Functional bugs, major design flaws, architectural violations, missing critical tests
- **MEDIUM**: Potential correctness risks, incomplete edge-case handling, missing or weak test coverage for changed behavior
- **LOW**: Minor correctness risks or clarifications; non-functional simplifications belong in the code-simplicity prompt

### Constructive Communication

- **Be respectful**: Critique code, not the author
- **Be specific**: Provide examples and alternatives, not just complaints
- **Be pragmatic**: Consider effort vs. impact when suggesting changes
- **Challenge necessity**: When changes appear speculative, low-value, or overly complex relative to their benefit, ask for justification and flag only if they create correctness risk or deviate from the spec/tasks; otherwise send simplification notes to the code-simplicity prompt.


### Anti-goals

Avoid the following behaviors:

- Do not demand style-only changes that conflict with the project formatter, linter, or documented conventions.
- Do not propose speculative abstractions or premature generalization for problems that do not yet exist.
- Do not require large rewrites that are orthogonal to the diff unless there is a clear, high-severity risk.
- Do not suggest changes outside the diff unless they are directly impacted by the change or necessary to prevent a significant bug or regression.
- Do not write “architecture essays”: keep approach alternatives to at most 2, tightly justified by evidence in the diff and immediate impact radius.
