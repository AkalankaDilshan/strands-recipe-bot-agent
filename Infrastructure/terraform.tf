terraform {
  required_version = "1.16.6"

  cloud {

    organization = "RootLab"

    workspaces {
      name = "strands-recipe-bot-agent"
    }
  }
}