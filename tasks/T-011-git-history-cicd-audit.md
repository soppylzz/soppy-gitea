# T-011 — Prepare atomic history and verify GitHub delivery

- Status: in-progress
- Owner: codex
- Branch: main
- Depends: T-009, D-021

## Spec

Replace the unpublished monolithic root commit with a small, reviewable Conventional
Commit history, audit the GitHub Actions workflows and release scripts, and publish the
verified `main` branch to the empty `origin` repository.

## Acceptance criteria

- [x] The original root commit is preserved on a local safety branch
- [x] `main` is split into English Conventional Commits with one logical concern each
- [x] The final tree is byte-identical to the reviewed tree except for documented audit
      fixes and this task record
- [x] GitHub workflows pass YAML parsing and `actionlint`
- [x] Shell scripts pass syntax checks and the local G2 build/package gates
- [x] Release version resolution is tested with no tags, an equal tag and an older
      declared version
- [x] The workflows use least-privilege token permissions and immutable action pins
- [x] The release workflow serializes runs so concurrent pushes cannot race for a tag
- [ ] `main` is pushed to `origin` and the remote CI/release results are verified

## Handoff log

- 2026-09-28 codex: `origin` has no branches or tags (`git ls-remote` returned no refs),
  so rewriting the single local root commit does not rewrite shared history. The public
  GitHub repository exists and has no default branch yet.
- 2026-09-28 codex: the pre-rewrite tree passed `scripts/check.sh`, local packaging of
  `soppy-0.1.0.zip`, archive-content inspection, `git diff-tree --check`, and Ruby YAML
  parsing. The archive mirrors `public/assets/{css,img,soppy}` and carries both licenses.
- 2026-09-28 codex: hardened both workflows by pinning GitHub-owned actions to verified
  full SHAs, fixing the runner at `ubuntu-24.04`, and adding ten-minute job timeouts.
  The release workflow now has a non-cancelling `release` concurrency group, preventing
  simultaneous runs from resolving and creating the same tag.
- 2026-09-28 codex: `actionlint` v1.7.12 and YAML parsing pass; all shell files pass
  `bash -n`; G2 and packaging pass after the workflow edits. `version.sh` resolves
  `v0.1.0` with no tags, `v0.1.1` with equal `v0.1.0`, and `v0.2.5` when `v0.2.4` is
  newer than the declared version. Temporary test tags were removed.
- 2026-09-28 codex: GitHub reports Actions enabled. Each workflow explicitly overrides
  the repository's broad default permission: CI uses `contents: read`; release uses only
  `contents: write`, which `gh release create` needs to create its tag and release.
