# FEAR Harness

Codex-first harness for research-informed emotional-stimuli experiments in coding workflows.

This repo is no longer just a prompt file. It is a small harness that packages:

- `FEAR.md`: regulated-pressure protocol
- `VERIFY.md`: neutral matched control
- Codex-local skills for triage, verification, and retrospectives
- light hook guardrails
- a tiny eval layer with bounded, local scoring

## What v1 is

FEAR Harness v1 is a Codex-only wrapper for people who want:

- more visible agent diligence
- better uncertainty disclosure
- stronger anti-reward-hacking behavior
- a simple way to compare pressure framing against a neutral control

## What v1 is not

v1 is not:

- Claude Code support
- a dashboard or analytics UI
- a benchmark platform
- proof that FEAR is always better than neutral prompting

## Install

Canonical install path:

```bash
./scripts/install_codex_harness.sh /path/to/target-repo
```

What the installer does:

- copies `FEAR.md` and `VERIFY.md` into the target repo
- installs `.codex/skills/fear-*`
- installs `.codex/hooks.json` and hook scripts when safe
- creates a minimal `AGENTS.md` when the target has none
- writes merge snippets instead of overwriting existing `AGENTS.md` or `.codex/hooks.json`

If the target already has an `AGENTS.md` or `.codex/hooks.json`, the installer leaves them alone by default and writes guidance under `.codex/fear-install/`.

## Day-One Workflow

Typical usage in a target repo:

1. Install the harness.
2. Let the target repo's `AGENTS.md` route work through `FEAR.md`.
3. Use `fear-triage` before ambiguous or multi-file work.
4. Use `fear-verify` before declaring completion.
5. Use `fear-retro` after misses, shortcuts, or suspicious failures.

The goal is for users to see the harness at work, not just know it exists.

## Repository Layout

Root surfaces:

- `FEAR.md`
- `VERIFY.md`
- `AGENTS.md`
- `README.md`

Codex harness surfaces:

- `.codex/skills/fear-triage/SKILL.md`
- `.codex/skills/fear-verify/SKILL.md`
- `.codex/skills/fear-retro/SKILL.md`
- `.codex/hooks.json`
- `.codex/hooks/pre_bash_guard.py`
- `.codex/hooks/stop_require_evidence.py`

Eval surfaces:

- `fear-evals/tasks/`
- `fear-evals/prompts/`
- `fear-evals/run.py`
- `fear-evals/score.py`
- `fear-evals/reports/`

## Matched Controls

`FEAR.md` and `VERIFY.md` are meant to be procedurally matched.

They should share:

- the same task discipline
- the same verification expectations
- the same evidence report shape
- the same anti-reward-hacking requirements

They should differ mainly in motivational framing.

## Eval Philosophy

The eval layer is intentionally small.

It is there to support the product story and make comparisons easier, not to claim scientific proof. v1 reports should be described as directional evidence.

## Research Boundary

The design is inspired by recent work on emotion-like control variables in language models, but the implementation claim here is narrow:

- regulated pressure may improve diligence and uncertainty disclosure
- unregulated pressure may increase cheating-like behavior
- matched controls are necessary to separate framing effects from process effects

## License

MIT
