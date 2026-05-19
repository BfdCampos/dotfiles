#!/usr/bin/env python3
"""
Analyse Claude Code session logs to extract voice/tone patterns.

Usage:
    # Analyse the N most recent sessions
    python3 capture_voice.py --recent 5

    # Analyse a specific session
    python3 capture_voice.py --session <session-id>

    # Analyse all sessions from the last N days
    python3 capture_voice.py --days 7

Output: Markdown summary of observed voice patterns, printed to stdout.
Pipe to a file or use within a skill to update the voice profile.
"""

import argparse
import json
import os
import re
import sys
from collections import Counter
from datetime import datetime, timedelta
from pathlib import Path


PROJECTS_DIR = Path.home() / ".claude" / "projects"


def find_project_dirs():
    """Find all project directories with session logs."""
    if not PROJECTS_DIR.exists():
        return []
    return [d for d in PROJECTS_DIR.iterdir() if d.is_dir()]


def find_sessions(project_dir, recent=None, days=None, session_id=None):
    """Find session JSONL files matching criteria."""
    sessions = sorted(
        project_dir.glob("*.jsonl"),
        key=lambda p: p.stat().st_mtime,
        reverse=True,
    )

    if session_id:
        return [s for s in sessions if session_id in s.stem]

    if days:
        cutoff = datetime.now() - timedelta(days=days)
        sessions = [s for s in sessions if datetime.fromtimestamp(s.stat().st_mtime) > cutoff]

    if recent:
        sessions = sessions[:recent]

    return sessions


def extract_user_messages(session_path):
    """Extract user messages from a session JSONL file."""
    messages = []
    with open(session_path, "r") as f:
        for line in f:
            try:
                msg = json.loads(line)
                if msg.get("type") != "user" or msg.get("isMeta", False):
                    continue

                content = msg.get("message", {}).get("content", "")

                if isinstance(content, str):
                    if len(content) > 10 and not content.startswith(("{", "<")):
                        messages.append(content)
                elif isinstance(content, list):
                    for item in content:
                        if isinstance(item, dict) and item.get("type") == "text":
                            text = item.get("text", "")
                            if len(text) > 10 and not text.startswith(("{", "<")):
                                messages.append(text)
            except (json.JSONDecodeError, KeyError):
                continue

    return messages


def analyse_patterns(messages):
    """Analyse voice patterns from a list of messages."""
    if not messages:
        return None

    stats = {
        "total_messages": len(messages),
        "total_chars": sum(len(m) for m in messages),
        "avg_message_length": sum(len(m) for m in messages) / len(messages),
    }

    # Capitalisation patterns
    starts_lowercase = sum(1 for m in messages if m and m[0].islower())
    stats["lowercase_start_pct"] = round(100 * starts_lowercase / len(messages), 1)

    # Punctuation patterns
    all_text = " ".join(messages)
    stats["multiple_marks"] = len(re.findall(r"[?!]{2,}", all_text))
    stats["all_caps_words"] = len(re.findall(r"\b[A-Z]{2,}\b", all_text))
    stats["ellipsis_count"] = all_text.count("...")

    # Contractions vs formal
    contractions = len(re.findall(r"\b\w+n't\b|\b\w+'s\b|\b\w+'re\b|\b\w+'ll\b|\b\w+'ve\b|\bI'm\b", all_text, re.IGNORECASE))
    stats["contractions_per_msg"] = round(contractions / len(messages), 2)

    # Filler words
    fillers = ["like", "tbh", "genuinely", "basically", "honestly", "literally"]
    filler_count = sum(len(re.findall(rf"\b{f}\b", all_text, re.IGNORECASE)) for f in fillers)
    stats["filler_words_per_msg"] = round(filler_count / len(messages), 2)

    # Emoji / internet expressions
    internet_exprs = len(re.findall(r"\bLOL\b|\bXD\b|\blmao\b|\bhaha+\b|\b:[\w-]+:", all_text))
    stats["internet_expressions"] = internet_exprs

    # Short messages (< 30 chars)
    short = sum(1 for m in messages if len(m) < 30)
    stats["short_message_pct"] = round(100 * short / len(messages), 1)

    # Swearing
    swear_patterns = r"\bf+u+c+k+\b|\bs+h+i+t+\b|\bdamn\b|\bcrap\b|\bbloody\b"
    stats["swear_count"] = len(re.findall(swear_patterns, all_text, re.IGNORECASE))

    # Common phrases
    words = re.findall(r"\b\w+\b", all_text.lower())
    bigrams = [f"{words[i]} {words[i+1]}" for i in range(len(words) - 1)]
    common_bigrams = Counter(bigrams).most_common(20)
    stats["common_phrases"] = [(phrase, count) for phrase, count in common_bigrams if count >= 3]

    # Question patterns
    stats["questions"] = all_text.count("?")
    stats["multi_question_marks"] = len(re.findall(r"\?{2,}", all_text))

    return stats


def format_report(stats, session_count):
    """Format analysis as markdown."""
    lines = [
        "# Voice Capture Report",
        "",
        f"Analysed {stats['total_messages']} messages across {session_count} sessions.",
        "",
        "## Patterns observed",
        "",
        f"- Messages starting lowercase: {stats['lowercase_start_pct']}%",
        f"- Short messages (< 30 chars): {stats['short_message_pct']}%",
        f"- Average message length: {stats['avg_message_length']:.0f} chars",
        f"- Contractions per message: {stats['contractions_per_msg']}",
        f"- Filler words per message: {stats['filler_words_per_msg']}",
        f"- ALL CAPS emphasis words: {stats['all_caps_words']}",
        f"- Multiple punctuation marks (??? or !!!): {stats['multiple_marks']}",
        f"- Internet expressions (LOL, XD, haha): {stats['internet_expressions']}",
        f"- Swear words: {stats['swear_count']}",
        f"- Questions asked: {stats['questions']}",
        f"- Multi-question-mark questions: {stats['multi_question_marks']}",
        "",
    ]

    if stats.get("common_phrases"):
        lines.append("## Frequently used phrases")
        lines.append("")
        for phrase, count in stats["common_phrases"]:
            lines.append(f"- \"{phrase}\" ({count}x)")
        lines.append("")

    lines.append("## Suggested voice profile updates")
    lines.append("")
    lines.append("Review the patterns above and consider updating `~/.claude/rules/voice.md` with any new observations.")
    lines.append("")

    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description="Analyse Claude Code sessions for voice patterns")
    parser.add_argument("--recent", type=int, default=5, help="Number of recent sessions to analyse")
    parser.add_argument("--days", type=int, help="Analyse sessions from last N days")
    parser.add_argument("--session", type=str, help="Specific session ID to analyse")
    parser.add_argument("--project", type=str, help="Project directory name (partial match)")
    args = parser.parse_args()

    project_dirs = find_project_dirs()
    if args.project:
        project_dirs = [d for d in project_dirs if args.project in d.name]

    if not project_dirs:
        print("No project directories found.", file=sys.stderr)
        sys.exit(1)

    all_messages = []
    session_count = 0

    for project_dir in project_dirs:
        sessions = find_sessions(
            project_dir,
            recent=args.recent if not args.days and not args.session else None,
            days=args.days,
            session_id=args.session,
        )

        for session_path in sessions:
            messages = extract_user_messages(session_path)
            all_messages.extend(messages)
            session_count += 1

    if not all_messages:
        print("No user messages found in the selected sessions.", file=sys.stderr)
        sys.exit(1)

    stats = analyse_patterns(all_messages)
    report = format_report(stats, session_count)
    print(report)


if __name__ == "__main__":
    main()
