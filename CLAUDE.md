# Response style for Claude

- Always follow BESA (British English Spelling Always).
- Exceptions to BESA are allowed for proper nouns, acronyms, and specific terms.
- Exceptions are also allowed for coding languages and general code since syntax is often standardised in American English.
- Use British English spelling for all other words, specifically for documentation, README files, comments in code, user facing text, and any other text outputted that is not code.
- NEVER use em-dashes (—) anywhere. Use commas, full stops, colons, or restructure the sentence instead.
- NEVER use the bold-keyword-dash pattern in lists (e.g. `- **Word** — explanation`). Just write plain list items. If a list item needs a label, use a sub-header or a colon without bolding.
- NEVER assume the time or date. Always use bash commands to get the current time or date if needed. E.g. `date +"%Y-%m-%d %H:%M:%S"` to get the current date and time.
- ALWAYS use bash commands to do mathematical calculations. EVEN for simple calculations. E.g. `echo "5 + 3" | bc` to get the result of 5 + 3. USE this for ALL calculations without exception.

> [!NOTE]
> Each repo may have its own standards. Make sure to read the repo's standards and IFF there is a conflict between the instructions above and the repo standards, first inform the user of the standards for the repo and tell them how to proceed. Whatever the answer is, include this in the local CLAUDE.md file for the project.

## Important Working Philosophy

**ALWAYS READ and UNDERSTAND context first** - Do not use bash commands to automate reading and substituting things. The user can write bash scripts themselves. I am here to:

- READ files and understand their context
- ANALYSE what needs to be changed and why
- PROVIDE thoughtful edits based on understanding
- EXPLAIN the reasoning behind changes

**NEVER automate with bash what should be done with understanding:**

- ❌ WRONG: `find . -name "*.yml" -exec sed -i 's/old/new/g' {} \;`
- ✅ CORRECT: Read specific files, understand their purpose, make targeted edits with explanations

## Shell Command Notes

**NEVER use `cd` commands** - The user has a zoxide alias that will cause errors. Instead:

- Always use absolute paths when running commands
- Use `--directory` flags where available (e.g., with `uv`)
- Specify full paths to files and directories

## BigQuery CLI Usage

When querying BigQuery data, use the `bigquery` skill for command patterns and data sensitivity guidelines.

## Claude Skills Management

Skills are stored in `~/dotfiles/claude/skills/` and symlinked to `~/.claude/skills/`. Rules (auto-loaded guidelines) are stored in `~/dotfiles/claude/rules/` and symlinked to `~/.claude/rules/`. This keeps them version-controlled and portable.

**Adding a new skill:**
1. Create the skill in `~/.claude/skills/<skill-name>/SKILL.md` (Claude Code creates it here)
2. Copy the skill to dotfiles: `mkdir -p ~/dotfiles/claude/skills/<skill-name>` then copy the SKILL.md
3. Verify files match: `diff ~/.claude/skills/<skill-name>/SKILL.md ~/dotfiles/claude/skills/<skill-name>/SKILL.md`
4. Replace with symlink: `ln -sf ~/dotfiles/claude/skills/<skill-name>/SKILL.md ~/.claude/skills/<skill-name>/SKILL.md`
5. Add entry to `config/dotfiles.yaml` under the `symlinks:` section:
   ```yaml
   - source: claude/skills/<skill-name>/SKILL.md
     destination: ~/.claude/skills/<skill-name>/SKILL.md
     description: "<skill description>"
     create_parent: true
   ```

**On a new machine:** Run `python setup.py` to create all symlinks from dotfiles.

## Voice Profile

A writing voice profile lives at `~/.claude/rules/voice.md`. Use it when drafting anything on Bruno's behalf (Slack messages, docs, proposals, PR descriptions, emails, tickets). Do NOT apply it to normal working conversation.

Actively maintain this profile:
- After direct feedback on tone ("too formal", "that doesn't sound like me", "more casual"), immediately update `~/.claude/rules/voice.md` with the specific correction.
- When Bruno accepts a drafted piece without pushback, especially if the tone was a judgement call, note what worked.
- If you notice new patterns in how Bruno writes (from his messages, his edits to your drafts, or his phrasing preferences), add them to the voice profile. Don't wait to be asked.

A capture script at `~/.claude/scripts/capture_voice.py` can analyse session logs for voice patterns. It outputs a statistical report of writing habits.

## Learning Mode

**Learning mode is NOT the default.** Only enter learning mode when:
- Bruno explicitly says "learning mode" or "I want to learn this"
- You ask and Bruno confirms

**When in learning mode:**
- Show examples first, then let Bruno ask questions
- Explain the "why" and fundamentals, not just the "how"
- Use concrete examples over abstract explanations
- Connect new concepts to existing knowledge (check `~/.claude/knowledge/`)
- Let Bruno type things himself - guide, don't do
- Show what's happening under the hood when relevant
- Be patient with lots of questions - that's the process

**When NOT in learning mode:**
- Just do the task efficiently as normal
- Don't over-explain unless asked

## Knowledge Base System

Bruno's knowledge is tracked in `~/.claude/knowledge/` with flat markdown files:
- `languages.md` - Programming languages (confidence levels, what he knows)
- `tools-and-systems.md` - Tools, CLIs, platforms
- `concepts.md` - CS concepts, patterns, fundamentals

**How to use:**
- Check relevant files when teaching to leverage existing knowledge
- Use known concepts as bridges to explain new ones
- Skip basics Bruno is confident in

**How to update:**
- When you notice Bruno is confident in something new, add it
- When a good analogy clicks, note it for future use
- Keep entries SHORT - bullet points only, not prose
- Use confidence levels: `confident`, `learning`, `heard of`
- Don't update every session - only meaningful additions

## Worktree Workspace Workflow

**ALWAYS work in a worktree when making file changes that will be committed.** The main repo checkout is for read-only context, exploration, and conversation only. Before creating or editing any files intended for a commit, find an available worktree workspace and work there. This applies to ALL repos, not just analytics.

Skip this only when the user explicitly says to work in the main repo.

Do NOT use Claude Code's built-in `EnterWorktree`/`ExitWorktree` tools. Those create session-scoped worktrees in `.claude/worktrees/` with random names. We manage our own persistent workspaces instead.

### Naming convention

Worktrees live as sibling directories of the main repo, named `{repo}-a`, `{repo}-b`, ..., `{repo}-z`. If all 26 are taken, continue with `{repo}-alpha`, `{repo}-beta`, `{repo}-gamma`, `{repo}-delta`, etc.

Example for a repo at `/path/to/analytics`:
- `/path/to/analytics-a`
- `/path/to/analytics-b`
- etc.

### Parking branches and availability detection

Each workspace has a **parking branch** named `_park/{repo}-{letter}`. This is purely a marker for availability.

A workspace is **free** if:
- It is on its `_park/` branch
- Its working tree is clean

A workspace is **in use** if:
- It is on any other branch, OR
- It has uncommitted changes

Legacy worktrees without parking branches should be treated as in use.

### At the start of a task requiring changes

1. List existing worktrees: `git worktree list`
2. For each worktree, check if it's free (on a `_park/` branch with clean tree)
3. If one is free, claim it:
   ```bash
   git -C /path/to/workspace fetch origin master
   git -C /path/to/workspace reset --hard origin/master
   git -C /path/to/workspace checkout -b feature-branch-name
   ```
4. If none are free, create the next one in the naming sequence:
   ```bash
   git worktree add /path/to/{repo}-{next-letter} -b _park/{repo}-{next-letter} origin/master
   git -C /path/to/{repo}-{next-letter} checkout -b feature-branch-name
   ```
5. Use **absolute paths** to the worktree for ALL file operations (Read, Write, Edit, Bash, etc.)

### Releasing a workspace

When the user says work is done (PR merged, branch no longer needed):
```bash
git -C /path/to/workspace checkout _park/{repo}-{letter}
git -C /path/to/workspace reset --hard origin/master
git -C /path/to/workspace clean -fd
```

Do NOT release automatically. Only release when the user explicitly asks.

### Key rules

- NEVER commit to the main repo checkout directly
- Use `git -C /path/to/worktree` for all git commands (consistent with the no-cd rule)
- Use absolute paths to the worktree for all file tool operations
- One task per worktree at a time
- Always check for free worktrees before creating new ones
- Multiple branches may be used in a single worktree over time, that is fine

## Legacy Memory

Before Claude Code had native auto-memory, we used a custom memory system at `~/personal_projects/claude-memory/`. That project is now retired, but some older memories and context may still live there if you need to reference them.

