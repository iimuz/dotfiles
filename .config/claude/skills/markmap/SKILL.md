---
name: markmap
description: Author markmap-format Markdown. Use when writing a mindmap (マインドマップ / markmap) in Markdown.
---

# Writing markmap

markmap turns a single Markdown file into an interactive mindmap. You write
ordinary-looking Markdown; markmap reads its heading and list hierarchy and
draws a tree. Your job with this skill is to produce that Markdown well — the
structure and the `markmap:` config that base Markdown knowledge alone tends
to get wrong.

This skill is authoring only. Do not convert or render the file to
HTML/SVG/PNG and do not start a viewer or dev server — the user previews the
file themselves with their own tooling. Deliver a `.md` file, or a fenced
`markdown` block if the user just wants the text.

## How Markdown Becomes The Tree

- Headings (`#` … `######`) form the outer branches; nested bullet lists under
  a heading form the deeper branches and leaves.
- Start with a single `# Title`. It becomes the one root node, so the map has
  a clean center.
- Each heading or list item is a node; its indented children are its
  branches; an item with no children is a leaf.
- Document order is preserved — siblings render top-to-bottom in the order
  you write them.
- Markdown has only six heading levels. To go deeper than six, switch to
  nested lists — the documented way to build arbitrarily deep branches. A
  common pattern is headings for the top 1–3 levels and nested lists below.

## Frontmatter Config: The markmap Block

Put options in YAML frontmatter under the `markmap:` key. Prefer setting
these: a raw list of bullets renders, but without config the map opens fully
expanded and uncolored, which is rarely what the user wants.

```markdown
---
markmap:
  colorFreezeLevel: 2
  initialExpandLevel: 2
---

# Title
```

Keys you can set in frontmatter:

| Key                  | Type                                          | Default                    | What it does                                                                                  |
| -------------------- | --------------------------------------------- | -------------------------- | --------------------------------------------------------------------------------------------- |
| `color`              | string or string[]                            | d3 category10              | Palette cycled across branches.                                                               |
| `colorFreezeLevel`   | number                                        | 0                          | Freeze color at level N so a branch and all its descendants share one color; 0 = no freezing. |
| `initialExpandLevel` | number                                        | -1                         | Deepest level expanded on load; -1 = expand everything.                                       |
| `maxWidth`           | number                                        | 0                          | Max node width in px; 0 = no limit.                                                           |
| `duration`           | number                                        | 500                        | Fold/unfold animation in ms.                                                                  |
| `spacingHorizontal`  | number                                        | 80                         | Horizontal gap between nodes.                                                                 |
| `spacingVertical`    | number                                        | 5                          | Vertical gap between nodes.                                                                   |
| `zoom`               | boolean                                       | true                       | Allow zoom.                                                                                   |
| `pan`                | boolean                                       | true                       | Allow pan.                                                                                    |
| `extraCss`           | string[]                                      | —                          | Extra stylesheet URLs (`npm:` URLs resolve via CDN).                                          |
| `extraJs`            | string[]                                      | —                          | Extra script URLs (`npm:` URLs resolve via CDN).                                              |
| `activeNode`         | object `{ placement: 'center' \| 'visible' }` | `{ placement: 'visible' }` | How the focused node is positioned.                                                           |
| `lineWidth`          | number                                        | computed                   | Connector line width (markmap >= 0.18.8).                                                     |

Do NOT put these in frontmatter — they look plausible but are low-level view
options that the `markmap:` block does not read, so they silently do nothing:

- `autoFit`
- `fitRatio`
- `paddingX`
- `embedGlobalCSS`
- `nodeMinHeight`
- `scrollForPan`
- `toggleRecursively`
- `maxInitialScale`

If the user needs those, they belong to the viewer or renderer the user runs,
not to the file you write.

## Fold Magic Comments

Add an HTML comment at the end of a heading or list-item line to set that
node's initial fold state:

- `<!-- markmap: fold -->` folds that node.
- `<!-- markmap: foldAll -->` folds that node and all its descendants.

```markdown
## Details <!-- markmap: fold -->

- hidden until the user expands it
```

Use these instead of a low `initialExpandLevel` when you want most of the map
open but a few heavy subtrees collapsed.

## What You Can Put Inside A Node

markmap renders normal Markdown inside nodes, so you can use:

- Bold, italic, strikethrough, inline code.
- Links `[text](url)` and images `![alt](url)`.
- KaTeX math: inline `$E = mc^2$` and block `$$ ... $$`.
- Fenced code blocks (syntax-highlighted).
- Task lists: `- [ ]` and `- [x]`.
- Tables, blockquotes, and raw HTML.

Assets for math and code highlighting load automatically when those features
appear, so you don't declare anything extra.

## Authoring Guidance

- Keep node labels short — terse phrases read far better than full sentences
  in a mindmap.
- Match the label language to the user's content (e.g. Japanese content →
  Japanese labels).
- On a large map, set `initialExpandLevel` (2 is a good start) so it doesn't
  open as an unreadable wall.
- Use `colorFreezeLevel` (often 1 or 2) to give each top-level branch its own
  color family.
- Reach for `maxWidth` only if some nodes carry unavoidably long text.

## Examples

Compact map, lists for depth beyond headings:

```markdown
---
markmap:
  colorFreezeLevel: 2
  initialExpandLevel: 2
---

# Project

## Backend

- API
  - Auth
    - OAuth
    - JWT
- Database

## Frontend

- UI
- State
```

Richer nodes plus a folded subtree:

```markdown
---
markmap:
  initialExpandLevel: 3
---

# Release plan

## Tasks

- [x] Draft spec
- [ ] Ship beta

## Notes <!-- markmap: fold -->

- Formula: $a^2 + b^2 = c^2$
- [Docs](https://markmap.js.org/docs)
```
