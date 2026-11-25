# AGENTS.md

Guidance for coding agents and people working on the Flyers Cycling Club platform repo. `CLAUDE.md` imports this file.

## What this repo is

OpenTofu for the club's shared platform: the Flyers-Cycling GitHub org settings and repositories, and the club-owned Cloudflare account's members. State lives in the club's Cloudflare R2 bucket `flyers-tofu-state`. The club is fully separate from Michael's homelab, personal accounts and Ride Cedar Valley.

## Standing rules

1. **Tickets:** every piece of work has a ticket in Iris space FLYERS (product set: Club platform). The ticket is the source of truth for findings, decisions needed and hand steps.
2. **Changes by pull request only.** Repos and their settings change only through PRs to this repo. Randall Adams owns Flyers-Cycling-Club-Website, so changes to that repo's settings need his review.
3. **Applies are gated on Michael.** CI plans automatically. Apply runs only after a human approves the `apply` environment. Before every apply the workflow saves a dated state copy (R2 has no versioning).
4. **No pipeline runs as a person.** Pipelines use a Cloudflare account API token (`cfat_`), the club-owned GitHub App, and OIDC later for AWS. Never put a personal token in a workflow. Every credential gets an entry in `docs/credential-inventory.md`.
5. **GitHub-hosted runners only.** No homelab runners, Vault, Kong or services.
6. **Hand-only steps** (creating the GitHub App, the R2 token, the first apply) live in `docs/runbooks/` and are never wired into CI.
7. **No secrets in the repo.** Public repo: assume every file and every CI log is world-readable. Member emails come in through a sensitive variable, not tfvars.
8. Dates and times in Mountain.

## Layout

- `terraform/` root module. `managed.auto.tfvars` is the file people edit. `modules/github-repos/` manages one repository plus optional branch protection.
- `docs/runbooks/` how-to steps (`TEMPLATE.md` to start one). `docs/decisions/` ADRs. `docs/credential-inventory.md`.
- `changelog.d/` one small file per change.
- `Makefile` laptop targets; `scripts/` helpers.

## Commands

`make help` lists everything. The usual loop is `make init`, `make plan`, `make apply` (laptop only, see the laptop bootstrap runbook).
