# remote-dotfiles

> English · [中文](README_zh-CN.md)

Configuration for remote cluster machines reached over SSH.

| Package | Docs |
|---|---|
| tmux | [docs/tmux.md](docs/tmux.md) |

## Install

Clone onto persistent storage, then:

```bash
./install.sh            # link configs and fetch pinned plugins
./install.sh --links    # links only, no network (fresh machine, repo already present)
```

Existing files are renamed to `*.bak.<timestamp>`, never deleted.

## Layout

```text
install.sh          idempotent installer
tmux/tmux.conf      main config, linked to ~/.tmux.conf
tmux/theme.conf     catppuccin theme, loaded only when the plugin is installed
tmux/plugins.txt    pinned plugins
tmux/bin/           status bar helper
tests/              package tests, run by `make test` and CI
docs/               per-package guides
```
