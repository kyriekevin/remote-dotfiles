# Contributing

> English · [中文](CONTRIBUTING_zh-CN.md)

## Setup

```bash
pip install pre-commit   # or: uv tool install pre-commit
pre-commit install       # pre-commit and commit-msg hooks
```

## Workflow

1. Branch from `main` with a typed prefix: `feat/`, `fix/`, `docs/`, `chore/`, `refactor/`.
2. Commit with [Conventional Commits](https://www.conventionalcommits.org):
   `<type>(<scope>): <subject>`, imperative and lowercase, no trailing period.
   Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`.
3. Run `make verify` before pushing.
4. Open a pull request. Its title must also be a Conventional Commit: it becomes the commit on `main`.
5. Squash merge after CI passes. Do not push directly to `main`.
