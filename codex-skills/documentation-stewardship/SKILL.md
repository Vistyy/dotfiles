---
name: documentation-stewardship
description: Enforce single source of truth and cross-reference integrity across BudgEat design documentation. Use BEFORE editing or writing any file under docs-ai/docs/ (especially roadmap.md, initiative/feature overview.md/design.md, initiatives/**/integration/*, and decisions/ ADRs) and after doc changes to audit duplication, contradictions, and downstream impact.
---

# Documentation Stewardship

Maintain consistency across design documentation by enforcing a single source of truth, proper cross-references, and upstream/downstream awareness.

Core principle: each piece of information lives in ONE place. Everything else links to it.

## STOP - Before You Edit

This skill triggers before you modify any file under `docs-ai/docs/`.

If you're about to edit a design doc, stop and run this checklist first:

1. Identify the exact files you intend to change.
2. Read `docs-ai/docs/roadmap.md` first to understand current focus and prior decisions.
3. Read the relevant initiative/feature `overview.md` before touching `design.md`.
4. If touching schema/data flow, read the relevant initiative integration docs (when they exist), e.g.:
   - `docs-ai/docs/initiatives/<initiative>/integration/schema-overview.md`
   - `docs-ai/docs/initiatives/<initiative>/integration/data-flow.md`
5. Check upstream/downstream consumers: which other docs link to (or rely on) what you will change?

Tip: use `rg -n "<keyword>" docs-ai/docs` to find duplicates and cross-references before making changes.

## When to Use

Tier 1 (full workflow):
- Any file under `docs-ai/docs/initiatives/`
- `docs-ai/docs/roadmap.md`
- Any file under `docs-ai/docs/initiatives/**/integration/`

Tier 2 (awareness only):
- `docs-ai/docs/decisions/` ADRs (check for contradictions)
- `docs-ai/docs/architecture/` (update when an initiative ships)

Skip for:
- `docs-ai/docs/conventions/`
- `docs-ai/docs/research/`
- `docs-ai/docs/business-context/`

## Source of Truth Hierarchy

| Information Type | Source of Truth | Others Link To It |
|------------------|-----------------|-------------------|
| Feature/initiative status | `docs-ai/docs/roadmap.md` | overview.md files |
| Initiative-owned schema (tables, columns) | `docs-ai/docs/initiatives/<initiative>/integration/schema-overview.md` (when present) | feature design/spec docs |
| Cross-feature data flow (within an initiative) | `docs-ai/docs/initiatives/<initiative>/integration/data-flow.md` (when present) | feature design/spec docs |
| Project-wide decisions | `docs-ai/docs/roadmap.md` Decisions table | feature docs |
| Feature-specific decisions | feature `design.md` | - |
| Cross-feature integration notes (within an initiative) | `docs-ai/docs/initiatives/<initiative>/integration/` (prefer an `overview.md` index if it grows) | feature overview/design docs |
| SQL query patterns | `schema-overview.md` OR `data-flow.md` | Never duplicate |

File purposes:

| File | Contains | Does NOT Contain |
|------|----------|------------------|
| `overview.md` | Goal (1-2 sentences), work items table, links | Design details, schema, rationale |
| `design.md` | Full spec, rationale, decisions | Status (lives in overview), duplicated schema |
| `taxonomy.md` | List of items only | Design notes, implementation details |
| `spec.md` | Work item scope, acceptance criteria | Implementation details |
| `plan.md` | Executable implementation steps + verification commands | Rationale/design narrative, duplicated schema |

## Work Item Status Updates

When a work item status changes (e.g., planned → done), update all of these locations:

Required updates:

| Location | What to Update |
|----------|----------------|
| `docs-ai/docs/roadmap.md` | Phase 0 table, Implementation Tracker, or Decisions Made table |
| `docs-ai/docs/initiatives/.../features/{feature}/overview.md` | Work Items table status column |
| `docs-ai/docs/initiatives/.../features/{feature}/work-items/{item}/spec.md` | Status field + acceptance criteria checkboxes |

Conditional (initiative-specific) updates:

| Condition | Also Update |
|-----------|-------------|
| Initiative has a delivery map | `docs-ai/docs/initiatives/delivery-map.md` (mark the line **DONE** and keep ✅/⛔ unchanged; add ADR link when applicable) |

Conditional updates:

| Condition | Also Update |
|-----------|-------------|
| Work item produced an ADR | `docs-ai/docs/decisions/` (create ADR file) |
| Work item produced an ADR | `docs-ai/docs/roadmap.md` Decisions Made table (add row with link) |
| Work item affects design | Feature `design.md` if design details changed |
| Work item affects schema | The relevant initiative `integration/schema-overview.md` (when present) |
| Work item affects data flow | The relevant initiative `integration/data-flow.md` (when present) |

Checklist for completing a work item:

```
□ spec.md: Status → done, acceptance criteria checked
□ overview.md: Work item row status → done
□ roadmap.md: Relevant table updated (Phase 0 / Implementation Tracker)
□ If applicable: delivery-map.md line marked **DONE** (with ADR link if applicable)
□ If ADR created: Added to roadmap.md Decisions Made table
```

Example: Tech decision work item

1. Create ADR in `docs-ai/docs/decisions/NNN-{name}.md`.
2. Update work item `spec.md`: status → done, criteria checked.
3. Update feature `overview.md`: work item → done.
4. Update `docs-ai/docs/roadmap.md`: Phase 0 table → Done with ADR link.
5. Update `docs-ai/docs/roadmap.md`: add row to Decisions Made table.
6. Update `delivery-map.md`: mark DONE with ADR link.

## Workflow Checklist

Before making changes:

1. Read `docs-ai/docs/roadmap.md` first.
2. Read the relevant feature `overview.md` (work items, current status).
3. Read the relevant feature `design.md` (existing design decisions).
4. If touching schema/data flow, read the relevant initiative `integration/` docs (when they exist).
5. Check upstream/downstream consumers: what features/initiatives depend on your output?

While making changes:

7. Write to the source of truth only:
   - Schema changes → the relevant initiative `integration/schema-overview.md` only
   - Data flow logic → the relevant initiative `integration/data-flow.md` only
   - Feature design → that feature's `design.md` only

8. Link, don't copy:

```markdown
<!-- GOOD -->
See [schema-overview.md](../../integration/schema-overview.md#table-name) for schema.

<!-- BAD -->
The schema looks like this: [copies 20 lines of SQL]
```

9. Keep reference files pure:
   - `taxonomy.md` = list of items + link to design.md for "how it works"
   - Do not add "Design notes" sections to reference files
   - For cross-cutting integration: prefer initiative-level `integration/` docs, not feature overviews

10. Consolidate duplication when found: move to source of truth, replace others with a link.

After making changes:

11. Update status consistently: if status changed, update both `roadmap.md` and the relevant `overview.md`.
12. Check cross-references: ensure renamed/removed items do not break links.
13. Verify no contradictions: align with decisions recorded in `roadmap.md`.
14. Check downstream docs: if schema/data flow changed, update consuming features as needed.
15. Remove or rewrite outdated guidance: do not leave stale sections that contradict the new shape.
16. Propagate structural changes: if you changed a feature/work-item list, slug, or ownership boundary, update the parent overview tables and any docs that link to it.

### delivery-map.md Symbol Legend

The delivery-map uses symbols to indicate **parallelization**, not completion:

| Symbol | Meaning |
|--------|---------|
| ✅ | Parallelizable (can run concurrently with other items) |
| ⛔ | Sequential/blocked (must wait for dependencies) |
| **DONE** | Work item completed (append to line, with link if applicable) |

**Example progression:**
```markdown
# Before completion:
- ✅ `persistence-layer/ingestion-pipeline/provenance-refactor` (2d)

# After completion:
- ✅ `persistence-layer/ingestion-pipeline/provenance-refactor` (2d) — **DONE**

# With ADR link (for tech decisions):
- ✅ `persistence-layer/foundation/persistence-db-stack-decision` (2d) — **DONE** ([ADR-002](../../../decisions/002-persistence-db-stack.md))
```

**Important:** The ✅/⛔ symbols remain unchanged when marking done—they indicate the parallelization property of the work item, which is static.

## Common Violations

| Violation | Example | Fix |
|-----------|---------|-----|
| SQL in multiple places | Same query in design.md and schema-overview.md | Keep in schema-overview.md, link from design.md |
| Design notes in reference files | "How it works" section in taxonomy.md | Move to design.md, keep only list in taxonomy.md |
| Status inconsistency | "Designed" in one place and "Future" in another | Pick one status, update all mentions |
| Schema in feature docs | Column definitions copied into design.md | Link to schema-overview.md |
| No upstream read | Making changes without reading roadmap.md first | Always read roadmap.md before editing |
| Ignored downstream | Changed schema, did not check consuming features | Check all features that consume your output |
| Cross-cutting integration buried in one feature | “Integration overview” written inside a single feature `overview.md` | Move to initiative `integration/` doc, link from features |

## Red Flags - Stop and Check

If you're about to:
- Copy SQL from one doc to another → stop, link instead
- Add "Design notes" / "Implementation" section to a reference file → stop, belongs in design.md
- Update status in one file but not others → stop, update all
- Make changes without having read `docs-ai/docs/roadmap.md` → stop, read it first
- Add schema details outside `schema-overview.md` → stop, wrong file
- Add cross-cutting integration notes inside one feature overview → stop, move to initiative `integration/`

## Duplication Decision Tree

```
Found same info in multiple files?
│
├─► Is there a designated source of truth? (see hierarchy)
│   ├─► Yes → Update source, replace others with link
│   └─► No → Designate based on:
│       • Schema → schema-overview.md
│       • Data flow → data-flow.md
│       • Feature logic → that feature's design.md
│       • Cross-feature pattern → the initiative integration/ level
│
└─► Is this a design pattern used by 3+ features?
    └─► Create shared doc at the initiative integration/ level
```

## Quick Reference

Before: `roadmap.md` → initiative `overview.md` → feature `overview.md` → feature `design.md` → initiative `integration/` docs (if needed)

During: write to ONE source of truth, link everywhere else

After: update status in ALL places, check downstream impact
