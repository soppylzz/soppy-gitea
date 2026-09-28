# T-010 — Review fixes: fill contrast, diff code size, missed overrides

- Status: review
- Owner: orchestrator
- Branch: feature/ui-fixes
- Depends: T-005 (components), T-003 (palette), D-020

## Spec

Act on the findings of the pre-release style review. Each was re-verified against the
pinned Gitea tree before it was acted on, and each fix carries the upstream citation.

## Acceptance criteria

- [x] Colored fills carry AA text in the dark variant (the Open/Closed/Merged issue
      badges and the Actions status badges were unreadable)
- [x] Code lines are the code size in every code context, diffs included
- [x] The feed keycap glyph is centred (the override needed `!important`)
- [x] `.ui.pointing.dropdown > .menu` and `.ui.upward.selection.dropdown .menu` are
      covered by the radius and shadow overrides
- [x] The spinner comment matches what the cascade actually does
- [x] `scripts/check.sh` passes; contrast measured, not asserted
- [ ] G3 visual pass in the preview instance, light and dark (human)

## Handoff log

- 2026-09-28 orchestrator: measured the dark ladder before the fix — white text on
  `--color-green` 1.34:1 (`.ui.green.label` is the Open issue badge,
  `repo/issue/view_title.tmpl:50`), purple 2.64, red 2.78, grey 3.42; Gitea hardcodes
  `color: var(--color-white)` at `modules/label.css:90-182`, `modules/button.css:216-268`
  and `actions.css:9-28`. Upstream's own dark theme avoids this by using mid-tone named
  colors (its red measures 4.58:1), ours are bright pxlkit hues by design (D-020).
- 2026-09-28 orchestrator: added `--soppy-ink-on-color` (white in light, `#0a0a0f` in
  dark) and applied it to those fills. After the fix the dark variant's worst case across
  the affected surfaces is 4.99:1; the light variant is unchanged, since its ink is the
  white upstream already applies.
- 2026-09-28 orchestrator: **open item, deliberately not fixed here** — the light variant
  still measures below AA on fills that are bright in light mode too: yellow 1.67:1,
  red-light 2.22:1 (the Actions `task-status-failure` badge), orange 3.78:1, green 4.33:1.
  These are upstream's own magnitudes (upstream light green is 2.57:1, yellow 1.40:1), so
  they are inherited rather than a regression, but `.agents/rules/conduct.md` §4 asks for
  AA in both variants. Fix would be per-color ink for those three fills; needs a palette
  decision, not a mechanical change.
- 2026-09-28 orchestrator: the diff code size was dead CSS. `.file-view.code-view` exists
  only on `repo/view_file.tmpl:98` and `repo/blame.tmpl:32`; a diff is
  `file-body file-code code-diff` (`repo/diff/box.tmpl:172`) and an issue-comment diff is
  `file-body file-code code-view code-diff` (`issue/view_content/conversation.tmpl:49`),
  so both kept `base.css:648-654`'s 12px while inheriting our 24px `--line-height-code`.
  Now mirrors upstream's own selector list, which also covers `shared/searchfile.tmpl:9`,
  blob excerpts and markup code previews.
- 2026-09-28 orchestrator: the keycap `margin-right: 0` was a no-op — `tailwind.config.ts:27`
  sets `important: true`, so the template's `tw-mr-1` wins. Now `!important` with the
  citation the conduct rule requires.
