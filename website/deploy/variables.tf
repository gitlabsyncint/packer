variable "name" {
  default = "packer-test"
  description = "Name of the website in slug format."
}

variable "github_repo" {
  default = "jescalan/packer"
  description = "GitHub repository of the provider in 'org/name' format."
}

variable "github_branch" {
  default = "stable-website"
  description = "GitHub branch which netlify will continuously deploy."
}
