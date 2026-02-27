<p align="center">
  <img width="400" height="200" alt="Gemini_Generated_Image_hzl8uqhzl8uqhzl8" src="https://github.com/user-attachments/assets/dffb6a8a-146d-447c-ac72-c017a898028e" />
</p>

# FEAR.md

A quality enforcement document for AI coding agents.

SOUL.md tells an agent who it is. FEAR.md tells it what happens when it gets sloppy.

## What it does

FEAR.md makes agents more careful and more correct. It enforces:

- Reading files before editing them
- Verifying assumptions instead of guessing
- Writing tests for new logic
- Running the project's lint, typecheck, format, and build tools
- Reviewing diffs before declaring work done
- Admitting uncertainty instead of hallucinating

## Usage

Drop `FEAR.md` into your project root. Point your agent to it.

If your agent uses `AGENTS.md`, add this pointer line:

```md
@~/FEAR.md
```

For Claude Code, add to your `CLAUDE.md`:

```
Read and follow FEAR.md before starting any task.
```

For other agents (Cursor, Copilot, Windsurf, etc.), add it to whatever config file your agent reads at startup (`.cursorrules`, system prompt, etc.).

## When to use it

- You're tired of agents confidently writing wrong code
- You're spending more time fixing agent output than writing code yourself
- Your agent keeps hallucinating function names, imports, or API shapes
- You want the agent to run your linter and tests without being told every time

## Customization

Fork it. Edit it. The anti-patterns section is the easiest place to add project-specific failures you keep running into. Add your own BAD/REALITY/RULE entries for things your agent keeps getting wrong.

## License

MIT. Do whatever you want with it.
