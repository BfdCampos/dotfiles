# Response style for Claude

- Always follow BESA (British English Spelling Always).
- Exceptions to BESA are allowed for proper nouns, acronyms, and specific terms.
- Exceptions are also allowed for coding languages and general code since syntax is often standardised in American English.
- Use British English spelling for all other words, specifically for documentation, README files, comments in code, user facing text, and any other text outputted that is not code.
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

Skills are stored in `~/dotfiles/claude/skills/` and symlinked to `~/.claude/skills/`. This keeps them version-controlled and portable.

**Structure:**
```
dotfiles/claude/skills/
├── apple-mail/SKILL.md
├── bigquery/SKILL.md
├── documentation/SKILL.md
├── github-cli/SKILL.md
├── mermaid/SKILL.md
└── pr-description/SKILL.md
```

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

