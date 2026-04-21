# PR Slack: Format a review request for Slack

## Command Usage
`/user:pr-slack [pr_number_or_url]`

## Purpose
Formats a Slack message requesting PR review in Bruno's standard format, then copies it to the clipboard via `pbcopy`. Asks Bruno for the 2-sentence description before copying.

## Output format
```
:github: *[TICKET-CODE] PR title*
:pr-arrow: <pr url>

<2 sentences from Bruno>
```

If there's no Linear ticket, use `NO-TICKET` instead of the ticket code.

## Instructions for Claude

### Step 1: Resolve the PR

If the argument is a full URL, extract the PR number from it. If it's just a number, use it directly. If no argument is provided, check if the current branch has an open PR via `gh pr view --json number,title,url`.

Use `gh pr view <number> --repo monzo/analytics --json title,url,headRefName` to get the PR details.

### Step 2: Extract the Linear ticket code

Look for a Linear ticket pattern (e.g. `DAT-1234`, `DEVEL-567`) in:
1. The PR title first
2. The branch name second

The pattern is: 1-5 uppercase letters, a hyphen, then 1-5 digits (e.g. `DAT-2504`, `DEVEL-2732`, `OPS2-246`).

If no ticket is found, use `NO-TICKET`.

### Step 3: Determine the title

Use the PR title. If the title starts with the ticket code (e.g. "DAT-2504: Some title"), strip the ticket prefix and colon/space so it's not duplicated. The ticket code goes in the square brackets, the title goes after.

### Step 4: Ask Bruno for the description

Use AskUserQuestion to ask Bruno to write the 2-sentence description. Show a preview of the first two lines so he knows the context. Tell him to just write the sentences, nothing else.

### Step 5: Assemble and copy

Format the full message and pipe it to `pbcopy`. Confirm it's in the clipboard.

Do NOT use echo with the pipe. Use printf to avoid issues with special characters.
