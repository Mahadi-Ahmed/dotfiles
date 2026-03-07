#!/bin/sh
# Returns icon + name for the current path.
# Git repo (inc. worktrees): git icon + repo name
# Non-repo: folder icon + directory name
cd "$1" 2>/dev/null || exit 0
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  path="${1/#$HOME/~}"
  printf '\xef\x81\xbb %s' "$path"
  exit 0
fi

common=$(git rev-parse --git-common-dir 2>/dev/null)

case "$common" in
  */worktrees/*)
    repo="${common%/worktrees/*}"
    repo="${repo%/.git}"
    printf '\xee\x9c\x82 %s' "$(basename "$repo")"
    ;;
  *)
    printf '\xee\x9c\x82 %s' "$(basename "$(git rev-parse --show-toplevel)")"
    ;;
esac
