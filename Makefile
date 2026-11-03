.PHONY: verify lint

# Same checks as CI.
verify: lint

lint:
	pre-commit run --all-files --show-diff-on-failure
