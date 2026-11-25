terraform {
  required_version = ">= 1.10"

  # Partial configuration: the rest is in backend.hcl (init -backend-config=backend.hcl).
  backend "s3" {}

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}

# Auth comes from GITHUB_TOKEN (laptop: gh auth token; CI: the club GitHub App's
# installation token) and CLOUDFLARE_API_TOKEN.
provider "github" {
  owner = var.github_owner
}

provider "cloudflare" {}
