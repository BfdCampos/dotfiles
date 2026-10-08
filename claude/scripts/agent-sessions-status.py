#!/usr/bin/env python3
"""Prints your agent-view sessions as status line rows: running ones with how
long they've run, finished or blocked ones with how long since they notified you.

Reads ~/.claude/jobs/*/state.json (what agent view reads). Prints nothing while
~/.claude/state/agent-sessions-hidden exists; /sessions toggles that file.
"""

import json
import os
import sys
import time
from datetime import datetime
from pathlib import Path

CLAUDE = Path.home() / ".claude"
JOBS = CLAUDE / "jobs"
HIDDEN_FLAG = CLAUDE / "state" / "agent-sessions-hidden"

MAX_ROWS = 8
NAME_WIDTH = 40
STALE_WORKING_S = 2 * 3600
BLOCKED_MAX_AGE_S = 3 * 24 * 3600
FINISHED_MAX_AGE_S = 12 * 3600

AGENT_RGB = {
    "red": (220, 38, 38),
    "blue": (106, 155, 204),
    "green": (22, 163, 74),
    "yellow": (202, 138, 4),
    "purple": (130, 125, 189),
    "orange": (217, 119, 87),
    "pink": (196, 102, 134),
    "cyan": (8, 145, 178),
}
STATUS = {
    "working": ("●", "\033[94m"),
    "blocked": ("?", "\033[93m"),
    "done": ("✓", "\033[92m"),
    "failed": ("✗", "\033[91m"),
}
RESET = "\033[0m"
DIM = "\033[90m"
BOLD = "\033[1m"


def to_epoch(iso):
    if not iso:
        return None
    try:
        return datetime.fromisoformat(iso.replace("Z", "+00:00")).timestamp()
    except ValueError:
        return None


def working_since(job_dir):
    """Start of the trailing run of 'working' entries in the job's timeline."""
    path = job_dir / "timeline.jsonl"
    try:
        with path.open("rb") as handle:
            handle.seek(0, os.SEEK_END)
            handle.seek(max(0, handle.tell() - 64 * 1024))
            lines = handle.read().decode("utf-8", "ignore").splitlines()
    except OSError:
        return None

    start = None
    for line in reversed(lines):
        try:
            entry = json.loads(line)
        except ValueError:
            continue
        if entry.get("state") != "working":
            break
        start = entry.get("at")
    return to_epoch(start)


def elapsed(seconds):
    seconds = max(0, int(seconds))
    minutes, hours, days = seconds // 60, seconds // 3600, seconds // 86400
    if days:
        return f"{days}d {hours % 24}h"
    if hours:
        return f"{hours}h {minutes % 60:02d}m"
    if minutes:
        return f"{minutes}m"
    return f"{seconds}s"


def sessions(own_session_id, now):
    rows = []
    for state_path in JOBS.glob("*/state.json"):
        try:
            job = json.loads(state_path.read_text())
        except (OSError, ValueError):
            continue

        status = job.get("state")
        if status not in STATUS or job.get("sessionId") == own_session_id:
            continue

        updated = to_epoch(job.get("updatedAt")) or now
        if status == "working":
            if now - updated > STALE_WORKING_S:
                continue
            since = working_since(state_path.parent) or to_epoch(job.get("createdAt")) or updated
        else:
            terminal = to_epoch(job.get("lastTerminalAt")) if status in ("done", "failed") else None
            since = terminal or updated
            max_age = BLOCKED_MAX_AGE_S if status == "blocked" else FINISHED_MAX_AGE_S
            if now - since > max_age:
                continue

        rows.append(
            {
                "name": job.get("name") or state_path.parent.name,
                "color": job.get("color"),
                "status": status,
                "since": since,
            }
        )

    running = sorted((r for r in rows if r["status"] == "working"), key=lambda r: r["since"])
    waiting = sorted((r for r in rows if r["status"] != "working"), key=lambda r: -r["since"])
    return running + waiting


def render(row, now):
    glyph, status_colour = STATUS[row["status"]]
    name = row["name"]
    if len(name) > NAME_WIDTH:
        name = name[: NAME_WIDTH - 1] + "…"

    rgb = AGENT_RGB.get(row["color"] or "")
    name_colour = f"\033[38;2;{rgb[0]};{rgb[1]};{rgb[2]}m" if rgb else ""
    weight = BOLD if row["status"] != "working" else ""
    age = elapsed(now - row["since"])
    when = age if row["status"] == "working" else f"{age} ago"

    return f"{status_colour}{glyph}{RESET} {weight}{name_colour}{name}{RESET} {DIM}·{RESET} {status_colour}{when}{RESET}"


def main():
    if HIDDEN_FLAG.exists():
        return

    try:
        own_session_id = json.loads(sys.stdin.read() or "{}").get("session_id")
    except ValueError:
        own_session_id = None

    now = time.time()
    rows = sessions(own_session_id, now)
    if not rows:
        return

    for row in rows[:MAX_ROWS]:
        print(render(row, now))
    if len(rows) > MAX_ROWS:
        print(f"{DIM}+{len(rows) - MAX_ROWS} more{RESET}")


if __name__ == "__main__":
    main()
