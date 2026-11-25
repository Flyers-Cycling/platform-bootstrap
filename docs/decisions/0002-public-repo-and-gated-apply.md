# ADR 0002: Public repo, gated apply

Status: accepted, 24 Nov 2026 (Michael).

## Decision

`platform-bootstrap` is public (`visibility = "public"` in `managed.auto.tfvars`) so environment required reviewers, which gate the apply, work on the free GitHub org plan. Revisit if the nonprofit GitHub plan (FLYERS-7) comes through.

## Consequences

- Everything in the repo and every CI log is world-readable. No emails, tokens or private details in tfvars; member emails come from a sensitive variable fed by an environment secret.
- Plans run only for same-repo PRs, never forks.
- Plans run automatically on PRs. Apply runs on merge to `main` only after Michael approves the `apply` environment.
- Default branch is `main`.
