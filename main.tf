terraform {
  required_version = ">= 1.14.5"
}

# 1. Database
resource "terraform_data" "database" {
  input = "postgres:15-alpine"
  provisioner "local-exec" {
    command = "docker rm -f twitter-deploy-database-1 || true && docker run -d --name twitter-deploy-database-1 --network app-network -e POSTGRES_PASSWORD=password postgres:15-alpine"
  }
}

# 2. Backend (зависит от базы)
resource "terraform_data" "backend" {
  depends_on = [terraform_data.database]
  input      = "twitter-deploy-backend:latest"
  provisioner "local-exec" {
    command = "docker rm -f twitter-deploy-backend-1 || true && docker run -d --name twitter-deploy-backend-1 --network app-network ${self.input}"
  }
}

# 3. Frontend (зависит от бэкенда)
resource "terraform_data" "frontend" {
  depends_on = [terraform_data.backend]
  input      = "twitter-deploy-frontend:latest"
  provisioner "local-exec" {
    command = "docker rm -f twitter-deploy-frontend-1 || true && docker run -d --name twitter-deploy-frontend-1 --network app-network -p 8082:80 ${self.input}"
  }
}
