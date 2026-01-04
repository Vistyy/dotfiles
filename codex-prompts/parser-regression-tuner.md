---
description: Use when parser regression cases fail (or when adding/updating them). Diagnoses selection-layer failures via candidate counts, guardrail reasons, and cue scores, and iterates using `scripts/debug_parser.py` on `tests/data/parser_regression/*.case.json` fixtures.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

If the user input provides a case name, fixture path, or pytest selector, treat it as authoritative.

## Expected Inputs

Preferred:
- A `*.case.json` path under `tests/data/parser_regression/`
- A case name (maps to `tests/data/parser_regression/<case_name>.case.json`)
- A pytest selector like `-k <case_name>`

If `$ARGUMENTS` is empty and no failing case is provided, STOP and ask for a case name or `*.case.json` path.

## Goal

Triage and fix a failing parser regression case with the shortest possible loop:
pytest failure → debug trace on the same `*.case.json` → minimal code change → re-run.

## When You're Invoked

- `tests/integration/parser_regression/test_parser_regression_suite_v2.py` fails for one or more `*.case.json` files
- A regression case was added/updated and now fails strict comparisons
- Parser selects the wrong candidate (OCR spans exist but winner is wrong)
- A change “fixed” a case by accident (unintended new extraction) and the suite caught it

## What The Suite Is (Brief)

The suite runs the parser against deterministic inputs and asserts strict equality against a stored expectation.

**Fixtures directory:** `tests/data/parser_regression/`

**Each case file:** `tests/data/parser_regression/<case_name>.case.json` contains:
- `meta` (schema version + stable hashes)
- `context` (a JSON object shaped like `PriceTagContext`, including `store.retailer` and deterministic `trace_id`)
- `expected` (a JSON object shaped like `ResultEnvelope`, success-only)

**Strictness (critical):** comparisons are across the full `ResultEnvelope` universe (missing optionals in `expected` are treated as expected `null`). This intentionally fails when a previously-`null` optional field starts being populated.

## Primary Debug Loop (Fast)

1) Reproduce the failure narrowly (source of truth for what mismatched):

```bash
just test tests/integration/parser_regression/test_parser_regression_suite_v2.py -k <case_name>
```

2) Read the expected values:
- Open `tests/data/parser_regression/<case_name>.case.json` and inspect `expected`.

3) Inspect current behavior using the debug script on the **same case** (actual):

```bash
uv run python scripts/debug_parser.py tests/data/parser_regression/<case_name>.case.json
# options: --brief (no cue details), --candidates (per-field candidate lists), --full (JSON dump)
```

4) Compare expected vs actual:
- Compare the debug output’s current parsed values against the fixture’s `expected` values.
- If pytest failed on a field not shown in the default debug output, re-run debug with `--full` and follow the pytest mismatch path/value.

5) Apply the smallest viable change, then re-run:
- `uv run python scripts/debug_parser.py ...` (diagnostics)
- `just test ... -k <case_name>` (strict assertion)

6) When satisfied, run the suite + quality gate:

```bash
just test tests/integration/parser_regression/test_parser_regression_suite_v2.py
just quality
```

## Selection Layer Overview

```
Span Sources → Pipeline Evaluation (cues score spans) → Sorting → Winner Selection → Coherence
```

**Key locations:**
- Entry point: `packages/providers/budgeat_parser_standard/src/budgeat_parser_standard/domain/selection/pipeline.py`
- Pipelines: `packages/providers/budgeat_parser_standard/src/budgeat_parser_standard/domain/selection/pipelines/` (defaults/, stores/)
- Cues: `packages/providers/budgeat_parser_standard/src/budgeat_parser_standard/domain/selection/cues/`
- Tie-breaks: `packages/providers/budgeat_parser_standard/src/budgeat_parser_standard/domain/selection/scoring/tie_break.py`
- Guardrails: `packages/providers/budgeat_parser_standard/src/budgeat_parser_standard/domain/selection/guardrails.py`
- Split config: `packages/providers/budgeat_parser_standard/src/budgeat_parser_standard/config.py`

## Interpreting `debug_parser.py` Output

| Section | What to look for |
|---------|------------------|
| RESULT | Parsed field values (product_name, price, currency, unit_price, unit) |
| WINNERS | Selected values with scores and zones |
| CANDIDATES | Total count and per-field breakdown |
| ISSUES | Conflicts, coherence warnings, guardrail reasons |
| WINNER CUE DETAILS | Individual cue scores (+matched/-unmatched) |

## Common Failure Patterns (Heuristics)

These are not mutually exclusive categories. Treat them as “what to check next”, guided by what you see in the trace.

| Symptom (in trace / pytest) | What it often means | What to check next |
|---|---|---|
| Expected value not present in `all_candidates` for that field | Candidate generation/formatting didn’t produce it (or fixture doesn’t contain it) | Verify `context.input.detections` / `content_text`, then span sources and formatting for that field |
| Expected candidate exists but loses to another | Scoring/penalties/zone cues favor the wrong one | Compare top candidates + “WINNER CUE DETAILS”; check penalties and zone cues on both |
| Candidate seems plausible but gets rejected | Guardrails/coherence rules block it (sometimes indirectly) | Look at `guardrail_reasons`, `conflict_reasons`, and `coherence.warnings` |
| Two candidates are close; winner looks “geometrically wrong” | Tie-break order or geometry-derived cues dominate | Confirm scores are close; check tie-break ordering and any zone/geometry cues |
| Pytest fails because an optional field became non-null | Strictness caught a new extraction (often accidental/noisy) | Decide: constrain/remove the accidental extraction (usual) vs intentionally update `expected` |

## Change Ladder (Smallest → Biggest Global Impact)

Make the minimum change that fixes the failing case **without** breaking others. Prefer narrow blast radius and move outward only if needed.

1) **Do not edit fixtures by default**
- Treat fixtures as locked behavior. Fix code to match them.
- Editing a `*.case.json` is appropriate only when the expected output is wrong and you explicitly want new behavior, or when improving fixture hygiene.

2) **Low-impact tuning (preferred)**
- Adjust `acceptance_threshold` in the relevant pipeline definition.
- Adjust cue `score_weight` and penalty magnitudes.
- Adjust split-join tolerances (`SplitPriceConfig`).

3) **Moderate-impact selection changes**
- Change tie-break order / tie-break logic (`tie_break.py`).
- Add a new cue (primitive + builder) and wire it into the pipeline:
  - Primitive: `.../cues/primitives/` (`CueProtocol`)
  - Builder: `.../cues/builders/` (+ export in `.../cues/__init__.py`)
  - Pipeline wiring: add to the relevant pipeline definition
- Adjust the pipeline that applies to this case:
  - Pipelines are resolved by `(store, layout)` with fallbacks (store-only, layout-only, defaults).
  - Prefer changing an existing retailer+layout pipeline under `pipelines/stores/<retailer>/<layout>/` when it exists.
  - If the fix is retailer-specific and you would otherwise have to change defaults, prefer adding a retailer+layout override instead.

4) **High-impact global changes (ask human first)**
- Span source ordering / candidate generation changes.
- Layout classification threshold changes (e.g. `ASPECT_RATIO_THRESHOLD`).

## Examples Of Small, Targeted Changes

```python
acceptance_threshold=0.15  # lower threshold
gap_too_large_penalty(penalty=-0.3)  # soften penalty
max_gap_ratio=1.5  # widen split tolerance
("polygon_present", "span_length", "zone_priority", "span_order")  # tie-break reorder
```

## Fixture Hygiene (Only When Intentional)

- Fixtures must be **Polish price-tag content only**; avoid addresses, phone numbers, or unrelated freeform text.
- Preserve determinism: `context.trace_id` and `context.store.retailer` must remain valid.
- If `context` or `expected` changes, update `meta` hashes (hash mismatch is a hard failure).

## Red Flags - Ask Human First

- Changing span source order (global impact)
- Modifying `ASPECT_RATIO_THRESHOLD`
- Creating a new FieldType
- Removing required cues from defaults
- “Fixing” by weakening strictness (the suite’s strictness is intentional)
