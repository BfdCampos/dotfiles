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

