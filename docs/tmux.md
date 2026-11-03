# tmux

> English · [中文](tmux_zh-CN.md)

tmux 3.3+, one layer: local terminal → ssh → tmux. Prefix is `C-b`.

## Keys

| Key (after prefix) | Action |
|---|---|
| `\|` / `-` | split left-right / top-bottom, in the current directory |
| `h` `j` `k` `l` | select pane; `H` `J` `K` `L` resize (repeatable) |
| `Tab` / `S-Tab` | next / previous pane |
| `z` | zoom pane |
| `c` / `1`…`9` / `X` | new window / go to window / kill window |
| `[` / `]` | previous / next session |
| `N` / `w` | new session / session and window tree |
| `P` | paste the latest tmux buffer |
| `v` | copy mode: `v` select, `C-v` block, `y` copy, `H` / `L` line start / end |
| `e` | open the pane's full scrollback in vim |
| `q` / `d` | detach |
| `R` | reload config |

## Clipboard

Copies (copy mode, mouse selection) go to the local clipboard through OSC 52
(`set-clipboard on`). The local terminal must allow OSC 52 writes. Hold Shift
while dragging to use the terminal's own selection instead.

## Status bar

- Left: session name, red while the prefix is pressed.
- Windows: the current one is highlighted; a window whose program rang the bell
  is shown in peach with `!`, `Z` marks a zoomed window.
- Right: average GPU utilisation (hidden on machines without a GPU) and local
  time. The time zone defaults to `Asia/Singapore`; set `REMOTE_DOTFILES_TZ` in
  the environment of the tmux server to change it.

The bar is transparent and uses no Nerd Font icons: their width differs between
the server and the local terminal, so they overlap neighbouring text. Only the
powerline half-circle `U+E0B4` is used.

The theme is [catppuccin/tmux](https://github.com/catppuccin/tmux) (Mocha),
pinned in `tmux/plugins.txt`. Without the plugin, `tmux.conf` falls back to the
same colours written by hand.

When a window is split, each pane shows a title with its index, command and
directory; the active one is highlighted.

## Shell

Not managed by this repository. A helper worth adding to `~/.bashrc`:

```bash
# t [name]: attach to session `name` (default main), creating it if needed
t() { tmux new-session -A -s "${1:-main}"; }
```

## Agents

- Long-running agents and jobs survive SSH disconnects; reattach with `t <name>`.
- Configure the agent to ring the terminal bell when it finishes (for Claude Code,
  the `terminal_bell` notification channel); the window gets flagged.
- `focus-events on` lets editors reload files changed by an agent.
