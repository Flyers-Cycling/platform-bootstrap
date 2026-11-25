# ADR 0001: Cloudflare R2 as the OpenTofu state backend

Status: accepted, 24 Nov 2026 (Michael). Tested in FLYERS-15.

## Context

The club needs remote state with locking and zero cost. Options were an R2 bucket through OpenTofu's S3 backend, or HCP Terraform free tier.

## Decision

Use R2 bucket `flyers-tofu-state` in the club's Cloudflare account, S3 backend with `use_lockfile = true`.

## Evidence

- init, plan and apply worked from Michael's laptop (OpenTofu 1.13.9).
- Locking works: a second run was refused with a 412 PreconditionFailed.
- R2 has no object versioning. Recovery is a dated state copy saved before every apply (`scripts/backup-state.sh`, `backups/` prefix, 90-day lifecycle rule). Restoring a copy with `tofu state push -force` was proven.

## Consequences

- Every apply, laptop or CI, runs the backup first.
- The runner check (same backend from a GitHub-hosted runner) is covered by the first passing `plan` run in this repo.
- Fallback if R2 misbehaves: HCP Terraform free tier.
