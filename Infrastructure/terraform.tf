terraform {
  required_version = ">= 1.9.0, < 2.0.0"

  cloud {

    organization = "RootLab"

    workspaces {
      name = "strands-recipe-bot-agent"
    }
  }
}