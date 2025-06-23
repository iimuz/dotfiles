---
mode: "agent"
tools: ["git_commit", "git_diff", "git_diff_staged", "git_log", "git_show"]
description: "Git workflow"
---

# Git Workflow

This document describes best practices for creating commits and pull requests.

## Creating Commits

Follow these steps when creating commits:

1. Confirm Changes

   ```bash
   # Check untracked files and changes
   git status

   # Check details of changes
   git diff

   # Check commit message style
   git log
   ```

2. Analyze Changes
   - Identify changed or added files
   - Understand the nature of the change (new feature, bug fix, refactoring, etc.)
   - Evaluate the impact on the project
   - Check for sensitive information
3. Create Commit Message
   - Focus on "why"
   - Use clear and concise language
   - Accurately reflect the purpose of the change
   - Avoid generic expressions
4. Execute Commit

   ```bash
   # Stage only relevant files
   git add <files>

   # Create commit message (using HEREDOC)
   git commit -m "$(cat <<'EOF'
   :art: Introduce Result type for user authentication

   - Make error handling more type-safe
   - Enforce explicit handling of error cases
   - Improve tests

   🤖 Generated with ${K4}
   Co-Authored-By: Claude noreply@anthropic.com
   EOF
   )"
   ```

## Creating Pull Requests

Follow these steps when creating pull requests:

1. Check Branch Status

   ```bash
   # Check for uncommitted changes
   git status

   # Check changes
   git diff

   # Check differences from main
   git diff develop...HEAD

   # Check commit history
   git log
   ```

2. Analyze Changes
   - Check all commits since branching from develop
   - Understand the nature and purpose of the changes
   - Evaluate the impact on the project
   - Check for sensitive information
3. Create Pull Request

   ```bash
   # Create pull request (using HEREDOC)
   gh pr create --title ":art: Improve error handling with Result type" --body "$(cat <<'EOF'
   ## Related URLs

   ## Changes

   - Introduction of Result type using neverthrow
   - Explicit type definition for error cases
   - Addition of test cases

   ## Confirmation Results

   <!-- Describe preconditions, steps, and results of confirmation if any -->

   ## Review Points

   - Is the Result type used appropriately?
   - Comprehensiveness of error cases
   - Sufficiency of tests

   ## Limitations

   <!-- Describe known limitations of this change or items to be addressed in a separate PR if any -->
   EOF
   )"
   ```

## Important Notes

1. Commit Related
   - Use `git commit -am` when possible
   - Do not include unrelated files
   - Do not create empty commits
   - Do not change git settings
2. Pull Request Related
   - Create a new branch if necessary
   - Commit changes appropriately
   - Use the `-u` flag when pushing to remote
   - Analyze all changes
3. Operations to Avoid
   - Using interactive git commands (-i flag)
   - Pushing directly to the remote repository
   - Changing git settings

## Commit Message Examples

```bash
# Add new feature
:sparkles: Introduce Result type for error handling

# Improve existing feature
:art: Improve cache feature performance

# Fix bug
:bug: Fix authentication token expiration handling

# Refactor
:recycle: Abstract external dependencies using Adapter pattern

# Add tests
:white_check_mark: Add tests for Result type error cases

# Update documentation
:memo: Add best practices for error handling
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

## Pull Request Example

```markdown
## Changes

- Introduction of neverthrow library
- Use of Result type in API client
- Type definition for error cases
- Addition of test cases

## Confirmation Results

<!-- Describe preconditions, steps, and results of confirmation if any -->

## Review Points

- Is the Result type used appropriately?
- Comprehensiveness of error cases
- Sufficiency of tests

## Limitations

<!-- Describe known limitations of this change or items to be addressed in a separate PR if any -->
```
