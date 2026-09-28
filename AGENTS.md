# soppy-gitea — agent harness

Pixel-art style theme for Gitea 1.27.3, CSS only. This file is the entry point for every
agent (Claude Code, Codex, Pi); the detail lives in `.agents/` — follow the reading order.
Humans: start at `README.md`.

## Non-negotiables

1. Reference repos are READ-ONLY — never create, modify or delete anything under
   `/Users/soppylzz/code/reference/gitea` or
   `/Users/soppylzz/code/reference/gitea-github-theme`.
2. Never invent selectors, class names or CSS variables — verify against the pinned
   source (grep recipes: `.agents/references/ground-truth.md`). This is Gitea, not GitHub.
3. CSS only. JS, template or Go changes require an accepted entry in
   `.agents/decisions.md` first.
4. Comments and commit messages: English. Conventional Commits, one logical change
   per commit.
5. The repo is the memory: claim tasks in `tasks/`, write findings into the task file,
   never keep state only in session memory.
6. Accepted entries in `.agents/decisions.md` bind; to change one, append a superseding
   entry — never edit or delete existing text.

## Reading order

| File | Read |
|------|------|
| `.agents/references/project.md` | before your first task in this repo |
| `.agents/rules/conduct.md` | before writing any CSS or commit |
| `.agents/rules/workflow.md` | before claiming or working a task |
| `.agents/references/ground-truth.md` | before styling any component (mechanics + grep recipes) |
| `.agents/decisions.md` | every session: the tail; accepted entries bind |

New rules go into `.agents/rules/`, new reference material into `.agents/references/`.
