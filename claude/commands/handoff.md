# Handoff: Summarise work for a future agent

## Command Usage
`/user:handoff [project_name]`

## Purpose
Creates a timestamped handoff document that captures everything a future agent needs to pick up this work. Stored in `~/.claude/handoffs/` with a folder structure derived from the current repository.

## Instructions for Claude

### Step 1: Get the current session ID

Run this to get the current Claude Code session ID so the receiving agent can access the raw conversation history:

```bash
# Build the project directory name from pwd
PROJECT_DIR=$(echo "$PWD" | sed 's|/|-|g; s|\.|-|g')
# Find the most recently modified session file
SESSION_ID=$(ls -t ~/.claude/projects/${PROJECT_DIR}/*.jsonl 2>/dev/null | head -1 | xargs basename 2>/dev/null | sed 's/\.jsonl$//')
echo "$SESSION_ID"
```

If this fails (e.g. not in a project context), set `SESSION_ID` to empty and skip the session line in the handoff.

### Step 2: Determine the project name

The argument `$ARGUMENTS` is the project name (snake_case).

- If provided, use it directly (convert to snake_case if needed)
- If not provided, use AskUserQuestion to ask: "What should I call this handoff? Give me a short project name (e.g. data_standards_exceptions, model_migration, test_fixes)"

### Step 3: Determine the repository context

Run these commands to build the folder path:

```bash
# Get the repo root and extract org/repo
git -C "$(pwd)" remote get-url origin 2>/dev/null | sed 's/.*[:/]\([^/]*\/[^/]*\)\.git/\1/' | sed 's/.*[:/]\([^/]*\/[^/]*\)$/\1/'
```

This gives you something like `monzo/analytics`. Use this to build the storage path.

If not in a git repo, use `no-repo` as the path segment.

### Step 4: Get the timestamp

```bash
date +"%Y%m%d_%H%M%S"
```

### Step 5: Build the file path

The handoff goes to:
```
~/.claude/handoffs/{org}/{repo}/{project_name}/{timestamp}.md
```

Example: `~/.claude/handoffs/monzo/analytics/data_standards_exceptions/20260313_100108.md`

Create any missing directories.

### Step 6: Write the handoff

Review the ENTIRE conversation. Then write a handoff document with this structure:

```markdown
# Handoff: {Project Name (human readable)}

> **Previous session**: `claude --resume {SESSION_ID}`
> Use this to access the full raw conversation history if you need more context than this handoff provides.

**Created**: {timestamp}
**Repository**: {org/repo}
**Working directory**: {pwd}
**Branch**: {current git branch}

## What we're doing

One paragraph. What is the project, what is the goal.

## Where we got to

What's been completed. What state things are in right now. Be specific about files created, pages built, things deployed.

## Key decisions made

Bullet list. Each decision: what was decided, why, and what was rejected. These are the things a new agent MUST know to avoid re-litigating.

## Files that matter

List every file relevant to the project with a one-line description of what it is and whether it's current or outdated.

## Feedback received

Any feedback from team members, stakeholders, reviewers. Who said what, and what was done about it.

## What's left to do

Numbered list of remaining work, in priority order.

## Open questions

Anything unresolved that needs the user's input or team discussion.

## Context a new agent should read first

List of files the new agent should read before doing anything, in order. Be specific with full paths.
```

**Critical rules for writing the handoff:**
- Be comprehensive but concise. A new agent reading this should understand everything without reading the full conversation.
- Emphasise DECISIONS. The reasoning behind choices is the hardest thing to reconstruct.
- Include rejected alternatives for major decisions (e.g. "we chose X over Y because Z").
- Use full file paths, never relative.
- Don't be vague. "We updated the page" is useless. "We added a green Notion callout with a toggle at the top of the partitioning standard page" is useful.

### Step 7: Confirm

Tell the user the handoff was written and give them the full path. Mention the key sections so they can verify nothing was missed.
