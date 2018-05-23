// Terraform Deployment Script
// ---------------------------
//
// Running this script requires an oauth token for netlify & github. You must
// generate these tokens yourself. If you set them as environment variables as
// suggested below, the script will run automatically. Otherwise, it will prompt
// you for these two values each run.
//
// You also will need admin access to both this repo on github and the netlify
// project.
//
// For Netlify:
// - Generate a token here: https://app.netlify.com/account/applications
// - Optionally set it as an environment variable called NETLIFY_TOKEN
//
// For Github:
// - Generate a token here: https://github.com/settings/tokens
// - Make sure it has access to `repo` and `admin:repo_hook` permissions
// - Optionally set it as an environment variable called GITHUB_TOKEN
//
// To install plugins, within this folder run `terraform init`. After this, you
// should be good to plan/run the script as usual.

locals {
  github_parts = ["${split("/", var.github_repo)}"]
  github_full  = "${var.github_repo}"
  github_org   = "${local.github_parts[0]}"
  github_repo  = "${local.github_parts[1]}"
}

//-------------------------------------------------------------------
// GitHub Resources

provider "github" {
  organization = "${local.github_org}"
}

// Configure the repository with the dynamically created Netlify key.
resource "github_repository_deploy_key" "key" {
  title      = "Netlify"
  repository = "${local.github_repo}"
  key        = "${netlify_deploy_key.key.public_key}"
  read_only  = false
}

// Create a webhook that triggers Netlify builds on push.
resource "github_repository_webhook" "main" {
  repository = "${local.github_repo}"
  name       = "web"
  events     = ["delete", "push", "pull_request"]

  configuration {
    content_type = "json"
    url          = "https://api.netlify.com/hooks/github"
  }

  depends_on = ["netlify_site.main"]
}

//-------------------------------------------------------------------
// Netlify Resources

// A new, unique deploy key for this specific website
resource "netlify_deploy_key" "key" {}

resource "netlify_site" "main" {
  name = "${var.name}"

  repo {
    repo_branch = "${var.github_branch}"
    command = "cd website && bundle && middleman build --verbose"
    deploy_key_id = "${netlify_deploy_key.key.id}"
    dir = "website/build"
    provider = "github"
    repo_path = "${local.github_full}"
  }
}
