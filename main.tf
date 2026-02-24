terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.2"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_container" "backend" {
  name  = "twitter-deploy-backend-1"
  image = "twitter-deploy-backend:latest"
  restart = "always"
  
  networks_advanced {
    name = "app-network"
  }
}

resource "docker_container" "frontend" {
  name  = "twitter-deploy-frontend-1"
  image = "twitter-deploy-frontend:latest"
  restart = "always"
  
  ports {
    internal = 80
    external = 8082
  }

  networks_advanced {
    name = "app-network"
  }
}
