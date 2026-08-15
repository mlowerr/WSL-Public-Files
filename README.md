# HP-Laptop-WSL-Files

Bash utilities for media-file cleanup/organization and Windows drive mounting in WSL. Most scripts are in `tools/` and are intended to be run directly from a terminal.

## Getting started
1. Set `TOOLS_DIR` so wrapper scripts can find shared helpers.
2. Ensure scripts are executable (`chmod +x tools/* tools/base_scripts/*` if needed).
3. Install or link `tools/` at `~/tools`; `.profile` sources `~/tools/media-cleanup-aliases` when it exists.

```bash
export TOOLS_DIR=/workspace/HP-Laptop-WSL-Files/tools
```

## Requirements
- WSL environment with Windows drives available at `/mnt/<drive_letter>`.
- `ffmpeg` for `tools/downsample-video`.
- `get-all-of-interest` on `PATH` for `tools/get-all-of-interest-wrapper`.

## Script overview

### Cleanup and organization
- `tools/media-cleanup-aliases`: A source-only Bash script that provides these current-directory aliases:
  - `hoist-video-files`: For every immediate child directory, moves matches beneath `Vid*` directories into that child directory.
  - `delete-empty-video-dirs`: Deletes empty `Videos` directories exactly two levels below the current directory.
  - `organize-video-folders`: Runs `hoist-video-files`, then `delete-empty-video-dirs` if hoisting succeeds.
  - `delete-screen-dirs`: Enables recursive globbing and removes directories matching `{S,s}screen{,s,list}` recursively.
- `tools/process_files`: Runs `remove-nfo`, `flatten-input`, and `sort-and-playlist` in sequence.
- `tools/prep-folders`: For each immediate subdirectory, creates `0-Watched` and runs `flatten-input` inside that directory.
- `tools/flatten-input`: Processes subfolders to:
  - move a single media file whose extension starts with `m`/`M` up one level,
  - move multi-match folders to `0-MultiFile`,
  - move potential duplicates to `0-PossibleDuplicate`,
  - remove empty `0-*` folders (except `0-Downloads`, `0-Keep`, `0-Watched`).
- `tools/sort-and-playlist`: Moves media files (`*.[mM]*`) into `a-z` folders by first character and generates `00-playlist-<letter>.m3u` files.
- `tools/downsample-video`: Transcodes `.mp4` files to lower bitrate in `output/`, then deletes originals.

### Course cleanup
- `tools/clean_courses [--dry-run] [-t|--transcode] [--source-prefix PREFIX] [--get-files-dir NAME] <course_root>`: Cleans downloaded course folders under an explicit target directory. It removes configured bracketed source-site prefixes such as `[ WebToolTip.com ]` from top-level directories case-insensitively, recursively normalizes whitespace in file and directory names to underscores, moves files out of `~Get Your Files Here !` / `~Get_Your_Files_Here_!` folders, and deletes Bonus Resources files with common text, PDF, and HTML extensions. Use `--dry-run` first to preview destructive renames, moves, directory removals, and file deletions. When a destination already exists, the script creates a deterministic suffixed path such as `__1`, `__2`, and reports the collision in its summary. Pass `-t` / `--transcode` to run `~/git/ffmpeg_utility_scripts/unix/transcode_all.sh -r` from the cleaned course root after the cleanup summary and completion message; with `--dry-run`, the transcode command is only printed.
- `tools/normalize-path-names [--dry-run]`: Runs from the current directory and recursively normalizes every file and folder name below it. It removes leading whitespace, replaces remaining whitespace with underscores, converts bracketed text such as `[Source]` to `Source--`, uses deterministic `__1` collision suffixes, and deletes folders named `SCR`, `Screenshot`, `Screenlist`, `screenshot`, or `screenlist`.

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
