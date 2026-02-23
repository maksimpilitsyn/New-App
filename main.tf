terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {}

resource "docker_network" "app_network" {
  name = "app-network"
}

# Пример ресурса для фронтенда
resource "docker_container" "frontend" {
  name  = "twitter-deploy-frontend-1"
  image = "twitter-deploy-frontend:latest" # Образ должен быть собран в Jenkins
  ports {
    internal = 80
    external = 8082
  }
  networks_advanced {
    name = docker_network.app_network.name
  }
}

# Аналогично добавь ресурсы для backend и database...
