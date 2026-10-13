terraform {
  required_version = "1.16.5"

  cloud {
    
    organization = "RootLab"

    workspaces {
      name = "strands-recipe-bot-agent"
    }
  }
}