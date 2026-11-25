# Credential inventory

Every credential the platform uses. No pipeline runs as a person. Dates are Mountain; fill the TODOs when each credential is created.

| Credential | Purpose | Stored in | Who can rotate | How to rotate | Expires |
| --- | --- | --- | --- | --- | --- |
| Cloudflare account API token `flyers-platform-tofu` (`cfat_`) | OpenTofu manages Cloudflare account members | Club password manager; `apply` and `plan` environment secret `CLOUDFLARE_API_TOKEN` | Michael (Cloudflare account admin) | Create a new account token, update both environment secrets, delete the old token | TODO(mike): date |
| R2 account token `flyers-tofu-state-pipeline` | Read/write state and backups in `flyers-tofu-state` | Club password manager; environment secrets `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY` | Michael | Create a new bucket-scoped token, update both secrets, delete the old token | TODO(mike): date |
| R2 account token `flyers-tofu-state-test` | Used for the FLYERS-15 test and the laptop bootstrap | Club password manager | Michael | Delete after the pipeline token works | 24 Dec 2026 |
| GitHub App `flyers-platform` private key | CI authenticates to GitHub as the club-owned App | Environment secret `CLUB_APP_PRIVATE_KEY`; app ID is variable `CLUB_APP_ID` | Michael (org owner) | Generate a new key on the App page, update both secrets, delete the old key | No expiry; rotate yearly |
| `CLOUDFLARE_MEMBER_EMAILS` | Keeps member emails out of this public repo | Environment secrets | Michael | Edit the JSON in both environments | n/a |
| Michael's `gh` login | Laptop bootstrap only, never in CI | Michael's laptop | Michael | `gh auth refresh` | n/a |

Later: OIDC from GitHub Actions to AWS, when the club has an AWS account.

Check before every release of workflows: `grep -rniE 'ghp_|github_pat_|secrets\.GITHUB_TOKEN|PERSONAL' .github` finds nothing.
