# Agent Memory

In this project, knowledge is systematically managed using the following files.

- Important: Whenever you make a new implementation or important decision, update the relevant file.

## `.agent-memory/project-improvements.md`

- Records of past trial and error
- Failed implementations and their causes
- Improvement processes and results

```md
# Improvement History

## 2024-12-15: Improved Page Load Speed

Issue: Initial display of the product list page took over 3 seconds

Attempts:

- ❌ Lazy loading images → Limited effect
- ❌ SQL query optimization → ~10% improvement
- ✅ Incremental loading of product data → 60% improvement

Final solution:

1. Show only 20 items on initial load
1. Load more items with infinite scroll
1. Convert images to WebP and deliver via CDN

Lesson learned: Incremental loading is more effective for UX than displaying all items at once.
```

## `.agent-memory/common-patterns.md`

- Frequently used command patterns
- Standard implementation templates

```md
# Common Patterns

## Component Generation

`claude create component [ComponentName] with TypeScript and styled-components`
```

## Debug Information Management

### Persistence Rules

Log issues in `.agent-memory/debug-log.md` if they meet any of the following:

- Took more than 30 minutes to resolve
- Likely to recur
- Should be shared with the whole team

### Directory Structure

```
.agent-memory/
├── debug-log.md       # Persistent debug information file
├── YYYY-MM-DD-TITLE1/ # Active issues
└── archive/           # Resolved issues archive
    └── YYYY-MM-DD-TITLE2/
```

### `.agent-memory/debug-log.md` Entry Format

```md
## [YYYY-MM-DD] Issue Summary
Symptoms: Error messages or abnormal behavior
Environment: OS, Node.js, browser version
Reproduction steps: Specific steps to reproduce
Attempts: Methods tried and their results
Final solution: Steps that reliably solved the issue
Root cause: Fundamental reason for the problem
Prevention: Measures to avoid recurrence
```
