---
name: aws-mermaid
description: >-
  Generate AWS architecture diagrams in Mermaid.
  Invoke when the user asks to draw, design, or document AWS architecture as Mermaid.
---

# aws-mermaid

## Purpose

Generate AWS architecture diagrams as Mermaid `flowchart LR`.
AWS service icons are fetched from Iconify (`https://api.iconify.design/logos/aws-*.svg`)
and embedded via the Mermaid v11.3.0 image-node extension (`nodeID@{img,label,pos,w,h,constraint}`).

Do not use `architecture-beta` (no click support; external icons do not render on Notion / GitHub).
`flowchart` supports click navigation, subgraph nesting, and the full edge vocabulary,
so it is the more general choice.

## When to use / not to use

### Use

- The user asks to draw / design / document AWS architecture as Mermaid
- Convert an existing text architecture / CloudFormation / CDK / Terraform description into Mermaid
- Produce a before/after or Option A vs Option B comparison diagram

### Do not use

- The user wants draw.io / drawio XML output — delegate to `deploy-on-aws:aws-architecture-diagram`
- A plain text (ASCII art) diagram is sufficient

## Workflow

1. Enumerate targets (AWS services / external services / browser / on-prem)
2. Group the hierarchy (account / region / VPC / external) with `subgraph`
3. Start from the skeleton in [`references/template.md`](references/template.md)
4. Look up icon URLs in [`references/icons.md`](references/icons.md)
5. Apply the rules in the "Layout" and "Labels" sections below
6. Add `click` lines **only when the user explicitly asks** for management-console links; in that case use [`references/console-urls.md`](references/console-urls.md)

## Minimum skeleton

```mermaid
---
title: <title>
config:
  theme: neutral
  flowchart:
    nodeSpacing: 10
    rankSpacing: 30
---
flowchart LR

nodeID@{img: "<iconify URL>", label: "<label, <br> for line break>", pos: "b", w: 60, h: 60, constraint: "on"}

subgraph groupID["<group label>"]
  ...
end

nodeA --- nodeB
nodeA ----|"label"| nodeB
nodeA -.-> nodeB    %% async / config reference
nodeA ~~~ nodeB     %% invisible (layout only)

classDef default fill:#fff
classDef group fill:none,stroke:none
style groupID fill:#fff,color:#345,stroke:#345
```

## Defaults

| Item                          | Default                                              |
| ----------------------------- | ---------------------------------------------------- |
| Direction                     | `flowchart LR` (external → internal, left to right)  |
| Theme                         | `neutral`                                            |
| `nodeSpacing` / `rankSpacing` | 10 / 30                                              |
| Icon size                     | `w: 60, h: 60`                                       |
| Label position                | `pos: "b"` (below the icon)                          |
| AWS icon URL pattern          | `https://api.iconify.design/logos/aws-<service>.svg` |
| Non-AWS fallback              | `material-symbols/*` or `logos/<vendor>`             |

## Layout

- Keep `subgraph` nesting to 2–3 levels (e.g. AWS account → region → VPC). Do not go deeper.
- For multi-region diagrams, split regions into their own subgraphs (`subgraph use1["us-east-1"]` / `subgraph apne1["ap-northeast-1"]`).
- To align nodes in the same column, wrap them in an **empty-label invisible subgraph**
  (`subgraph g-foo[" "]`) and remove its frame with `classDef group fill:none,stroke:none` +
  `class g-foo group`.
- To control vertical ordering between subgraphs, chain them with **invisible edges** `~~~` (e.g. `g-cdn ~~~ vpc ~~~ g-aux`).

## Labels

- Use `<br>` (HTML) for line breaks. `\n` does not work.
- Do **not** put a colon `:` or pipe `|` inside a label; the Mermaid parser can misbehave.
  Substitute a full-width colon (`：`) or rephrase if needed.

## Output rules

- Wrap the diagram in a fenced ` ```mermaid ` block.
- Add `click nodeID href "URL" _blank` **only when the user explicitly asks** for
  management-console navigation. Never embed by default.
- For comparison diagrams (before/after, Option A vs Option B, etc.), **reuse the same node IDs
  and layout across both diagrams** and color only the diff parts with `classDef diff`
  (see the end of [`references/template.md`](references/template.md)).

## Anti-patterns

- Using `architecture-beta` (see "Purpose")
- Wrapping everything in `subgraph` so nesting goes deep (keep it 2–3 levels)
- Using whitespace or unusual characters in node IDs (`-`, `/`, `_`, alphanumerics only)
- Embedding click URLs when the user did not ask for them
