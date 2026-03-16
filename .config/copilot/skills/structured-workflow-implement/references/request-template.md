# Implementation Request Template

Content structure for `sw-implement-request-{iteration}.md`:

## Implementation Request

### Scope

Scope items as a bullet list.

### Instructions

- Implement ALL scope items completely.
- Do not fix pre-existing issues unrelated to the scope.

## Recovery Rule

If `{session_dir}/sw-implement-request-{iteration}.md` already exists and
`{session_dir}/sw-checkpoint-{iteration}.json` shows `status: "complete"`, skip
re-generation and return the existing file path.
