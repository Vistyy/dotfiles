---
description: Analyze code review feedback and determine which issues are valid
---

**IMPORTANT**: The next message will contain the code review comments. Acknowledge these instructions and wait for the review to be provided.

Once you receive the code review feedback, analyze it thoroughly. First, create a numbered list of all issues raised in the review for easy reference, preserving for each one (if provided):
- Its severity (`CRITICAL`, `HIGH`, `MEDIUM`, `LOW`)
- Its disposition (`Must-fix before merge` vs `Follow-up / Nice-to-have`)
- Any explicit flags such as "questionable additions"

Then for each issue:

1. Investigate the relevant code, specs, and tasks to understand the context and confirm the reviewer’s interpretation.
2. Determine whether the issue is valid and should be addressed, and whether the suggested severity and disposition are appropriate.
3. Do not make any code edits until the analysis is reviewed and approved by the user.
4. Categorize issues as:
   - **Valid**: Real issues that should be fixed
   - **Not applicable**: Based on incorrect assumptions or outdated information
   - **Already addressed**: Issues that have been resolved
   - **By design**: Intentional decisions with valid reasoning

5. For each valid issue:
   - State whether it must be fixed before merge or can be treated as follow-up, based on risk and the (possibly adjusted) disposition.
   - Provide recommendations on how to address it that favor simplification, reuse of existing patterns, and the minimum necessary change to resolve the risk.
6. For non-issues (Not applicable, Already addressed, By design), explain why they don't need to be addressed, referencing specs, project conventions, or review anti-goals (for example, style-only changes that conflict with formatters/linters, speculative abstractions, or large rewrites unrelated to the diff).

Pay special attention to:
- Issues the reviewer marked as "questionable additions": critically assess whether the new code is necessary and lean toward removal or simplification when the value is unclear.
- The review’s top risks and overall verdict (`BLOCK`, `NON-BLOCKING`, `APPROVE`): ensure your recommendations clearly indicate which issues keep the change blocked and which are safe to defer.

Provide a clear summary at the end that:
- Lists which issues to fix before merge, which can be deferred as follow-up, and which to ignore, with reasoning.
- Re-states a recommended overall verdict (`BLOCK`, `NON-BLOCKING`, or `APPROVE`) for the current state, with a short justification (for example, "BLOCK until issues #1 and #3 are fixed").
