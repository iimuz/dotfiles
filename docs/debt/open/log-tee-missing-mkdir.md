# Debt: log_tee Missing Directory Creation

## Summary

- Description: `log_tee` assumes date-based log directories already exist and fails on first use for a new path.

## Location

- Path: `.config/bash/command.sh`

## Issue

- Detail: The function changes directory into a computed log path but does not create missing
  directories first, causing command failure when the path has not been created yet.

## FIX_CONDITION

- Condition: `log_tee` creates required destination directories before entering or writing,
  and succeeds on a clean first run.
