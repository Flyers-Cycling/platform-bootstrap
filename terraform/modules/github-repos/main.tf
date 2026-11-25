locals {
  r  = var.repository
  bp = try(local.r.branch_protection, null)
}

resource "github_repository" "this" {
  name                   = var.name
  description            = local.r.description
  homepage_url           = try(local.r.homepage_url, null)
  visibility             = local.r.visibility
  topics                 = try(local.r.topics, [])
  has_issues             = try(local.r.has_issues, true)
  has_projects           = try(local.r.has_projects, false)
  has_wiki               = try(local.r.has_wiki, false)
  has_discussions        = try(local.r.has_discussions, false)
  allow_merge_commit     = try(local.r.allow_merge_commit, true)
  allow_squash_merge     = try(local.r.allow_squash_merge, true)
  allow_rebase_merge     = try(local.r.allow_rebase_merge, true)
  allow_auto_merge       = try(local.r.allow_auto_merge, false)
  delete_branch_on_merge = try(local.r.delete_branch_on_merge, true)
  vulnerability_alerts   = try(local.r.vulnerability_alerts, true)

  # Never delete a repo from OpenTofu by accident.
  archive_on_destroy = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_branch_default" "this" {
  repository = github_repository.this.name
  branch     = try(local.r.default_branch, "main")
}

resource "github_branch_protection" "default" {
  count = local.bp == null ? 0 : 1

  repository_id = github_repository.this.node_id
  pattern       = try(local.r.default_branch, "main")

  enforce_admins                  = local.bp.enforce_admins
  require_signed_commits          = false
  required_linear_history         = local.bp.require_linear_history
  require_conversation_resolution = local.bp.require_conversation_resolution
  allows_force_pushes             = local.bp.allow_force_pushes
  allows_deletions                = local.bp.allow_deletions

  required_pull_request_reviews {
    required_approving_review_count = local.bp.required_approvals
    require_code_owner_reviews      = local.bp.require_code_owners
    dismiss_stale_reviews           = local.bp.dismiss_stale_reviews
  }

  dynamic "required_status_checks" {
    for_each = length(local.bp.required_status_checks) > 0 ? [1] : []
    content {
      strict   = true
      contexts = local.bp.required_status_checks
    }
  }
}
