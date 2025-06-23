---
mode: "agent"
tools: []
description: ""
---

## Overview

Within the "Memo List by Category" section, collect all note links from daily memos and organize them by category in a weekly review document.
The goal is to consolidate scattered notes into a coherent weekly summary with appropriate categorization.

## Context

- Source files: Daily memos with "Memo List by Category" sections
- Target file: Weekly review memo with consolidated categories
- The weekly memo should serve as a comprehensive summary of the week's activities

## Rules

1. Extract all note links from the "Mobile First Daily Interface" sections in the daily memos
1. Ensure all note links follow the format `- YYYY-MM-DD [title](basename)`
1. Group links by major category using level 3 headings (`### Category`)
1. Reorganize categories for appropriate granularity suitable for zettelkasten extraction
1. For each category section, write a comprehensive summary of the contents in prose
1. Consolidate related categories when they have similar themes or limited content
1. Create new categories when existing ones become too broad or contain diverse topics

## Category Organization Guidelines

### Consolidation Criteria

- Combine categories with fewer than 3-5 items unless they represent distinct domains
- Merge closely related technical topics (e.g., LLM + Local LLM → AI and Machine Learning)
- Group lifestyle and consumer products together (e.g., Bag + Water Bottle → Daily Items & Lifestyle)

### Granularity Guidelines

- Each category should be substantial enough to warrant a separate zettelkasten file
- Categories should have coherent themes that enable meaningful synthesis
- Avoid overly specific categories that would result in fragmented knowledge

### Suggested Category Framework

- Work-related activities
- AI and Machine Learning
- Development Environment & Tools
- Hardware & Gadgets
- Technology Trends
- Daily Items & Lifestyle
- Self-improvement
- Family & Private

## Output Format

```md
## Memo List by Category

### Category Name

- 2025-04-21 [Title 1](basename1)
- 2025-04-22 [Title 2](basename2)
- 2025-04-23 [Title 3](basename3)

This category summarizes the specific contents in prose. In particular, it focuses on the main points and learning outcomes, highlighting the key activities undertaken.

### Next Category Name

- 2025-04-24 [Title 4](basename4)

A summary of the contents of another category.
```

## Notes

- Zettelkasten file links must use the basename without file extension
- Ensure all note links from daily memos are included in the weekly summary
- Category descriptions should provide meaningful synthesis, not just listing
- Maintain consistent date formatting throughout
