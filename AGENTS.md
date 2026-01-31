# Agent Notes for HP-Laptop-WSL-Files

## Project overview
This repository is a collection of Bash utilities used in a WSL environment to manage media files and Windows drive mounts. Most scripts live in the `tools/` directory and are intended to be run from a terminal. Many scripts depend on the `TOOLS_DIR` environment variable pointing at the `tools/` directory so they can call each other.

## Key locations
- `tools/`: Primary scripts for file cleanup, organization, and mounting drives.
- `tools/base_scripts/`: Shared helper scripts (mounting and removal utilities).
- `tools/archive/`: Older or deprecated scripts (e.g., `mount-ext.old`).

## Notable scripts and behavior
- `tools/process_files`: Runs a cleanup pipeline (`remove-nfo`, `flatten-input`, `sort-and-playlist`).
- `tools/flatten-input`: Flattens subfolders by moving a single media file up a directory, moving multi-file folders to `0-MultiFile`, and possible duplicates to `0-PossibleDuplicate`.
- `tools/sort-and-playlist`: Sorts media by first letter into folders and creates VLC-compatible playlists.
- `tools/remove-nfo` / `tools/remove-m3u`: Wrappers around `base_scripts/remove-file` to clean up `.nfo`/`.m3u` files.
- `tools/downsample-video`: Uses `ffmpeg` to compress `.mp4` files into an `output/` directory and delete originals.
- `tools/mount-drive-*` and `tools/mount-drives`: Mount Windows drives via `base_scripts/mount-drive-base`.
- `tools/get-all-of-interest-wrapper`: Wrapper around the external `get-all-of-interest` command for collecting matching files into a catchall directory.

## Dependencies and assumptions
- `ffmpeg` is required for `tools/downsample-video`.
- `get-all-of-interest` must be installed and available on `PATH` for `tools/get-all-of-interest-wrapper`.
- Scripts assume a WSL environment with Windows drives mounted under `/mnt/<drive_letter>`.
- Set `TOOLS_DIR` to the absolute path of `tools/` to ensure wrappers find shared scripts.

## Required maintenance workflow (MANDATORY)
1. After completing each work request, update this `AGENTS.md` to capture any newly discovered project context.
2. Every time you run, review and update `README.md` to keep repository documentation current.
