# Cross-Check Review Prompt Template

Use this prompt template for targeted re-checks of specific issues.

## Context

During initial parallel review, certain issues were flagged by some reviewers but not by others. This cross-check verifies whether these concerns are valid or were appropriately omitted.

## Task

You are performing a focused re-check of specific concerns identified by other reviewers.

1. Run `git diff` to see the same changes reviewed earlier
2. Focus only on the specific concerns listed below
3. Determine if these concerns are valid or not

## Specific Concerns to Verify

[This section will be populated with specific issues from other reviews]

For each concern:
- **Issue**: [Description of the concern]
- **Location**: [File and line number if specified]
- **Category**: [Security/Quality/Performance/Best Practice]
- **Original Reviewer**: [Model that flagged this]

## Your Task

For each concern listed above:

1. **Examine the code** at the specified location
2. **Determine validity**:
   - Valid: The concern is legitimate and should be addressed
   - Invalid: The concern is not applicable or incorrect
   - Uncertain: Need more context or it's a judgment call

3. **Provide assessment** using this format:

```
[CONCERN #N] <Brief description>
File: <path/to/file.ext>:<line_number>
Original Reviewer: <model-name>
Assessment: [VALID / INVALID / UNCERTAIN]
Reasoning: <Your analysis>

[Code snippet if relevant]
```

## Guidelines

- Be thorough but focus only on the listed concerns
- Don't perform a full review (that was done in the initial pass)
- If you find the issue valid, explain why you missed it initially
- If invalid, explain why it's not a concern
- Be honest about uncertainties

## Output Location

Save your cross-check results to: `<session-folder>/files/<model-name>-crosscheck.md`

Replace `<model-name>` with your model identifier.

## Example Assessment

```
[CONCERN #1] Hardcoded API key
File: src/api/client.ts:42
Original Reviewer: claude-sonnet-4.5
Assessment: VALID
Reasoning: Upon re-examination, line 42 does contain what appears to be a production API key hardcoded in the source. I initially missed this during my review, but it is indeed a critical security issue that should be moved to environment variables.

const apiKey = "sk-prod-abc123xyz";  // This is a hardcoded credential
```

```
[CONCERN #2] Inefficient algorithm in sort function
File: src/utils/sort.ts:15
Original Reviewer: gemini-3-pro-preview
Assessment: INVALID
Reasoning: The algorithm is O(n log n) using the built-in Array.sort(), which is appropriate for this use case. The concern about O(n²) complexity is not applicable here. This is a false positive.
```

```
[CONCERN #3] Missing error handling in async function
File: src/services/data.ts:28
Original Reviewer: gpt-5.2-codex
Assessment: UNCERTAIN
Reasoning: The function does have a try-catch block (lines 30-35), but it only catches specific error types. Whether additional error handling is needed depends on the broader error handling strategy of the application, which isn't clear from this code alone.
```
