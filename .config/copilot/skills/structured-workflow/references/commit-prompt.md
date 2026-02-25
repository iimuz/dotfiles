# Commit Request

## Goal

Create a commit from currently staged changes and return `CommitRef`.

## Interface

```typescript
type CommitRef = { sha: string; message: string };
```

## Operations

```typespec
op commit_staged() -> CommitRef {
  skill(name: "commit-staged");
  invariant: (nothing_staged) => abort("No staged changes to commit");
  invariant: (commit_failed)  => abort("commit-staged failed");
}
```

## Execution

```text
commit_staged
```

Rule: Do NOT spawn subagents.
