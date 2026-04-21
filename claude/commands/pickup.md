# Pickup: Resume work from a handoff

## Command Usage
`/user:pickup [search_terms]`

## Purpose
Finds and loads a previous handoff document so you can continue where a previous agent left off.

## Instructions for Claude

### Step 1: Find the handoff

The argument `$ARGUMENTS` contains search terms (e.g. "data standards exceptions", "model migration").

**If search terms are provided:**

1. First, try to match against folder names in `~/.claude/handoffs/` recursively:
   ```bash
   find ~/.claude/handoffs/ -type d -maxdepth 4
   ```

2. Look for folder names that fuzzy-match the search terms. If there's a clear match, list the handoff files in that folder (there may be multiple timestamps, take the most recent).

3. If no folder match, search inside handoff files for the terms:
   ```bash
   grep -rl "search terms" ~/.claude/handoffs/ 2>/dev/null
   ```

**If no search terms are provided, or no match found:**

1. List all available handoffs grouped by repo:
   ```bash
   find ~/.claude/handoffs/ -name "*.md" -type f | sort
   ```

2. Use AskUserQuestion to present the options, grouped by repo. Format like:
   ```
   I found these handoffs:

   monzo/analytics:
     - data_standards_exceptions (latest: 20260313_100108)
     - model_migration (latest: 20260312_143022)

   monzo/wearemonzo:
     - blog_redesign (latest: 20260310_091500)

   Which one would you like to pick up?
   ```

### Step 2: Read the handoff

Once you've identified the correct handoff file, read it completely.

### Step 3: Read the context files

The handoff has a "Context a new agent should read first" section. Read every file listed there, in order. These are essential for understanding the project.

### Step 4: Confirm and orient

Tell the user:
- What project you've picked up
- When the handoff was created
- A brief summary of where things left off (2-3 sentences)
- What the next steps are
- Ask if anything has changed since the handoff was written

If the handoff contains a session ID (in the "Previous session" line), also tell the user:
> If you'd rather continue the exact conversation instead of starting fresh with a new agent, run: `claude --resume <session_id>`

**Do NOT start doing work yet.** Wait for the user to confirm or update you on what's changed.
