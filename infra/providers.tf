terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4"
    }
    github = {
      source  = "integrations/github"
      version = "~> 4"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 3"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3"
    }
  }
}

provider "aws" {
  #checkov:skip=CKV_AWS_41:Ignore in this project for sake of learning with short-lived generated creds
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

data "aws_caller_identity" "current" {}


provider "github" {
  token = var.github_token # or `${GITHUB_TOKEN}`
  owner = var.github_user
}