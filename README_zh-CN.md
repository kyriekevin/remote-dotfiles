# remote-dotfiles

> [English](README.md) · 中文

通过 SSH 使用的远端集群机器的配置。

| 包 | 文档 |
|---|---|
| tmux | [docs/tmux_zh-CN.md](docs/tmux_zh-CN.md) |

## 安装

clone 到持久存储上，然后：

```bash
./install.sh            # 建软链接，拉取固定版本的插件
./install.sh --links    # 只建软链接，不联网（新机器、仓库已在）
```

已有文件会被改名为 `*.bak.<时间戳>`，不会删除。

## 目录

```text
install.sh          可重复运行的安装脚本
tmux/tmux.conf      主配置，软链到 ~/.tmux.conf
tmux/theme.conf     catppuccin 主题，仅在插件已安装时加载
tmux/plugins.txt    固定版本的插件
tmux/bin/           状态栏辅助脚本
docs/               各个包的说明
```
