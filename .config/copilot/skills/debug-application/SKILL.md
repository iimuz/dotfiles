---
name: debug-application
description: Systematically debug applications to identify, analyze, and resolve bugs using structured root cause analysis, reproduction, and verification workflows. Invoke when investigating test failures, runtime errors, or unexpected application behavior.
---

# Debug Application

Systematically identify, analyze, and resolve bugs in applications through structured debugging workflows.

## When to Use This Skill

Invoke this skill when:

- Test failures occur and root cause needs investigation
- Runtime errors or exceptions require diagnosis
- Unexpected application behavior needs analysis
- Stack traces or error messages need interpretation
- Regression bugs appear after code changes
- Intermittent issues require reproduction and verification

## Debugging Workflow

### Phase 1: Problem Assessment

**Gather Context:**

- Read error messages, stack traces, and failure reports
- Examine codebase structure and recent changes using `grep` and `view` tools
- Identify expected vs actual behavior from test outputs
- Review relevant test files and their failures using `bash` to run tests

**Reproduce the Bug:**

- Run the application or tests using `bash` tool to confirm the issue
- Document exact reproduction steps from terminal output
- Capture error outputs, logs, and unexpected behaviors
- Create a bug report with:
  - Reproduction steps
  - Expected behavior
  - Actual behavior
  - Error messages/stack traces
  - Environment details

### Phase 2: Investigation

**Root Cause Analysis:**

- Trace code execution path leading to the bug using `view` and `grep`
- Examine variable states, data flows, and control logic
- Check for common issues: null references, off-by-one errors, race conditions, incorrect assumptions
- Use `grep` to search code patterns and understand component interactions
- Review git history using `bash` for recent changes that might have introduced the bug

**Hypothesis Formation:**

- Form specific hypotheses about the root cause
- Prioritize hypotheses by likelihood and impact
- Plan verification steps for each hypothesis

### Phase 3: Resolution

**Implement Fix:**

- Make targeted, minimal changes using `edit` tool to address root cause
- Follow existing code patterns and conventions
- Add defensive programming practices where appropriate
- Consider edge cases and potential side effects

**Verification:**

- Run tests using `bash` to verify the fix resolves the issue
- Execute original reproduction steps to confirm resolution
- Run broader test suites to ensure no regressions
- Test edge cases related to the fix

### Phase 4: Quality Assurance

**Code Quality:**

- Review the fix for code quality and maintainability
- Add or update tests to prevent regression
- Update documentation if necessary
- Search using `grep` for similar patterns that might have the same bug

**Final Report:**

- Summarize what was fixed and how
- Explain the root cause
- Document preventive measures taken
- Suggest improvements to prevent similar issues

## Debugging Principles

- **Be Systematic**: Follow phases methodically; understand before fixing
- **Document Findings**: Keep detailed records of attempts and discoveries
- **Think Incrementally**: Make small, testable changes rather than large refactors
- **Consider Context**: Understand broader system impact of changes
- **Stay Focused**: Address the specific bug without unnecessary changes
- **Test Thoroughly**: Verify fixes work in various scenarios and environments

## Tool Usage

- **bash**: Run tests, execute application, reproduce bugs, check git history
- **grep**: Search code patterns, find similar issues, trace execution paths
- **view**: Examine source files, test files, and configuration
- **edit**: Apply targeted fixes to resolve root causes
- **web_fetch**: Research error messages or framework-specific issues when needed
