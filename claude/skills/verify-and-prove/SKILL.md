---
name: verify-and-prove
description: Verify your own change actually works, then attach proof to the PR description (screenshot or short GIF for anything rendered, a real text capture for CLI output, an aggregate before/after table for data changes). Use when about to open or update a PR whose change has an outcome a reviewer could observe, for example rendered HTML, a web UI, a CLI's user-facing output, or dbt model results, or when the user says /verify-and-prove. Skip for refactors, renames, config, CI, docs, dependency bumps, Terraform, and anything where CI and the diff already show everything.
---

# Verify and prove

Before a PR goes up, check the change does what it claims, then put the evidence in the PR description so the reviewer sees the outcome without checking out the branch.

Verification comes first. Proof is the receipt of a check you actually ran, not a flattering capture. If the check fails, fix it or say so in the PR. Never hunt for an angle that looks right.

## 1. Pick the proof

| Change | Proof | Format |
| --- | --- | --- |
| Rendered HTML, report, visualisation, web UI | One or two screenshots. A GIF only when the interaction is the feature | PNG / GIF, published (step 4) |
| CLI or TUI output | The real command and its output | Fenced text block |
| dbt or data change | Before/after aggregates: row counts, distinct keys, null rates, key totals | Markdown table |
| Go service, eval harness, other backend | Test run, eval summary, or a trimmed request/response | Fenced text block |
| No observable outcome | Nothing | One line: "No observable change, proof skipped." |

Text beats images wherever text works: it's searchable, diffable and needs no hosting. Data proof is aggregates only, never row-level output or customer identifiers.

## 2. Capture (rendered changes)

One-time setup, if `node_modules` is missing:

```bash
npm install --prefix ~/.claude/skills/verify-and-prove
~/.claude/skills/verify-and-prove/node_modules/.bin/playwright install chromium
```

`bin/capture.mjs` runs one headless Chromium session through the steps you give it on the command line, then exits. Steps share one page, so a flow (type, wait, screenshot) works in a single call.

```bash
node ~/.claude/skills/verify-and-prove/bin/capture.mjs --out "$CLAUDE_JOB_DIR/tmp/proof" --video search --size 1000x600 \
  goto "file://$PWD/report.html" wait 400 shot before \
  fill '#q' test wait 600 shot filtered
```

Verbs: `goto <url>`, `click <sel>`, `fill <sel> <text>`, `press <key>`, `hover <sel>`, `wait <ms|sel>`, `shot <name>`, `fullshot <name>`. `--video <name>` records the whole run to `<name>.webm`. Use `$CLAUDE_JOB_DIR/tmp` when it's set, otherwise a temp dir. On a failed step it saves `failure.png` and exits 1.

`goto` only accepts `file://`, `localhost` and `127.0.0.1`. To reach anything else, pass `--allow-host <host>` explicitly. Never point it at production; local dev or staging (s101) only.

For a single static screenshot, typing Playwright directly is fine too: `npx playwright screenshot --viewport-size=1000,600 file://$PWD/report.html out.png`.

Turn a recording into a GIF as its own command (keep it under about 15 seconds and 5 MB):

```bash
ffmpeg -loglevel error -y -i search.webm -vf "fps=10,scale=800:-1:flags=lanczos,split[a][b];[a]palettegen[p];[b][p]paletteuse" search.gif
```

### Keep the helper honest

`capture.mjs` passes monzo-guard because every destination and action is on the command line where the auto mode classifier sees it, and the file holds no network client code. Keep it that way:

- Don't add an `evaluate`, init-script or request-routing step. In-page JS can fetch anything, invisibly.
- Don't read steps or URLs from a file. They stay on the command line.
- Don't spawn other programs from it (ffmpeg, git). Run those as their own commands.
- If the guard ever asks about it, something changed. Stop and look, don't work around it.

## 3. Check every asset before it leaves the machine

Open each PNG/GIF with the Read tool and look at it. Confirm:

- It shows what the caption will claim.
- No production data, customer names, emails, account or user IDs, tokens, env vars or internal hostnames. Terminal captures are the sneaky ones.
- At most three assets per PR.

If in doubt, crop, re-capture against safer data, or fall back to text.

## 4. Publish images

Images live on a per-PR orphan branch in the **same repo** as the PR, `proof/<pr-branch>`, built with git plumbing so nothing touches the working tree or the PR's diff. Each publish chains onto the last, so earlier image links keep working. Run from the repo, with `DIR` set to the capture directory, as visible commands. Keep the `${…}` braces: in zsh, `$commit:refs` is read as a `:r` modifier.

```bash
branch=$(git branch --show-current); proof="proof/${branch}"
tree=$( { for f in filtered.png search.gif; do printf "100644 blob %s\t%s\n" "$(git hash-object -w "$DIR/$f")" "$f"; done; } | git mktree)
if git fetch -q origin "refs/heads/${proof}" 2>/dev/null
then commit=$(git commit-tree "$tree" -p FETCH_HEAD -m "proof: ${branch}")
else commit=$(git commit-tree "$tree" -m "proof: ${branch}")
fi
git push -q origin "${commit}:refs/heads/${proof}"
repo=$(gh repo view --json nameWithOwner -q .nameWithOwner)
```

Embed with the commit SHA, never the branch name, so later pushes can't swap the evidence:

```markdown
![Filtered list](https://github.com/<repo>/blob/<commit>/filtered.png?raw=true)
```

Never push assets to a different repo, a gist, or onto the PR branch itself. If the push fails or the repo forbids extra branches, fall back: leave the files in the job dir, put a placeholder plus the caption in the description, and tell Bruno which files to drag in.

The proof branch can be deleted once the PR has merged and nobody needs the images.

## 5. Write it into the PR description

Read the current body first and keep everything already there (especially anything Bruno added). Add a collapsible section at the end, above any footer:

```markdown
<details>
<summary>Proof</summary>

Local dev against s101, at <short-sha>. Typing "test" keeps "Demo" because its slug is `testing_demo1`.

![Filtered list](https://github.com/<repo>/blob/<commit>/filtered.png?raw=true)

</details>
```

Every asset gets one sentence saying exactly what it shows, the environment, and the commit it was taken at. Update the body with `gh pr edit --body-file`. Proof goes in the description only, never as a PR comment.
