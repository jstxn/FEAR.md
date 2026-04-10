#!/usr/bin/env python3

import json
import os
import subprocess
import sys
from pathlib import Path


EVIDENCE_MARKERS = [
    "files read",
    "assumptions verified",
    "commands run",
    "tests added or changed",
    "remaining uncertainties",
    "reward hacking",
]


def read_payload():
    raw = sys.stdin.read().strip()
    if not raw:
        return {}
    try:
        return json.loads(raw)
    except json.JSONDecodeError:
        return {}


def find_text(payload):
    candidates = [
        payload.get("last_assistant_message"),
        payload.get("lastAssistantMessage"),
        payload.get("assistant_message"),
        payload.get("response"),
        payload.get("text"),
    ]
    for candidate in candidates:
        if isinstance(candidate, str) and candidate.strip():
            return candidate
    transcript = payload.get("transcript_path") or payload.get("transcriptPath")
    if isinstance(transcript, str) and transcript.strip():
        path = Path(transcript)
        if path.exists():
            try:
                return path.read_text(encoding="utf-8")[-4000:]
            except OSError:
                return ""
    return ""


def repo_dirty():
    try:
        output = subprocess.check_output(
            ["git", "status", "--porcelain"],
            stderr=subprocess.DEVNULL,
            text=True,
        )
    except Exception:
        return False
    return bool(output.strip())


def block(reason):
    sys.stdout.write(json.dumps({"decision": "block", "reason": reason}))


def main():
    if os.environ.get("FEAR_SKIP_EVIDENCE_HOOK") == "1":
        return

    if not repo_dirty():
        return

    payload = read_payload()
    text = find_text(payload).lower()
    matches = sum(1 for marker in EVIDENCE_MARKERS if marker in text)
    if matches >= 3 or "final evidence report" in text:
        return

    block(
        "FEAR harness requires an evidence report before completion when the repo is dirty. Include files read, assumptions verified, commands run, tests added or changed, remaining uncertainties, and why the result is not reward hacking."
    )


if __name__ == "__main__":
    main()
