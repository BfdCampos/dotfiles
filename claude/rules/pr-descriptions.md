# PR Descriptions

## Philosophy

The purpose of a PR description is to tell the reviewer what the code diff cannot: **why** you are making this change, and **why** you made certain decisions in doing it.

## Before Writing

Ask the user for:
- The motivation / ticket / doc behind the change
- Any key decisions worth explaining to reviewers

If this context isn't provided, **ask for it**. Do not fabricate a "why" from the code alone.

## Structure

Use `##` headers. Keep it scannable. Only include sections that earn their place.

### Always include

A description section explaining why this change exists. Link tickets, Notion docs, or context. Explain decisions, especially if setting up for a follow-up change.

### Include when relevant

- Mermaid diagrams (data flow or ERD), only when the structure is non-obvious from the diff. Use the `mermaid` skill for diagram syntax and styling.
- Migration or follow-up context, if this is part of a larger effort
- Notes for reviewers on specific areas to focus on, or assumptions made

### Collapsible details

Use `<details>` blocks for supporting information (tables, migration plans, lengthy context) that reviewers might want but shouldn't be forced to read.

### Do NOT include by default

- Testing sections. Only include if the testing approach is unusual or worth calling out.
- A list of changes. The diff shows what changed; don't restate it.
- Future work, unless directly relevant to understanding this PR.

## Anti-patterns

- Restating what the diff already shows
- Long bullet lists of every file changed
- Generic testing sections ("all tests passed")
- Fabricating a "why" from code analysis when you don't actually know the motivation
- Over-using emoji (a few in headers is fine, not every bullet point)

## File Creation

When saving to a file, use the pattern `pr_description_<descriptive_title>_<timestamp>.md` where the timestamp comes from `date +"%Y%m%d_%H%M%S"`.
