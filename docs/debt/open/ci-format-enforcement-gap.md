# Debt: CI Format Enforcement Gap

## Summary

- Description: CI validates linting but does not enforce formatting consistency.

## Location

- Path: `.github/workflows/ci.yml`
- Path: `lefthook.yml`

## Issue

- Detail: Local hooks include formatting and linting, but CI runs only lint. This allows formatting
  drift when hooks are bypassed.

## Fix Condition

- Condition: CI includes formatting validation equivalent to local policy and rejects unformatted changes.
