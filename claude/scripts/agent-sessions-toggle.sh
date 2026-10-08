#!/usr/bin/env bash
# UserPromptExpansion hook for /sessions: flips the flag agent-sessions-status.py
# reads, then blocks the expansion so no prompt reaches the model.

flag="$HOME/.claude/state/agent-sessions-hidden"
mkdir -p "$(dirname "$flag")"

if [ -e "$flag" ]; then
  rm -f "$flag"
  msg="Sessions list on"
else
  touch "$flag"
  msg="Sessions list off"
fi

printf '{"decision":"block","reason":"%s","hookSpecificOutput":{"hookEventName":"UserPromptExpansion","suppressOriginalPrompt":true}}\n' "$msg"
