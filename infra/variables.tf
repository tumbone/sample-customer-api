variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "application_name" {
  type = string
  #   default = "sample-api"
  default = "tum-tf-test"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "container_image_uri" {
  type    = string
  default = "public.ecr.aws/docker/library/httpd:latest"
}
variable "container_port" {
  type    = number
  default = 80
}
variable "host_port" {
  type    = number
  default = 80
}
variable "container_command" {
  type = list(string)
  # default = []
  default = ["/bin/sh -c \"echo '<html> <head> <title>Amazon ECS Sample App</title> <style>body {margin-top: 40px; background-color: #333;} </style> </head><body> <div style=color:white;text-align:center> <h1>Amazon ECS Sample App</h1> <h2>Congratulations!</h2> <p>Your application is now running on a container in Amazon ECS.</p> </div></body></html>' >  /usr/local/apache2/htdocs/index.html && httpd-foreground\""]
}
variable "container_entry_point" {
  type = list(string)
  # default = []
  default = ["sh", "-c"]
}