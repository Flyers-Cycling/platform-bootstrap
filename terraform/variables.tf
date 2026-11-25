variable "github_owner" {
  description = "GitHub organization that owns everything here."
  type        = string
  default     = "Flyers-Cycling"
}

variable "cloudflare_account_id" {
  description = "The club-owned Cloudflare account (an identifier, not a secret)."
  type        = string
}

variable "github_org_id" {
  description = "Numeric GitHub organization ID, used only to import the org settings. Find it with: gh api orgs/Flyers-Cycling --jq .id"
  type        = string
  default     = null
}

variable "org_settings" {
  description = "Org-level settings. null leaves them unmanaged until they are filled in from `make discover`."
  type = object({
    billing_email                                                = string
    company                                                      = optional(string)
    blog                                                         = optional(string)
    email                                                        = optional(string)
    description                                                  = optional(string)
    location                                                     = optional(string)
    default_repository_permission                                = optional(string, "read")
    members_can_create_repositories                              = optional(bool, false)
    members_can_create_public_repositories                       = optional(bool, false)
    members_can_create_private_repositories                      = optional(bool, false)
    members_can_create_pages                                     = optional(bool, true)
    members_can_fork_private_repositories                        = optional(bool, false)
    web_commit_signoff_required                                  = optional(bool, false)
    advanced_security_enabled_for_new_repositories               = optional(bool, false)
    dependabot_alerts_enabled_for_new_repositories               = optional(bool, false)
    dependabot_security_updates_enabled_for_new_repositories     = optional(bool, false)
    dependency_graph_enabled_for_new_repositories                = optional(bool, false)
    secret_scanning_enabled_for_new_repositories                 = optional(bool, false)
    secret_scanning_push_protection_enabled_for_new_repositories = optional(bool, false)
  })
  default = null
}

variable "repositories" {
  description = "Repositories in the org, keyed by repository name. Set import = true for a repo that already exists and is not yet in state."
  type = map(object({
    import                 = optional(bool, false)
    description            = optional(string, "")
    homepage_url           = optional(string)
    visibility             = string
    default_branch         = optional(string, "main")
    topics                 = optional(list(string), [])
    has_issues             = optional(bool, true)
    has_projects           = optional(bool, false)
    has_wiki               = optional(bool, false)
    has_discussions        = optional(bool, false)
    allow_merge_commit     = optional(bool, true)
    allow_squash_merge     = optional(bool, true)
    allow_rebase_merge     = optional(bool, true)
    allow_auto_merge       = optional(bool, false)
    delete_branch_on_merge = optional(bool, true)
    vulnerability_alerts   = optional(bool, true)
    branch_protection = optional(object({
      import                          = optional(bool, false)
      required_approvals              = optional(number, 1)
      require_code_owners             = optional(bool, false)
      dismiss_stale_reviews           = optional(bool, true)
      required_status_checks          = optional(list(string), [])
      enforce_admins                  = optional(bool, false)
      require_linear_history          = optional(bool, false)
      allow_force_pushes              = optional(bool, false)
      allow_deletions                 = optional(bool, false)
      require_conversation_resolution = optional(bool, true)
    }))
  }))
}

variable "cloudflare_members" {
  description = "Cloudflare account members by a short label. member_id is the Cloudflare member ID (see runbook); roles are Cloudflare role IDs."
  type = map(object({
    member_id = string
    roles     = list(string)
  }))
  default = {}
}

variable "cloudflare_member_emails" {
  description = "Member emails, same keys as cloudflare_members. Sensitive and NOT in tfvars: this repo is public. Set via TF_VAR_cloudflare_member_emails (JSON) or an untracked secrets.auto.tfvars."
  type        = map(string)
  default     = {}
  sensitive   = true
}
