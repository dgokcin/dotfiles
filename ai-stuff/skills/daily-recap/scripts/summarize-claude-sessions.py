#!/usr/bin/env python3
"""
Summarize Claude Code sessions for a given date.
Outputs structured text suitable for LLM summarization.

Usage: python3 summarize-claude-sessions.py [YYYY-MM-DD]
       Defaults to today in Europe/Amsterdam timezone.
"""

import json
import os
import re
import sys
from datetime import datetime
from zoneinfo import ZoneInfo


TZ = ZoneInfo("Europe/Amsterdam")
PROJECTS_DIR = os.path.expanduser("~/.claude/projects")
# Minimum lines to consider a session substantive
MIN_LINES = 5


def main():
    date_str = sys.argv[1] if len(sys.argv) > 1 else datetime.now(tz=TZ).strftime("%Y-%m-%d")

    try:
        target_date = datetime.strptime(date_str, "%Y-%m-%d").date()
    except ValueError:
        print(f"Error: invalid date '{date_str}', expected YYYY-MM-DD", file=sys.stderr)
        sys.exit(1)

    sessions = []

    for project_dir in sorted(os.listdir(PROJECTS_DIR)):
        proj_path = os.path.join(PROJECTS_DIR, project_dir)
        if not os.path.isdir(proj_path):
            continue

        for fname in os.listdir(proj_path):
            if not fname.endswith(".jsonl"):
                continue
            fp = os.path.join(proj_path, fname)

            # Quick mtime pre-filter: skip files not touched on target date
            try:
                mtime = os.path.getmtime(fp)
                mtime_date = datetime.fromtimestamp(mtime, tz=TZ).date()
                if mtime_date != target_date:
                    continue
            except OSError:
                continue

            data = parse_session(fp, target_date)
            if data:
                sessions.append(data)

    if not sessions:
        print(f"No Claude Code sessions found for {date_str}.")
        sys.exit(0)

    # Sort by start time
    sessions.sort(key=lambda s: s["start_time"])

    lines = [f"Claude Code sessions for {date_str} ({len(sessions)} sessions):\n"]
    for i, s in enumerate(sessions, 1):
        lines.append(f"--- Session {i} ---")
        lines.append(f"Project: {s['project']}")
        lines.append(f"Directory: {s['cwd']}")
        lines.append(f"Time: {s['start_time_str']} ({s['duration_min']}min)")
        lines.append(f"Task: {s['first_user_msg']}")
        if s["tool_summary"]:
            lines.append(f"Activity: {s['tool_summary']}")
        if s["last_assistant_text"]:
            lines.append(f"Outcome: {s['last_assistant_text']}")
        lines.append("")

    print("\n".join(lines))


def parse_session(fp: str, target_date) -> dict | None:
    try:
        with open(fp) as f:
            raw_lines = f.readlines()
    except (PermissionError, OSError):
        return None

    if len(raw_lines) < MIN_LINES:
        return None

    first_user_msg = None
    last_assistant_text = None
    tool_calls = []
    timestamps = []
    cwd = None

    for raw in raw_lines:
        try:
            obj = json.loads(raw)
        except json.JSONDecodeError:
            continue

        # Collect timestamps (ISO 8601 string like "2026-06-23T12:18:10.948Z")
        ts = obj.get("timestamp")
        if ts and isinstance(ts, str):
            try:
                dt = datetime.fromisoformat(ts.replace("Z", "+00:00")).astimezone(TZ)
                if dt.date() == target_date:
                    timestamps.append(dt)
            except ValueError:
                pass

        if not cwd and obj.get("cwd"):
            cwd = obj["cwd"]

        kind = obj.get("type")
        msg = obj.get("message", {})
        content = msg.get("content", []) if isinstance(msg, dict) else []

        if kind == "user":
            # Skip meta messages (skill body injections, system context)
            if obj.get("isMeta"):
                continue

            # Content can be a string (skill invocations) or list (regular messages)
            raw_content = msg.get("content", "")

            if isinstance(raw_content, str) and first_user_msg is None:
                # Skill invocation: extract <command-args> if present, else raw text
                args_match = re.search(r"<command-args>(.*?)</command-args>", raw_content, re.DOTALL)
                if args_match:
                    first_user_msg = args_match.group(1).strip()[:400]
                elif not raw_content.startswith("<"):
                    first_user_msg = raw_content.strip()[:400]

            elif isinstance(raw_content, list) and first_user_msg is None:
                for c in raw_content:
                    if not isinstance(c, dict) or c.get("type") != "text":
                        continue
                    text = c.get("text", "").strip()
                    if text and not text.startswith("<") and not text.startswith("[Image"):
                        first_user_msg = text[:400]
                        break

        if kind == "assistant" and isinstance(content, list):
            for c in content:
                if not isinstance(c, dict):
                    continue
                if c.get("type") == "text":
                    text = c.get("text", "").strip()
                    if text:
                        last_assistant_text = text[:250]
                elif c.get("type") == "tool_use":
                    tool_calls.append((c.get("name", ""), c.get("input", {})))

    # Only include sessions with activity on the target date
    if not timestamps:
        return None

    start_dt = min(timestamps)
    end_dt = max(timestamps)
    duration_min = max(1, int((end_dt - start_dt).total_seconds() / 60))
    project = os.path.basename(cwd) if cwd else os.path.basename(fp).replace(".jsonl", "")

    return {
        "project": project,
        "cwd": cwd or "unknown",
        "start_time": start_dt,
        "start_time_str": start_dt.strftime("%H:%M"),
        "duration_min": duration_min,
        "first_user_msg": first_user_msg or "(no message)",
        "last_assistant_text": _trim_to_sentence(last_assistant_text or ""),
        "tool_summary": _summarize_tools(tool_calls),
    }


def _summarize_tools(tool_calls: list) -> str:
    git_commits = []
    files_edited = []
    bash_count = 0
    mcp_tools = set()

    for name, inp in tool_calls:
        if name in ("Edit", "Write"):
            fp = inp.get("file_path", "")
            if fp:
                files_edited.append(os.path.basename(fp))
        elif name == "Bash":
            cmd = inp.get("command", "")
            bash_count += 1
            # Extract commit message from git commit commands
            m = re.search(r'git commit[^\'"\n]*[\'"]([^\'"]+)[\'"]', cmd)
            if m:
                git_commits.append(m.group(1)[:80])
        elif name and "__" in name:
            # MCP tool like mcp__claude_ai_Slack__...
            parts = name.split("__")
            if len(parts) >= 2:
                mcp_tools.add(parts[1].replace("_", " "))

    parts = []
    if git_commits:
        parts.append("Commits: " + "; ".join(git_commits[:4]))
    if files_edited:
        unique = list(dict.fromkeys(files_edited))[:8]
        parts.append("Files: " + ", ".join(unique))
    if bash_count and not git_commits and not files_edited:
        parts.append(f"{bash_count} shell commands")
    if mcp_tools:
        parts.append("Tools: " + ", ".join(sorted(mcp_tools)[:4]))

    return " | ".join(parts)


def _trim_to_sentence(text: str) -> str:
    """Keep only the first ~150 chars, cut at sentence boundary if possible."""
    if len(text) <= 150:
        return text
    cut = text[:150]
    # Try to cut at last sentence end
    for sep in (". ", "! ", "? "):
        idx = cut.rfind(sep)
        if idx > 60:
            return cut[: idx + 1]
    return cut.rstrip() + "…"


if __name__ == "__main__":
    main()
