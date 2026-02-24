terraform {
  required_version = ">= 1.14.5"
}

# Используем terraform_data для управления контейнерами через системный Docker CLI
# Это гарантирует, что версия API всегда будет актуальной (1.45+)

resource "terraform_data" "backend" {
  # Следим за образом. Если образ обновится, команда выполнится снова.
  input = "twitter-deploy-backend:latest"

  provisioner "local-exec" {
    command = <<EOT
      docker rm -f twitter-deploy-backend-1 || true
      docker run -d --name twitter-deploy-backend-1 --network app-network ${self.input}
    EOT
  }
}

resource "terraform_data" "frontend" {
  input = "twitter-deploy-frontend:latest"
  
  depends_on = [terraform_data.backend]

  provisioner "local-exec" {
    command = <<EOT
      docker rm -f twitter-deploy-frontend-1 || true
      docker run -d --name twitter-deploy-frontend-1 --network app-network -p 8082:80 ${self.input}
    EOT
  }
}
