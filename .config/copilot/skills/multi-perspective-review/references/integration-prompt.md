# Integration Agent Prompt Template

Use this prompt template for the consolidation agent.

## Task

Synthesize multiple aspect-based code review reports and cross-check results into a single unified review.

## Process

1. **Read all review files** from session folder files/ directory:
   - Initial aspect-based reviews: `<aspect>-<model-name>-review.md`
   - Cross-check results: `<aspect>-<model-name>-crosscheck.md`
   - Aspects: security, quality, performance, bestpractices
   - Models: claude-sonnet-4.5, gemini-3-pro-preview, gpt-5.2-codex

2. **Process cross-check assessments**:
   - For each cross-check file, note the assessments (VALID/INVALID/UNCERTAIN)
   - Use these assessments to refine the consolidated findings
   - If an issue was marked INVALID in cross-check, remove or downgrade it
   - If marked VALID, ensure it's included in final report
   - If UNCERTAIN, flag for developer attention

3. **Merge duplicate findings**:
   - Identify issues reported by multiple reviewers
   - Combine them into single entries
   - Preserve unique perspectives from each review
   - Note when multiple reviewers confirmed the same issue

4. **Validate findings**:
   - Check each issue against the actual code
   - Verify file paths and line numbers are correct
   - Confirm issues are genuine problems
   - Consider cross-check assessments in validation

5. **Flag questionable findings**:
   - If a finding appears incorrect, keep it but mark as "potentially incorrect"
   - Explain why it might be a false positive
   - Note if cross-check marked it as INVALID or UNCERTAIN
   - Let the developer make the final decision

6. **Organize output**:
   - Group by priority (Critical → Warning → Suggestion)
   - Within each priority, group by category (Security, Quality, Performance, Best Practices)
   - Deduplicate similar issues

## Output Format

Structure the consolidated review as:

```md
# Consolidated Code Review

## Executive Summary

- Total files reviewed: [N]
- Total issues found: [N]
  - Critical: [N]
  - Warnings: [N]
  - Suggestions: [N]
- Reviewers: [model names]
- Cross-checks performed: [N]

## Critical Issues

[List critical issues grouped and deduplicated]
[Indicate if confirmed by multiple reviewers or cross-checks]

## Warnings

[List warnings grouped and deduplicated]
[Indicate if confirmed by multiple reviewers or cross-checks]

## Suggestions

[List suggestions grouped and deduplicated]
[Indicate if confirmed by multiple reviewers or cross-checks]

## Cross-Check Results

[Summary of cross-check assessments]
- Issues validated (VALID): [N]
- Issues refuted (INVALID): [N]
- Uncertain issues requiring developer judgment: [N]

## Validation Notes

[Any findings flagged as potentially incorrect with explanations]
[Include cross-check assessments that marked issues as INVALID or UNCERTAIN]
```

## Output Location

Save the consolidated review to: `<session-folder>/files/consolidated-review.md`

## Guidelines

- Be thorough in deduplication
- Preserve all unique insights
- Mark false positives clearly (especially those identified in cross-checks)
- Provide actionable summary
- Focus on helping the developer improve their code
