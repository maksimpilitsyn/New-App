terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_container" "frontend" {
  name  = "twitter-deploy-frontend-1"
  image = "twitter-deploy-frontend:latest"
  
  ports {
    internal = 80
    external = 8082
  }

  # Просто указываем имя, не ссылаясь на ресурс Terraform
  networks_advanced {
    name = "app-network"
  }
}

# Если есть backend, сделай аналогично для него
