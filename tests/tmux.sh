#!/usr/bin/env bash
# Load the tmux config on private servers and check that it applies cleanly,
# with and without the catppuccin plugin. Never touches the real HOME or the
# default tmux server.
#
#   bash tests/tmux.sh            plugin case runs install.sh (needs network)
#   OFFLINE=1 bash tests/tmux.sh  skip the plugin case
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="$(mktemp -d)"
SOCKETS=()
cleanup() {
  local s
  for s in "${SOCKETS[@]}"; do tmux -L "$s" kill-server 2>/dev/null || true; done
  rm -rf "$WORK"
}
trap cleanup EXIT
export TERM=xterm-256color

FAILED=0
pass() { printf '  ok    %s\n' "$*"; }
fail() { printf '  FAIL  %s\n' "$*"; FAILED=1; }
check() { # check <description> <command...>
  local desc=$1; shift
  if "$@" >/dev/null 2>&1; then pass "$desc"; else fail "$desc"; fi
}

# start_server <name> <home>: start a detached server with HOME=<home>.
start_server() {
  local name=$1 home=$2 sock
  sock="rdf-test-$name-$$"
  SOCKETS+=("$sock")
  HOME="$home" tmux -L "$sock" -f "$home/.tmux.conf" new-session -d -s test
  printf '%s' "$sock"
}

# common_checks <socket> <home>
common_checks() {
  local s=$1 home=$2 opt want got key n0 n1
  check "config re-sources without errors" \
    env HOME="$home" tmux -L "$s" source-file "$home/.tmux.conf"

  n0=$(tmux -L "$s" show -sv terminal-features | wc -l)
  HOME="$home" tmux -L "$s" source-file "$home/.tmux.conf"
  HOME="$home" tmux -L "$s" source-file "$home/.tmux.conf"
  n1=$(tmux -L "$s" show -sv terminal-features | wc -l)
  if [ "$n0" = "$n1" ]; then pass "reload does not duplicate terminal-features"
  else fail "terminal-features grew from $n0 to $n1 on reload"; fi

  for opt in "prefix C-b" "mouse on" "set-clipboard on" "focus-events on" \
             "extended-keys on" "bell-action none" "monitor-bell on" \
             "base-index 1" "history-limit 100000" "mode-keys vi"; do
    want=${opt#* }; got=$(tmux -L "$s" show -gv "${opt%% *}")
    if [ "$got" = "$want" ]; then pass "${opt%% *} = $want"
    else fail "${opt%% *} = '$got', want '$want'"; fi
  done
  got=$(tmux -L "$s" show -sv escape-time)
  if [ "$got" -le 10 ]; then pass "escape-time = $got"; else fail "escape-time = $got"; fi

  for key in '|' - h j k l H J K L N q X e R; do
    if tmux -L "$s" list-keys -T prefix "$key" >/dev/null 2>&1; then :
    else fail "prefix $key is not bound"; return; fi
  done
  pass "prefix bindings present"
  # tmux defaults that must keep their meaning.
  for opt in "[ copy-mode" "] paste-buffer" "( switch-client -p" ") switch-client -n"; do
    if tmux -L "$s" list-keys -T prefix "${opt%% *}" | grep -qF -- "${opt#* }"; then
      pass "prefix ${opt%% *} = ${opt#* }"
    else fail "prefix ${opt%% *} is not ${opt#* }"; fi
  done
}

echo "== status helper"
fake="$WORK/fakebin"; mkdir -p "$fake"
printf '#!/bin/sh\necho "No devices were found"\nexit 6\n' > "$fake/nvidia-smi"
chmod +x "$fake/nvidia-smi"
check "time is HH:MM" bash -c "[[ \$('$ROOT/tmux/bin/tmux-status' time) =~ ^[0-9]{2}:[0-9]{2}\$ ]]"
check "gpu is empty without GPUs" bash -c "[ -z \"\$(PATH='$fake':\$PATH '$ROOT/tmux/bin/tmux-status' gpu)\" ]"

echo "== no Nerd Font icons in status formats"
if grep -nP '[\x{E000}-\x{F8FF}\x{F0000}-\x{FFFFD}]' "$ROOT"/tmux/*.conf | grep -vP '^[^:]+:\d+:.*\x{E0B4}' ; then
  fail "private-use glyphs other than U+E0B4 found above"
else
  pass "only U+E0B4 is used"
fi

echo "== fallback look (plugin missing)"
home="$WORK/home-fallback"; mkdir -p "$home/.config/tmux"
cp -R "$ROOT/tmux" "$WORK/tmux-noplugin"; rm -rf "$WORK/tmux-noplugin/plugins"
ln -s "$WORK/tmux-noplugin/tmux.conf" "$home/.tmux.conf"
ln -s "$WORK/tmux-noplugin" "$home/.config/tmux/remote-dotfiles"
s=$(start_server fallback "$home")
common_checks "$s" "$home"
check "fallback status-right uses tmux-status" \
  bash -c "tmux -L '$s' show -gv status-right | grep -q 'tmux-status'"
check "theme not loaded" bash -c "[ -z \"\$(tmux -L '$s' show -gqv @thm_mauve)\" ]"

if [ "${OFFLINE:-0}" = 1 ]; then
  echo "== catppuccin (skipped: OFFLINE=1)"
else
  echo "== install.sh + catppuccin"
  home="$WORK/home-full"; mkdir -p "$home"
  printf 'set -g mouse off\n' > "$home/.tmux.conf"
  check "install.sh succeeds" env HOME="$home" "$ROOT/install.sh"
  check "existing ~/.tmux.conf backed up" bash -c "ls '$home'/.tmux.conf.bak.* "
  out=$(HOME="$home" "$ROOT/install.sh" 2>&1)
  if grep -qE 'linked|backed up|clone' <<<"$out"; then fail "install.sh is not idempotent: $out"
  else pass "install.sh is idempotent"; fi
  check "--links works offline" env HOME="$home" "$ROOT/install.sh" --links

  s=$(start_server full "$home")
  common_checks "$s" "$home"
  check "theme loaded" bash -c "[ -n \"\$(tmux -L '$s' show -gqv @thm_mauve)\" ]"
  check "status-right shows the clock" \
    bash -c "tmux -L '$s' show -gv status-right | grep -q 'tmux-status time'"
  check "status bar is transparent" bash -c "[ \"\$(tmux -L '$s' show -gv status-style)\" = default ]"
fi

if [ "$FAILED" = 0 ]; then echo "all tmux checks passed"; else echo "tmux checks FAILED"; exit 1; fi
