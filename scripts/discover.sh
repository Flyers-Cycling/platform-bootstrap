#!/usr/bin/env bash
# Print the current org and repo settings so managed.auto.tfvars can match them.
# Read-only. Needs gh logged in with read access to the Flyers-Cycling org.
set -euo pipefail
ORG="Flyers-Cycling"
echo "== org (id, billing_email and the *_for_new_repositories flags need org-owner access)"
gh api "orgs/${ORG}" --jq '{id, description, company, blog, email, location, billing_email, default_repository_permission, members_can_create_repositories, members_can_create_public_repositories, members_can_create_private_repositories, members_can_create_pages, members_can_fork_private_repositories, web_commit_signoff_required, advanced_security_enabled_for_new_repositories, dependabot_alerts_enabled_for_new_repositories, dependabot_security_updates_enabled_for_new_repositories, dependency_graph_enabled_for_new_repositories, secret_scanning_enabled_for_new_repositories, secret_scanning_push_protection_enabled_for_new_repositories}'
for repo in platform-bootstrap Flyers-Cycling-Club-Website; do
  echo "== repo ${repo}"
  gh api "repos/${ORG}/${repo}" --jq '{description, homepage, visibility, default_branch, topics, has_issues, has_projects, has_wiki, has_discussions, allow_merge_commit, allow_squash_merge, allow_rebase_merge, allow_auto_merge, delete_branch_on_merge}'
  echo "-- branch protection on the default branch (404 means none)"
  branch="$(gh api "repos/${ORG}/${repo}" --jq .default_branch)"
  gh api "repos/${ORG}/${repo}/branches/${branch}/protection" 2>&1 || true
done
