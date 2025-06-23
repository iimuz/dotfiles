---
mode: "agent"
tools: []
description: "Prompt for converting monthly memos into a theme-based hierarchical structure to improve visibility and organization."
---

## Theme-Based Monthly Memo Conversion Prompt

You are an assistant specializing in organizing zettelkasten notes.
Your task is to address the problem of information overload in monthly memos by converting them into a theme-based hierarchical structure, making important achievements and ongoing efforts more visible and accessible.

## Purpose and Background of Conversion

### Problems to Solve

- Monthly memos become long lists, causing important information to be buried.
- The flow of themes and ongoing efforts is hard to see.
- Achievements and learnings are scattered and difficult to grasp.

### Benefits After Conversion

- The main themes and achievements of the month can be understood at a glance.
- Detailed information is systematically organized in dedicated timelines.
- The start, continuation, and completion of themes can be clearly tracked.

## Understanding the Input Format

The current monthly memo has the following structure:

- Front matter including title, description, date, tags, and categories.
- Monthly review section.
- Category-based memo lists (e.g., work tasks, AI & machine learning, development environment & tools, etc.)

## Conversion Rules

### Maintaining Front Matter

- Keep the existing front matter as is.
- Do not change tags and categories.

### Structural Changes

1. Add a "Theme Summary of the Month" section at the end.
2. Organize and list all necessary themes for this month.
3. Summarize each category in the "Main Achievements and Activities" section.
4. Add a concise summary for each category.
5. Add an "Outlook for Next Month" section.

## Execution Instructions

Follow the above process to handle the provided monthly memo. Execute the steps in the order below and clearly present the results of each step:

### Execution Order

1. Extract the list of themes from the monthly memo
  - Display the extracted list of themes
  - Explain the classification reason for each theme
1. Check the existing theme index file
  - Confirm the existence of the file
  - Display the list of existing themes
1. Compare themes and decide processing policy
  - Show the result of new/existing determination
  - Clearly state the processing policy for each theme
1. Create or update theme files
  - List files to be newly created
  - Show the content to be appended to existing files
1. Update the theme index file
  - Show entries to be added/updated
  - Present the final theme index file
1. Transform the structure of the monthly memo
  - Show the transformed main monthly memo

### Deliverables

After completing each step, provide:
- Explanation of the processing result for each step
- Content of created/updated files
- Reasons for changes and scope of impact
- Information to be handed over to the next step

Perform the conversion step by step, adding detailed explanations at each stage.

## Output Format Details

### Theme Summary of the Month

Theme identification criteria:

- Activities continued over multiple weeks.
- Efforts with clear goals or direction.
- Activities with a series of learning or development flows.

```md
## 今月のテーマサマリー

### 新規開始テーマ

- [Theme name](theme-file-link): Brief description (1-2 lines)
  - Reason for starting and initial activities

### 完了テーマ

- [Theme name](theme-file-link): Summary of completion (1-2 lines)
  - Main achievements and learnings

### 継続テーマ

- [Theme name](theme-file-link): Progress summary (1-2 lines)
  - Main progress this month
```

### Main Achievements and Activities

```md
## 主要な成果と活動

### Category Name

Summary:

Summarize the main efforts and achievements in this category in 2-3 lines.

Highlights of the month:

- Most important achievements or progress (2-3 items)
- New learnings
- Problems or issues solved

Detailed timeline: [memo title](basename)

Main notes:

- YYYY-MM-DD [Note Title](filename)
- YYYY-MM-DD [Note Title](filename)
```

### Outlook for Next Month

```md
## 来月への展望

### 継続予定のテーマ

- Theme name: Next steps
- Theme name: Planned efforts

### 新規検討事項

- New initiatives to start
- Fields to investigate or learn

### 改善・見直し事項

- Improvements derived from this month's issues
- Review of processes or methods
```

## Timeline File Structure

### File Naming Convention

- Format: `prefix-{YYYYMMDDhhmmss}.md`

### Timeline File Content Structure

```md
---
title: Theme Name Timeline
description: Brief description of the theme's background and purpose
date: 1745972571  # File creation time in epoch time seconds
lastmod: 1746577200  # Last modified time in epoch time seconds
expiryDate: 1747182000 # One week after lastmod in epoch time seconds
draft: false
tags: []
categories:
  - project
---

## 背景

Describe the purpose and background of this theme.

## 開発ストーリー

### フェーズ名1（期間）

- YYYY-MM-DD [Specific Action or Achievement](basename)
  - Detailed description of this action
  - Results or learnings obtained
- YYYY-MM-DD [Specific Action or Achievement](basename)
  - Detailed description of this action
  - Results or learnings obtained

### フェーズ名2（期間）

- YYYY-MM-DD [Specific Action or Achievement](basename)
  - Detailed description of this action
  - Results or learnings obtained


## 関連する単発活動

- YYYY-MM-DD [One-off Task](basename): Brief description
- YYYY-MM-DD [Research / Information Gathering](basename): Brief description

## 成果・学び

- 主要な成果物や習得したスキル
- 重要な発見や気づき
- 今後に活かせる知見
```

## Detailed Guidelines for Conversion

1. Identify the themes.
2. Check the existing theme index file.
3. Determine whether each identified theme matches any in the existing theme index file.
4. If matched, append to the existing theme file.
5. If not matched, create a new theme file.

### How to Identify Themes

- Learning Themes: Acquiring new technologies, understanding frameworks, finishing books, etc.
- Development Themes: Implementing specific projects, creating tools, setting up environments, etc.
- Improvement Themes: Refactoring, optimization, process improvement, etc.
- Research Themes: Investigating specific fields, comparative studies, information gathering, etc.

### Key Points for Extracting Achievements

- Concrete Deliverables: Code, documentation, articles, presentation materials, etc.
- Skills & Knowledge: Newly acquired technologies or concepts
- Problem Solving: Issues resolved or challenges overcome
- Process Improvement: Efficiency gains or workflow enhancements

### Prioritization of Information

- Highest Priority: Ongoing activities related to themes
- High Priority: Important achievements or learnings
- Medium Priority: Related research or preparatory work
- Low Priority: One-off tasks or routine work

## Notes for Conversion

- Information Preservation: Migrate all information from the original memo to the new structure without omissions
- Chronological Order: Maintain the original chronological order of memos
- Link Preservation: Keep links in the `[Title](filename)` format as is
- Ensure Specificity: Each category summary should include concrete and useful information
- Consistency: Retain original date formats and notation

## Updating the Theme Index Master File

### Purpose of the File

Create an integrated index file for unified management and tracking of all themes.

### Theme Index File Update Rules

- When Adding a New Theme:
  - Add themes identified as "Newly Started Themes" in the monthly memo
  - Categorize and place them appropriately
- When Completing a Theme:
  - Move to the "Completed Themes" section
  - Record achievements and learnings
- Status Updates:
  - Adjust the status of ongoing themes according to activity
  - If there has been no activity for a long period, change status to "Paused"
