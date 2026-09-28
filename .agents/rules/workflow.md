# Workflow — multi-agent protocol

Applies identically to Claude Code, Codex and Pi (harness: `AGENTS.md`). The human is
the product owner: priorities, reviews, merges, and answers to blocked questions.

## Principles

- The repo is the memory. Task files, decisions and commits carry all state; nothing
  important lives only in an agent's session.
- One task, one owner at a time. Two agents never co-edit one task or one file.
- Small tasks beat large ones: a task is one reviewable CSS concern.

## Task lifecycle

`draft → in-progress → review → done`, with `blocked` reachable from any state.

- Task files live in `tasks/`, named `T-###-<short-slug>.md` (`###` zero-padded,
  monotonically increasing across the repo, never reused).
- A task starts as `draft` on the backlog board (`tasks/backlog.md`). The claiming agent
  copies `TEMPLATE.md`, fills spec + acceptance criteria, sets owner and `in-progress`
  in BOTH the task file and the board — claim before work, so a parallel agent sees it.
- Acceptance criteria are written before implementation and are concrete enough to
  check mechanically.
- `review`: gates passed, work committed, waiting on the human.
- `blocked`: the task log names the exact question and what was already tried; the agent
  stops there instead of guessing.

## Session protocol (every agent, every session)

1. Harness is loaded automatically (Claude Code via `CLAUDE.md` import; Codex and Pi
   read `AGENTS.md` first thing if not).
2. If the human assigned a task file — read it. Otherwise pick a `draft` task from the
   backlog board and claim it (see above). Do not silently expand scope; new ideas
   become new backlog entries.
3. Skim the tail of `.agents/decisions.md` — accepted entries override local judgment.
4. Verify selectors/variables against the pinned source before writing rules.
5. Work; append findings to the task's handoff log as they occur, with file:line
   citations into the pinned sources.
6. Run the applicable gates, update status, commit.

## Verification gates

Apply the gates that exist for the change at hand; a gate that cannot run yet (G2
before the pipeline lands) is skipped, not faked.

- **G1 selector audit** — every selector and variable written traces to the pinned
  source via a grep recipe (`.agents/references/ground-truth.md`), or is a documented `--soppy-*` token.
  Record the audit as a checklist in the task log for non-trivial tasks.
- **G2 build** — once T-002 lands: pipeline runs clean; output diffed against the last
  committed build.
- **G3 visual** — theme loaded in a Gitea 1.27.3 instance (or the preview harness from
  T-007), pages eyeballed in light AND dark: explore/home, repo home, code browse, file
  view, diff, issues list, issue view, PR files, dashboard, user settings, sign-in.
  The human does the final eyeball; the agent does the honest first pass and says what
  it could not check.
- **G4 commit** — Conventional Commits, English, one logical change, no stray files
  (`git status` clean apart from intentional changes).

## Handoff contract

A task file must let a cold-start agent resume without asking the human anything the
repo can answer. Minimum contents: the spec, checked acceptance criteria, a handoff log
with dated entries (findings with citations, decisions taken, state left behind), and
the current status. "It's in my context" is a bug.

## Parallel agents

- Different tasks may run in parallel only if they touch different files; the palette
  layer (`:root`) is a chokepoint — only one palette task runs at a time.
- Branches: `task/T-###-slug` when working in parallel or on risky changes; solo
  doc/small-fix work may commit straight to `main`. Merges to `main` happen after
  review.
- Never rewrite git history on shared branches.

## Definition of done

- All acceptance criteria in the task file checked
- Selector/variable audit passed (every rule traces to the pinned source)
- Build clean (once the pipeline exists) and visual pass done in light AND dark
- Task file updated (status + handoff log) and commits follow `.agents/rules/conduct.md` §6

## Driving an agent

Run `claude`, `codex` or `pi` from the repo root; all three load this harness. Prompts
that work:

- "Take the next backlog item." — the agent claims a task, expands it from the template
  and works the gates above.
- "Work on T-003." / "Show the backlog."
- "I want <idea>." — the agent drafts a backlog entry first, then implements once the
  human confirms.

The human owns priorities, answers `blocked` questions, does the final visual review
(gate G3) and merges.

## Local preview

`scripts/sync-preview.sh` builds the theme and symlinks `dist/` and `assets/` into a
local Gitea instance under `gitea-root/` — the deployment-shape loop, where a CSS edit
needs only a browser refresh. `gitea-root/` is gitignored local state: it holds the
instance binary, its database and its admin credentials, and it is safe to delete and
rebuild. Its own `README.md` documents start/stop, the theme loop and the icon
entry-point audit.

## Releasing

`version.txt` at the repo root is the single source of truth (D-021). Bumping it on
`main` is what cuts a release:

1. Set `version.txt` to the intended version and merge to `main`.
2. `release.yml` resolves it against the existing tags through `scripts/version.sh`: a
   version ahead of the newest tag is released as is; an equal or older one falls back to
   a patch bump of that tag, so a release can never repeat or move backwards.
3. If the resolved tag already exists, the run stops. Otherwise the workflow runs the G2
   checks, packages `dist/soppy-<version>.zip`, and creates the tag and the release.

Nobody tags by hand, and a tag only ever appears at a release. Local packaging takes the
same default: `scripts/package.sh` with no argument uses `version.txt`.
