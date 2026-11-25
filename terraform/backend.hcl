# Non-secret backend settings. Credentials come from AWS_ACCESS_KEY_ID and
# AWS_SECRET_ACCESS_KEY (the R2 token), never from this file.
bucket                      = "flyers-tofu-state"
key                         = "platform-bootstrap/terraform.tfstate"
region                      = "auto"
endpoints                   = { s3 = "https://ccfd89f34d2e2f3f9a6ee709eb156f44.r2.cloudflarestorage.com" }
use_path_style              = true
use_lockfile                = true
skip_credentials_validation = true
skip_region_validation      = true
skip_requesting_account_id  = true
skip_metadata_api_check     = true
skip_s3_checksum            = true
