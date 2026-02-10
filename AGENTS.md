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
  - `tools/p-remove-nfo`: Runs `remove-nfo` in parallel for `/mnt/d`, `/mnt/e`, and `/mnt/f`.
  - `tools/base_scripts/remove-file`: Shared recursive delete helper; excludes `0-Downloads` unless `--include-0-downloads` is provided.
- Media organization:
  - `tools/flatten-input`: Moves single media files up one level; routes multi-file or possible duplicate folders to `0-MultiFile` / `0-PossibleDuplicate`; prunes empty `0-*` directories except known keep folders.
  - `tools/sort-and-playlist`: Moves media files into `a-z` folders and writes per-folder VLC playlists.
  - `tools/downsample-video`: Uses `ffmpeg` to transcode `.mp4` files into `output/` and removes original source files.
- Mounting:
  - `tools/mount-drive-{d,e,f}`: Per-drive wrappers around `base_scripts/mount-drive-base`.
  - `tools/mount-drives`: Convenience wrapper that mounts `d`, `e`, and `f`.
  - `tools/base_scripts/mount-drive-base`: Core drive-mount implementation.
- Search/move helpers:
  - `tools/get-all-of-interest-wrapper`: Pass-through wrapper around external `get-all-of-interest` with `-m`, `-t`, and repeatable `-e` options.
  - `tools/move-all`: Finds files containing all requested words (and excluding optional words) and moves them to a target directory.

## Required maintenance workflow (MANDATORY)
1. After completing each work request, update this `AGENTS.md` to capture newly discovered or corrected project context.
2. Every time you run, review and update `README.md` so documentation reflects the current script behavior.
