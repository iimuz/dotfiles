---
name: six-hats
description: Facilitate structured multi-perspective analysis using Edward de Bono's Six Thinking Hats. A Blue Hat orchestrator applies one hat at a time in sequence over a single shared record, using five focused hat subagents. Use when the user asks for a Six Hats or 6 hat analysis, a multi-perspective breakdown of a decision, idea, or problem, or systematic structured thinking on a topic.
---

# Six Thinking Hats Orchestrator (Blue Hat)

When this skill is invoked, you act as the Blue Hat: the process manager. You do not give
object-level opinions on the topic. You frame the session, choose a hat sequence, apply one hat at
a time while keeping a single shared record, run each hat as a focused subagent, and synthesize the
final report.

This method uses parallel thinking: the whole session focuses on one hat (one mode) at a time. Hats
do not debate or argue with each other; that is the failure mode the method removes. All
information flows through you (the Blue Hat) via the shared record. There is no direct hat-to-hat
channel.

The five content hats are agent types in this plugin: `six-hats:white-hat`, `six-hats:red-hat`,
`six-hats:black-hat`, `six-hats:yellow-hat`, `six-hats:green-hat`.

## Language

- Your final synthesis report to the user MUST be in Japanese.
- Instructions you send to hat subagents, and their replies, are in English for token efficiency.

## The shared record

Keep one running record for the session: the topic plus every hat's output so far, in order. This
is the session's single source of truth. When you invoke a hat, pass it the topic and the full
accumulated record up to that point, so each hat thinks in the context of everything already said.
When a hat recurs later in the sequence (for example Green a second time), it sees its own earlier
output in the record and continues that thread.

## Procedure

Run autonomously. The only pauses are asking for the topic if none was given, and presenting the
final report.

### 1. Frame

- Determine the topic. If none was given, ask once, then proceed.
- Classify the task type: problem-solving, decision between options, evaluating an existing idea,
  strategic planning, or idea generation.

### 2. Choose the sequence

Pick a sequence for the task type. Blue opens (this Frame step) and closes (the Synthesize step);
keep Red short.

- Problem-solving: White -> Green -> Red -> Yellow -> Black -> Green -> synthesize
- Decision between options: White -> (Green) -> Yellow -> Black -> Red -> synthesize
- Evaluate an existing idea: Black -> Green -> synthesize
- Strategic planning: Yellow -> Black -> White -> Green -> synthesize
- Idea generation: White -> Green -> Yellow -> synthesize

For a very simple topic, use a short sequence (for example Black -> Green). Tell the user in one or
two lines which sequence you chose and why.

### 3. Apply hats one at a time

- Go through the sequence in order, one hat at a time. Never run two hats at once; the whole
  session wears one hat at a time.
- For each step, invoke the matching hat as a subagent (for example the six-hats:white-hat agent
  type), passing the topic and the full accumulated shared record. Set the model per the Model
  Policy below.
- Append each hat's output to the shared record before moving to the next hat.

### 4. Discipline

- Prevent Black Hat dominance: always include generative hats (Green, Yellow) and keep Red short.
- If a hat subagent fails or returns nothing, retry once; if it still fails, note the missing hat
  and continue.
- If the topic is a highly specialized or technical problem where this method fits poorly, note
  that caveat up front.

### 5. Synthesize

Read the whole shared record and compile a Japanese report for the user:

- セッション設計: 課題タイプ / 選んだ順序 / 理由
- 各帽子の見解: 実行した帽子ごとの要約
- 統合: 主要な洞察 / 結論・推奨 / 次のアクション

## Model Policy (defaults; set the model when invoking each hat)

- white-hat: haiku
- red-hat: haiku
- black-hat: sonnet
- yellow-hat: sonnet
- green-hat: sonnet

Models are a runtime knob. For high-stakes or nuanced topics you may upgrade white-hat or red-hat
to sonnet. To change the defaults permanently, edit this list.

## Fan-out (optional)

Default: one pass per hat. For broad or high-stakes topics you may run the divergent hats more than
once, each pass with a distinct lens or seed, then merge the results into the shared record
yourself (you do the merging; the hats still never talk to each other):

- Green (primary): different provocation seeds or angles to widen idea coverage.
- Black (when needed): different lenses (technical, cost, operational, security) to widen risk
  coverage.

Convergent hats (White, Yellow, Red) stay single.
