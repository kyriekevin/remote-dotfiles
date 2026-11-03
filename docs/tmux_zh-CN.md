# tmux

> [English](tmux.md) · 中文

tmux 3.3+，单层：本地终端 → ssh → tmux。prefix 是 `C-b`。

## 按键

| 键（先按 prefix） | 作用 |
|---|---|
| `\|` / `-` | 左右 / 上下分屏，继承当前目录 |
| `h` `j` `k` `l` | 切换 pane；`H` `J` `K` `L` 调整大小（可连按） |
| `Tab` / `S-Tab` | 下一个 / 上一个 pane |
| `z` | pane 全屏切换 |
| `c` / `1`…`9` / `X` | 新窗口 / 跳到窗口 / 关闭窗口 |
| `[` / `]` | 上一个 / 下一个 session |
| `N` / `w` | 新建 session / session 和窗口树 |
| `P` | 粘贴最近一次复制的内容 |
| `v` | copy mode：`v` 选择，`C-v` 块选择，`y` 复制，`H` / `L` 行首 / 行尾 |
| `e` | 用 vim 打开当前 pane 的完整 scrollback |
| `q` / `d` | detach |
| `R` | 重新加载配置 |

## 剪贴板

复制（copy mode、鼠标选择）通过 OSC 52 进入本地剪贴板（`set-clipboard on`），本地终端需要允许
OSC 52 写入。按住 Shift 拖拽可以改用终端自己的选择。

## 状态栏

- 左边：session 名，按下 prefix 时变红。
- 窗口：当前窗口高亮；程序响过铃的窗口显示为橙色并带 `!`，`Z` 表示 pane 处于全屏。
- 右边：GPU 平均利用率（没有 GPU 的机器不显示）和本地时间。时区默认 `Asia/Singapore`，可以在 tmux
  server 的环境中设置 `REMOTE_DOTFILES_TZ` 修改。

状态栏背景透明，不使用 Nerd Font 图标：这类图标在服务器和本地终端上的宽度不一致，会压到旁边的字。
只用了 powerline 半圆 `U+E0B4`。

主题是 [catppuccin/tmux](https://github.com/catppuccin/tmux)（Mocha），版本固定在
`tmux/plugins.txt`。插件不存在时，`tmux.conf` 会回退到手写的同色系配色。

分屏时每个 pane 顶部显示编号、命令和目录，当前 pane 高亮。

## Shell

不由本仓库管理。值得加进 `~/.bashrc` 的一个函数：

```bash
# t [name]：进入 session name（默认 main），不存在就新建
t() { tmux new-session -A -s "${1:-main}"; }
```

## Agent

- 长时间运行的 agent 和任务不受 SSH 断线影响，用 `t <name>` 重新连上。
- 让 agent 完成时响铃（Claude Code 选 `terminal_bell` 通知方式），对应窗口会被标记。
- `focus-events on` 让编辑器能重新加载被 agent 改过的文件。
