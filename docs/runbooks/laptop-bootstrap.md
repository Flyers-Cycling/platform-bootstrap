# Runbook: bootstrap the platform repo from Michael's laptop

**Ticket:** FLYERS-16
**Who runs it:** Michael
**Where:** browser and laptop terminal. None of this is wired into CI.

This is the chicken-and-egg step: the state bucket, the pipeline identity and the repo's own settings do not exist as code until the first apply, so the first runs happen by hand. After step 8 everything moves to pull requests and the gated apply workflow.

Stop at each CHECK. If it does not match, stop and comment what you saw on FLYERS-16.

## Before you start

- OpenTofu 1.10 or newer (`tofu version`), `gh` logged in as an owner of the Flyers-Cycling org, the `aws` CLI, and a clone of this repo on `main`.
- The club password manager open.

## Part A: credentials (browser)

1. Cloudflare dashboard, club account, **Manage Account > Account API Tokens > Create Token** (account-owned, so it survives membership changes).
   - Name: `flyers-platform-tofu`
   - Permissions: Account > Account Settings > Read, Account > Members > Edit (add more only when a resource needs them)
   - Account resources: the club account only. TTL: 1 year.
   - Copy the token (starts `cfat_`) into the password manager. It is shown once.

   CHECK: the token appears in the Account API Tokens list with those permissions.

2. R2 > Manage API tokens > Create **Account** API token.
   - Name: `flyers-tofu-state-pipeline`
   - Permission: Object Read & Write. Bucket: `flyers-tofu-state` only. TTL: 1 year.
   - Save the Access Key ID and Secret Access Key in the password manager.

   (The test token `flyers-tofu-state-test` expires 24 Dec 2026. Delete it once this one works.)

   CHECK: the token lists only `flyers-tofu-state`.

3. R2 > `flyers-tofu-state` > Settings > Object lifecycle rules > add a rule: prefix `backups/`, delete after 90 days.

   CHECK: the rule shows in the list.

## Part B: first plan (laptop)

4. In the terminal, in the repo root. Each `read` prompts without echoing; paste the value.

   ```sh
   read -rs AWS_ACCESS_KEY_ID && export AWS_ACCESS_KEY_ID
   read -rs AWS_SECRET_ACCESS_KEY && export AWS_SECRET_ACCESS_KEY
   read -rs CLOUDFLARE_API_TOKEN && export CLOUDFLARE_API_TOKEN
   make init
   ```

   CHECK: `OpenTofu has been successfully initialized!`

5. Read the current settings and match the config to them.

   ```sh
   make discover
   ```

   Copy the values into `terraform/managed.auto.tfvars` (org settings, the website repo). For Cloudflare members, list them in the dashboard (Manage Account > Members) and in `managed.auto.tfvars` add one entry each with a label, the member ID (shown in the member's URL) and role IDs. Put emails in `terraform/secrets.auto.tfvars` (untracked):

   ```hcl
   cloudflare_member_emails = { label = "person@example.org" }
   ```

   CHECK: `git status` does not list `secrets.auto.tfvars`.

6. Plan until it is clean.

   ```sh
   make plan
   ```

   The only acceptable changes on the first plan are the imports themselves. Any "update in-place" on the website repo or org settings means the config differs from what Randall set by hand: change the tfvars to match reality, never the other way round. Repeat until the summary reads `0 to add, 0 to change, 0 to destroy` (plus N to import).

   CHECK (stop here): paste the plan summary line on FLYERS-16 and wait for a go.

## Part C: first apply (laptop)

7. ```sh
   make apply
   ```

   This saves a dated state copy to `backups/` in the bucket, then asks for `yes`. Type it only after reading the plan once more.

   CHECK: `Apply complete! Resources: 0 added, 0 changed, 0 destroyed` and `make plan` right after shows no changes.

## Part D: pipeline identity (browser)

8. Register the club GitHub App: Flyers-Cycling > Settings > Developer settings > GitHub Apps > New. Name `flyers-platform`, no webhook, permissions: Repository Administration (read/write), Contents (read), Metadata (read), Organization Administration (read/write). Only on this account. Generate a private key, then install it on all repositories in the org.

   CHECK: the app lists as installed on Flyers-Cycling.

9. In this repo, Settings > Environments, create `plan` and `apply`. On `apply`, add Michael as required reviewer. In **each** environment add:
   - variable `CLUB_APP_ID` (the app ID)
   - secrets `CLUB_APP_PRIVATE_KEY` (the .pem contents), `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY`, `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_MEMBER_EMAILS` (JSON like `{"label":"person@example.org"}`)

   Then delete the downloaded .pem from the laptop.

   CHECK: open a trivial PR touching `terraform/`. The `plan` job passes and shows no changes. Link the run on FLYERS-16.

10. Update `docs/credential-inventory.md` with the real creation dates and expiry dates.

## If it goes wrong

- Bad apply: pull the latest `backups/<stamp>.tfstate` from the bucket, then `tofu -chdir=terraform state push -force <file>` and run `make plan`.
- Locked state: wait for the other run, or read the lock info in the error before using `tofu force-unlock`.
