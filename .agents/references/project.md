# Project — context and ground truth

## What this is

Pixel-art style theme for Gitea, shipped as installable theme CSS. This repo customizes
Gitea styles only: no JavaScript, no templates, no Go code.

- Target: Gitea **1.27.3** (pinned), self-hosted instance, light + dark variants.
- Name: **soppy**, token prefix `--soppy-*` (settled in D-013; D-005 superseded).
- Task system: `tasks/backlog.md` (claim board), `tasks/TEMPLATE.md`.

## Read-only references

NEVER create, modify or delete anything under these paths:

- Gitea source: `/Users/soppylzz/code/reference/gitea`
- Reference theme: `/Users/soppylzz/code/reference/gitea-github-theme`

The harness expects both trees at those paths; clone Gitea 1.27.3 there, or update this
file and `.agents/references/ground-truth.md` to wherever they live on your machine.

## Ground truth rule

Never invent selectors, class names, DOM structure, or CSS variables. This is Gitea, not
GitHub — names differ from every other product you know. Everything must be verified
against the pinned source before it is written into a rule:

| You need | Look at (gitea repo) |
|---|---|
| Design tokens / CSS variables | `web_src/css/base.css` (`:root` block) |
| What a theme file looks like | `web_src/css/themes/theme-gitea-dark.css` |
| Component styles | `web_src/css/` (per-area files, entry `index.css`) |
| Real markup / class usage | `templates/**/*.tmpl` |
| Theme discovery & install rules | `services/webtheme/webtheme.go` |

Ready-made grep recipes and the verified mechanics: `.agents/references/ground-truth.md`.
Two load-bearing facts everyone must know: the theme file is an **override layer loaded
after the base `index.css`** (not a standalone stylesheet), and a custom theme **must**
contain a `gitea-theme-meta-info` block.

If a selector or variable cannot be found in the pinned source, stop and record the open
question in the task file. Guessing is a defect, even when the guess looks right.
