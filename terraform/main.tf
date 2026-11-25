# Repositories (one module instance each).
module "repo" {
  source   = "./modules/github-repos"
  for_each = var.repositories

  name       = each.key
  repository = each.value
}

# Adopt repos that already exist. Plan after import must show no changes:
# fill managed.auto.tfvars from `make discover` until it does.
import {
  for_each = { for k, v in var.repositories : k => v if v.import }
  to       = module.repo[each.key].github_repository.this
  id       = each.key
}

import {
  for_each = { for k, v in var.repositories : k => v if v.import }
  to       = module.repo[each.key].github_branch_default.this
  id       = each.key
}

import {
  for_each = { for k, v in var.repositories : k => v if v.import && v.branch_protection != null && v.branch_protection.import }
  to       = module.repo[each.key].github_branch_protection.default[0]
  id       = "${each.key}:${each.value.default_branch}"
}

# Org settings.
resource "github_organization_settings" "this" {
  count = var.org_settings == null ? 0 : 1

  billing_email                                                = var.org_settings.billing_email
  company                                                      = var.org_settings.company
  blog                                                         = var.org_settings.blog
  email                                                        = var.org_settings.email
  description                                                  = var.org_settings.description
  location                                                     = var.org_settings.location
  default_repository_permission                                = var.org_settings.default_repository_permission
  members_can_create_repositories                              = var.org_settings.members_can_create_repositories
  members_can_create_public_repositories                       = var.org_settings.members_can_create_public_repositories
  members_can_create_private_repositories                      = var.org_settings.members_can_create_private_repositories
  members_can_create_pages                                     = var.org_settings.members_can_create_pages
  members_can_fork_private_repositories                        = var.org_settings.members_can_fork_private_repositories
  web_commit_signoff_required                                  = var.org_settings.web_commit_signoff_required
  advanced_security_enabled_for_new_repositories               = var.org_settings.advanced_security_enabled_for_new_repositories
  dependabot_alerts_enabled_for_new_repositories               = var.org_settings.dependabot_alerts_enabled_for_new_repositories
  dependabot_security_updates_enabled_for_new_repositories     = var.org_settings.dependabot_security_updates_enabled_for_new_repositories
  dependency_graph_enabled_for_new_repositories                = var.org_settings.dependency_graph_enabled_for_new_repositories
  secret_scanning_enabled_for_new_repositories                 = var.org_settings.secret_scanning_enabled_for_new_repositories
  secret_scanning_push_protection_enabled_for_new_repositories = var.org_settings.secret_scanning_push_protection_enabled_for_new_repositories
}

import {
  for_each = var.org_settings != null && var.github_org_id != null ? { org = var.github_org_id } : {}
  to       = github_organization_settings.this[0]
  id       = each.value
}

# Cloudflare account members (emails come from a sensitive variable).
resource "cloudflare_account_member" "this" {
  for_each = var.cloudflare_members

  account_id = var.cloudflare_account_id
  email      = var.cloudflare_member_emails[each.key]
  roles      = each.value.roles
}

import {
  for_each = var.cloudflare_members
  to       = cloudflare_account_member.this[each.key]
  id       = "${var.cloudflare_account_id}/${each.value.member_id}"
}
