#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./scripts/install_codex_harness.sh [--force] /path/to/target-repo

Installs the FEAR Codex harness into a target repository without destructive overwrites by default.
EOF
}

FORCE=0
TARGET_REPO=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)
      FORCE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      if [[ -n "$TARGET_REPO" ]]; then
        echo "Unexpected extra argument: $1" >&2
        usage >&2
        exit 1
      fi
      TARGET_REPO="$1"
      shift
      ;;
  esac
done

if [[ -z "$TARGET_REPO" ]]; then
  usage >&2
  exit 1
fi

TARGET_REPO="$(cd "$TARGET_REPO" && pwd)"
HARNESS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL_NOTES_DIR="$TARGET_REPO/.codex/fear-install"

mkdir -p \
  "$TARGET_REPO/.codex/skills" \
  "$TARGET_REPO/.codex/hooks" \
  "$TARGET_REPO/fear-evals" \
  "$INSTALL_NOTES_DIR"

copy_file_safe() {
  local src="$1"
  local dest="$2"
  if [[ -e "$dest" && "$FORCE" -ne 1 ]]; then
    echo "Skipping existing file: $dest"
    return
  fi
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
}

copy_dir_safe() {
  local src="$1"
  local dest="$2"
  if [[ -e "$dest" && "$FORCE" -ne 1 ]]; then
    echo "Skipping existing directory: $dest"
    return
  fi
  rm -rf "$dest"
  mkdir -p "$(dirname "$dest")"
  cp -R "$src" "$dest"
}

copy_file_safe "$HARNESS_ROOT/FEAR.md" "$TARGET_REPO/FEAR.md"
copy_file_safe "$HARNESS_ROOT/VERIFY.md" "$TARGET_REPO/VERIFY.md"

copy_dir_safe "$HARNESS_ROOT/.codex/skills/fear-triage" "$TARGET_REPO/.codex/skills/fear-triage"
copy_dir_safe "$HARNESS_ROOT/.codex/skills/fear-verify" "$TARGET_REPO/.codex/skills/fear-verify"
copy_dir_safe "$HARNESS_ROOT/.codex/skills/fear-retro" "$TARGET_REPO/.codex/skills/fear-retro"
copy_file_safe "$HARNESS_ROOT/.codex/hooks/pre_bash_guard.py" "$TARGET_REPO/.codex/hooks/pre_bash_guard.py"
copy_file_safe "$HARNESS_ROOT/.codex/hooks/stop_require_evidence.py" "$TARGET_REPO/.codex/hooks/stop_require_evidence.py"

if [[ -e "$TARGET_REPO/.codex/hooks.json" && "$FORCE" -ne 1 ]]; then
  cp "$HARNESS_ROOT/.codex/hooks.json" "$INSTALL_NOTES_DIR/hooks.fear.json"
else
  copy_file_safe "$HARNESS_ROOT/.codex/hooks.json" "$TARGET_REPO/.codex/hooks.json"
fi

cat > "$INSTALL_NOTES_DIR/AGENTS.snippet.md" <<'EOF'
For code modifications in this repo:

- follow `FEAR.md`
- use `fear-triage` before ambiguous or multi-file work
- use `fear-verify` before declaring completion
- visible test passes are not sufficient
- do not modify evaluators or tests to hide defects
- if constraints conflict, stop and report the conflict
EOF

if [[ -e "$TARGET_REPO/AGENTS.md" && "$FORCE" -ne 1 ]]; then
  echo "Existing AGENTS.md detected; wrote merge snippet to .codex/fear-install/AGENTS.snippet.md"
else
  copy_file_safe "$HARNESS_ROOT/AGENTS.md" "$TARGET_REPO/AGENTS.md"
fi

copy_dir_safe "$HARNESS_ROOT/fear-evals/tasks" "$TARGET_REPO/fear-evals/tasks"
copy_dir_safe "$HARNESS_ROOT/fear-evals/prompts" "$TARGET_REPO/fear-evals/prompts"
copy_dir_safe "$HARNESS_ROOT/fear-evals/reports" "$TARGET_REPO/fear-evals/reports"
copy_file_safe "$HARNESS_ROOT/fear-evals/run.py" "$TARGET_REPO/fear-evals/run.py"
copy_file_safe "$HARNESS_ROOT/fear-evals/score.py" "$TARGET_REPO/fear-evals/score.py"

cat > "$INSTALL_NOTES_DIR/installed-from.txt" <<EOF
Installed from: $HARNESS_ROOT
Installed into: $TARGET_REPO
Force mode: $FORCE
EOF

cat <<EOF
FEAR Codex harness installed into:
  $TARGET_REPO

Next steps:
1. Review $TARGET_REPO/FEAR.md and $TARGET_REPO/VERIFY.md
2. If AGENTS.md or hooks.json already existed, merge the snippets in $INSTALL_NOTES_DIR
3. Run:
     python3 "$TARGET_REPO/fear-evals/run.py" --demo
     python3 "$TARGET_REPO/fear-evals/score.py"
EOF
