# The file people edit. Public repo: no emails, tokens or private details here.
# Flow: docs/runbooks/change-settings.md

cloudflare_account_id = "ccfd89f34d2e2f3f9a6ee709eb156f44"

# TODO(mike): run `make discover`, then fill in org_settings and github_org_id
# so the first plan shows no changes. Left unset (unmanaged) until then.
# github_org_id = "..."
# org_settings = { billing_email = "..." }

repositories = {
  # This repo adopts itself. Branch protection is added in a follow-up PR once
  # the plan workflow exists to name as a required check.
  "platform-bootstrap" = {
    import         = true
    description    = "OpenTofu for the Flyers Cycling Club platform"
    visibility     = "public"
    default_branch = "main"
  }

  # Randall's repo, imported as it is today. TODO(mike): replace these values
  # with the output of `make discover` until the plan shows 0 changes.
  # Set branch_protection (with import = true) only if the repo has it today.
  "Flyers-Cycling-Club-Website" = {
    import      = true
    description = "TODO(mike): copy from make discover"
    visibility  = "public"
  }
}

# TODO(mike): list Cloudflare members (label => member_id and role IDs) from
# the Cloudflare steps in the laptop runbook. Emails go in
# secrets.auto.tfvars (untracked) as cloudflare_member_emails, never here.
cloudflare_members = {}
