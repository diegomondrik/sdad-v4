# .claude/hooks/

Hooks are Claude Code lifecycle scripts that run automatically at defined
points in the development workflow (e.g., before a tool call, after a response).

## Status in SDAD v4.0

**Hooks are inactive in v4.0.**

The folder exists to reserve the extension point. No hook scripts are shipped
or executed in this version.

## Planned for future versions

Hooks will be evaluated once G7 has real project evidence of where automation
adds consistent value. Candidates under consideration:

- **pre-build** — validate SPEC.md §9 is complete before $build on Tier 3 projects
- **post-qa** — auto-append QA summary to DECISIONS.md after each $qa run
- **pre-commit** — run a lightweight security check before git commit

These will only be added when a recurring manual step justifies automation.
Hooks designed in the abstract tend to add friction without payoff.

## If you want to experiment

Claude Code hooks documentation:
https://docs.anthropic.com/en/docs/claude-code/hooks

Any hook added here activates automatically for all developers using this repo.
Test in a branch before merging to main.
