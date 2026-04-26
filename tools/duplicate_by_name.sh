#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: ${0##*/} [OPTIONS] [SOURCE_DIR]

Finds files containing spaces whose underscore-converted twin already exists.
Verifies they are true duplicates by checking file size (always) and optionally
MD5 hash before moving the spaced copy to a duplicates folder.

Options:
  -r, --recursive        Scan subdirectories recursively
  -i, --insensitive      Case-insensitive twin matching
  -m, --md5              Also verify identical MD5 checksum before moving
  -e, --execute          Actually move files (default is dry-run only)
  -t, --target DIR       Target directory for duplicates
                         (default: SOURCE_DIR/duplicates)
  -v, --verbose          Show every file scanned (slower, noisy)
  -h, --help             Show this help message
EOF
}

# --- Defaults ---
RECURSIVE=0
CASE_INSENSITIVE=0
CHECK_MD5=0
DRY_RUN=1
VERBOSE=0
SOURCE_DIR="."
TARGET_DIR=""

# --- Parse arguments ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    -r|--recursive)   RECURSIVE=1; shift ;;
    -i|--insensitive) CASE_INSENSITIVE=1; shift ;;
    -m|--md5)         CHECK_MD5=1; shift ;;
    -e|--execute)     DRY_RUN=0; shift ;;
    -v|--verbose)     VERBOSE=1; shift ;;
    -t|--target)
      if [[ -z "${2:-}" ]]; then
        echo "Error: --target requires an argument" >&2; exit 1
      fi
      TARGET_DIR="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    -*)
      echo "Error: Unknown option: $1" >&2; usage >&2; exit 1 ;;
    *) SOURCE_DIR="$1"; shift ;;
  esac
done

# --- Resolve absolute paths ---
SOURCE_DIR=$(cd -- "$SOURCE_DIR" && pwd) || {
  printf 'Error: cannot access source directory: %s\n' "$SOURCE_DIR" >&2
  exit 1
}

if [[ -z "$TARGET_DIR" ]]; then
  TARGET_DIR="$SOURCE_DIR/duplicates"
fi
mkdir -p "$TARGET_DIR"
TARGET_DIR=$(cd -- "$TARGET_DIR" && pwd) || {
  printf 'Error: cannot access target directory: %s\n' "$TARGET_DIR" >&2
  exit 1
}

# --- Detect MD5 tool ---
md5_tool=""
if [[ "$CHECK_MD5" -eq 1 ]]; then
  if command -v md5sum >/dev/null 2>&1; then
    md5_tool="md5sum"
  elif command -v md5 >/dev/null 2>&1; then
    md5_tool="md5"
  else
    printf 'Error: --md5 requested but neither md5sum nor md5 found.\n' >&2
    exit 1
  fi
fi

# --- Report settings ---
printf 'Source:      %s\n' "$SOURCE_DIR"
printf 'Target:      %s\n' "$TARGET_DIR"
printf 'Recursive:   %s\n' "$([[ $RECURSIVE -eq 1 ]] && echo yes || echo no)"
printf 'Case-insens: %s\n' "$([[ $CASE_INSENSITIVE -eq 1 ]] && echo yes || echo no)"
printf 'MD5 check:   %s\n' "$([[ $CHECK_MD5 -eq 1 ]] && echo yes || echo no)"
printf 'Dry-run:     %s\n' "$([[ $DRY_RUN -eq 1 ]] && echo yes || echo no)"
printf 'Scanning'
[[ "$RECURSIVE" -eq 1 ]] && printf ' recursively'
printf ' ...\n\n'

# --- Build find arguments ---
# CRITICAL FIX: prune the target directory so find never descends into it
find_args=("$SOURCE_DIR")
if [[ "$RECURSIVE" -eq 0 ]]; then
  find_args+=(-maxdepth 1)
fi
find_args+=(
  "(" -path "$TARGET_DIR" -prune ")" -o
  -type f -print0
)

# --- Helpers ---
underscore_name() {
  printf '%s' "${1// /_}"
}

file_size() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    stat -f %z "$1"
  else
    stat -c %s "$1"
  fi
}

compute_md5() {
  if [[ "$md5_tool" == "md5sum" ]]; then
    md5sum "$1" | awk '{print $1}'
  else
    md5 -q "$1"
  fi
}

moved=0
scanned=0
skipped_size=0
skipped_md5=0
checked=0

# --- Main loop ---
while IFS= read -r -d '' file; do

  dir=$(dirname -- "$file")
  base=$(basename -- "$file")
  checked=$((checked + 1))

  [[ "$VERBOSE" -eq 1 ]] && printf '[scan] %s\n' "$file"

  # We only act on the "spaced" version
  [[ "$base" != *" "* ]] && continue

  expected_twin=$(underscore_name "$base")
  twin_path=""

  if [[ "$CASE_INSENSITIVE" -eq 1 ]]; then
    while IFS= read -r -d '' candidate; do
      twin_path="$candidate"
      break
    done < <(find "$dir" -maxdepth 1 -type f -iname "$expected_twin" -print0)
  else
    candidate="$dir/$expected_twin"
    [[ -e "$candidate" ]] && twin_path="$candidate"
  fi

  # No twin found → nothing to do
  [[ -z "$twin_path" ]] && continue

  # Safety: ensure they are not the same inode (hardlink)
  [[ "$file" -ef "$twin_path" ]] && continue

  # --- Verification 1: identical file size ---
  size_orig=$(file_size "$file")
  size_twin=$(file_size "$twin_path")

  if [[ "$size_orig" != "$size_twin" ]]; then
    [[ "$VERBOSE" -eq 1 ]] && printf '  SIZE MISMATCH: %s vs %s\n' "$size_orig" "$size_twin"
    skipped_size=$((skipped_size + 1))
    continue
  fi

  # --- Verification 2: identical MD5 (optional) ---
  if [[ "$CHECK_MD5" -eq 1 ]]; then
    printf '  Computing MD5 for %s ... ' "$base"
    hash_orig=$(compute_md5 "$file")
    hash_twin=$(compute_md5 "$twin_path")
    printf 'done\n'

    if [[ "$hash_orig" != "$hash_twin" ]]; then
      printf '  MD5 MISMATCH (skipped)\n'
      skipped_md5=$((skipped_md5 + 1))
      continue
    fi
  fi

  # --- All checks passed ---
  scanned=$((scanned + 1))

  printf '\nVERIFIED DUPLICATE:\n'
  printf '  spaced : %s\n' "$file"
  printf '  under  : %s\n' "$twin_path"
  printf '  size   : %s bytes\n' "$size_orig"
  [[ "$CHECK_MD5" -eq 1 ]] && printf '  md5    : %s\n' "$hash_orig"

  if [[ "$DRY_RUN" -eq 0 ]]; then
    rel_path="${file#$SOURCE_DIR/}"
    dest="$TARGET_DIR/$rel_path"
    dest_dir=$(dirname -- "$dest")

    [[ -d "$dest_dir" ]] || mkdir -p "$dest_dir"

    if [[ -e "$dest" ]]; then
      counter=1
      while [[ -e "$dest.$counter" ]]; do
        counter=$((counter + 1))
      done
      dest="$dest.$counter"
    fi

    mv -n -- "$file" "$dest"
    printf '  -> moved to: %s\n' "$dest"
    moved=$((moved + 1))
  else
    printf '  (dry-run: pass -e or --execute to move)\n'
  fi

done < <(find "${find_args[@]}")

# --- Summary ---
printf '\n========================================\n'
printf 'Files checked:            %d\n' "$checked"
printf 'Verified duplicates:      %d\n' "$scanned"
printf 'Skipped (size mismatch):  %d\n' "$skipped_size"
[[ "$CHECK_MD5" -eq 1 ]] && printf 'Skipped (MD5 mismatch):   %d\n' "$skipped_md5"
if [[ "$DRY_RUN" -eq 0 ]]; then
  printf 'Files moved:              %d\n' "$moved"
else
  printf 'Dry-run: no files moved. Use -e to execute.\n'
fi