---
name: save-conventions
description: >-
  Defines where to save work-in-progress artifacts (design, plan, research,
  temporary files) so output paths stay consistent. Use when saving a design,
  plan, research note, or temp script, or when running /deep-read, /write-plan,
  or superpowers (brainstorming/writing-plans).
---

# Save Conventions

Save work-in-progress artifacts to consistent locations. Without these rules,
output paths drift across the existing folder structure each time.

## docs/ layout (reference)

| Directory       | Purpose                                                                   |
| --------------- | ------------------------------------------------------------------------- |
| `docs/adr/`     | Architecture Decision Records                                             |
| `docs/design/`  | System-wide specs and design docs (not per-feature implementation design) |
| `docs/reports/` | Research notes, plans, and other work-in-progress artifacts               |
| `docs/tmp/`     | Disposable scripts and scratch output                                     |

## Output path rules

| Tool                 | Output path                                                 |
| -------------------- | ----------------------------------------------------------- |
| superpowers (design) | `docs/superpowers/specs/YYYY-MM-DD-{topic}-design.md`       |
| superpowers (plan)   | `docs/superpowers/plans/YYYY-MM-DD-{topic}.md`              |
| `/deep-read`         | `docs/reports/YYYY-MM-DD-{topic}-research-{small-topic}.md` |
| `/write-plan`        | `docs/reports/YYYY-MM-DD-{topic}-plan.md`                   |

- `YYYY-MM-DD` is today's date; `{topic}` is the work subject in kebab-case.
  Always include both so parallel work stays distinguishable.
- For superpowers, do NOT redirect output into `docs/reports/`. Follow
  superpowers' own default directories (`docs/superpowers/specs/`,
  `docs/superpowers/plans/`). State this explicitly because, without it,
  superpowers picks a different location each time.
