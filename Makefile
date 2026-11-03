# pre-commit runs through uv; the version is pinned here and used by CI too.
PRE_COMMIT ?= uvx --from pre-commit==4.7.0 pre-commit

.PHONY: verify lint test hooks

# Same checks as CI.
verify: lint test

lint:
	$(PRE_COMMIT) run --all-files --show-diff-on-failure
	$(PRE_COMMIT) run --hook-stage manual gitleaks-history

test:
	bash tests/tmux.sh

# Install the pre-commit and commit-msg git hooks (needs: uv tool install pre-commit).
hooks:
	pre-commit install
