# Agent Notes for HP-Laptop-WSL-Files

## Project overview
This repository is a collection of Bash utilities used in a WSL environment to manage media files and Windows drive mounts. Most scripts live in the `tools/` directory and are intended to be run from a terminal.

## Key locations
- `tools/`: Primary scripts for cleanup, organization, mounting, and file selection.
- `tools/base_scripts/`: Shared helper scripts (`mount-drive-base`, `remove-file`).
- `tools/archive/`: Older/deprecated scripts (for reference only).

## Environment assumptions
- Set `TOOLS_DIR` to the absolute path of `tools/` so wrapper scripts can locate shared scripts.
- Scripts assume a WSL setup with Windows drives mounted under `/mnt/<drive_letter>`.
- `ffmpeg` is required for `tools/downsample-video`.
- `get-all-of-interest` must be installed and on `PATH` for `tools/get-all-of-interest-wrapper`.

## Script map (current)
- Cleanup pipeline:
  - `tools/process_files`: Runs `remove-nfo`, `flatten-input`, and `sort-and-playlist` in sequence.
  - `tools/prep-folders`: Creates `0-Watched` in each immediate child directory, then runs `flatten-input` inside each.
- Cleanup/removal utilities:
  - `tools/remove-nfo`: Removes `*.nfo` files via `base_scripts/remove-file`; supports `--include-0-downloads`.
  - `tools/remove-m3u`: Removes `*.m3u` files via `base_scripts/remove-file`.
  - `tools/p-remove-nfo`: Runs `remove-nfo` in parallel for `/mnt/d` through `/mnt/i` (built from a drive-letter list).
  - `tools/base_scripts/remove-file`: Shared recursive delete helper; excludes `0-Downloads` unless `--include-0-downloads` is provided.
- Media organization:
  - `tools/flatten-input`: Moves single media files up one level; routes multi-file or possible duplicate folders to `0-MultiFile` / `0-PossibleDuplicate`; prunes empty `0-*` directories except known keep folders.
  - `tools/sort-and-playlist`: Moves media files into `a-z` folders and writes per-folder VLC playlists.
  - `tools/downsample-video`: Uses `ffmpeg` to transcode `.mp4` files into `output/` and removes original source files.
- Mounting:
  - `tools/mount-drive-{d,e,f,g,h,i}`: Per-drive wrappers around `base_scripts/mount-drive-base`.
  - `tools/mount-drives`: Convenience wrapper that mounts `d` through `i` using a drive-letter loop.
  - `tools/base_scripts/mount-drive-base`: Core drive-mount implementation.
- Search/move helpers:
  - `tools/get-all-of-interest-wrapper`: Pass-through wrapper around external `get-all-of-interest` with `-m`, `-t`, and repeatable `-e` options; forwards target dir using `-c`.
  - `tools/move-all`: Finds files containing all requested words (and excluding optional words) and moves them to a target directory.

## Repo hygiene notes
- A temporary editor swap file exists at `tools/.move-all.swp`.

## Required maintenance workflow (MANDATORY)
1. After completing each work request, update this `AGENTS.md` to capture newly discovered or corrected project context.
2. Every time you run, review and update `README.md` so documentation reflects the current script behavior.


## Skills
A skill is a set of local instructions to follow that is stored in a `SKILL.md` file. Below is the list of skills that can be used. Each entry includes a name, description, and file path so you can open the source for full instructions when using a specific skill.
### Available skills
- skill-creator: Guide for creating effective skills. This skill should be used when users want to create a new skill (or update an existing skill) that extends Codex's capabilities with specialized knowledge, workflows, or tool integrations. (file: /opt/codex/skills/.system/skill-creator/SKILL.md)
- skill-installer: Install Codex skills into $CODEX_HOME/skills from a curated list or a GitHub repo path. Use when a user asks to list installable skills, install a curated skill, or install a skill from another repo (including private repos). (file: /opt/codex/skills/.system/skill-installer/SKILL.md)
### How to use skills
- Discovery: The list above is the skills available in this session (name + description + file path). Skill bodies live on disk at the listed paths.
- Trigger rules: If the user names a skill (with `$SkillName` or plain text) OR the task clearly matches a skill's description shown above, you must use that skill for that turn. Multiple mentions mean use them all. Do not carry skills across turns unless re-mentioned.
- Missing/blocked: If a named skill isn't in the list or the path can't be read, say so briefly and continue with the best fallback.
- How to use a skill (progressive disclosure):
  1) After deciding to use a skill, open its `SKILL.md`. Read only enough to follow the workflow.
  2) When `SKILL.md` references relative paths (e.g., `scripts/foo.py`), resolve them relative to the skill directory listed above first, and only consider other paths if needed.
  3) If `SKILL.md` points to extra folders such as `references/`, load only the specific files needed for the request; don't bulk-load everything.
  4) If `scripts/` exist, prefer running or patching them instead of retyping large code blocks.
  5) If `assets/` or templates exist, reuse them instead of recreating from scratch.
- Coordination and sequencing:
  - If multiple skills apply, choose the minimal set that covers the request and state the order you'll use them.
  - Announce which skill(s) you're using and why (one short line). If you skip an obvious skill, say why.
- Context hygiene:
  - Keep context small: summarize long sections instead of pasting them; only load extra files when needed.
  - Avoid deep reference-chasing: prefer opening only files directly linked from `SKILL.md` unless you're blocked.
  - When variants exist (frameworks, providers, domains), pick only the relevant reference file(s) and note that choice.
- Safety and fallback: If a skill can't be applied cleanly (missing files, unclear instructions), state the issue, pick the next-best approach, and continue.
