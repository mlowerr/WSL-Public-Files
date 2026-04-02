# HP-Laptop-WSL-Files

Bash utilities for media-file cleanup/organization and Windows drive mounting in WSL. Most scripts are in `tools/` and are intended to be run directly from a terminal.

## Getting started
1. Set `TOOLS_DIR` so wrapper scripts can find shared helpers.
2. Ensure scripts are executable (`chmod +x tools/* tools/base_scripts/*` if needed).

```bash
export TOOLS_DIR=/workspace/HP-Laptop-WSL-Files/tools
```

## Requirements
- WSL environment with Windows drives available at `/mnt/<drive_letter>`.
- `ffmpeg` for `tools/downsample-video`.
- `get-all-of-interest` on `PATH` for `tools/get-all-of-interest-wrapper`.

## Script overview

### Cleanup and organization
- `tools/process_files`: Runs `remove-nfo`, `flatten-input`, and `sort-and-playlist` in sequence.
- `tools/prep-folders`: For each immediate subdirectory, creates `0-Watched` and runs `flatten-input` inside that directory.
- `tools/flatten-input`: Processes subfolders to:
  - move a single media file whose extension starts with `m`/`M` up one level,
  - move multi-match folders to `0-MultiFile`,
  - move potential duplicates to `0-PossibleDuplicate`,
  - remove empty `0-*` folders (except `0-Downloads`, `0-Keep`, `0-Watched`).
- `tools/sort-and-playlist`: Moves media files (`*.[mM]*`) into `a-z` folders by first character and generates `00-playlist-<letter>.m3u` files.
- `tools/downsample-video`: Transcodes `.mp4` files to lower bitrate in `output/`, then deletes originals.

### File removal helpers
- `tools/remove-nfo [--include-0-downloads] [directory]`: Removes `*.nfo` recursively using `tools/base_scripts/remove-file`.
- `tools/remove-m3u [directory]`: Removes `*.m3u` recursively using `tools/base_scripts/remove-file`.
- `tools/p-remove-nfo [--include-0-downloads]`: Runs `remove-nfo` in parallel against `/mnt/d` through `/mnt/i` (generated from a drive-letter list in the script).
- `tools/base_scripts/remove-file [--include-0-downloads] [directory] [pattern]`: Generic recursive delete utility; excludes `0-Downloads` by default.

### Drive mounting
- `tools/mount-drive-d`, `tools/mount-drive-e`, `tools/mount-drive-f`, `tools/mount-drive-g`, `tools/mount-drive-h`, `tools/mount-drive-i`: Mount one Windows drive each via `tools/base_scripts/mount-drive-base`.
- `tools/mount-drives`: Mounts drives `d` through `i` in one call (iterates a drive-letter list).
- `tools/base_scripts/mount-drive-base <drive_letter>`: Core mount logic using `drvfs`.

### Search and move utilities
- `tools/get-all-of-interest-wrapper [-m maxdepth] [-t target_dir] [-e exclude_word] word...`: Wrapper around external `get-all-of-interest` using `-c` for target directory pass-through.
- `tools/move-all [-m maxdepth] [-t target_dir] [-e exclude_word] word...`: Finds files containing all words (excluding optional words) and moves them to a target directory.

## Notes
- `tools/archive/` contains older scripts kept for historical reference.
- There is a temporary editor swap file at `tools/.move-all.swp`.
