variable "name" {
  default = "packer-test"
  description = "Name of the website in slug format."
}

variable "github_repo" {
  default = "hashicorp/packer"
  description = "GitHub repository of the provider in 'org/name' format."
}
