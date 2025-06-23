---
mode: "agent"
tools: []
description: ""
---

## Overview

Automatically extract, split, link, and consolidate concise memos under the "Mobile First Daily Interface" section from a specified daily note file into individual zettelkasten files, following the rules below.

## Rules

1. Extract high-value reusable knowledge (such as technical, operational, troubleshooting, management, design, or insights) from the chronological memos under "Mobile First Daily Interface" and split them into separate zettelkasten files.
1. For each extracted item, leave only a link in the original file directly under "Mobile First Daily Interface" in the format: `- time [title](basename)`.
1. All links to the split files must be listed together directly under the section titled `### yyyy-mm-ddT00:00:00.000+09:00` in the original file. Do not create additional sections for each time or memo.
1. Each zettelkasten file must have the following frontmatter:

```yml
title: Insert an appropriate title for each file
description: Add a concise description
date: File creation time in epoch time seconds
lastmod: Last modified time in epoch time seconds
expiryDate: One week after lastmod in epoch time seconds
draft: false
tags: []
categories:
  - fleeting or literature
```

1. If there are duplicate or consecutive memos with similar content, consolidate them into a single zettelkasten file and leave only one link in the original file.
1. Delete the original consolidated files, leaving only a notice or removing them entirely.
1. After splitting and consolidating, if there are duplicate links in the original file, merge them into one.
1. Leave non-target memos and introductory text in the original file as is.

## Example

### 2025-05-22T00:00:00.000+09:00
- 09:26:28 [Task Management Method](dummy-20250522092628)
- 09:27:56 [New LLM Model Release Info](dymmy-20250522092756)
  ...

## Notes

- Zettelkasten file links must use the basename without file extension.
- The date/lastmod/expiryDate fields in the frontmatter must be automatically calculated and inserted.
- Choose categories according to the content.
- All processing must be performed automatically in a single batch.
- The content copied to zettelkasten files must be transcribed exactly as written in the original daily memo, without intentional alteration, summarization, or editing.
