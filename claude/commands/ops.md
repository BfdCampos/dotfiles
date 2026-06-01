# Ops: Command Centre

## Command Usage
`/ops [subcommand] [args]`

## Purpose
Persistent task management command centre. Triage incoming work, challenge assumptions, build actionable plans, and dispatch tasks to subagents with clear prompts.

## Architecture

Two systems work together:

1. **Obsidian kanban** (`~/personal_projects/Journal/📋 Tasks.md`) is the source of truth for what tasks exist, their status, and their priority. This is the user's visual board.
2. **Agent memory** (`~/.claude/command-centre/`) stores what the agent needs across conversations: triage transcripts, dispatch prompts, and an activity log. This is NOT the task board.

### Obsidian kanban format

The kanban uses the Obsidian kanban plugin. File structure:

```markdown
---

kanban-plugin: board

---

## 📥 Backlog

- [ ] 🟠 Task title here
- [ ] 🔴 [Linked task](https://notion.so/...)

## 📝 Todo

- [ ] 🔴 Task with sub-tasks:
	- [ ] 🟠 Sub-task one
	- [x] 🔴 Completed sub-task

## 🚧 In Progress

- [ ] 🟢 Active task

## ✅ Done

**Complete**
- [x] 🟢 Finished task
- [x] 🟠 Another finished task


%% kanban:settings
{"kanban-plugin":"board","list-collapse":[false,false,false,false]}
%%
```

Key rules for the kanban file:
- Columns are `## 📥 Backlog`, `## 📝 Todo`, `## 🚧 In Progress`, `## ✅ Done`
- Each task is a `- [ ]` checkbox (or `- [x]` if done)
- Priority emoji comes first: 🔴 (critical/high), 🟠 (medium), 🟢 (low)
- Sub-tasks are indented with a tab under their parent
- Links can be `[text](url)` for external resources or `[[wiki-link]]` for Obsidian pages/people
- Done items use `- [x]` and go under the `**Complete**` line
- The `%% kanban:settings ... %%` block at the end must never be touched
- Two blank lines before the settings block

### Obsidian task pages

Each kanban card can have a corresponding Obsidian page in the Journal folder. The page filename is the card text (including the priority emoji), e.g.:

Card: `- [ ] 🔴 Write blog post on the role of the human`
Page: `~/personal_projects/Journal/🔴 Write blog post on the role of the human.md`

These pages are where the user writes detailed notes, context, brainstorming, and links. Not every task has a page, but when one exists, READ IT during triage as it contains the user's thinking.

### Agent memory layout

```
~/.claude/command-centre/
├── log.md             # Chronological activity log
└── tasks/
    └── {slug}.md      # Triage notes, dispatch prompts, decisions
```

No INDEX.md. The kanban IS the index.

## Instructions for Claude

### On every invocation

1. Read `~/personal_projects/Journal/📋 Tasks.md` (the kanban board)
2. Read the last 50 lines of `~/.claude/command-centre/log.md`
3. Route to the correct subcommand based on `$ARGUMENTS` and context

If `~/.claude/command-centre/` doesn't exist yet, create it along with `tasks/` and an empty `log.md`.

### Routing

| Input | Action |
|-------|--------|
| No args | Show the board |
| `board` | Show the board |
| `new` or free text / image / Linear link | Start triaging a new task |
| A known task slug (e.g. `ops fix-auth-middleware`) | Open that task |
| `dispatch <slug>` | Generate the dispatch prompt |
| `done <slug>` | Mark task complete |
| `drop <slug>` | Remove a task |
| `triage <slug>` | Continue triaging an existing task |

If the user typed `/ops` and provides input in the same message (text, bullet points, an image, a Linear issue link), treat it as a new task intake.

---

## Subcommand: Board

Parse the kanban file and display the current state. Group tasks by column in this order:

1. In Progress
2. Todo
3. Backlog

For each task, show: the title, priority (from emoji), and any links or sub-task summary.

Cross-reference with `~/.claude/command-centre/tasks/` to note which tasks have dispatch prompts ready.

After showing the board, suggest actions based on state (e.g. "2 backlog items need triaging" or "data-day-prep has a dispatch prompt ready").

Also show the 3 most recently completed tasks from the Done column.

---

## Subcommand: New Task (Triage)

The core workflow. Turn vague input into a crisp, dispatchable task.

### Phase 1: Capture

Accept the input (text, bullets, image, Linear link). If it's a Linear link, use the Linear MCP tools to fetch the issue details. If it's an image, describe what you see.

Add the task to the kanban file in the `📥 Backlog` column with an appropriate priority emoji. Use the card text as a short title.

Create a task file at `~/.claude/command-centre/tasks/{slug}.md` to hold triage details.

Check if an Obsidian page exists for this task in `~/personal_projects/Journal/`. If so, read it for existing context.

Log: `{timestamp} | created | {slug} | Captured from {source type}`

### Phase 2: Triage Interview

Ask questions using AskUserQuestion where practical (for structured choices) and plain text for open-ended ones. The triage is a conversation, not a form. Be curious, be challenging, be helpful.

Work through these areas, adapting to what's relevant. Don't ask all of these robotically. Read the input, figure out what's unclear, and ask the RIGHT questions:

**Understanding the task:**
- What exactly needs to happen? (if the input is vague)
- What does "done" look like? What's the acceptance criteria?
- Is there a specific approach in mind, or is that open?
- What repo/project/area does this live in?
- Are there related files, docs, or context the agent will need?

**Challenging urgency and priority:**
- When does this need to be done by?
- Is that deadline hard or soft? What happens if it slips?
- Who set the deadline? Is it externally driven (customer, regulation, launch) or internally driven (sprint, preference)?
- What happens if we just... don't do this? What breaks?
- Is something else more important right now? (reference other active tasks from the board)
- Could this be smaller? What's the minimum viable version?

**Dependencies and risks:**
- Does this block anyone else?
- Does this depend on anything that isn't ready yet?
- Are there other people who need to review, approve, or be consulted?
- What could go wrong? What's the riskiest part?

**Context for dispatch:**
- What does a fresh agent need to know that isn't in the code?
- Any decisions already made that the agent shouldn't re-litigate?
- Any gotchas, tribal knowledge, or "don't touch X" warnings?
- Should the agent check in at certain points, or just go?

After each answer, update the task file with the new information. Don't wait until the end.

### Phase 3: Prioritise

Based on the triage answers, assign:

**Priority** (use this framework):
- `p0-critical` / 🔴: Blocking others, hard deadline within 24h, or production issue
- `p1-high` / 🔴: Hard deadline within the week, or high-impact work
- `p2-medium` / 🟠: Soft deadline, important but not urgent
- `p3-low` / 🟢: Nice to have, no deadline, do when there's space

**Deadline**: actual date if there is one, otherwise none
**Deadline type**: `hard` (real external consequence), `soft` (internal preference), or `none`

Present your assessment to the user and let them override. Challenge gently if everything is P0 ("If everything is critical, nothing is. Which of these would you actually drop if you had to?").

Update the priority emoji on the kanban card if it changed.

### Phase 4: Plan

Write a numbered plan of what the agent will do. Keep it concrete:
- Which files to read first
- What to change and why
- How to verify the change works
- What NOT to do (scope boundaries)

### Phase 5: Build Dispatch Prompt

Write a self-contained prompt that can be copy-pasted to a fresh agent (or sent via the Agent tool). This prompt must include:

1. A clear statement of the task and why it matters
2. All context, decisions, and constraints from the triage
3. The plan (numbered steps)
4. Files to read first
5. Definition of done
6. Scope boundaries (what NOT to do)
7. Whether to check in or just complete autonomously

The prompt should be written as if briefing a smart colleague who just walked into the room. No references to "the triage" or "as discussed". Everything self-contained.

Move the kanban card from Backlog to `📝 Todo` (it's ready to be worked on).

Log: `{timestamp} | ready | {slug} | Triage complete, dispatch prompt built`

---

## Subcommand: Dispatch

Read the task file for the given slug. Show the dispatch prompt to the user.

Ask: "Want me to send this to an agent now, or do you want to copy it yourself?"

If the user says go:
- Use the Agent tool to spawn a subagent with the dispatch prompt
- Move the kanban card to `🚧 In Progress`
- Log: `{timestamp} | dispatched | {slug} | Sent to subagent`

If the user wants to copy it:
- Display the prompt cleanly
- Move the kanban card to `🚧 In Progress`
- Log: `{timestamp} | dispatched | {slug} | User taking manual dispatch`

---

## Subcommand: Done

Mark a task as complete. Ask the user for a brief outcome note.

In the kanban:
- Remove the card from its current column
- Add it to the `✅ Done` column as `- [x] {emoji} {title}` under the `**Complete**` line

Log: `{timestamp} | done | {slug} | {outcome note}`

---

## Subcommand: Drop

Remove a task. Ask for confirmation.

Remove the card from the kanban entirely. Note the drop in the task file with a reason.

Log: `{timestamp} | dropped | {slug} | {reason}`

---

## Subcommand: Open Task

Find the task in the kanban. Read the corresponding task file from `~/.claude/command-centre/tasks/` if one exists. Also check for an Obsidian page in the Journal folder and read it if present.

Show the current status and offer relevant actions:

- Backlog with no task file: "This needs triaging. Want to go through the questions?"
- Backlog with a task file: "This has some triage notes. Want to continue or build a dispatch prompt?"
- Todo: "This has a dispatch prompt ready. Want to dispatch it?"
- In Progress: "This is being worked on. Any updates?"
- Done: Show the outcome note.

---

## Task File Format

```markdown
---
title: Human readable title
slug: kebab-case-slug
priority: p0-critical | p1-high | p2-medium | p3-low
deadline: YYYY-MM-DD or none
deadline_type: hard | soft | none
deadline_reason: Why the deadline exists
created: YYYY-MM-DD HH:MM
updated: YYYY-MM-DD HH:MM
source: text | linear | image | notion | slack
linear_id: LINEAR-123 (if applicable)
obsidian_page: filename.md (if an Obsidian page exists for this task)
---

# {Title}

## Context
Why this task exists, what prompted it. Raw input preserved here.

## Triage
Q&A from the triage interview. Structured as the conversation flowed.

## Priority Rationale
Why this priority and deadline. What happens if it slips.

## Plan
1. Step one
2. Step two
3. ...

## Dispatch Prompt

Self-contained prompt for a fresh agent. Everything needed is here.

## Scope Boundaries
What the agent should NOT do. Explicit exclusions.

## History
- YYYY-MM-DD HH:MM: Created from {source}
- YYYY-MM-DD HH:MM: Triaged, set to {priority}
- YYYY-MM-DD HH:MM: Dispatch prompt built
- YYYY-MM-DD HH:MM: Dispatched to agent
- YYYY-MM-DD HH:MM: Completed - {outcome}
```

---

## Log Format

Append-only in `~/.claude/command-centre/log.md`. One line per event.

```
YYYY-MM-DD HH:MM | {action} | {slug} | {details}
```

Actions: `created`, `triaged`, `ready`, `dispatched`, `done`, `dropped`, `updated`, `blocked`, `unblocked`

---

## Behaviour Guidelines

- Be opinionated. If the user says "everything is urgent", push back. Help them actually prioritise.
- Be curious. The best triage comes from understanding WHY, not just WHAT.
- Be practical. Don't over-process small tasks. A quick fix doesn't need 10 triage questions.
- Scale the triage to the task size. A one-liner config change gets a light triage. A multi-day refactor gets the full treatment.
- When editing the kanban file, make targeted edits. Don't rewrite the whole file.
- Preserve existing links (Notion, Slack, wiki-links) and sub-tasks in the kanban.
- When showing the board, be concise. The user wants a glance, not a report.
- When building dispatch prompts, be thorough. The receiving agent has zero context.
- Reference other tasks when relevant ("this is similar to the auth-migration you did last week").
- Use the current date/time from bash, never assume.
- Keep the log concise. One line per event. It's for quick scanning, not narrative.
- Always check for an Obsidian page before triaging. The user's notes are gold.
