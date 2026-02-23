# Debt: set_bashrc Duplicate Check Logic

## Summary

- Description: `set_bashrc` duplicate detection is malformed in two setup scripts and can append duplicate sourcing lines.

## Location

- Path: `setup_aarch64.sh`
- Path: `setup_codespaces.sh`

## Issue

- Detail: The duplicate check uses a malformed grep invocation pattern that is not a reliable
  fixed-string presence test for the source marker line in the rc file.

## FIX_CONDITION

- Condition: Duplicate detection uses a reliable fixed-string grep check and repeated script runs
  do not append duplicate source lines.
