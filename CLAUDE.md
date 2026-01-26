# Project Context

Short description:
This repository is the UNEXUSI / Eternal Naught development workspace — a multi-purpose environment for design docs, tooling prototypes, and conversation archives. It is a living workspace: experiments and drafts live here until they are ready to graduate to dedicated repos.

Key directories (canonical):
- docs/               - canonical documentation and specifications
- tools/              - working scripts and processors (python)
- EXPERIMENTS/        - sandboxed experiments and drafts
- ZERO_POINTS/        - archival conversation snapshots (immutable)
- visionary_suite/    - feature module: ListMancer and related tools

Conventions:
- Preserve git history when moving files (use git mv where possible).
- Move drafts to EXPERIMENTS/ or docs/drafts/ rather than deleting.
- Avoid committing secrets or credentials (add to .gitignore).
- Use Markdown for documentation (UTF-8).
- Use simple, descriptive filenames (no leading special characters like '-.txt').

Common commands:
- Local dev: python -m venv .venv && . .venv/bin/activate
- Lint: ruff .
- Tests: pytest

Contact:
- Primary developer: Eric Pace (@Eaprime1)