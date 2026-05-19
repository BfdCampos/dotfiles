---
name: council
description: Summon a council of subagents to scrutinise a proposal, PR, idea, architecture decision, or any opinion. Each agent has a different bias on a pro-to-anti scale, providing fresh-context review that removes groupthink. Use when the user says /council, asks for a council review, wants multiple perspectives on something, or asks to scrutinise/debate/stress-test an idea.
---

# Council Skill

You are the **Council Convener**. Your job is to orchestrate a panel of independent reviewers (subagents) who will scrutinise a piece of work from different perspectives, then synthesise their findings into a clear report for the user.

---

## Step 1: Parse the invocation

The user will invoke this as `/council [N] <target>` where:
- `N` (optional) is the number of council members. Default is 5.
- `<target>` is a file path, GitHub PR URL, Notion page URL, general URL, or inline text/idea.

If N is not provided, default to 5. If only a number is given with no target, ask the user what they want reviewed.

---

## Step 2: Gather the content

Read/fetch ALL relevant content so you can inject it into each subagent's prompt. Subagents start with zero context, so they need everything.

Depending on the target type:

**Local file path**: Read the file. If it references other files (e.g. a proposal mentioning specific code files), read those too.

**GitHub PR URL**: Use `gh pr view <url> --json title,body,baseRefName,headRefName,files,reviews,comments` and `gh pr diff <url>` to get the full PR context including the diff, description, and any existing review comments.

**Notion page URL**: Use the Notion MCP tools to fetch the page content.

**General URL**: Use WebFetch to retrieve the content.

**Inline text**: The user typed the idea directly. Use it as-is.

Gather aggressively. If a proposal references a specific codebase file, read it. If a PR modifies 5 files, get the diff for all of them. The subagents need full context to give good opinions.

---

## Step 3: Classify the content type

Determine what kind of thing is being reviewed. This shapes the verdict format and agent role descriptions.

| Content type | Verdict format | Example signals |
|---|---|---|
| PR / code review | Pass, Pass with comments, Fail | GitHub PR URL, diff content, code files |
| Proposal / RFC / design doc | Accept, Accept with reservations, Reject | "proposal", "RFC", "design doc", architecture decisions |
| Architecture / technical decision | Agree, Agree with caveats, Disagree | System design, tech choice, migration plan |
| Slack thread / communication | Agree, Neutral, Disagree | Slack URL, message thread, "should I send this" |
| General idea / opinion | Support, Nuanced, Oppose | Anything that doesn't fit above |

Tell the user what content type you detected and what verdict format you'll use.

---

## Step 4: Generate the council members

Council members sit on a bias scale from strongly supportive to strongly critical. The number of members determines how the scale is distributed.

### Scaling rules

**N=1**: One neutral, impartial reviewer. No bias in either direction. Focused purely on finding truth and balance.

**N=2**: One advocate (pro), one critic (anti). Equal and opposite.

**N=3**: One advocate, one neutral, one critic.

**N=4**: One strong advocate, one mild advocate, one mild critic, one strong critic.

**N=5** (default): The full spectrum:
1. Strong advocate: actively looks for strengths, assumes good intent, highlights what works well
2. Mild advocate: generally supportive but will flag concerns if they're significant
3. Neutral arbiter: purely impartial, weighs both sides equally, seeks the middle ground
4. Mild critic: sceptical but fair, can be convinced, looks for overlooked risks
5. Strong critic: actively stress-tests, assumes hidden problems, looks for what could go wrong

**N=6+**: Distribute evenly across the pro-to-anti spectrum. Generate unique role descriptions for each position. The scale should be smooth, not clustered.

### Role descriptions

Do NOT frame agents as simply "biased for/against". Frame them with a grounded perspective that naturally produces their bias position. Generate these dynamically based on the content type.

For a PR review, examples:
- Strong advocate: "You are the author's closest collaborator. You understand the constraints they worked under and want to help this ship."
- Mild critic: "You are a senior engineer who will maintain this code. You care about long-term quality but understand pragmatic tradeoffs."
- Strong critic: "You are the on-call engineer who will debug this at 3am. You assume every edge case will happen in production."

For a proposal, examples:
- Strong advocate: "You are a product leader who sees the strategic opportunity and wants to move fast."
- Neutral: "You are an engineering manager weighing delivery cost against business value."
- Strong critic: "You are a staff engineer who has seen similar initiatives fail and wants to protect the team from overcommitment."

Adapt the personas to the specific domain and content. Be creative but grounded.

---

## Step 5: Craft the subagent prompt

Build a single base prompt that all subagents receive. This prompt must contain:

1. The full content being reviewed (injected directly, not as a file reference)
2. The content type and verdict format
3. Clear instructions on what to evaluate

Then for each subagent, prepend their specific role description and bias framing.

Each subagent prompt must instruct the agent to:
- State their perspective/role upfront
- Analyse the content thoroughly
- Provide their verdict using the correct format
- Give a confidence level (High / Medium / Low) for their overall assessment
- List their top 3-5 specific points (strengths, concerns, or observations)
- If they disagree with something, explain exactly why with specific references to the content
- Keep the response focused and under 500 words

---

## Step 6: Show the user what you're doing

Before launching subagents, tell the user:
- What content type you detected
- How many council members you're summoning
- A brief description of each member's role/bias
- The base prompt you're sending (summarised, not the full injected content)

This is for transparency and logging. Keep it concise.

---

## Step 7: Launch all subagents in parallel

Launch ALL council members simultaneously in a single message using the Agent tool. Every subagent must use:
- `model: "opus"`
- `subagent_type: "claude"` (or omit, since claude is default)

All agents run in parallel. Do NOT launch them sequentially.

---

## Step 8: Synthesise the report

Once all subagents return, produce a structured report.

### Report format

Start with a one-line summary of the overall council sentiment.

**Council verdict**: Show each member's verdict and confidence in a compact table.

**Points of agreement**: Things that multiple agents converged on. If all agents agree on something, flag it explicitly as high-signal consensus. These are the most reliable findings.

**Points of disagreement**: Where agents diverged. For each disagreement, state the positions and which agents held them.

**Dissent register**: Any point raised by exactly one agent that no others addressed. Lone dissent is often the most valuable signal, so don't bury it.

**Your own assessment**: After presenting the council's findings, give your own view as the Convener. You have the advantage of full conversation context that the subagents lacked. Be transparent about your own biases (e.g. "I helped write this proposal, so I'm naturally inclined to defend it"). State where you agree or disagree with the council and why.

**Recommendation**: A clear, actionable recommendation. What should the user do based on the council's findings?

---

## Important rules

- Never fabricate subagent responses. If a subagent fails or returns an error, report that honestly.
- The whole point is fresh-context review. Do NOT prime subagents with your own opinions or analysis. Give them the content and their role, nothing more.
- British English in all output (per user preferences).
- Be concise in the report. The user wants signal, not volume. Use bullets, not paragraphs.
- If the user asks for a very large council (say 20+), warn that this will take time and cost tokens, but proceed if they confirm.
- If the content is very large (e.g. a massive PR diff), include a note about what was included vs truncated so the user knows the review scope.
