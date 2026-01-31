# HP-Laptop-WSL-Files

A collection of Bash utilities for managing media files and Windows drive mounts from a WSL environment. The scripts are designed to be run from a terminal and are grouped under the `tools/` directory.

## Getting started
- Set `TOOLS_DIR` to the absolute path of the `tools/` directory so wrapper scripts can find shared helpers.
- Most scripts can be executed directly once they are marked executable.

```bash
export TOOLS_DIR=/workspace/HP-Laptop-WSL-Files/tools
```

## Tooling overview
- **Drive mounting**: `tools/mount-drive-{d,e,f}` and `tools/mount-drives` mount Windows drives using `tools/base_scripts/mount-drive-base`.
- **Cleanup pipeline**: `tools/process_files` runs `remove-nfo`, `flatten-input`, and `sort-and-playlist` in sequence.
- **Flattening media folders**: `tools/flatten-input` collapses single-file subfolders and routes multi-file or duplicate cases to `0-MultiFile` or `0-PossibleDuplicate`.
- **Sorting + playlists**: `tools/sort-and-playlist` groups files by first letter and creates VLC-compatible playlists.
- **File removal**: `tools/remove-nfo` and `tools/remove-m3u` wrap `tools/base_scripts/remove-file`.
- **Downsample video**: `tools/downsample-video` uses `ffmpeg` to compress `.mp4` files into an `output/` directory and delete originals.
- **Search wrapper**: `tools/get-all-of-interest-wrapper` wraps the external `get-all-of-interest` command to gather files into a target directory.

## Dependencies
- `ffmpeg` is required for `tools/downsample-video`.
- `get-all-of-interest` must be installed and on `PATH` for `tools/get-all-of-interest-wrapper`.
- Scripts assume Windows drives are mounted under `/mnt/<drive_letter>` in WSL.
