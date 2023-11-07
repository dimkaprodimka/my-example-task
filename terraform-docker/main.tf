terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {}

resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = false
}

resource "docker_container" "nginx" {
  name  = "nginx"
  image = docker_image.nginx.image_id

  ports {
    internal = 80
    external = 8080
  }

  volumes {
    container_path = "/usr/share/nginx/html"
    host_path      = "${abspath(path.root)}/html"
    read_only      = true
  }
}

variable "db_root_password" {
  type    = string
  default = ""
}


resource "docker_image" "mariadb" {
  name         = "mariadb:latest"
  keep_locally = false
}


resource "docker_container" "mariadb" {
  name  = "mariadb"
  image = docker_image.mariadb.image_id
  env = [ "MARIADB_ROOT_PASSWORD=${var.db_root_password}" ]
    
  
  ports {
    internal = 3306
    external = 3306
  }
}


