# 贡献指南

> [English](CONTRIBUTING.md) · 中文

## 准备

```bash
uv tool install pre-commit
make hooks               # 安装 pre-commit 和 commit-msg 两个 git hook
```

## 流程

1. 从 `main` 拉带类型前缀的分支：`feat/`、`fix/`、`docs/`、`chore/`、`refactor/`。
2. 提交信息遵循 [Conventional Commits](https://www.conventionalcommits.org)：
   `<type>(<scope>): <subject>`，祈使句、小写、结尾不加句号。
   类型：`feat`、`fix`、`docs`、`style`、`refactor`、`perf`、`test`、`build`、`ci`、`chore`、`revert`。
3. push 前运行 `make verify`。
4. 开 pull request，标题同样要符合 Conventional Commits：它会成为 `main` 上的提交。
5. CI 通过后 squash merge。不要直接 push 到 `main`。
