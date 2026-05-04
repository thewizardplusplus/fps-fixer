# Project Review (2026-05-04)

## Overall Assessment

The project is compact, readable, and solves a focused task well: scan videos and normalize FPS via FFmpeg. The CLI UX and logging are already better than typical one-file Bash utilities. The main risks are around portability, input validation, and media edge cases.

## Strengths

- Clear CLI structure using `getopt` with help/version output.
- Good operational logging with levels, timestamps, and colors.
- Reasonable safety defaults (`-nostdin`, explicit `-map`, optional dry-run mode via `--no-process`).
- Nice incremental feature set documented in changelog.

## Findings

### 1) Documentation drift (high)

`README.md` does not document options that are implemented in the script:

- `-s` / `--speed-factor`
- `--no-audio`

This causes discoverability issues and user confusion.

### 2) Tool/runtime assumptions are not documented (medium)

The script depends on external utilities beyond FFmpeg:

- `bc`
- GNU `date` (`--rfc-3339=ns`)
- `realpath --relative-to`
- GNU `getopt`

These may fail on macOS/BSD by default. Requirements should state GNU userland dependency (or script should include compatibility fallbacks).

### 3) Potential multi-line FPS parsing hazard (medium)

`get_fps()` scrapes `ffmpeg -i` stderr and extracts every `... fps` match. If more than one match appears, variable `video_fps` may contain multiple lines and later numeric comparison through `bc` can break or misbehave.

Recommendation: ensure a single value (`head -n1` / `tail -n1`) and validate it.

### 4) Version string duplication (low)

Version is hard-coded in script output (`v1.1.0`) and changelog tags. This can drift.

Recommendation: keep a single source of truth (e.g., `VERSION` file) and reuse it in script/help/release process.

### 5) No automated checks (medium)

No smoke-test script, lint config, or CI workflow is present. For shell utilities this increases regression risk.

Recommendation: add minimal checks:

- `shellcheck fps_fixer.bash`
- syntax check (`bash -n fps_fixer.bash`)
- optional self-test harness for argument parsing and no-process mode.

## Suggested Improvement Plan

1. Align README options with current CLI behavior.
2. Clarify platform/runtime requirements (GNU tools + FFmpeg + bc).
3. Harden FPS parsing and numeric validation.
4. Add shell lint/syntax checks and CI workflow.
5. Centralize versioning.

## Quick Risk Summary

- **Functional correctness:** good, but edge cases exist around FPS extraction and speed/audio combinations.
- **Portability:** moderate risk on non-GNU environments.
- **Maintainability:** good for size; would benefit from CI/lint and version centralization.
