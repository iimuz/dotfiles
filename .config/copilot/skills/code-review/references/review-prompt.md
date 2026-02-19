# Review Agent Prompt

## Invocation

```typespec
op invoke_review(context: ReviewContext) -> ReviewOutput {
  task(agent_type: "general-purpose", prompt: rendered_template(context));
  invariant: (response_empty) => retry(max: 1, then: mark_failed(context.model_name));
}
```

## Failure Handling

```typespec
op handle_review_failure(failed_model: string, outputs: ReviewOutput[]) -> ReviewOutput[] {
  invariant: (per_aspect_count < 2) => abort("Insufficient review coverage for aspect");
  invariant: (per_aspect_count == 2) => warn("Degraded mode; note missing model in consolidated report");
}
```

---

# Subagent Prompt Template

## Role

Senior code reviewer focusing on a specific aspect of code quality.

## Interface

```typescript
/**
 * @input  { context: ReviewContext }
 * @output { review: ReviewOutput }
 */

type Finding = {
  priority: "CRITICAL" | "WARNING" | "SUGGESTION";
  file: string;
  line: number;
  description: string;
  fix?: string;
};

type ReviewOutput = {
  aspect: ReviewAspect;
  findings: Finding[];
};
```

## Operations

```typespec
op review_changes(context: ReviewContext) -> ReviewOutput {
  // Run git diff; focus only on {aspect} using {aspect_criteria}
  invariant: (aspect_drift) => abort("Review only the assigned aspect; other aspects are covered by other reviewers");
  invariant: (no_issues_found) => state_explicitly("No issues found in this aspect");
  invariant: (critical_issue.location_missing) => require_file_path_and_line;
}

op format_output(review: ReviewOutput) -> string {
  // Write markdown to {output_path} organized by priority: Critical → Warning → Suggestion
  invariant: (critical_issue.location_missing) => reject("Critical issues must include file:line");
  invariant: (severity_label_invalid) => use_enum("CRITICAL" | "WARNING" | "SUGGESTION");
}
```

## Execution

```
review_changes -> format_output
```

## Input Context

```typescript
interface ReviewContext {
  session_id: string;
  aspect: "security" | "quality" | "performance" | "best-practices";
  aspect_criteria: string; // extracted section from review-criteria.md for this aspect
  model_name: string; // e.g., "claude-opus-4.6"
  file_scope?: string[]; // optional: restrict review to specific files
  directory_scope?: string; // optional: restrict review to directory pattern
}
```

Output path: `~/.copilot/session-state/{session_id}/files/{aspect}-{model_name}-review.md`

Output format per finding:

```
[PRIORITY] Brief description
File: path/to/file.ext:line_number
Issue: Detailed explanation
Fix: How to resolve it
```
