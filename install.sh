#!/usr/bin/env bash
# Idempotent installer for remote boxes.
#
#   ./install.sh            link configs + fetch missing/changed plugins
#   ./install.sh --links    link configs only (no network); for a fresh worker
#                           when this repo already lives on persistent storage
#
# Existing files are moved to <file>.bak.<timestamp>, never deleted.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LINKS_ONLY=0
[ "${1:-}" = "--links" ] && LINKS_ONLY=1

say() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }

link() {
  local src=$1 dst=$2
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then return; fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    local bak
    bak="$dst.bak.$(date +%Y%m%d%H%M%S)"
    mv "$dst" "$bak"
    say "backed up $dst -> $bak"
  fi
  ln -s "$src" "$dst"
  say "linked $dst -> $src"
}

retry() {
  local n
  for n in 1 2 3; do "$@" && return 0; say "retry $n: $*"; sleep $((n * 2)); done
  return 1
}

# ─── Links ───────────────────────────────────────────────────────────────────
link "$ROOT/tmux/tmux.conf" "$HOME/.tmux.conf"
mkdir -p "$HOME/.config/tmux"
link "$ROOT/tmux" "$HOME/.config/tmux/remote-dotfiles"   # theme, plugins, status script

[ "$LINKS_ONLY" = 1 ] && { say "links done"; exit 0; }

# ─── Plugins (pinned in tmux/plugins.txt) ───────────────────────────────────
fetch_plugins() {
  local list=$1 dest=$2 name url ref dir want
  mkdir -p "$dest"
  while read -r name url ref; do
    case "$name" in ''|'#'*) continue ;; esac
    dir="$dest/$name"
    if [ ! -d "$dir/.git" ]; then
      say "clone $name"
      retry git clone --quiet --filter=blob:none "$url" "$dir"
    fi
    want=$(git -C "$dir" rev-parse -q --verify "$ref^{commit}" || true)
    if [ -z "$want" ]; then
      retry git -C "$dir" fetch --quiet --tags origin
      want=$(git -C "$dir" rev-parse --verify "$ref^{commit}")
    fi
    if [ "$(git -C "$dir" rev-parse HEAD)" != "$want" ]; then
      git -C "$dir" -c advice.detachedHead=false checkout --quiet "$want"
      say "$name @ $ref"
    fi
  done < "$list"
}
fetch_plugins "$ROOT/tmux/plugins.txt" "$ROOT/tmux/plugins"

say "done. reload a running tmux with: prefix R"
