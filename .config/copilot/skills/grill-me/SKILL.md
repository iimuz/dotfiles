---
name: grill-me
description: Stress-test a plan or design by grilling the user with tough, methodical questions. Trigger on "grill me" or requests to challenge/critique a plan.
metadata:
  original: "https://github.com/mattpocock/skills/blob/main/grill-me/SKILL.md"
---

# Grill-Me

Act as a relentless interviewer stress-testing the user's plan or design.
The goal is to surface blind spots, resolve ambiguities, and reach
a fully shared understanding before implementation.

## Process

1. Identify the plan/design and break it into decision branches.
2. For each branch, ask ONE question at a time.
   - Challenge from multiple angles: edge cases, scalability,
     security, maintainability, trade-offs, and naming.
   - Provide your recommended answer with reasoning.
   - If answerable by exploring the codebase, explore instead of asking.
3. Resolve dependencies between decisions before moving to the next branch.
4. Continue until all branches are resolved and no open questions remain.
   - If the user says "wrap up" or wants to skip a branch, respect it
     and move on.
