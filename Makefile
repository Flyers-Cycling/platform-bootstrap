# Laptop targets. CI calls tofu directly (see .github/workflows).
# Credentials come from the environment, never from files in the repo:
#   AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY   R2 token for flyers-tofu-state
#   CLOUDFLARE_API_TOKEN                        Cloudflare account API token
#   GITHUB_TOKEN                                set below from `gh auth token` if empty
TF_DIR := terraform
TOFU   ?= tofu
export GITHUB_TOKEN ?= $(shell gh auth token 2>/dev/null)

.PHONY: help check-env init fmt validate plan apply backup-state discover

help: ## List targets
	@grep -E '^[a-z-]+:.*##' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "%-14s %s\n", $$1, $$2}'

check-env:
	@test -n "$$AWS_ACCESS_KEY_ID" && test -n "$$AWS_SECRET_ACCESS_KEY" || { echo "Set the R2 keys (see docs/runbooks/laptop-bootstrap.md)"; exit 1; }
	@test -n "$$CLOUDFLARE_API_TOKEN" || { echo "Set CLOUDFLARE_API_TOKEN"; exit 1; }
	@test -n "$$GITHUB_TOKEN" || { echo "Run gh auth login, or set GITHUB_TOKEN"; exit 1; }

init: check-env ## tofu init against the R2 backend
	$(TOFU) -chdir=$(TF_DIR) init -backend-config=backend.hcl

fmt: ## Format the config
	$(TOFU) fmt -recursive $(TF_DIR)

validate: ## Check the config (needs init -backend=false or init)
	$(TOFU) -chdir=$(TF_DIR) validate

plan: check-env ## Show what would change
	$(TOFU) -chdir=$(TF_DIR) plan

backup-state: check-env ## Save a dated copy of the state to the bucket
	./scripts/backup-state.sh

apply: check-env backup-state ## Backup, then apply interactively (laptop only)
	$(TOFU) -chdir=$(TF_DIR) apply

discover: ## Print current org and repo settings, to fill managed.auto.tfvars
	./scripts/discover.sh
