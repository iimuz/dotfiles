---
mode: "agent"
tools: ['codebase', 'usages', 'changes', 'searchResults', 'search', 'git_commit', 'git_diff_staged', 'git_log', 'git_show', 'git_status']
description: "Create Commit."
---

## Summary

This document describes best practices for creating git commits.
Although examples are shown using git commands, please use tools if available.

## Creating Commits

Follow these steps when creating commits:

1. Confirm Changes:
   - `git_diff_staged`: Check details of changes
   - `git_log`: Check commit message style
1. Analyze Changes
   - Identify changed or added files
   - Understand the nature of the change (new feature, bug fix, refactoring, etc.)
   - Evaluate the impact on the project
   - Check for sensitive information
1. Create Commit Message
   - Focus on "why"
   - Use clear and concise language
   - Accurately reflect the purpose of the change
   - Avoid generic expressions
1. Ask the user to review the commit message
1. Execute Commit

## Important Notes

- Use formal written language for commit messages.

## Commit Message Examples

```markdown
:art: Introduce Result type for user authentication

- Make error handling more type-safe
- Enforce explicit handling of error cases
- Improve tests
```

Use the following prefixes:

- `:art:`: Improve code structure/format
- `:zap:`: Improve performance
- `:fire:`: Remove code or files
- `:bug:`: Fix a bug
- `:ambulance:`: Critical hotfix
- `:sparkles:`: Introduce new features
- `:memo:`: Add or update documentation
- `:lipstick:`: Add or update UI and style files
- `:white_check_mark:`: Add, update, or pass tests
- `:lock:`: Fix security or privacy issues
- `:rotating_light:`: Fix compiler/linter warnings
- `:green_heart:`: Fix CI build
- `:arrow_down:`: Downgrade dependencies
- `:arrow_up:`: Upgrade dependencies
- `:pushpin:`: Pin dependencies to specific versions
- `:construction_worker:`: Add or update CI build system
- `:chart_with_upwards_trend:`: Add or update analytics or tracking code
- `:recycle:`: Refactor code
- `:heavy_plus_sign:`: Add a dependency
- `:heavy_minus_sign:`: Remove a dependency
- `:wrench:`: Add or update configuration files
- `:hammer:`: Add or update development scripts
- `:pencil2:`: Fix typos
- `:alien:`: Update code due to external API changes
- `:truck:`: Move or rename resources (files, paths, routes, etc.)
- `:page_facing_up:`: Add or update license
- `:boom:`: Introduce breaking changes
- `:bulb:`: Add or update comments in source code
- `:card_file_box:`: Perform database related changes
- `:loud_sound:`: Add or update logs
- `:mute:`: Remove logs
- `:building_construction:`: Make architectural changes
- `:clown_face:`: Implement mock
- `:see_no_evil:`: Add or update .gitignore file
- `:alembic:`: Perform experimental changes
- `:label:`: Add or update types
- `:triangular_flag_on_post:`: Add, update, or remove feature flags
- `:goal_net:`: Catch errors
- `:wastebasket:`: Address deprecated code that needs to be cleaned up
- `:passport_control:`: Work on code related to authorization, roles, and permissions
- `:adhesive_bandage:`: Simple fix for a non-critical issue
- `:coffin:`: Remove dead code
- `:test_tube:`: Add a failing test
- `:necktie:`: Add or update business logic
- `:stethoscope:`: Add or update health check
- `:bricks:`: Infrastructure related changes
- `:technologist:`: Improve developer experience
- `:thread:`: Add or update code related to multithreading or concurrency
- `:safety_vest:`: Add or update code related to validation
