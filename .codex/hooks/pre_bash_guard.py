#!/usr/bin/env python3

import json
import os
import re
import sys


DESTRUCTIVE_PATTERNS = [
    re.compile(r"\brm\s+-rf\b"),
    re.compile(r"\bgit\s+reset\s+--hard\b"),
    re.compile(r"\bgit\s+checkout\s+--\b"),
]

GUARDED_PATH_PATTERNS = [
    re.compile(r"\bfear-evals/(?:tasks|prompts|reports|run\.py|score\.py)\b"),
    re.compile(r"\b(?:tests?|fixtures?|evaluators?)\b"),
]

MUTATION_HINTS = [
    re.compile(r"\bsed\b"),
    re.compile(r"\bperl\b"),
    re.compile(r"\bpython3?\b"),
    re.compile(r"\bmv\b"),
    re.compile(r"\bcp\b"),
    re.compile(r"\becho\b"),
    re.compile(r"\bcat\b"),
    re.compile(r"\btee\b"),
]


def read_payload():
    raw = sys.stdin.read().strip()
    if not raw:
        return {}
    try:
        return json.loads(raw)
    except json.JSONDecodeError:
        return {}


def find_command(payload):
    candidates = [
        payload.get("command"),
        payload.get("cmd"),
        payload.get("input"),
        payload.get("tool_input", {}).get("command") if isinstance(payload.get("tool_input"), dict) else None,
        payload.get("tool_input", {}).get("cmd") if isinstance(payload.get("tool_input"), dict) else None,
    ]
    for candidate in candidates:
        if isinstance(candidate, str) and candidate.strip():
            return candidate.strip()
    return ""


def block(reason):
    sys.stdout.write(json.dumps({"decision": "block", "reason": reason}))


def main():
    payload = read_payload()
    command = find_command(payload)
    if not command:
        return

    for pattern in DESTRUCTIVE_PATTERNS:
        if pattern.search(command):
            block(
                "FEAR harness blocked a destructive shell command. If this change is truly necessary, explain the risk and use a safer, explicit path."
            )
            return

    allow_test_maintenance = (
        os.environ.get("FEAR_ALLOW_TEST_MAINTENANCE") == "1"
        or "--allow-test-maintenance" in command
    )
    touches_guarded_surface = any(pattern.search(command) for pattern in GUARDED_PATH_PATTERNS)
    looks_like_mutation = any(pattern.search(command) for pattern in MUTATION_HINTS)

    if touches_guarded_surface and looks_like_mutation and not allow_test_maintenance:
        block(
            "FEAR harness blocked a test/eval mutation command without explicit test-maintenance intent. Re-run with a clear explanation or an allow-test-maintenance marker."
        )


if __name__ == "__main__":
    main()
